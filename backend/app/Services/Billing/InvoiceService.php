<?php

namespace App\Services\Billing;

use App\Enums\InvoiceStatus;
use App\Models\Appointment;
use App\Models\Branch;
use App\Models\Invoice;
use App\Models\InvoiceItem;
use App\Models\Patient;
use App\Models\Service;
use App\Models\User;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpKernel\Exception\HttpException;

class InvoiceService
{
    public function __construct(
        private readonly BillingStatusService $statusService
    ) {
    }

    public function paginate(User $user, Request $request): LengthAwarePaginator
    {
        $perPage = max(1, min(100, (int) $request->integer('per_page', 15)));
        $query = Invoice::query()
            ->with(['patient:id,patient_code,full_name,phone', 'appointment:id,appointment_date,status', 'branch:id,name,code'])
            ->withCount(['items', 'payments'])
            ->withSum('payments', 'amount');

        $this->applyAccessScope($query, $user);
        $this->applyFilters($query, $request);
        $this->applySorting($query, $request);

        return $query->paginate($perPage)->appends($request->query());
    }

    public function findOrFail(User $user, Invoice $invoice): Invoice
    {
        if (! $this->canAccessInvoice($user, $invoice)) {
            throw new HttpException(404, 'Invoice not found.');
        }

        return $invoice->loadMissing([
            'patient:id,patient_code,full_name,phone',
            'appointment:id,appointment_date,status',
            'branch:id,name,code',
            'tenant:id,uuid,name,slug',
            'items.service:id,name,code',
            'payments.invoice:id,invoice_number,status,total',
            'payments.invoice.patient:id,patient_code,full_name',
        ])->loadCount(['items', 'payments'])
            ->loadSum('payments', 'amount');
    }

    /**
     * @param array<string,mixed> $payload
     */
    public function create(User $user, array $payload): Invoice
    {
        return DB::transaction(function () use ($user, $payload): Invoice {
            [$tenantId, $branchId] = $this->resolveTenantAndBranch($user, $payload);
            $patient = $this->resolvePatient((int) $payload['patient_id'], $tenantId, $branchId);
            $appointment = $this->resolveAppointment($payload['appointment_id'] ?? null, $tenantId, $branchId, $patient->id);

            $items = $this->prepareItems($payload['items'], $tenantId, $branchId);
            [$subtotal, $discount, $tax, $total] = $this->calculateTotals($items, $payload['discount'] ?? 0, $payload['tax'] ?? 0);

            $requestedStatus = $payload['status'] ?? null;
            $status = $this->resolveInitialStatus($requestedStatus);

            $invoice = Invoice::query()->create([
                'tenant_id' => $tenantId,
                'branch_id' => $branchId,
                'patient_id' => $patient->id,
                'appointment_id' => $appointment?->id,
                'invoice_number' => $this->generateInvoiceNumber($tenantId),
                'subtotal' => $subtotal,
                'discount' => $discount,
                'tax' => $tax,
                'total' => $total,
                'status' => $status,
                'issued_at' => $payload['issued_at'],
                'due_at' => $payload['due_at'] ?? null,
                'created_by' => $user->id,
            ]);

            foreach ($items as $item) {
                InvoiceItem::query()->create([
                    'invoice_id' => $invoice->id,
                    'service_id' => $item['service_id'],
                    'description' => $item['description'],
                    'quantity' => $item['quantity'],
                    'unit_price' => $item['unit_price'],
                    'total_price' => $item['total_price'],
                ]);
            }

            $invoice->refresh();
            $this->statusService->syncInvoiceStatus($invoice);

            return $this->findOrFail($user, $invoice);
        });
    }

