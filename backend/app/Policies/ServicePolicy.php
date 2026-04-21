<?php

namespace App\Policies;

use App\Models\Service;
use App\Models\User;
use App\Policies\Concerns\HandlesTenantScope;

class ServicePolicy
{
    use HandlesTenantScope;

    public function viewAny(User $user): bool
    {
        return $this->canUsePermission($user, ['services.manage', 'appointments.view', 'billing.view']);
    }

    public function view(User $user, Service $service): bool
    {
        if (! $this->canUsePermission($user, ['services.manage', 'appointments.view', 'billing.view'])) {
            return false;
        }

        return $this->isInTenantScope($user, $service)
            && $this->isInBranchScope($user, $service->branch_id);
    }

    public function create(User $user): bool
    {
        if ($user->hasRole('doctor')) {
            return false;
        }

        return $this->canUsePermission($user, 'services.manage');
    }

    public function update(User $user, Service $service): bool
    {
        if ($user->hasRole('doctor')) {
            return false;
        }

        return $this->canUsePermission($user, 'services.manage')
            && $this->isInTenantScope($user, $service)
            && $this->isInBranchScope($user, $service->branch_id);
    }

    public function delete(User $user, Service $service): bool
    {
        return $this->update($user, $service);
    }
}
