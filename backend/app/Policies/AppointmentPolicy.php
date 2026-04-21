<?php

namespace App\Policies;

use App\Models\Appointment;
use App\Models\User;
use App\Policies\Concerns\HandlesTenantScope;

class AppointmentPolicy
{
    use HandlesTenantScope;

    public function viewAny(User $user): bool
    {
        return $this->canUsePermission($user, 'appointments.view');
    }

    public function view(User $user, Appointment $appointment): bool
    {
        if (! $this->canUsePermission($user, 'appointments.view')) {
            return false;
        }

        if (! $this->isInTenantScope($user, $appointment) || ! $this->isInBranchScope($user, $appointment->branch_id)) {
            return false;
        }

        if ($user->hasRole('doctor')) {
            return $this->isDoctorOnAppointment($user, $appointment);
        }

        return true;
    }

    public function create(User $user): bool
    {
        if ($user->hasRole('doctor')) {
            return false;
        }

        return $this->canUsePermission($user, 'appointments.manage');
    }

    public function update(User $user, Appointment $appointment): bool
    {
        if (! $this->canUsePermission($user, 'appointments.manage')) {
            return false;
        }

        if (! $this->isInTenantScope($user, $appointment) || ! $this->isInBranchScope($user, $appointment->branch_id)) {
            return false;
        }

        if ($user->hasRole('doctor')) {
            return $this->isDoctorOnAppointment($user, $appointment);
        }

        return true;
    }

    public function delete(User $user, Appointment $appointment): bool
    {
        if ($user->hasRole('doctor')) {
            return false;
        }

        return $this->update($user, $appointment);
    }
}
