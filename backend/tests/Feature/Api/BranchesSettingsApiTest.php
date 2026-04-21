<?php

namespace Tests\Feature\Api;

use App\Enums\UserStatus;
use App\Models\Branch;
use App\Models\Role;
use App\Models\Tenant;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class BranchesSettingsApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed();
    }

    public function test_owner_can_list_create_update_and_delete_branch_when_unused(): void
    {
        $headers = $this->authHeaders('owner@clinic.test', 'password');
        $context = $this->getJson('/api/auth/me', $headers)->json('data');
        $tenantId = (int) $context['tenant']['id'];

        $list = $this->getJson('/api/branches?search=Main&sort=name&per_page=5', $headers);
        $list->assertOk()->assertJsonPath('data.pagination.per_page', 5);

        $create = $this->postJson('/api/branches', [
            'name' => 'Al Barsha Branch',
            'code' => 'BARSHA',
            'phone' => '+971500123456',
            'email' => 'barsha@demo-clinic.test',
            'address' => 'Al Barsha, Dubai',
            'status' => 'active',
        ], $headers);

        $create->assertCreated()
            ->assertJsonPath('data.tenant_id', $tenantId)
            ->assertJsonPath('data.code', 'BARSHA');

        $branchId = (int) $create->json('data.id');

        $update = $this->putJson('/api/branches/'.$branchId, [
            'name' => 'Al Barsha Updated',
            'status' => 'inactive',
        ], $headers);

        $update->assertOk()
            ->assertJsonPath('data.name', 'Al Barsha Updated')
            ->assertJsonPath('data.status', 'inactive');

        $delete = $this->deleteJson('/api/branches/'.$branchId, [], $headers);
        $delete->assertOk()->assertJsonPath('success', true);

        $this->assertSoftDeleted('branches', ['id' => $branchId]);
    }

    public function test_branch_delete_is_blocked_when_branch_is_in_use(): void
    {
        $headers = $this->authHeaders('owner@clinic.test', 'password');
        $inUseBranch = Branch::query()->where('code', 'MAIN')->firstOrFail();

        $delete = $this->deleteJson('/api/branches/'.$inUseBranch->id, [], $headers);
        $delete->assertStatus(422)
            ->assertJsonPath('message', 'Cannot delete branch that is already in use.');
    }

    public function test_settings_get_update_and_branch_fallback_behavior(): void
    {
        $headers = $this->authHeaders('owner@clinic.test', 'password');
        $branch = Branch::query()->where('code', 'MAIN')->firstOrFail();

        $tenantUpdate = $this->putJson('/api/settings', [
            'settings' => [
                'clinic_name' => 'Demo Medical Center HQ',
                'timezone' => 'Asia/Dubai',
                'currency' => 'AED',
                'invoice_prefix' => 'DMC',
                'invoice_due_days' => 14,
            ],
        ], $headers);
        $tenantUpdate->assertOk();

        $branchUpdate = $this->putJson('/api/settings/clinic-profile', [
            'branch_id' => $branch->id,
            'clinic_name' => 'Main Clinic Branch',
        ], $headers);
        $branchUpdate->assertOk();

        $branchInvoiceUpdate = $this->putJson('/api/settings/invoice', [
            'branch_id' => $branch->id,
            'invoice_prefix' => 'MAIN',
        ], $headers);
        $branchInvoiceUpdate->assertOk();

        $branchSettings = $this->getJson('/api/settings?branch_id='.$branch->id, $headers);
        $branchSettings->assertOk()
            ->assertJsonPath('data.general.clinic_name', 'Main Clinic Branch')
            ->assertJsonPath('data.invoice.invoice_prefix', 'MAIN')
            ->assertJsonPath('data.invoice.invoice_due_days', 14);

        $tenantSettings = $this->getJson('/api/settings', $headers);
        $tenantSettings->assertOk()
            ->assertJsonPath('data.general.clinic_name', 'Demo Medical Center HQ')
            ->assertJsonPath('data.invoice.invoice_prefix', 'DMC');
    }

    public function test_authorization_for_branches_and_settings(): void
    {
        $ownerHeaders = $this->authHeaders('owner@clinic.test', 'password');
        $context = $this->getJson('/api/auth/me', $ownerHeaders)->json('data');

        $receptionist = User::query()->create([
            'tenant_id' => $context['tenant']['id'],
            'branch_id' => $context['branch']['id'],
            'full_name' => 'Branch Reception',
            'email' => 'branch.reception@test.local',
            'phone' => '+971500077001',
            'password' => Hash::make('password'),
            'status' => UserStatus::Active,
        ]);
        $receptionist->roles()->sync([Role::query()->where('slug', 'receptionist')->firstOrFail()->id]);

        $doctorHeaders = $this->authHeaders('doctor@clinic.test', 'password');
        $receptionHeaders = $this->authHeaders('branch.reception@test.local', 'password');

        $doctorGetSettings = $this->getJson('/api/settings', $doctorHeaders);
        $doctorGetSettings->assertOk();

        $doctorCreateBranch = $this->postJson('/api/branches', [
            'name' => 'Not Allowed',
        ], $doctorHeaders);
        $doctorCreateBranch->assertForbidden();

        $doctorUpdateSettings = $this->putJson('/api/settings', [
            'settings' => ['clinic_name' => 'Doctor cannot update'],
        ], $doctorHeaders);
        $doctorUpdateSettings->assertForbidden();

        $receptionListBranches = $this->getJson('/api/branches', $receptionHeaders);
        $receptionListBranches->assertOk();

        $receptionGetSettings = $this->getJson('/api/settings', $receptionHeaders);
        $receptionGetSettings->assertOk();

        $receptionUpdateSettings = $this->putJson('/api/settings', [
            'settings' => ['clinic_name' => 'Blocked'],
        ], $receptionHeaders);
        $receptionUpdateSettings->assertForbidden();
    }

    public function test_tenant_aware_access_blocks_cross_tenant_branch_access(): void
    {
        $ownerHeaders = $this->authHeaders('owner@clinic.test', 'password');
        $otherTenant = Tenant::factory()->create();
        $foreignBranch = Branch::factory()->create([
            'tenant_id' => $otherTenant->id,
            'name' => 'Foreign Tenant Branch',
            'code' => 'FRGN01',
        ]);

        $show = $this->getJson('/api/branches/'.$foreignBranch->id, $ownerHeaders);
        $show->assertForbidden();
    }

    /**
     * @return array<string,string>
     */
    private function authHeaders(string $email, string $password): array
    {
        $login = $this->postJson('/api/auth/login', [
            'email' => $email,
            'password' => $password,
        ]);
        $login->assertOk();
        $token = (string) $login->json('data.access_token');

        return [
            'Authorization' => 'Bearer '.$token,
            'Accept' => 'application/json',
        ];
    }
}
