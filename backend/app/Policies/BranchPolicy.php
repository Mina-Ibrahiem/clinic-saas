<?php

namespace App\Policies;

use App\Models\Branch;
use App\Models\User;
use App\Policies\Concerns\HandlesTenantScope;

class BranchPolicy
{
    use HandlesTenantScope;

    public function viewAny(User $user): bool
    {
        return $this->canUsePermission($user, 'branches.view');
    }

    public function view(User $user, Branch $branch): bool
    {
        return $this->canUsePermission($user, 'branches.view')
            && $this->isInTenantScope($user, $branch)
            && $this->isInBranchScope($user, $branch->id);
    }

    public function create(User $user): bool
    {
        if ($user->hasRole('doctor')) {
            return false;
        }

        return $this->canUsePermission($user, 'branches.manage');
    }

    public function update(User $user, Branch $branch): bool
    {
        if ($user->hasRole('doctor')) {
            return false;
        }

        return $this->canUsePermission($user, 'branches.manage')
            && $this->isInTenantScope($user, $branch);
    }

    public function delete(User $user, Branch $branch): bool
    {
        return $this->update($user, $branch);
    }
}
