<?php

namespace App\Policies;

use App\Models\Invoice;
use App\Models\User;
use App\Policies\Concerns\HandlesTenantScope;

class InvoicePolicy
{
    use HandlesTenantScope;

    public function viewAny(User $user): bool
    {
        return $this->canUsePermission($user, ['invoices.view', 'billing.view']);
    }

    public function view(User $user, Invoice $invoice): bool
    {
        if (! $this->canUsePermission($user, ['invoices.view', 'billing.view'])) {
            return false;
        }

        if (! $this->isInTenantScope($user, $invoice) || ! $this->isInBranchScope($user, $invoice->branch_id)) {
            return false;
        }

        if ($user->hasRole('doctor')) {
            return $invoice->appointment !== null && $this->isDoctorOnAppointment($user, $invoice->appointment);
        }

        return true;
    }

    public function create(User $user): bool
    {
        if ($user->hasRole('doctor')) {
            return false;
        }

        return $this->canUsePermission($user, ['invoices.manage', 'billing.manage']);
    }

    public function update(User $user, Invoice $invoice): bool
    {
        if ($user->hasRole('doctor')) {
            return false;
        }

        return $this->canUsePermission($user, ['invoices.manage', 'billing.manage'])
            && $this->isInTenantScope($user, $invoice)
            && $this->isInBranchScope($user, $invoice->branch_id);
    }

    public function delete(User $user, Invoice $invoice): bool
    {
        return $this->update($user, $invoice);
    }
}
