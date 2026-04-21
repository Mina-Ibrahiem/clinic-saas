<?php

namespace App\Services\Analytics;

use App\Models\Branch;
use App\Models\User;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;
use Symfony\Component\HttpKernel\Exception\HttpException;

class ScopeResolver
{
    /**
     * @return array{0:?int,1:?int}
     */
    public function resolveFromRequest(User $user, Request $request): array
    {
        $requestedTenantId = $request->query('tenant_id');
        $tenantId = null;

        if ($user->hasRole('super_admin')) {
            $tenantId = $requestedTenantId !== null ? (int) $requestedTenantId : ($user->tenant_id !== null ? (int) $user->tenant_id : null);
        } else {
            $tenantId = $user->tenant_id !== null ? (int) $user->tenant_id : null;
            if ($requestedTenantId !== null && $tenantId !== (int) $requestedTenantId) {
                throw new HttpException(422, 'Invalid tenant scope.');
            }
        }

        $requestedBranchId = $request->query('branch_id');
        $branchId = null;

        if ($user->hasRole('super_admin')) {
            $branchId = $requestedBranchId !== null ? (int) $requestedBranchId : null;
        } elseif ($user->hasRole('clinic_owner')) {
            $branchId = $requestedBranchId !== null ? (int) $requestedBranchId : null;
        } else {
            $branchId = $user->branch_id !== null ? (int) $user->branch_id : null;
            if ($requestedBranchId !== null && $branchId !== (int) $requestedBranchId) {
                throw new HttpException(422, 'Invalid branch scope.');
            }
        }

        if ($branchId !== null) {
            $branch = Branch::query()->find($branchId);
            if ($branch === null) {
                throw new HttpException(422, 'Invalid branch.');
            }

            if ($tenantId !== null && (int) $branch->tenant_id !== $tenantId) {
                throw new HttpException(422, 'Branch does not belong to tenant scope.');
            }
        }

        return [$tenantId, $branchId];
    }

    public function apply(Builder $query, ?int $tenantId, ?int $branchId): void
    {
        if ($tenantId !== null) {
            $query->where($query->getModel()->getTable().'.tenant_id', $tenantId);
        }

        if ($branchId !== null) {
            $query->where($query->getModel()->getTable().'.branch_id', $branchId);
        }
    }
}
