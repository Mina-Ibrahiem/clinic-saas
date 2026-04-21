<?php

namespace App\Services\Services;

use App\Enums\ServiceStatus;
use App\Models\Branch;
use App\Models\Service;
use App\Models\User;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;
use Illuminate\Pagination\LengthAwarePaginator;
use Symfony\Component\HttpKernel\Exception\HttpException;

class ServiceService
{
    public function paginate(User $user, Request $request): LengthAwarePaginator
    {
        $perPage = max(1, min(100, (int) $request->integer('per_page', 15)));
        $query = Service::query()
            ->with(['branch:id,name,code', 'tenant:id,uuid,name,slug'])
            ->withCount(['appointments', 'invoiceItems']);

        $this->applyAccessScope($query, $user);
        $this->applyFilters($query, $request);
        $this->applySorting($query, $request);

        return $query->paginate($perPage)->appends($request->query());
    }

    public function findOrFail(User $user, Service $service): Service
    {
        $service->loadMissing(['branch:id,name,code', 'tenant:id,uuid,name,slug'])
            ->loadCount(['appointments', 'invoiceItems']);

        if (! $this->canAccessService($user, $service)) {
            throw new HttpException(404, 'Service not found.');
        }

        return $service;
    }

    /**
     * @param array<string, mixed> $payload
     */
    public function create(User $user, array $payload): Service
    {
        [$tenantId, $branchId] = $this->resolveTenantAndBranch($user, $payload);

        $status = (string) ($payload['status'] ?? ServiceStatus::Active->value);
        $code = $this->normalizeCode($payload['code'] ?? null);

        $this->ensureUniqueActiveCode($tenantId, $branchId, $code, $status, null);

        $service = Service::query()->create([
            'tenant_id' => $tenantId,
            'branch_id' => $branchId,
            'name' => $payload['name'],
            'code' => $code,
            'description' => $payload['description'] ?? null,
            'price' => $payload['price'],
            'duration_minutes' => $payload['duration_minutes'] ?? null,
            'status' => $status,
        ]);

        return $service->load(['branch:id,name,code', 'tenant:id,uuid,name,slug']);
    }

    /**
     * @param array<string, mixed> $payload
     */
    public function update(User $user, Service $service, array $payload): Service
    {
        if (array_key_exists('branch_id', $payload)) {
            [, $branchId] = $this->resolveTenantAndBranch($user, $payload, (int) $service->tenant_id);
            $service->branch_id = $branchId;
        }

        $newStatus = (string) ($payload['status'] ?? ($service->status?->value ?? $service->status));
        $newCode = array_key_exists('code', $payload)
            ? $this->normalizeCode($payload['code'])
            : $this->normalizeCode($service->code);

        $this->ensureUniqueActiveCode((int) $service->tenant_id, (int) $service->branch_id, $newCode, $newStatus, (int) $service->id);

        $service->fill([
            'name' => $payload['name'] ?? $service->name,
            'code' => $newCode,
            'description' => $payload['description'] ?? $service->description,
            'price' => $payload['price'] ?? $service->price,
            'duration_minutes' => $payload['duration_minutes'] ?? $service->duration_minutes,
            'status' => $newStatus,
        ]);
        $service->save();

        return $service->load(['branch:id,name,code', 'tenant:id,uuid,name,slug']);
    }

    public function delete(Service $service): void
    {
        $service->delete();
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
                $q->where('name', 'like', '%'.$search.'%')
                    ->orWhere('code', 'like', '%'.$search.'%')
                    ->orWhere('description', 'like', '%'.$search.'%');
            });
        }

        if ($status = $request->query('status')) {
            $query->where('status', (string) $status);
        }

        if ($branchId = $request->query('branch_id')) {
            $query->where('branch_id', (int) $branchId);
        }

        if ($priceMin = $request->query('price_min')) {
            $query->where('price', '>=', (float) $priceMin);
        }

        if ($priceMax = $request->query('price_max')) {
            $query->where('price', '<=', (float) $priceMax);
        }
    }

    private function applySorting(Builder $query, Request $request): void
    {
        $sort = (string) $request->query('sort', 'latest');

        match ($sort) {
            'oldest' => $query->oldest('created_at'),
            'name' => $query->orderBy('name'),
            'price' => $query->orderBy('price'),
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

    private function canAccessService(User $user, Service $service): bool
    {
        $query = Service::query()->whereKey($service->id);
        $this->applyAccessScope($query, $user);

        return $query->exists();
    }

    private function normalizeCode(?string $code): ?string
    {
        if ($code === null) {
            return null;
        }

        $trimmed = strtoupper(trim($code));

        return $trimmed === '' ? null : $trimmed;
    }

    private function ensureUniqueActiveCode(int $tenantId, int $branchId, ?string $code, string $status, ?int $ignoreServiceId): void
    {
        if ($code === null || $status !== ServiceStatus::Active->value) {
            return;
        }

        $query = Service::query()
            ->where('tenant_id', $tenantId)
            ->where('branch_id', $branchId)
            ->where('code', $code)
            ->where('status', ServiceStatus::Active->value);

        if ($ignoreServiceId !== null) {
            $query->whereKeyNot($ignoreServiceId);
        }

        if ($query->exists()) {
            throw new HttpException(422, 'Service code already exists for this branch.');
        }
    }
}