    /**
     * @param array<string,mixed> $payload
     */
    public function update(User $user, Invoice $invoice, array $payload): Invoice
    {
        if (($invoice->status?->value ?? $invoice->status) === InvoiceStatus::Cancelled->value) {
            throw new HttpException(422, 'Cancelled invoices cannot be updated.');
        }

        return DB::transaction(function () use ($user, $invoice, $payload): Invoice {
            [$tenantId, $branchId] = $this->resolveTenantAndBranch($user, $payload + ['branch_id' => $invoice->branch_id], (int) $invoice->tenant_id);
            if ((int) $invoice->tenant_id !== $tenantId) {
                throw new HttpException(422, 'Changing invoice tenant is not allowed.');
            }

            $patientId = (int) ($payload['patient_id'] ?? $invoice->patient_id);
            $patient = $this->resolvePatient($patientId, $tenantId, $branchId);
            $appointment = $this->resolveAppointment($payload['appointment_id'] ?? $invoice->appointment_id, $tenantId, $branchId, $patient->id);

            $preparedItems = null;
            if (array_key_exists('items', $payload)) {
                $preparedItems = $this->prepareItems($payload['items'], $tenantId, $branchId);
            } else {
                $preparedItems = $invoice->items()
                    ->get()
                    ->map(fn (InvoiceItem $item) => [
                        'service_id' => $item->service_id,
                        'description' => $item->description,
                        'quantity' => (int) $item->quantity,
                        'unit_price' => (float) $item->unit_price,
                        'total_price' => (float) $item->total_price,
                    ])->all();
            }

            [$subtotal, $discount, $tax, $total] = $this->calculateTotals(
                $preparedItems,
                $payload['discount'] ?? $invoice->discount,
                $payload['tax'] ?? $invoice->tax
            );

            $invoice->fill([
                'branch_id' => $branchId,
                'patient_id' => $patient->id,
                'appointment_id' => $appointment?->id,
                'subtotal' => $subtotal,
                'discount' => $discount,
                'tax' => $tax,
                'total' => $total,
                'issued_at' => $payload['issued_at'] ?? $invoice->issued_at,
                'due_at' => $payload['due_at'] ?? $invoice->due_at,
            ]);

            if (array_key_exists('status', $payload) && $payload['status'] !== null) {
                $this->assertStatusTransitionSafe($invoice, (string) $payload['status']);
                $invoice->status = $payload['status'];
            }

            $invoice->save();

            if (array_key_exists('items', $payload)) {
                $invoice->items()->delete();
                foreach ($preparedItems as $item) {
                    InvoiceItem::query()->create([
                        'invoice_id' => $invoice->id,
                        'service_id' => $item['service_id'],
                        'description' => $item['description'],
                        'quantity' => $item['quantity'],
                        'unit_price' => $item['unit_price'],
                        'total_price' => $item['total_price'],
                    ]);
                }
            }

            $invoice->refresh();
            $this->statusService->syncInvoiceStatus($invoice);

            return $this->findOrFail($user, $invoice);
        });
    }

    public function delete(Invoice $invoice): void
    {
        if ($invoice->payments()->exists()) {
            throw new HttpException(422, 'Cannot delete invoice with payments.');
        }

        if (($invoice->status?->value ?? $invoice->status) === InvoiceStatus::Paid->value) {
            throw new HttpException(422, 'Cannot delete paid invoice.');
        }

        $invoice->delete();
    }

    private function applyAccessScope(Builder $query, User $user): void
    {
        if (! $user->hasRole('super_admin') && $user->tenant_id !== null) {
            $query->where('tenant_id', $user->tenant_id);
        }

        if ($user->hasRole('doctor') && $user->doctorProfile !== null) {
            $doctorId = $user->doctorProfile->id;
            $query->whereHas('appointment', fn (Builder $q) => $q->where('doctor_id', $doctorId));
            return;
        }

        if (! $user->hasRole(['super_admin', 'clinic_owner']) && $user->branch_id !== null) {
            $query->where('branch_id', $user->branch_id);
        }
    }

    private function applyFilters(Builder $query, Request $request): void
    {
        if ($search = trim((string) $request->query('search', ''))) {
            $query->where(function (Builder $q) use ($search): void {
                $q->where('invoice_number', 'like', '%'.$search.'%')
                    ->orWhereHas('patient', function (Builder $p) use ($search): void {
                        $p->where('full_name', 'like', '%'.$search.'%')
                            ->orWhere('patient_code', 'like', '%'.$search.'%');
                    });
            });
        }

        foreach (['status', 'patient_id', 'appointment_id', 'branch_id'] as $field) {
            if ($value = $request->query($field)) {
                $query->where($field, $value);
            }
        }

        if ($date = $request->query('issued_at')) {
            $query->whereDate('issued_at', (string) $date);
        }
        if ($due = $request->query('due_at')) {
            $query->whereDate('due_at', (string) $due);
        }
        if ($from = $request->query('date_from')) {
            $query->whereDate('issued_at', '>=', (string) $from);
        }
        if ($to = $request->query('date_to')) {
            $query->whereDate('issued_at', '<=', (string) $to);
        }
    }

    private function applySorting(Builder $query, Request $request): void
    {
        $sort = (string) $request->query('sort', 'latest');

        match ($sort) {
            'oldest' => $query->oldest('created_at'),
            'issued_at' => $query->orderBy('issued_at')->orderBy('created_at'),
            'total' => $query->orderBy('total', 'desc'),
            default => $query->latest('created_at'),
        };
    }

    private function canAccessInvoice(User $user, Invoice $invoice): bool
    {
        $query = Invoice::query()->whereKey($invoice->id);
        $this->applyAccessScope($query, $user);

        return $query->exists();
    }

    /**
     * @param array<string,mixed> $payload
     * @return array{0:int,1:int}
     */
    private function resolveTenantAndBranch(User $user, array $payload, ?int $fallbackTenantId = null): array
    {
        $isSuperAdmin = $user->hasRole('super_admin');
        $tenantId = $fallbackTenantId !== null
            ? (int) $fallbackTenantId
            : ($isSuperAdmin ? (int) ($payload['tenant_id'] ?? $user->tenant_id ?? 0) : (int) ($user->tenant_id ?? 0));

        if ($tenantId <= 0) {
            throw new HttpException(422, 'Tenant context is required.');
        }

        if ($user->hasRole('clinic_owner')) {
            $branchId = (int) ($payload['branch_id'] ?? $user->branch_id ?? 0);
        } elseif ($isSuperAdmin) {
            $branchId = (int) ($payload['branch_id'] ?? 0);
        } else {
            $branchId = (int) ($user->branch_id ?? 0);
        }

        if ($branchId <= 0) {
            throw new HttpException(422, 'Branch context is required.');
        }

        $branch = Branch::query()->find($branchId);
        if ($branch === null || (int) $branch->tenant_id !== $tenantId) {
            throw new HttpException(422, 'Invalid branch for tenant.');
        }

        return [$tenantId, $branchId];
    }

