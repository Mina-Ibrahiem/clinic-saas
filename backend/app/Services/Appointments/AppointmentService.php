<?php

namespace App\Services\Appointments;

use App\Enums\AppointmentStatus;
use App\Models\Appointment;
use App\Models\AppointmentStatusHistory;
use App\Models\Branch;
use App\Models\Doctor;
use App\Models\Patient;
use App\Models\Service;
use App\Models\User;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;
use Illuminate\Pagination\LengthAwarePaginator;
use Symfony\Component\HttpKernel\Exception\HttpException;

class AppointmentService
{
    public function paginate(User $user, Request $request): LengthAwarePaginator
    {
        $perPage = max(1, min(100, (int) $request->integer('per_page', 15)));
        $query = Appointment::query()
            ->with([
                'patient:id,patient_code,full_name,phone',
                'doctor:id,doctor_code,full_name,specialization',
                'service:id,name,code,price',
                'branch:id,name,code',
                'tenant:id,uuid,name,slug',
            ]);

        $this->applyAccessScope($query, $user);
        $this->applyFilters($query, $request);
        $this->applySorting($query, $request);

        return $query->paginate($perPage)->appends($request->query());
    }

    public function findOrFail(User $user, Appointment $appointment): Appointment
    {
        if (! $this->canAccessAppointment($user, $appointment)) {
            throw new HttpException(404, 'Appointment not found.');
        }

        return $appointment->loadMissing([
            'patient:id,patient_code,full_name,phone',
            'doctor:id,doctor_code,full_name,specialization',
            'service:id,name,code,price',
            'branch:id,name,code',
            'tenant:id,uuid,name,slug',
        ]);
    }

    /**
     * @param array<string, mixed> $payload
     */
    public function create(User $user, array $payload): Appointment
    {
        [$tenantId, $branchId] = $this->resolveTenantAndBranch($user, $payload);
        $doctor = $this->resolveDoctor((int) $payload['doctor_id'], $tenantId, $branchId);
        $patient = $this->resolvePatient((int) $payload['patient_id'], $tenantId, $branchId);
        $serviceId = $payload['service_id'] ?? null;
        $service = $serviceId !== null ? $this->resolveService((int) $serviceId, $tenantId, $branchId) : null;

        $start = $this->normalizeTime((string) $payload['start_time']);
        $end = $this->normalizeTime((string) $payload['end_time']);
        $date = (string) $payload['appointment_date'];

        $this->ensureNoConflict($doctor->id, $date, $start, $end, null);

        $appointment = Appointment::query()->create([
            'tenant_id' => $tenantId,
            'branch_id' => $branchId,
            'patient_id' => $patient->id,
            'doctor_id' => $doctor->id,
            'service_id' => $service?->id,
            'appointment_date' => $date,
            'start_time' => $start,
            'end_time' => $end,
            'status' => $payload['status'] ?? AppointmentStatus::Booked->value,
            'notes' => $payload['notes'] ?? null,
            'created_by' => $user->id,
        ]);

        $this->recordStatusHistory($appointment, null, (string) ($appointment->status?->value ?? $appointment->status), $user->id, 'Created');

        return $this->findOrFail($user, $appointment);
    }

    /**
     * @param array<string, mixed> $payload
     */
    public function update(User $user, Appointment $appointment, array $payload): Appointment
    {
        $isDoctor = $user->hasRole('doctor');
        if ($isDoctor) {
            $allowed = collect(['status', 'notes']);
            $incoming = collect(array_keys($payload));
            if ($incoming->diff($allowed)->isNotEmpty()) {
                throw new HttpException(403, 'Doctor can only update appointment status or notes.');
            }
        }

        $tenantId = (int) $appointment->tenant_id;
        [$resolvedTenantId, $branchId] = $this->resolveTenantAndBranch($user, $payload + ['branch_id' => $appointment->branch_id], $tenantId);

        if ($resolvedTenantId !== $tenantId) {
            throw new HttpException(422, 'Changing appointment tenant is not allowed.');
        }

        $doctorId = (int) ($payload['doctor_id'] ?? $appointment->doctor_id);
        $patientId = (int) ($payload['patient_id'] ?? $appointment->patient_id);
        $serviceId = array_key_exists('service_id', $payload) ? $payload['service_id'] : $appointment->service_id;

        $doctor = $this->resolveDoctor($doctorId, $tenantId, $branchId);
        $patient = $this->resolvePatient($patientId, $tenantId, $branchId);
        $service = $serviceId !== null ? $this->resolveService((int) $serviceId, $tenantId, $branchId) : null;

        $date = (string) ($payload['appointment_date'] ?? $appointment->appointment_date?->toDateString());
        $start = $this->normalizeTime((string) ($payload['start_time'] ?? $appointment->start_time));
        $end = $this->normalizeTime((string) ($payload['end_time'] ?? $appointment->end_time));

        $this->ensureNoConflict($doctor->id, $date, $start, $end, (int) $appointment->id);

        $previousStatus = (string) ($appointment->status?->value ?? $appointment->status);

        $appointment->fill([
            'branch_id' => $branchId,
            'patient_id' => $patient->id,
            'doctor_id' => $doctor->id,
            'service_id' => $service?->id,
            'appointment_date' => $date,
            'start_time' => $start,
            'end_time' => $end,
            'status' => $payload['status'] ?? $previousStatus,
            'notes' => $payload['notes'] ?? $appointment->notes,
        ]);
        $appointment->save();

        $newStatus = (string) ($appointment->status?->value ?? $appointment->status);
        if ($previousStatus !== $newStatus) {
            $this->recordStatusHistory($appointment, $previousStatus, $newStatus, $user->id, 'Status updated');
        }

        return $this->findOrFail($user, $appointment);
    }

