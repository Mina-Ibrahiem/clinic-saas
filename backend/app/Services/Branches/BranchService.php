<?php

namespace App\Services\Branches;

use App\Enums\BranchStatus;
use App\Models\Branch;
use App\Models\User;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;
use Illuminate\Pagination\LengthAwarePaginator;
use Symfony\Component\HttpKernel\Exception\HttpException;

class BranchService
{
    public function paginate(User $user, Request $request): LengthAwarePaginator
    {
        $perPage = max(1, min(100, (int) $request->integer('per_page', 15)));
        $query = Branch::query()
            ->with('tenant:id,uuid,name,slug')
            ->withCount(['users', 'patients', 'doctors', 'appointments', 'invoices']);

        $this->applyAccessScope($query, $user);
        $this->applyFilters($query, $request);
        $this->applySorting($query, $request);

        return $query->paginate($perPage)->appends($request->query());
    }

    public function findOrFail(User $user, Branch $branch): Branch
    {
        if (! $this->canAccessBranch($user, $branch)) {
            throw new HttpException(404, 'Branch not found.');
        }

        return $branch->loadMissing('tenant:id,uuid,name,slug')
            ->loadCount(['users', 'patients', 'doctors', 'appointments', 'invoices']);
    }

    /**
     * @param array<string, mixed> $payload
     */
    public function create(User $user, array $payload): Branch
    {
        $tenantId = $this->resolveTenantId($user, $payload);
        $code = $this->normalizeCode($payload['code'] ?? null);
        $status = $payload['status'] ?? BranchStatus::Active->value;

        $this->ensureUniqueCode($tenantId, $code, null);

        $branch = Branch::query()->create([
            'tenant_id' => $tenantId,
            'name' => trim((string) $payload['name']),
            'code' => $code,
            'phone' => $payload['phone'] ?? null,
            'email' => $payload['email'] ?? null,
            'address' => $payload['address'] ?? null,
            'status' => $status,
        ]);

        return $branch->load('tenant:id,uuid,name,slug');
    }

    /**
     * @param array<string, mixed> $payload
     */
    public function update(User $user, Branch $branch, array $payload): Branch
    {
        if (! $this->canAccessBranch($user, $branch)) {
            throw new HttpException(404, 'Branch not found.');
        }

        $code = array_key_exists('code', $payload)
            ? $this->normalizeCode($payload['code'])
            : $this->normalizeCode($branch->code);

        $this->ensureUniqueCode((int) $branch->tenant_id, $code, (int) $branch->id);

        $branch->fill([
            'name' => $payload['name'] ?? $branch->name,
            'code' => $code,
            'phone' => array_key_exists('phone', $payload) ? $payload['phone'] : $branch->phone,
            'email' => array_key_exists('email', $payload) ? $payload['email'] : $branch->email,
            'address' => array_key_exists('address', $payload) ? $payload['address'] : $branch->address,
            'status' => $payload['status'] ?? $branch->status,
        ]);
        $branch->save();

        return $branch->load('tenant:id,uuid,name,slug');
    }

    public function delete(User $user, Branch $branch): void
    {
        if (! $this->canAccessBranch($user, $branch)) {
            throw new HttpException(404, 'Branch not found.');
        }

        $inUse = $branch->users()->exists()
            || $branch->patients()->exists()
            || $branch->doctors()->exists()
            || $branch->services()->exists()
            || $branch->appointments()->exists()
            || $branch->invoices()->exists()
            || $branch->payments()->exists()
            || $branch->notes()->exists();

        if ($inUse) {
            throw new HttpException(422, 'Cannot delete branch that is already in use.');
        }

        $branch->delete();
    }

    private function applyAccessScope(Builder $query, User $user): void
    {
        if (! $user->hasRole('super_admin') && $user->tenant_id !== null) {
            $query->where('tenant_id', $user->tenant_id);
        }

        if (! $user->hasRole(['super_admin', 'clinic_owner']) && $user->branch_id !== null) {
            $query->whereKey($user->branch_id);
        }
    }

    private function applyFilters(Builder $query, Request $request): void
    {
        if ($search = trim((string) $request->query('search', ''))) {
            $query->where(function (Builder $q) use ($search): void {
                $q->where('name', 'like', '%'.$search.'%')
                    ->orWhere('code', 'like', '%'.$search.'%')
                    ->orWhere('phone', 'like', '%'.$search.'%')
                    ->orWhere('email', 'like', '%'.$search.'%');
            });
        }

        if ($status = $request->query('status')) {
            $query->where('status', (string) $status);
        }
    }

    private function applySorting(Builder $query, Request $request): void
    {
        $sort = (string) $request->query('sort', 'latest');

        match ($sort) {
            'oldest' => $query->oldest('created_at'),
            'name' => $query->orderBy('name'),
            default => $query->latest('created_at'),
        };
    }

    /**
     * @param array<string,mixed> $payload
     */
    private function resolveTenantId(User $user, array $payload): int
    {
        if ($user->hasRole('super_admin')) {
            $tenantId = (int) ($payload['tenant_id'] ?? $user->tenant_id ?? 0);
        } else {
            $tenantId = (int) ($user->tenant_id ?? 0);
            if (array_key_exists('tenant_id', $payload) && $payload['tenant_id'] !== null && (int) $payload['tenant_id'] !== $tenantId) {
                throw new HttpException(422, 'Invalid tenant scope.');
            }
        }

        if ($tenantId <= 0) {
            throw new HttpException(422, 'Tenant context is required.');
        }

        return $tenantId;
    }

    private function canAccessBranch(User $user, Branch $branch): bool
    {
        $query = Branch::query()->whereKey($branch->id);
        $this->applyAccessScope($query, $user);

        return $query->exists();
    }

    private function normalizeCode(mixed $code): ?string
    {
        if ($code === null) {
            return null;
        }

        $normalized = strtoupper(trim((string) $code));

        return $normalized === '' ? null : $normalized;
    }

    private function ensureUniqueCode(int $tenantId, ?string $code, ?int $ignoreBranchId): void
    {
        if ($code === null) {
            return;
        }

        $query = Branch::withTrashed()
            ->where('tenant_id', $tenantId)
            ->where('code', $code);

        if ($ignoreBranchId !== null) {
            $query->whereKeyNot($ignoreBranchId);
        }

        if ($query->exists()) {
            throw new HttpException(422, 'Branch code already exists in this tenant.');
        }
    }
}
