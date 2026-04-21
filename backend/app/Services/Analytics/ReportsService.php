<?php

namespace App\Services\Analytics;

use App\Enums\AppointmentStatus;
use App\Enums\DoctorStatus;
use App\Enums\InvoiceStatus;
use App\Enums\PatientStatus;
use App\Models\Appointment;
use App\Models\Doctor;
use App\Models\Invoice;
use App\Models\InvoiceItem;
use App\Models\Patient;
use App\Models\Payment;
use App\Models\Service;
use App\Models\User;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

class ReportsService
{
    public function __construct(
        private readonly ScopeResolver $scopeResolver
    ) {
    }

    /**
     * @return array<string, mixed>
     */
    public function revenue(User $user, Request $request): array
    {
        [$tenantId, $branchId] = $this->scopeResolver->resolveFromRequest($user, $request);
        [$from, $to] = $this->resolveDateRange($request, 'issued_at');
        $perPage = $this->resolvePerPage($request);

        $query = Invoice::query()
            ->with(['patient:id,patient_code,full_name', 'branch:id,name,code'])
            ->withSum('payments', 'amount');
        $this->scopeResolver->apply($query, $tenantId, $branchId);
        $this->applyRevenueFilters($query, $request, $from, $to);

        $invoices = $query->latest('issued_at')->paginate($perPage)->appends($request->query());

        $totalInvoiced = (float) $query->clone()->sum('total');
        $paidTotal = (float) Payment::query()
            ->join('invoices', 'invoices.id', '=', 'payments.invoice_id')
            ->when($tenantId !== null, fn ($q) => $q->where('payments.tenant_id', $tenantId))
            ->when($branchId !== null, fn ($q) => $q->where('payments.branch_id', $branchId))
            ->when($from !== null, fn ($q) => $q->whereDate('invoices.issued_at', '>=', $from))
            ->when($to !== null, fn ($q) => $q->whereDate('invoices.issued_at', '<=', $to))
            ->when($request->query('status'), fn ($q) => $q->where('invoices.status', (string) $request->query('status')))
            ->sum('payments.amount');

        return [
            'scope' => ['tenant_id' => $tenantId, 'branch_id' => $branchId],
            'summary' => [
                'total_invoiced' => $this->amount($totalInvoiced),
                'paid_total' => $this->amount($paidTotal),
                'remaining_total' => $this->amount(max(0, $totalInvoiced - $paidTotal)),
                'invoices_count' => $query->clone()->count(),
            ],
            'items' => $invoices->getCollection()->map(fn (Invoice $invoice) => [
                'id' => $invoice->id,
                'invoice_number' => $invoice->invoice_number,
                'status' => $invoice->status?->value ?? $invoice->status,
                'issued_at' => $invoice->issued_at?->toDateString(),
                'due_at' => $invoice->due_at?->toDateString(),
                'total' => $invoice->total,
                'paid_amount' => $this->amount((float) ($invoice->payments_sum_amount ?? 0)),
                'remaining_amount' => $this->amount(max(0, (float) $invoice->total - (float) ($invoice->payments_sum_amount ?? 0))),
                'patient' => [
                    'id' => $invoice->patient?->id,
                    'patient_code' => $invoice->patient?->patient_code,
                    'full_name' => $invoice->patient?->full_name,
                ],
                'branch' => [
                    'id' => $invoice->branch?->id,
                    'name' => $invoice->branch?->name,
                    'code' => $invoice->branch?->code,
                ],
            ])->values()->all(),
            'pagination' => [
                'current_page' => $invoices->currentPage(),
                'per_page' => $invoices->perPage(),
                'total' => $invoices->total(),
                'last_page' => $invoices->lastPage(),
                'from' => $invoices->firstItem(),
                'to' => $invoices->lastItem(),
            ],
        ];
    }

