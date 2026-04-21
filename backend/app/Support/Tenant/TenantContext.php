<?php

namespace App\Support\Tenant;

/**
 * Placeholder for multi-tenant / SaaS isolation (organization_id, branch_id).
 */
final class TenantContext
{
    public function __construct(
        public readonly ?int $organizationId = null,
        public readonly ?int $branchId = null,
    ) {
    }

    public static function empty(): self
    {
        return new self;
    }
}
