<?php

namespace App\Policies;

use App\Models\Payment;
use App\Models\User;
use App\Policies\Concerns\HandlesTenantScope;

class PaymentPolicy
{
    use HandlesTenantScope;

    public function viewAny(User $user): bool
    {
        return $this->canUsePermission($user, ['payments.view', 'billing.view']);
    }

    public function view(User $user, Payment $payment): bool
    {
        return $this->canUsePermission($user, ['payments.view', 'billing.view'])
            && $this->isInTenantScope($user, $payment)
            && $this->isInBranchScope($user, $payment->branch_id);
    }

    public function create(User $user): bool
    {
        if ($user->hasRole('doctor')) {
            return false;
        }

        return $this->canUsePermission($user, ['payments.manage', 'billing.manage']);
    }

    public function update(User $user, Payment $payment): bool
    {
        if ($user->hasRole('doctor')) {
            return false;
        }

        return $this->canUsePermission($user, ['payments.manage', 'billing.manage'])
            && $this->isInTenantScope($user, $payment)
            && $this->isInBranchScope($user, $payment->branch_id);
    }

    public function delete(User $user, Payment $payment): bool
    {
        return $this->update($user, $payment);
    }
}