    /**
     * @return array<string, mixed>
     */
    public function payments(User $user, Request $request): array
    {
        [$tenantId, $branchId] = $this->scopeResolver->resolveFromRequest($user, $request);
        [$from, $to] = $this->resolveDateRange($request, 'payment_date');
        $perPage = $this->resolvePerPage($request);

        $query = Payment::query()
            ->with(['invoice:id,invoice_number,patient_id,total,status', 'invoice.patient:id,patient_code,full_name', 'branch:id,name,code']);
        $this->scopeResolver->apply($query, $tenantId, $branchId);

        if ($method = $request->query('payment_method')) {
            $query->where('payment_method', (string) $method);
        }
        if ($invoiceId = $request->query('invoice_id')) {
            $query->where('invoice_id', (int) $invoiceId);
        }
        if ($from !== null) {
            $query->whereDate('payment_date', '>=', $from);
        }
        if ($to !== null) {
            $query->whereDate('payment_date', '<=', $to);
        }

        $payments = $query->latest('payment_date')->paginate($perPage)->appends($request->query());
        $totalAmount = (float) $query->clone()->sum('amount');

        return [
            'scope' => ['tenant_id' => $tenantId, 'branch_id' => $branchId],
            'summary' => [
                'payments_count' => $query->clone()->count(),
                'total_amount' => $this->amount($totalAmount),
            ],
            'items' => $payments->getCollection()->map(fn (Payment $payment) => [
                'id' => $payment->id,
                'amount' => $payment->amount,
                'payment_method' => $payment->payment_method?->value ?? $payment->payment_method,
                'payment_date' => $payment->payment_date?->toDateString(),
                'reference_number' => $payment->reference_number,
                'invoice' => [
                    'id' => $payment->invoice?->id,
                    'invoice_number' => $payment->invoice?->invoice_number,
                    'total' => $payment->invoice?->total,
                    'status' => $payment->invoice?->status?->value ?? $payment->invoice?->status,
                ],
                'patient' => [
                    'id' => $payment->invoice?->patient?->id,
                    'patient_code' => $payment->invoice?->patient?->patient_code,
                    'full_name' => $payment->invoice?->patient?->full_name,
                ],
                'branch' => [
                    'id' => $payment->branch?->id,
                    'name' => $payment->branch?->name,
                    'code' => $payment->branch?->code,
                ],
            ])->values()->all(),
            'pagination' => [
                'current_page' => $payments->currentPage(),
                'per_page' => $payments->perPage(),
                'total' => $payments->total(),
                'last_page' => $payments->lastPage(),
                'from' => $payments->firstItem(),
                'to' => $payments->lastItem(),
            ],
        ];
    }

    /**
     * @return array<string, mixed>
     */
    public function appointments(User $user, Request $request): array
    {
        [$tenantId, $branchId] = $this->scopeResolver->resolveFromRequest($user, $request);
        [$from, $to] = $this->resolveDateRange($request, 'appointment_date');
        $perPage = $this->resolvePerPage($request);

        $query = Appointment::query()
            ->with([
                'patient:id,patient_code,full_name',
                'doctor:id,doctor_code,full_name,specialization',
                'service:id,name,code',
                'branch:id,name,code',
            ]);
        $this->scopeResolver->apply($query, $tenantId, $branchId);

        foreach (['doctor_id', 'patient_id', 'service_id'] as $field) {
            if ($value = $request->query($field)) {
                $query->where($field, (int) $value);
            }
        }

        if ($status = $request->query('status')) {
            $query->where('status', (string) $status);
        }
        if ($from !== null) {
            $query->whereDate('appointment_date', '>=', $from);
        }
        if ($to !== null) {
            $query->whereDate('appointment_date', '<=', $to);
        }

        $appointments = $query->latest('appointment_date')->paginate($perPage)->appends($request->query());

        return [
            'scope' => ['tenant_id' => $tenantId, 'branch_id' => $branchId],
            'summary' => [
                'total_count' => $query->clone()->count(),
                'booked_count' => $query->clone()->where('status', AppointmentStatus::Booked->value)->count(),
                'completed_count' => $query->clone()->where('status', AppointmentStatus::Completed->value)->count(),
                'cancelled_count' => $query->clone()->where('status', AppointmentStatus::Cancelled->value)->count(),
                'no_show_count' => $query->clone()->where('status', AppointmentStatus::NoShow->value)->count(),
            ],
            'items' => $appointments->getCollection()->map(fn (Appointment $appointment) => [
                'id' => $appointment->id,
                'appointment_date' => $appointment->appointment_date?->toDateString(),
                'start_time' => $appointment->start_time,
                'end_time' => $appointment->end_time,
                'status' => $appointment->status?->value ?? $appointment->status,
                'patient' => [
                    'id' => $appointment->patient?->id,
                    'patient_code' => $appointment->patient?->patient_code,
                    'full_name' => $appointment->patient?->full_name,
                ],
                'doctor' => [
                    'id' => $appointment->doctor?->id,
                    'doctor_code' => $appointment->doctor?->doctor_code,
                    'full_name' => $appointment->doctor?->full_name,
                ],
                'service' => [
                    'id' => $appointment->service?->id,
                    'name' => $appointment->service?->name,
                    'code' => $appointment->service?->code,
                ],
                'branch' => [
                    'id' => $appointment->branch?->id,
                    'name' => $appointment->branch?->name,
                    'code' => $appointment->branch?->code,
                ],
            ])->values()->all(),
            'pagination' => [
                'current_page' => $appointments->currentPage(),
                'per_page' => $appointments->perPage(),
                'total' => $appointments->total(),
                'last_page' => $appointments->lastPage(),
                'from' => $appointments->firstItem(),
                'to' => $appointments->lastItem(),
            ],
        ];
    }

