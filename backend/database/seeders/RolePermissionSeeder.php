<?php

namespace Database\Seeders;

use App\Models\Permission;
use App\Models\Role;
use Illuminate\Database\Seeder;

class RolePermissionSeeder extends Seeder
{
    public function run(): void
    {
        $rows = [
            ['name' => 'Manage tenants', 'slug' => 'tenants.manage', 'description' => 'Platform / SaaS tenant administration'],
            ['name' => 'Manage users', 'slug' => 'users.manage', 'description' => 'Invite, update, deactivate users'],
            ['name' => 'Manage roles', 'slug' => 'roles.manage', 'description' => 'Assign roles and permissions'],
            ['name' => 'View patients', 'slug' => 'patients.view', 'description' => 'Read patient records'],
            ['name' => 'Manage patients', 'slug' => 'patients.manage', 'description' => 'Create and edit patients'],
            ['name' => 'View appointments', 'slug' => 'appointments.view', 'description' => 'Read schedule'],
            ['name' => 'Manage appointments', 'slug' => 'appointments.manage', 'description' => 'Create, reschedule, cancel'],
            ['name' => 'View doctors', 'slug' => 'doctors.view', 'description' => 'Read doctor profiles'],
            ['name' => 'Manage doctors', 'slug' => 'doctors.manage', 'description' => 'Create and edit doctors'],
            ['name' => 'View branches', 'slug' => 'branches.view', 'description' => 'Read branch profiles'],
            ['name' => 'Manage branches', 'slug' => 'branches.manage', 'description' => 'Create and edit branches'],
            ['name' => 'Manage services', 'slug' => 'services.manage', 'description' => 'Configure services and pricing'],
            ['name' => 'View invoices', 'slug' => 'invoices.view', 'description' => 'Read invoices and invoice items'],
            ['name' => 'Manage invoices', 'slug' => 'invoices.manage', 'description' => 'Create and edit invoices'],
            ['name' => 'View payments', 'slug' => 'payments.view', 'description' => 'Read payments'],
            ['name' => 'Manage payments', 'slug' => 'payments.manage', 'description' => 'Create and reverse payments'],
            ['name' => 'View dashboard', 'slug' => 'dashboard.view', 'description' => 'View clinic dashboard KPIs'],
            ['name' => 'View billing', 'slug' => 'billing.view', 'description' => 'Read invoices and payments'],
            ['name' => 'Manage billing', 'slug' => 'billing.manage', 'description' => 'Create invoices, record payments'],
            ['name' => 'View reports', 'slug' => 'reports.view', 'description' => 'Operational and financial reports'],
            ['name' => 'View settings', 'slug' => 'settings.view', 'description' => 'Read clinic and branch settings'],
            ['name' => 'Manage settings', 'slug' => 'settings.manage', 'description' => 'Clinic and branch configuration'],
        ];

        $bySlug = collect($rows)->mapWithKeys(function (array $row) {
            $p = Permission::query()->firstOrCreate(
                ['slug' => $row['slug']],
                ['name' => $row['name'], 'description' => $row['description']]
            );

            return [$row['slug'] => $p];
        });

        $allSlugs = collect($rows)->pluck('slug')->all();

        $matrix = [
            'super_admin' => ['name' => 'Super Admin', 'permissions' => $allSlugs],
            'clinic_owner' => ['name' => 'Clinic Owner', 'permissions' => [
                'users.manage',
                'roles.manage',
                'patients.view',
                'patients.manage',
                'appointments.view',
                'appointments.manage',
                'doctors.view',
                'doctors.manage',
                'branches.view',
                'branches.manage',
                'services.manage',
                'invoices.view',
                'invoices.manage',
                'payments.view',
                'payments.manage',
                'dashboard.view',
                'billing.view',
                'billing.manage',
                'reports.view',
                'settings.view',
                'settings.manage',
            ]],
            'doctor' => ['name' => 'Doctor', 'permissions' => [
                'patients.view',
                'appointments.view',
                'appointments.manage',
                'doctors.view',
                'services.manage',
            ]],
            'receptionist' => ['name' => 'Receptionist', 'permissions' => [
                'patients.view',
                'patients.manage',
                'appointments.view',
                'appointments.manage',
                'doctors.view',
                'branches.view',
                'dashboard.view',
                'billing.view',
                'invoices.view',
                'invoices.manage',
                'settings.view',
            ]],
            'accountant' => ['name' => 'Accountant', 'permissions' => [
                'doctors.view',
                'branches.view',
                'dashboard.view',
                'invoices.view',
                'invoices.manage',
                'payments.view',
                'payments.manage',
                'billing.view',
                'billing.manage',
                'reports.view',
                'settings.view',
            ]],
        ];

        foreach ($matrix as $slug => $meta) {
            $role = Role::query()->firstOrCreate(
                ['slug' => $slug],
                [
                    'name' => $meta['name'],
                    'description' => 'Seeded role: '.$slug,
                ]
            );

            $ids = collect($meta['permissions'])
                ->map(fn (string $s) => $bySlug[$s]->id ?? null)
                ->filter()
                ->values()
                ->all();

            $role->permissions()->sync($ids);
        }
    }
}
