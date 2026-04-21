<?php

namespace App\Policies\Concerns;

use App\Models\Appointment;
use App\Models\Patient;
use App\Models\User;
use Illuminate\Database\Eloquent\Model;

/**
 * Shared helpers for branch / tenant scoped policies.
 */
trait HandlesTenantScope
{
    protected function isInTenantScope(User $user, Model $model): bool
    {
        if (!isset($model->tenant_id)) {
            return true;
        }

        if ($user->tenant_id === null) {
            return true;
        }

        return (int) $model->tenant_id === (int) $user->tenant_id;
    }

    protected function isInBranchScope(User $user, ?int $branchId): bool
    {
        if ($branchId === null || $user->branch_id === null) {
            return true;
        }

        if ($user->hasRole(['clinic_owner', 'super_admin'])) {
            return true;
        }

        return (int) $branchId === (int) $user->branch_id;
    }

    protected function canUsePermission(User $user, string|array $permissions): bool
    {
        return $user->hasPermission($permissions);
    }

    protected function isDoctorOnAppointment(User $user, Appointment $appointment): bool
    {
        return $user->doctorProfile !== null
            && (int) $appointment->doctor_id === (int) $user->doctorProfile->id;
    }

    protected function isDoctorLinkedToPatient(User $user, Patient $patient): bool
    {
        if ($user->doctorProfile === null) {
            return false;
        }

        return $patient->appointments()
            ->where('doctor_id', $user->doctorProfile->id)
            ->exists();
    }
}
