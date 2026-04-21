<?php

namespace App\Policies;

use App\Models\Patient;
use App\Models\User;
use App\Policies\Concerns\HandlesTenantScope;

class PatientPolicy
{
    use HandlesTenantScope;

    public function viewAny(User $user): bool
    {
        return $this->canUsePermission($user, 'patients.view');
    }

    public function view(User $user, Patient $patient): bool
    {
        if (! $this->canUsePermission($user, 'patients.view')) {
            return false;
        }

        if (! $this->isInTenantScope($user, $patient) || ! $this->isInBranchScope($user, $patient->branch_id)) {
            return false;
        }

        if ($user->hasRole('doctor')) {
            return $this->isDoctorLinkedToPatient($user, $patient);
        }

        return true;
    }

    public function create(User $user): bool
    {
        return $this->canUsePermission($user, 'patients.manage');
    }

    public function update(User $user, Patient $patient): bool
    {
        return $this->canUsePermission($user, 'patients.manage')
            && $this->isInTenantScope($user, $patient)
            && $this->isInBranchScope($user, $patient->branch_id);
    }

    public function delete(User $user, Patient $patient): bool
    {
        return $this->update($user, $patient);
    }
}
