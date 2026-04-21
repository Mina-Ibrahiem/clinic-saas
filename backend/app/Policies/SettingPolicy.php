<?php

namespace App\Policies;

use App\Models\Setting;
use App\Models\User;
use App\Policies\Concerns\HandlesTenantScope;

class SettingPolicy
{
    use HandlesTenantScope;

    public function viewAny(User $user): bool
    {
        return $this->canUsePermission($user, ['settings.view', 'settings.manage']);
    }

    public function view(User $user, Setting $setting): bool
    {
        return $this->canUsePermission($user, ['settings.view', 'settings.manage'])
            && $this->isInTenantScope($user, $setting)
            && $this->isInBranchScope($user, $setting->branch_id);
    }

    public function update(User $user): bool
    {
        if ($user->hasRole('doctor')) {
            return false;
        }

        return $this->canUsePermission($user, 'settings.manage');
    }
}