    /**
     * @return array<string, mixed>
     */
    public function patients(User $user, Request $request): array
    {
        [$tenantId, $branchId] = $this->scopeResolver->resolveFromRequest($user, $request);
        [$from, $to] = $this->resolveDateRange($request, 'created_at');
        $perPage = $this->resolvePerPage($request);

        $query = Patient::query()->with('branch:id,name,code');
        $this->scopeResolver->apply($query, $tenantId, $branchId);

        if ($from !== null) {
            $query->whereDate('created_at', '>=', $from);
        }
        if ($to !== null) {
            $query->whereDate('created_at', '<=', $to);
        }

        $patients = $query->latest('created_at')->paginate($perPage)->appends($request->query());

        $scoped = Patient::query();
        $this->scopeResolver->apply($scoped, $tenantId, $branchId);

        return [
            'scope' => ['tenant_id' => $tenantId, 'branch_id' => $branchId],
            'summary' => [
                'new_patients_count' => $query->clone()->count(),
                'active_count' => $scoped->clone()->where('status', PatientStatus::Active->value)->count(),
                'inactive_count' => $scoped->clone()->where('status', PatientStatus::Inactive->value)->count(),
                'gender_breakdown' => $scoped->clone()
                    ->selectRaw('gender, COUNT(*) as count')
                    ->groupBy('gender')
                    ->pluck('count', 'gender')
                    ->map(fn ($count) => (int) $count)
                    ->all(),
            ],
            'items' => $patients->getCollection()->map(fn (Patient $patient) => [
                'id' => $patient->id,
                'patient_code' => $patient->patient_code,
                'full_name' => $patient->full_name,
                'gender' => $patient->gender?->value ?? $patient->gender,
                'phone' => $patient->phone,
                'status' => $patient->status?->value ?? $patient->status,
                'created_at' => $patient->created_at,
                'branch' => [
                    'id' => $patient->branch?->id,
                    'name' => $patient->branch?->name,
                    'code' => $patient->branch?->code,
                ],
            ])->values()->all(),
            'pagination' => [
                'current_page' => $patients->currentPage(),
                'per_page' => $patients->perPage(),
                'total' => $patients->total(),
                'last_page' => $patients->lastPage(),
                'from' => $patients->firstItem(),
                'to' => $patients->lastItem(),
            ],
        ];
    }

    /**
     * @return array<string, mixed>
     */
    public function doctors(User $user, Request $request): array
    {
        [$tenantId, $branchId] = $this->scopeResolver->resolveFromRequest($user, $request);
        $perPage = $this->resolvePerPage($request);

        $doctors = Doctor::query()
            ->with(['branch:id,name,code'])
            ->withCount('appointments')
            ->when($tenantId !== null, fn (Builder $q) => $q->where('tenant_id', $tenantId))
            ->when($branchId !== null, fn (Builder $q) => $q->where('branch_id', $branchId));

        if ($status = $request->query('status')) {
            $doctors->where('status', (string) $status);
        }

        $doctorPage = $doctors->paginate($perPage)->appends($request->query());

        $revenueByDoctor = Invoice::query()
            ->join('appointments', 'appointments.id', '=', 'invoices.appointment_id')
            ->selectRaw('appointments.doctor_id, SUM(invoices.total) as total_invoice_revenue')
            ->when($tenantId !== null, fn ($q) => $q->where('invoices.tenant_id', $tenantId))
            ->when($branchId !== null, fn ($q) => $q->where('invoices.branch_id', $branchId))
            ->groupBy('appointments.doctor_id')
            ->pluck('total_invoice_revenue', 'appointments.doctor_id');

        return [
            'scope' => ['tenant_id' => $tenantId, 'branch_id' => $branchId],
            'summary' => [
                'total_doctors' => $doctors->clone()->count(),
                'active_count' => $doctors->clone()->where('status', DoctorStatus::Active->value)->count(),
                'inactive_count' => $doctors->clone()->where('status', DoctorStatus::Inactive->value)->count(),
                'on_leave_count' => $doctors->clone()->where('status', DoctorStatus::OnLeave->value)->count(),
            ],
            'items' => $doctorPage->getCollection()->map(function (Doctor $doctor) use ($revenueByDoctor): array {
                $revenue = (float) ($revenueByDoctor[$doctor->id] ?? 0);

                return [
                    'id' => $doctor->id,
                    'doctor_code' => $doctor->doctor_code,
                    'full_name' => $doctor->full_name,
                    'specialization' => $doctor->specialization,
                    'status' => $doctor->status?->value ?? $doctor->status,
                    'appointments_count' => (int) $doctor->appointments_count,
                    'revenue_contribution' => $this->amount($revenue),
                    'branch' => [
                        'id' => $doctor->branch?->id,
                        'name' => $doctor->branch?->name,
                        'code' => $doctor->branch?->code,
                    ],
                ];
            })->values()->all(),
            'pagination' => [
                'current_page' => $doctorPage->currentPage(),
                'per_page' => $doctorPage->perPage(),
                'total' => $doctorPage->total(),
                'last_page' => $doctorPage->lastPage(),
                'from' => $doctorPage->firstItem(),
                'to' => $doctorPage->lastItem(),
            ],
        ];
    }

