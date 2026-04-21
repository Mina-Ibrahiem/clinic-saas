<?php

namespace App\Services\Billing;

use App\Enums\InvoiceStatus;
use App\Models\Invoice;
use App\Models\Payment;
use App\Models\User;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpKernel\Exception\HttpException;

class PaymentService
{
    public function __construct(
        private readonly BillingStatusService $statusService
    ) {
    }

    public function paginate(User $user, Request $request): LengthAwarePaginator
    {
        $perPage = max(1, min(100, (int) $request->integer('per_page', 15)));
        $query = Payment::query()
            ->with([
                'invoice:id,invoice_number,status,total,patient_id',
                'invoice.patient:id,patient_code,full_name',
                'branch:id,name,code',
            ]);

        $this->applyAccessScope($query, $user);
        $this->applyFilters($query, $request);
        $this->applySorting($query, $request);

        return $query->paginate($perPage)->appends($request->query());
    }

    public function findOrFail(User $user, Payment $payment): Payment
    {
        if (! $this->canAccessPayment($user, $payment)) {
            throw new HttpException(404, 'Payment not found.');
        }

        return $payment->loadMissing([
            'invoice:id,invoice_number,status,total,patient_id',
            'invoice.patient:id,patient_code,full_name',
            'branch:id,name,code',
        ]);
    }

    /**
     * @param array<string,mixed> $payload
     */
    public function create(User $user, array $payload): Payment
    {
        return DB::transaction(function () use ($user, $payload): Payment {
            $invoice = Invoice::query()->lockForUpdate()->find((int) $payload['invoice_id']);
            if ($invoice === null) {
                throw new HttpException(422, 'Invoice not found.');
            }

            $this->assertInvoiceScope($invoice, $user, $payload);
            if (($invoice->status?->value ?? $invoice->status) === InvoiceStatus::Cancelled->value) {
                throw new HttpException(422, 'Cannot add payment to cancelled invoice.');
            }

            $amount = round((float) $payload['amount'], 2);
            if ($amount <= 0) {
                throw new HttpException(422, 'Payment amount must be greater than zero.');
            }

            $paidBefore = (float) $invoice->payments()->sum('amount');
            $remainingBefore = round((float) $invoice->total - $paidBefore, 2);
            if ($amount - $remainingBefore > 0.0001) {
                throw new HttpException(422, 'Payment exceeds remaining invoice balance.');
            }

            $payment = Payment::query()->create([
                'tenant_id' => $invoice->tenant_id,
                'branch_id' => $invoice->branch_id,
                'invoice_id' => $invoice->id,
                'payment_method' => $payload['payment_method'],
                'amount' => $amount,
                'payment_date' => $payload['payment_date'],
                'reference_number' => $payload['reference_number'] ?? null,
                'notes' => $payload['notes'] ?? null,
                'received_by' => $user->id,
            ]);

            $invoice->refresh();
            $this->statusService->syncInvoiceStatus($invoice);

            return $this->findOrFail($user, $payment);
        });
    }

    public function delete(User $user, Payment $payment): void
    {
        DB::transaction(function () use ($payment): void {
            $invoice = Invoice::query()->lockForUpdate()->find($payment->invoice_id);
            if ($invoice === null) {
                throw new HttpException(422, 'Linked invoice not found.');
            }

            if (($invoice->status?->value ?? $invoice->status) === InvoiceStatus::Cancelled->value) {
                throw new HttpException(422, 'Cannot delete payment from cancelled invoice.');
            }

            $payment->delete();

            $invoice->refresh();
            $this->statusService->syncInvoiceStatus($invoice);
        });
    }

    private function applyAccessScope(Builder $query, User $user): void
    {
        if (! $user->hasRole('super_admin') && $user->tenant_id !== null) {
            $query->where('tenant_id', $user->tenant_id);
        }

        if (! $user->hasRole(['super_admin', 'clinic_owner']) && $user->branch_id !== null) {
            $query->where('branch_id', $user->branch_id);
        }
    }

    private function applyFilters(Builder $query, Request $request): void
    {
        if ($search = trim((string) $request->query('search', ''))) {
            $query->where(function (Builder $q) use ($search): void {
                $q->where('reference_number', 'like', '%'.$search.'%')
                    ->orWhereHas('invoice', function (Builder $invoiceQuery) use ($search): void {
                        $invoiceQuery->where('invoice_number', 'like', '%'.$search.'%')
                            ->orWhereHas('patient', function (Builder $patientQuery) use ($search): void {
                                $patientQuery->where('full_name', 'like', '%'.$search.'%');
                            });
                    });
            });
        }

        foreach (['payment_method', 'branch_id', 'invoice_id'] as $field) {
            if ($value = $request->query($field)) {
                $query->where($field, $value);
            }
        }

        if ($date = $request->query('payment_date')) {
            $query->whereDate('payment_date', (string) $date);
        }
        if ($from = $request->query('date_from')) {
            $query->whereDate('payment_date', '>=', (string) $from);
        }
        if ($to = $request->query('date_to')) {
            $query->whereDate('payment_date', '<=', (string) $to);
        }
    }

    private function applySorting(Builder $query, Request $request): void
    {
        $sort = (string) $request->query('sort', 'latest');

        match ($sort) {
            'oldest' => $query->oldest('created_at'),
            'payment_date' => $query->orderBy('payment_date')->orderBy('created_at'),
            'amount' => $query->orderBy('amount', 'desc'),
            default => $query->latest('created_at'),
        };
    }

    private function canAccessPayment(User $user, Payment $payment): bool
    {
        $query = Payment::query()->whereKey($payment->id);
        $this->applyAccessScope($query, $user);

        return $query->exists();
    }

    /**
     * @param array<string,mixed> $payload
     */
    private function assertInvoiceScope(Invoice $invoice, User $user, array $payload): void
    {
        if ($user->tenant_id !== null && ! $user->hasRole('super_admin') && (int) $invoice->tenant_id !== (int) $user->tenant_id) {
            throw new HttpException(422, 'Invoice is outside tenant scope.');
        }

        if ($user->branch_id !== null && ! $user->hasRole(['super_admin', 'clinic_owner']) && (int) $invoice->branch_id !== (int) $user->branch_id) {
            throw new HttpException(422, 'Invoice is outside branch scope.');
        }

        if (array_key_exists('branch_id', $payload) && $payload['branch_id'] !== null && (int) $payload['branch_id'] !== (int) $invoice->branch_id) {
            throw new HttpException(422, 'Payment branch_id must match invoice branch.');
        }

        if (array_key_exists('tenant_id', $payload) && $payload['tenant_id'] !== null && (int) $payload['tenant_id'] !== (int) $invoice->tenant_id) {
            throw new HttpException(422, 'Payment tenant_id must match invoice tenant.');
        }
    }
}
