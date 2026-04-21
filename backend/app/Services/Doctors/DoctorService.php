<?php

namespace App\Services\Doctors;

use App\Enums\DoctorStatus;
use App\Models\Branch;
use App\Models\Doctor;
use App\Models\User;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;
use Illuminate\Pagination\LengthAwarePaginator;
use Symfony\Component\HttpKernel\Exception\HttpException;

class DoctorService
{
    public function paginate(User $user, Request $request): LengthAwarePaginator
    {
        $perPage = max(1, min(100, (int) $request->integer('per_page', 15)));
        $query = Doctor::query()
            ->with([
                'user:id,full_name,email,phone,status',
                'branch:id,name,code',
                'tenant:id,uuid,name,slug',
            ])
            ->withCount(['appointments', 'notes']);

        $this->applyAccessScope($query, $user);
        $this->applyFilters($query, $request);
        $this->applySorting($query, $request);

        return $query->paginate($perPage)->appends($request->query());
    }

    public function findOrFail(User $user, Doctor $doctor): Doctor
    {
        if (! $this->canAccessDoctor($user, $doctor)) {
            throw new HttpException(404, 'Doctor not found.');
        }

        return $doctor->loadMissing([
            'user:id,full_name,email,phone,status',
            'branch:id,name,code',
            'tenant:id,uuid,name,slug',
        ])->loadCount(['appointments', 'notes']);
    }

    /**
     * @param array<string, mixed> $payload
     */
    public function create(User $user, array $payload): Doctor
    {
        [$tenantId, $branchId] = $this->resolveTenantAndBranch($user, $payload);

        $linkedUser = $this->resolveLinkedUser($payload['user_id'] ?? null, $tenantId, $branchId, null);
        $doctorCode = $this->normalizeCode($payload['doctor_code'] ?? null);
        $license = $this->normalizeLicense($payload['license_number'] ?? null);

        $this->ensureUniqueDoctorCode($tenantId, $doctorCode, null);
        $this->ensureUniqueLicense($tenantId, $license, null);

        $doctor = Doctor::query()->create([
            'tenant_id' => $tenantId,
            'branch_id' => $branchId,
            'user_id' => $linkedUser?->id,
            'doctor_code' => $doctorCode,
            'full_name' => trim((string) $payload['full_name']),
            'specialization' => trim((string) $payload['specialization']),
            'license_number' => $license,
            'consultation_fee' => $payload['consultation_fee'] ?? null,
            'bio' => $payload['bio'] ?? null,
            'status' => $payload['status'] ?? DoctorStatus::Active->value,
        ]);

        return $doctor->load(['user:id,full_name,email,phone,status', 'branch:id,name,code', 'tenant:id,uuid,name,slug']);
    }

    /**
     * @param array<string, mixed> $payload
     */
    public function update(User $user, Doctor $doctor, array $payload): Doctor
    {
        if (array_key_exists('branch_id', $payload)) {
            [, $branchId] = $this->resolveTenantAndBranch($user, $payload, (int) $doctor->tenant_id);
            $doctor->branch_id = $branchId;
        }

        $tenantId = (int) $doctor->tenant_id;
        $branchId = (int) $doctor->branch_id;
        $linkedUser = array_key_exists('user_id', $payload)
            ? $this->resolveLinkedUser($payload['user_id'], $tenantId, $branchId, (int) $doctor->id)
            : $doctor->user;

        $doctorCode = array_key_exists('doctor_code', $payload)
            ? $this->normalizeCode($payload['doctor_code'])
            : $this->normalizeCode($doctor->doctor_code);
        $license = array_key_exists('license_number', $payload)
            ? $this->normalizeLicense($payload['license_number'])
            : $this->normalizeLicense($doctor->license_number);

        $this->ensureUniqueDoctorCode($tenantId, $doctorCode, (int) $doctor->id);
        $this->ensureUniqueLicense($tenantId, $license, (int) $doctor->id);

        $doctor->fill([
            'user_id' => $linkedUser?->id,
            'doctor_code' => $doctorCode,
            'full_name' => $payload['full_name'] ?? $doctor->full_name,
            'specialization' => $payload['specialization'] ?? $doctor->specialization,
            'license_number' => $license,
            'consultation_fee' => $payload['consultation_fee'] ?? $doctor->consultation_fee,
            'bio' => array_key_exists('bio', $payload) ? $payload['bio'] : $doctor->bio,
            'status' => $payload['status'] ?? $doctor->status,
        ]);
        $doctor->save();

        return $doctor->load(['user:id,full_name,email,phone,status', 'branch:id,name,code', 'tenant:id,uuid,name,slug']);
    }

