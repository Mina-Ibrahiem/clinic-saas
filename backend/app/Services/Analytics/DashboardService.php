<?php

namespace App\Services\Analytics;

use App\Enums\AppointmentStatus;
use App\Enums\DoctorStatus;
use App\Enums\InvoiceStatus;
use App\Models\Appointment;
use App\Models\Doctor;
use App\Models\Invoice;
use App\Models\Patient;
use App\Models\Payment;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

class DashboardService
{
    public function __construct(
        private readonly ScopeResolver $scopeResolver
    ) {
    }

    /**
     * @return array<string, mixed>
     */
    public function overview(User $user, Request $request): array
    {
        [$tenantId, $branchId] = $this->scopeResolver->resolveFromRequest($user, $request);
        $today = now()->toDateString();

        $patients = Patient::query();
        $doctors = Doctor::query();
        $appointments = Appointment::query();
        $invoices = Invoice::query();
        $payments = Payment::query();

        $this->scopeResolver->apply($patients, $tenantId, $branchId);
        $this->scopeResolver->apply($doctors, $tenantId, $branchId);
        $this->scopeResolver->apply($appointments, $tenantId, $branchId);
        $this->scopeResolver->apply($invoices, $tenantId, $branchId);
        $this->scopeResolver->apply($payments, $tenantId, $branchId);

        $totalInvoiced = (float) $invoices
            ->clone()
            ->whereNotIn('status', [InvoiceStatus::Cancelled->value, InvoiceStatus::Draft->value])
            ->sum('total');

        $totalPaid = (float) $payments->clone()->sum('amount');

        return [
            'scope' => [
                'tenant_id' => $tenantId,
                'branch_id' => $branchId,
            ],
            'totals' => [
                'total_patients' => $patients->clone()->count(),
                'active_doctors' => $doctors->clone()->where('status', DoctorStatus::Active->value)->count(),
                'today_appointments_count' => $appointments->clone()->whereDate('appointment_date', $today)->count(),
                'upcoming_appointments_count' => $appointments->clone()
                    ->whereDate('appointment_date', '>', $today)
                    ->where('status', AppointmentStatus::Booked->value)
                    ->count(),
                'paid_invoices_count' => $invoices->clone()->where('status', InvoiceStatus::Paid->value)->count(),
                'open_invoices_count' => $invoices->clone()
                    ->whereIn('status', [InvoiceStatus::Unpaid->value, InvoiceStatus::PartiallyPaid->value])
                    ->count(),
                'total_revenue' => $this->formatAmount($totalPaid),
                'outstanding_balance' => $this->formatAmount(max(0, $totalInvoiced - $totalPaid)),
            ],
        ];
    }

    /**
     * @return array<string, mixed>
     */
    public function revenueSummary(User $user, Request $request): array
    {
        [$tenantId, $branchId] = $this->scopeResolver->resolveFromRequest($user, $request);

        $payments = Payment::query();
        $invoices = Invoice::query();
        $this->scopeResolver->apply($payments, $tenantId, $branchId);
        $this->scopeResolver->apply($invoices, $tenantId, $branchId);

        $todayStart = now()->startOfDay();
        $todayEnd = now()->endOfDay();
        $weekStart = now()->startOfWeek();
        $weekEnd = now()->endOfWeek();
        $monthStart = now()->startOfMonth();
        $monthEnd = now()->endOfMonth();

        $dateFrom = $request->query('date_from')
            ? Carbon::parse((string) $request->query('date_from'))->startOfDay()
            : now()->subDays(29)->startOfDay();
        $dateTo = $request->query('date_to')
            ? Carbon::parse((string) $request->query('date_to'))->endOfDay()
            : now()->endOfDay();

        $grouped = $payments->clone()
            ->selectRaw('DATE(payment_date) as date, SUM(amount) as total')
            ->whereBetween('payment_date', [$dateFrom->toDateString(), $dateTo->toDateString()])
            ->groupBy(DB::raw('DATE(payment_date)'))
            ->orderBy('date')
            ->get()
            ->map(fn ($row) => [
                'date' => $row->date,
                'amount' => $this->formatAmount((float) $row->total),
            ])
            ->values()
            ->all();

        return [
            'scope' => [
                'tenant_id' => $tenantId,
                'branch_id' => $branchId,
            ],
            'totals' => [
                'revenue_today' => $this->formatAmount((float) $payments->clone()->whereBetween('payment_date', [$todayStart, $todayEnd])->sum('amount')),
                'revenue_this_week' => $this->formatAmount((float) $payments->clone()->whereBetween('payment_date', [$weekStart, $weekEnd])->sum('amount')),
                'revenue_this_month' => $this->formatAmount((float) $payments->clone()->whereBetween('payment_date', [$monthStart, $monthEnd])->sum('amount')),
                'paid_amount' => $this->formatAmount((float) $payments->clone()->sum('amount')),
                'unpaid_amount' => $this->formatAmount((float) $invoices->clone()->where('status', InvoiceStatus::Unpaid->value)->sum('total')),
                'partially_paid_amount' => $this->formatAmount((float) $invoices->clone()->where('status', InvoiceStatus::PartiallyPaid->value)->sum('total')),
            ],
            'chart' => [
                'granularity' => 'day',
                'range' => [
                    'from' => $dateFrom->toDateString(),
                    'to' => $dateTo->toDateString(),
                ],
                'points' => $grouped,
            ],
        ];
    }

    /**
     * @return array<string, mixed>
     */
    public function appointmentsSummary(User $user, Request $request): array
    {
        [$tenantId, $branchId] = $this->scopeResolver->resolveFromRequest($user, $request);
        $today = now()->toDateString();

        $appointments = Appointment::query();
        $this->scopeResolver->apply($appointments, $tenantId, $branchId);

        $rangeFrom = $request->query('date_from')
            ? Carbon::parse((string) $request->query('date_from'))->toDateString()
            : now()->subDays(14)->toDateString();
        $rangeTo = $request->query('date_to')
            ? Carbon::parse((string) $request->query('date_to'))->toDateString()
            : now()->addDays(14)->toDateString();

        $chartPoints = $appointments->clone()
            ->selectRaw('appointment_date, COUNT(*) as count')
            ->whereBetween('appointment_date', [$rangeFrom, $rangeTo])
            ->groupBy('appointment_date')
            ->orderBy('appointment_date')
            ->get()
            ->map(fn ($row) => [
                'date' => $row->appointment_date,
                'count' => (int) $row->count,
            ])
            ->values()
            ->all();

        return [
            'scope' => [
                'tenant_id' => $tenantId,
                'branch_id' => $branchId,
            ],
            'totals' => [
                'booked_count' => $appointments->clone()->where('status', AppointmentStatus::Booked->value)->count(),
                'completed_count' => $appointments->clone()->where('status', AppointmentStatus::Completed->value)->count(),
                'cancelled_count' => $appointments->clone()->where('status', AppointmentStatus::Cancelled->value)->count(),
                'no_show_count' => $appointments->clone()->where('status', AppointmentStatus::NoShow->value)->count(),
                'today_appointments' => $appointments->clone()->whereDate('appointment_date', $today)->count(),
                'upcoming_appointments' => $appointments->clone()
                    ->whereDate('appointment_date', '>', $today)
                    ->where('status', AppointmentStatus::Booked->value)
                    ->count(),
            ],
            'chart' => [
                'granularity' => 'day',
                'range' => [
                    'from' => $rangeFrom,
                    'to' => $rangeTo,
                ],
                'points' => $chartPoints,
            ],
        ];
    }

    private function formatAmount(float $value): string
    {
        return number_format($value, 2, '.', '');
    }
}