    public function delete(User $user, Appointment $appointment): void
    {
        $previousStatus = (string) ($appointment->status?->value ?? $appointment->status);
        $appointment->delete();
        $this->recordStatusHistory($appointment, $previousStatus, AppointmentStatus::Cancelled->value, $user->id, 'Appointment deleted');
    }

    private function applyAccessScope(Builder $query, User $user): void
    {
        if (! $user->hasRole('super_admin') && $user->tenant_id !== null) {
            $query->where('tenant_id', $user->tenant_id);
        }

        if ($user->hasRole('doctor') && $user->doctorProfile !== null) {
            $query->where('doctor_id', $user->doctorProfile->id);
            return;
        }

        if (! $user->hasRole(['super_admin', 'clinic_owner']) && $user->branch_id !== null) {
            $query->where('branch_id', $user->branch_id);
        }
    }

    private function applyFilters(Builder $query, Request $request): void
    {
        if ($search = trim((string) $request->query('search', ''))) {
            $query->where(function (Builder $sub) use ($search): void {
                $sub->whereHas('patient', function (Builder $q) use ($search): void {
                    $q->where('full_name', 'like', '%'.$search.'%')
                        ->orWhere('patient_code', 'like', '%'.$search.'%');
                })->orWhereHas('doctor', function (Builder $q) use ($search): void {
                    $q->where('full_name', 'like', '%'.$search.'%');
                });
            });
        }

        foreach (['doctor_id', 'patient_id', 'service_id', 'branch_id'] as $column) {
            if ($value = $request->query($column)) {
                $query->where($column, (int) $value);
            }
        }

        if ($status = $request->query('status')) {
            $query->where('status', (string) $status);
        }

        if ($date = $request->query('appointment_date')) {
            $query->whereDate('appointment_date', (string) $date);
        }

        if ($from = $request->query('date_from')) {
            $query->whereDate('appointment_date', '>=', (string) $from);
        }

        if ($to = $request->query('date_to')) {
            $query->whereDate('appointment_date', '<=', (string) $to);
        }
    }

    private function applySorting(Builder $query, Request $request): void
    {
        $sort = (string) $request->query('sort', 'latest');

        match ($sort) {
            'oldest' => $query->oldest('created_at'),
            'appointment_date' => $query->orderBy('appointment_date')->orderBy('start_time'),
            default => $query->latest('created_at'),
        };
    }

    /**
     * @param array<string, mixed> $payload
     * @return array{0:int,1:int}
     */
    private function resolveTenantAndBranch(User $user, array $payload, ?int $fallbackTenantId = null): array
    {
        $isSuperAdmin = $user->hasRole('super_admin');

        $tenantId = $fallbackTenantId !== null
            ? (int) $fallbackTenantId
            : ($isSuperAdmin
                ? (int) ($payload['tenant_id'] ?? $user->tenant_id ?? 0)
                : (int) ($user->tenant_id ?? 0));

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
            throw new HttpException(422, 'Invalid branch for the selected tenant.');
        }

        return [$tenantId, $branchId];
    }

    private function resolveDoctor(int $doctorId, int $tenantId, int $branchId): Doctor
    {
        $doctor = Doctor::query()
            ->whereKey($doctorId)
            ->where('tenant_id', $tenantId)
            ->where('branch_id', $branchId)
            ->first();

        if ($doctor === null) {
            throw new HttpException(422, 'Doctor does not belong to tenant/branch scope.');
        }

        return $doctor;
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

    private function resolveService(int $serviceId, int $tenantId, int $branchId): Service
    {
        $service = Service::query()
            ->whereKey($serviceId)
            ->where('tenant_id', $tenantId)
            ->where('branch_id', $branchId)
            ->first();

        if ($service === null) {
            throw new HttpException(422, 'Service does not belong to tenant/branch scope.');
        }

        return $service;
    }

    private function ensureNoConflict(int $doctorId, string $date, string $start, string $end, ?int $ignoreAppointmentId): void
    {
        $query = Appointment::query()
            ->where('doctor_id', $doctorId)
            ->whereDate('appointment_date', $date)
            ->where('status', '!=', AppointmentStatus::Cancelled->value)
            ->where(function (Builder $q) use ($start, $end): void {
                $q->where('start_time', '<', $end)
                    ->where('end_time', '>', $start);
            });

        if ($ignoreAppointmentId !== null) {
            $query->whereKeyNot($ignoreAppointmentId);
        }

        if ($query->exists()) {
            throw new HttpException(422, 'Doctor already has an overlapping appointment in this time slot.');
        }
    }

    private function normalizeTime(string $time): string
    {
        if (preg_match('/^\d{2}:\d{2}$/', $time) === 1) {
            return $time.':00';
        }

        if (preg_match('/^\d{2}:\d{2}:\d{2}$/', $time) === 1) {
            return $time;
        }

        throw new HttpException(422, 'Invalid time format.');
    }

    private function canAccessAppointment(User $user, Appointment $appointment): bool
    {
        $query = Appointment::query()->whereKey($appointment->id);
        $this->applyAccessScope($query, $user);

        return $query->exists();
    }

    private function recordStatusHistory(Appointment $appointment, ?string $from, string $to, int $changedBy, ?string $note): void
    {
        AppointmentStatusHistory::query()->create([
            'appointment_id' => $appointment->id,
            'from_status' => $from,
            'to_status' => $to,
            'changed_by' => $changedBy,
            'note' => $note,
            'created_at' => now(),
        ]);
    }
}