    private function resolvePatient(int $patientId, int $tenantId, int $branchId): Patient
    {
        $patient = Patient::query()
            ->whereKey($patientId)
            ->where('tenant_id', $tenantId)
            ->where('branch_id', $branchId)
            ->first();

        if ($patient === null) {
            throw new HttpException(422, 'Patient does not belong to tenant/branch scope.');
        }

        return $patient;
    }

    private function resolveAppointment(int|string|null $appointmentId, int $tenantId, int $branchId, int $patientId): ?Appointment
    {
        if ($appointmentId === null) {
            return null;
        }

        $appointment = Appointment::query()
            ->whereKey((int) $appointmentId)
            ->where('tenant_id', $tenantId)
            ->where('branch_id', $branchId)
            ->where('patient_id', $patientId)
            ->first();

        if ($appointment === null) {
            throw new HttpException(422, 'Appointment does not match patient/tenant/branch.');
        }

        return $appointment;
    }

    /**
     * @param array<int,array<string,mixed>> $items
     * @return array<int,array<string,mixed>>
     */
    private function prepareItems(array $items, int $tenantId, int $branchId): array
    {
        $prepared = [];

        foreach ($items as $idx => $item) {
            $serviceId = $item['service_id'] ?? null;
            $description = trim((string) ($item['description'] ?? ''));
            $quantity = (int) ($item['quantity'] ?? 0);
            $unitPrice = (float) ($item['unit_price'] ?? 0);

            if ($quantity <= 0 || $unitPrice < 0) {
                throw new HttpException(422, 'Invalid quantity or unit_price at item index '.$idx.'.');
            }

            if ($serviceId !== null) {
                $service = Service::query()
                    ->whereKey((int) $serviceId)
                    ->where('tenant_id', $tenantId)
                    ->where('branch_id', $branchId)
                    ->first();
                if ($service === null) {
                    throw new HttpException(422, 'Invalid service scope at item index '.$idx.'.');
                }
                if ($description === '') {
                    $description = $service->name;
                }
            }

            if ($description === '') {
                throw new HttpException(422, 'Each item needs description or service_id.');
            }

            $totalPrice = round($quantity * $unitPrice, 2);

            $prepared[] = [
                'service_id' => $serviceId !== null ? (int) $serviceId : null,
                'description' => $description,
                'quantity' => $quantity,
                'unit_price' => $unitPrice,
                'total_price' => $totalPrice,
            ];
        }

        return $prepared;
    }

    /**
     * @param array<int,array<string,mixed>> $items
     * @return array{0:float,1:float,2:float,3:float}
     */
    private function calculateTotals(array $items, mixed $discount, mixed $tax): array
    {
        $subtotal = round(collect($items)->sum('total_price'), 2);
        $discountValue = round((float) $discount, 2);
        $taxValue = round((float) $tax, 2);

        if ($discountValue < 0 || $taxValue < 0) {
            throw new HttpException(422, 'Discount and tax must be non-negative.');
        }

        if ($discountValue > $subtotal) {
            throw new HttpException(422, 'Discount cannot exceed subtotal.');
        }

        $total = round(($subtotal - $discountValue) + $taxValue, 2);
        if ($total < 0) {
            throw new HttpException(422, 'Calculated total is invalid.');
        }

        return [$subtotal, $discountValue, $taxValue, $total];
    }

    private function resolveInitialStatus(mixed $requestedStatus): string
    {
        if ($requestedStatus === null) {
            return InvoiceStatus::Unpaid->value;
        }

        $value = (string) $requestedStatus;
        return match ($value) {
            InvoiceStatus::Draft->value,
            InvoiceStatus::Unpaid->value,
            InvoiceStatus::Cancelled->value => $value,
            default => InvoiceStatus::Unpaid->value,
        };
    }

    private function assertStatusTransitionSafe(Invoice $invoice, string $newStatus): void
    {
        if ($newStatus === InvoiceStatus::Cancelled->value && $invoice->payments()->exists()) {
            throw new HttpException(422, 'Cannot cancel an invoice that already has payments.');
        }
    }

    private function generateInvoiceNumber(int $tenantId): string
    {
        for ($i = 0; $i < 5; $i++) {
            $seq = str_pad((string) random_int(1, 999999), 6, '0', STR_PAD_LEFT);
            $invoiceNo = sprintf('INV-%03d-%s-%s', $tenantId, now()->format('Ymd'), $seq);

            if (! Invoice::query()->where('invoice_number', $invoiceNo)->exists()) {
                return $invoiceNo;
            }
        }

        return sprintf('INV-%03d-%s-%d', $tenantId, now()->format('Ymd'), time());
    }
}
