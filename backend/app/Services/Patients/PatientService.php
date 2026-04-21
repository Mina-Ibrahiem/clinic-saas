<?php

namespace App\Services\Patients;

use App\Enums\PatientStatus;
use App\Models\Branch;
use App\Models\Patient;
use App\Models\User;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Str;
use Symfony\Component\HttpKernel\Exception\HttpException;

class PatientService
{
    public function paginate(User $user, Request $request): LengthAwarePaginator
    {
        $perPage = max(1, min(100, (int) $request->integer('per_page', 15)));
        $query = Patient::query()
            ->with(['branch:id,name,code', 'tenant:id,uuid,name,slug'])
            ->withCount(['appointments', 'invoices', 'notes']);

        $this->applyAccessScope($query, $user);
        $this->applyFilters($query, $request);
        $this->applySorting($query, $request);

        return $query->paginate($perPage)->appends($request->query());
    }

    public function findOrFail(User $user, Patient $patient): Patient
    {
        $patient->loadMissing(['branch:id,name,code', 'tenant:id,uuid,name,slug'])
            ->loadCount(['appointments', 'invoices', 'notes']);

        if (! $this->canAccessPatient($user, $patient)) {
            throw new HttpException(404, 'Patient not found.');
        }

        return $patient;
    }

    /**
     * @param array<string, mixed> $payload
     */
    public function create(User $user, array $payload): Patient
    {
        [$tenantId, $branchId] = $this->resolveTenantAndBranch($user, $payload);

        $patient = Patient::query()->create([
            'tenant_id' => $tenantId,
            'branch_id' => $branchId,
            'patient_code' => $this->generatePatientCode($tenantId),
            'full_name' => $payload['full_name'],
            'gender' => $payload['gender'] ?? 'unknown',
            'date_of_birth' => $payload['date_of_birth'] ?? null,
            'phone' => $payload['phone'],
            'email' => $payload['email'] ?? null,
            'address' => $payload['address'] ?? null,
            'emergency_contact_name' => $payload['emergency_contact_name'] ?? null,
            'emergency_contact_phone' => $payload['emergency_contact_phone'] ?? null,
            'blood_group' => $payload['blood_group'] ?? null,
            'allergies' => $payload['allergies'] ?? null,
            'medical_notes' => $payload['medical_notes'] ?? null,
            'status' => $payload['status'] ?? PatientStatus::Active->value,
        ]);

        return $patient->load(['branch:id,name,code', 'tenant:id,uuid,name,slug']);
    }

    /**
     * @param array<string, mixed> $payload
     */
    public function update(User $user, Patient $patient, array $payload): Patient
    {
        if (array_key_exists('branch_id', $payload)) {
            [, $branchId] = $this->resolveTenantAndBranch($user, $payload, (int) $patient->tenant_id);
            $patient->branch_id = $branchId;
        }

        $patient->fill([
            'full_name' => $payload['full_name'] ?? $patient->full_name,
            'gender' => $payload['gender'] ?? $patient->gender?->value ?? $patient->gender,
            'date_of_birth' => $payload['date_of_birth'] ?? $patient->date_of_birth,
            'phone' => $payload['phone'] ?? $patient->phone,
            'email' => $payload['email'] ?? $patient->email,
            'address' => $payload['address'] ?? $patient->address,
            'emergency_contact_name' => $payload['emergency_contact_name'] ?? $patient->emergency_contact_name,
            'emergency_contact_phone' => $payload['emergency_contact_phone'] ?? $patient->emergency_contact_phone,
            'blood_group' => $payload['blood_group'] ?? $patient->blood_group,
            'allergies' => $payload['allergies'] ?? $patient->allergies,
            'medical_notes' => $payload['medical_notes'] ?? $patient->medical_notes,
            'status' => $payload['status'] ?? $patient->status?->value ?? $patient->status,
        ]);
        $patient->save();

        return $patient->load(['branch:id,name,code', 'tenant:id,uuid,name,slug']);
    }

    public function delete(Patient $patient): void
    {
        $patient->delete();
    }

    private function applyAccessScope(Builder $query, User $user): void
    {
        if (! $user->hasRole('super_admin') && $user->tenant_id !== null) {
            $query->where('tenant_id', $user->tenant_id);
        }

        if ($user->hasRole('doctor') && $user->doctorProfile !== null) {
            $doctorId = $user->doctorProfile->id;
            $query->whereHas('appointments', fn (Builder $q) => $q->where('doctor_id', $doctorId));
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
                $q->where('full_name', 'like', '%'.$search.'%')
                    ->orWhere('phone', 'like', '%'.$search.'%')
                    ->orWhere('patient_code', 'like', '%'.$search.'%');
            });
        }

        if ($gender = $request->query('gender')) {
            $query->where('gender', $gender);
        }

        if ($status = $request->query('status')) {
            $query->where('status', $status);
        }

        if ($branchId = $request->query('branch_id')) {
            $query->where('branch_id', (int) $branchId);
        }
    }

    private function applySorting(Builder $query, Request $request): void
    {
        $sort = (string) $request->query('sort', 'latest');

        match ($sort) {
            'oldest' => $query->oldest('created_at'),
            'full_name' => $query->orderBy('full_name'),
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

    private function canAccessPatient(User $user, Patient $patient): bool
    {
        $query = Patient::query()->whereKey($patient->id);
        $this->applyAccessScope($query, $user);

        return $query->exists();
    }

    private function generatePatientCode(int $tenantId): string
    {
        $prefix = 'P-'.str_pad((string) $tenantId, 3, '0', STR_PAD_LEFT);

        for ($i = 0; $i < 5; $i++) {
            $candidate = $prefix.'-'.Str::upper(Str::random(6));
            $exists = Patient::query()
                ->where('tenant_id', $tenantId)
                ->where('patient_code', $candidate)
                ->exists();

            if (! $exists) {
                return $candidate;
            }
        }

        return $prefix.'-'.time();
    }
}
