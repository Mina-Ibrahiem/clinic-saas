<?php

namespace App\Policies;

use App\Models\Doctor;
use App\Models\User;
use App\Policies\Concerns\HandlesTenantScope;

class DoctorPolicy
{
    use HandlesTenantScope;

    public function viewAny(User $user): bool
    {
        return $this->canUsePermission($user, ['doctors.view', 'appointments.view']);
    }

    public function view(User $user, Doctor $doctor): bool
    {
        if (! $this->canUsePermission($user, ['doctors.view', 'appointments.view'])) {
            return false;
        }

        if (! $this->isInTenantScope($user, $doctor) || ! $this->isInBranchScope($user, $doctor->branch_id)) {
            return false;
        }

        if ($user->hasRole('doctor')) {
            return $doctor->user_id !== null && (int) $doctor->user_id === (int) $user->id;
        }

        return true;
    }

    public function create(User $user): bool
    {
        if ($user->hasRole('doctor')) {
            return false;
        }

        return $this->canUsePermission($user, 'doctors.manage');
    }

    public function update(User $user, Doctor $doctor): bool
    {
        if ($user->hasRole('doctor')) {
            return false;
        }

        return $this->canUsePermission($user, 'doctors.manage')
            && $this->isInTenantScope($user, $doctor)
            && $this->isInBranchScope($user, $doctor->branch_id);
    }

    public function delete(User $user, Doctor $doctor): bool
    {
        return $this->update($user, $doctor);
    }
}