    /**
     * @return array<string, mixed>
     */
    public function services(User $user, Request $request): array
    {
        [$tenantId, $branchId] = $this->scopeResolver->resolveFromRequest($user, $request);
        $perPage = $this->resolvePerPage($request);

        $serviceQuery = Service::query()
            ->with('branch:id,name,code')
            ->withCount('appointments')
            ->when($tenantId !== null, fn (Builder $q) => $q->where('tenant_id', $tenantId))
            ->when($branchId !== null, fn (Builder $q) => $q->where('branch_id', $branchId));

        if ($status = $request->query('status')) {
            $serviceQuery->where('status', (string) $status);
        }

        $services = $serviceQuery->orderByDesc('appointments_count')->paginate($perPage)->appends($request->query());

        $revenueByService = InvoiceItem::query()
            ->join('invoices', 'invoices.id', '=', 'invoice_items.invoice_id')
            ->selectRaw('invoice_items.service_id, SUM(invoice_items.total_price) as total_revenue')
            ->whereNotNull('invoice_items.service_id')
            ->when($tenantId !== null, fn ($q) => $q->where('invoices.tenant_id', $tenantId))
            ->when($branchId !== null, fn ($q) => $q->where('invoices.branch_id', $branchId))
            ->groupBy('invoice_items.service_id')
            ->pluck('total_revenue', 'invoice_items.service_id');

        return [
            'scope' => ['tenant_id' => $tenantId, 'branch_id' => $branchId],
            'summary' => [
                'total_services' => $serviceQuery->clone()->count(),
                'active_count' => $serviceQuery->clone()->where('status', 'active')->count(),
                'inactive_count' => $serviceQuery->clone()->where('status', 'inactive')->count(),
            ],
            'items' => $services->getCollection()->map(function (Service $service) use ($revenueByService): array {
                return [
                    'id' => $service->id,
                    'name' => $service->name,
                    'code' => $service->code,
                    'status' => $service->status?->value ?? $service->status,
                    'appointments_count' => (int) $service->appointments_count,
                    'revenue' => $this->amount((float) ($revenueByService[$service->id] ?? 0)),
                    'branch' => [
                        'id' => $service->branch?->id,
                        'name' => $service->branch?->name,
                        'code' => $service->branch?->code,
                    ],
                ];
            })->values()->all(),
            'pagination' => [
                'current_page' => $services->currentPage(),
                'per_page' => $services->perPage(),
                'total' => $services->total(),
                'last_page' => $services->lastPage(),
                'from' => $services->firstItem(),
                'to' => $services->lastItem(),
            ],
        ];
    }

    private function resolvePerPage(Request $request): int
    {
        return max(1, min(100, (int) $request->integer('per_page', 15)));
    }

    /**
     * @return array{0:?string,1:?string}
     */
    private function resolveDateRange(Request $request, string $defaultField): array
    {
        $from = $request->query('date_from');
        $to = $request->query('date_to');

        if ($defaultField === '') {
            return [null, null];
        }

        $fromValue = $from !== null ? Carbon::parse((string) $from)->toDateString() : null;
        $toValue = $to !== null ? Carbon::parse((string) $to)->toDateString() : null;

        return [$fromValue, $toValue];
    }

    private function applyRevenueFilters(Builder $query, Request $request, ?string $from, ?string $to): void
    {
        if ($status = $request->query('status')) {
            $query->where('status', (string) $status);
        }
        if ($from !== null) {
            $query->whereDate('issued_at', '>=', $from);
        }
        if ($to !== null) {
            $query->whereDate('issued_at', '<=', $to);
        }
    }

    private function amount(float $value): string
    {
        return number_format($value, 2, '.', '');
    }
}