    public function delete(Doctor $doctor): void
    {
        if ($doctor->appointments()->exists()) {
            throw new HttpException(422, 'Cannot delete doctor with linked appointments.');
        }

        $doctor->delete();
    }

    private function applyAccessScope(Builder $query, User $user): void
    {
        if (! $user->hasRole('super_admin') && $user->tenant_id !== null) {
            $query->where('tenant_id', $user->tenant_id);
        }

        if ($user->hasRole('doctor')) {
            $query->where('user_id', $user->id);
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
                    ->orWhere('doctor_code', 'like', '%'.$search.'%')
                    ->orWhere('specialization', 'like', '%'.$search.'%')
                    ->orWhere('license_number', 'like', '%'.$search.'%')
                    ->orWhereHas('user', fn (Builder $uq) => $uq->where('email', 'like', '%'.$search.'%'));
            });
        }

        if ($status = $request->query('status')) {
            $query->where('status', (string) $status);
        }

        if ($branchId = $request->query('branch_id')) {
            $query->where('branch_id', (int) $branchId);
        }

        if ($specialization = $request->query('specialization')) {
            $query->where('specialization', 'like', '%'.trim((string) $specialization).'%');
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

    private function canAccessDoctor(User $user, Doctor $doctor): bool
    {
        $query = Doctor::query()->whereKey($doctor->id);
        $this->applyAccessScope($query, $user);

        return $query->exists();
    }

    private function normalizeCode(mixed $doctorCode): ?string
    {
        if ($doctorCode === null) {
            return null;
        }

        $normalized = strtoupper(trim((string) $doctorCode));

        return $normalized === '' ? null : $normalized;
    }

    private function normalizeLicense(mixed $license): ?string
    {
        if ($license === null) {
            return null;
        }

        $normalized = strtoupper(trim((string) $license));

        return $normalized === '' ? null : $normalized;
    }

    private function ensureUniqueDoctorCode(int $tenantId, ?string $doctorCode, ?int $ignoreDoctorId): void
    {
        if ($doctorCode === null) {
            return;
        }

        $query = Doctor::query()
            ->where('tenant_id', $tenantId)
            ->where('doctor_code', $doctorCode);

        if ($ignoreDoctorId !== null) {
            $query->whereKeyNot($ignoreDoctorId);
        }

        if ($query->exists()) {
            throw new HttpException(422, 'Doctor code already exists in this tenant.');
        }
    }

    private function ensureUniqueLicense(int $tenantId, ?string $licenseNumber, ?int $ignoreDoctorId): void
    {
        if ($licenseNumber === null) {
            return;
        }

        $query = Doctor::query()
            ->where('tenant_id', $tenantId)
            ->where('license_number', $licenseNumber);

        if ($ignoreDoctorId !== null) {
            $query->whereKeyNot($ignoreDoctorId);
        }

        if ($query->exists()) {
            throw new HttpException(422, 'License number already exists in this tenant.');
        }
    }

    private function resolveLinkedUser(mixed $userId, int $tenantId, int $branchId, ?int $ignoreDoctorId): ?User
    {
        if ($userId === null) {
            return null;
        }

        $user = User::query()
            ->whereKey((int) $userId)
            ->where('tenant_id', $tenantId)
            ->where('branch_id', $branchId)
            ->first();

        if ($user === null) {
            throw new HttpException(422, 'Linked user is outside tenant/branch scope.');
        }

        $doctorQuery = Doctor::query()->where('user_id', $user->id);
        if ($ignoreDoctorId !== null) {
            $doctorQuery->whereKeyNot($ignoreDoctorId);
        }

        if ($doctorQuery->exists()) {
            throw new HttpException(422, 'Linked user already has a doctor profile.');
        }

        return $user;
    }
}
