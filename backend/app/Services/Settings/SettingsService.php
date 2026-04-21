<?php

namespace App\Services\Settings;

use App\Models\Branch;
use App\Models\Setting;
use App\Models\User;
use Illuminate\Http\Request;
use Symfony\Component\HttpKernel\Exception\HttpException;

class SettingsService
{
    /** @var array<int,string> */
    private const GENERAL_KEYS = [
        'clinic_name',
        'clinic_phone',
        'clinic_email',
        'clinic_address',
        'timezone',
        'currency',
    ];

    /** @var array<int,string> */
    private const CLINIC_PROFILE_KEYS = [
        'clinic_name',
        'clinic_phone',
        'clinic_email',
        'clinic_address',
        'timezone',
        'currency',
        'branding_logo_url',
        'branding_primary_color',
    ];

    /** @var array<int,string> */
    private const INVOICE_KEYS = [
        'invoice_prefix',
        'invoice_due_days',
        'tax_default',
        'invoice_footer',
    ];

    /** @var array<string,mixed> */
    private const DEFAULT_VALUES = [
        'clinic_name' => null,
        'clinic_phone' => null,
        'clinic_email' => null,
        'clinic_address' => null,
        'timezone' => 'Asia/Dubai',
        'currency' => 'AED',
        'branding_logo_url' => null,
        'branding_primary_color' => null,
        'invoice_prefix' => 'INV',
        'invoice_due_days' => 7,
        'tax_default' => 0,
        'invoice_footer' => null,
    ];

    /**
     * @return array<string,mixed>
     */
    public function getAll(User $user, Request $request): array
    {
        [$tenantId, $branchId] = $this->resolveScope($user, (array) $request->query());

        return $this->buildStructuredSettings($tenantId, $branchId);
    }

    /**
     * @param array<string,mixed> $payload
     * @return array<string,mixed>
     */
    public function updateAll(User $user, array $payload): array
    {
        [$tenantId, $branchId] = $this->resolveScope($user, $payload);
        $settings = $payload['settings'] ?? [];

        if (! is_array($settings) || $settings === []) {
            throw new HttpException(422, 'settings payload is required.');
        }

        $allowed = array_values(array_unique([
            ...self::GENERAL_KEYS,
            ...self::CLINIC_PROFILE_KEYS,
            ...self::INVOICE_KEYS,
        ]));

        $unknown = collect(array_keys($settings))
            ->reject(fn (string $key) => in_array($key, $allowed, true))
            ->values()
            ->all();

        if ($unknown !== []) {
            throw new HttpException(422, 'Unsupported setting keys: '.implode(', ', $unknown));
        }

        $this->upsertSettings($tenantId, $branchId, $settings);

        return $this->buildStructuredSettings($tenantId, $branchId);
    }

    /**
     * @return array<string,mixed>
     */
    public function getClinicProfile(User $user, Request $request): array
    {
        [$tenantId, $branchId] = $this->resolveScope($user, (array) $request->query());
        $resolved = $this->resolveSettingsValues($tenantId, $branchId, self::CLINIC_PROFILE_KEYS);

        return [
            'scope' => ['tenant_id' => $tenantId, 'branch_id' => $branchId],
            'clinic_profile' => $resolved,
        ];
    }

    /**
     * @param array<string,mixed> $payload
     * @return array<string,mixed>
     */
    public function updateClinicProfile(User $user, array $payload): array
    {
        [$tenantId, $branchId] = $this->resolveScope($user, $payload);
        $values = collect($payload)
            ->only(self::CLINIC_PROFILE_KEYS)
            ->all();

        if ($values === []) {
            throw new HttpException(422, 'No clinic profile settings provided.');
        }

        $this->upsertSettings($tenantId, $branchId, $values);

        return $this->getClinicProfile($user, new Request(['tenant_id' => $tenantId, 'branch_id' => $branchId]));
    }

    /**
     * @return array<string,mixed>
     */
    public function getInvoice(User $user, Request $request): array
    {
        [$tenantId, $branchId] = $this->resolveScope($user, (array) $request->query());
        $resolved = $this->resolveSettingsValues($tenantId, $branchId, self::INVOICE_KEYS);

        return [
            'scope' => ['tenant_id' => $tenantId, 'branch_id' => $branchId],
            'invoice' => $resolved,
        ];
    }

    /**
     * @param array<string,mixed> $payload
     * @return array<string,mixed>
     */
    public function updateInvoice(User $user, array $payload): array
    {
        [$tenantId, $branchId] = $this->resolveScope($user, $payload);
        $values = collect($payload)
            ->only(self::INVOICE_KEYS)
            ->all();

        if ($values === []) {
            throw new HttpException(422, 'No invoice settings provided.');
        }

        $this->upsertSettings($tenantId, $branchId, $values);

        return $this->getInvoice($user, new Request(['tenant_id' => $tenantId, 'branch_id' => $branchId]));
    }

    /**
     * @param array<string,mixed> $input
     * @return array{0:int,1:?int}
     */
    private function resolveScope(User $user, array $input): array
    {
        if ($user->hasRole('super_admin')) {
            $tenantId = (int) ($input['tenant_id'] ?? $user->tenant_id ?? 0);
        } else {
            $tenantId = (int) ($user->tenant_id ?? 0);
            if (array_key_exists('tenant_id', $input) && $input['tenant_id'] !== null && (int) $input['tenant_id'] !== $tenantId) {
                throw new HttpException(422, 'Invalid tenant scope.');
            }
        }

        if ($tenantId <= 0) {
            throw new HttpException(422, 'Tenant context is required.');
        }

        $requestedBranch = array_key_exists('branch_id', $input) ? $input['branch_id'] : null;
        if ($user->hasRole(['super_admin', 'clinic_owner'])) {
            $branchId = $requestedBranch !== null ? (int) $requestedBranch : null;
        } else {
            $branchId = $user->branch_id !== null ? (int) $user->branch_id : null;
            if ($requestedBranch !== null && $branchId !== (int) $requestedBranch) {
                throw new HttpException(422, 'Invalid branch scope.');
            }
        }

        if ($branchId !== null) {
            $branch = Branch::query()->find($branchId);
            if ($branch === null || (int) $branch->tenant_id !== $tenantId) {
                throw new HttpException(422, 'Invalid branch for tenant scope.');
            }
        }

        return [$tenantId, $branchId];
    }

    /**
     * @param array<int,string> $keys
     * @return array<string,mixed>
     */
    private function resolveSettingsValues(int $tenantId, ?int $branchId, array $keys): array
    {
        $rows = Setting::query()
            ->where('tenant_id', $tenantId)
            ->whereIn('key', $keys)
            ->when($branchId !== null, fn ($q) => $q->where(function ($sub) use ($branchId): void {
                $sub->whereNull('branch_id')->orWhere('branch_id', $branchId);
            }), fn ($q) => $q->whereNull('branch_id'))
            ->get();

        $tenantDefaults = [];
        $branchOverrides = [];
        foreach ($rows as $row) {
            $decoded = $this->decodeValue($row->value);
            if ($row->branch_id === null) {
                $tenantDefaults[$row->key] = $decoded;
            } elseif ($branchId !== null && (int) $row->branch_id === $branchId) {
                $branchOverrides[$row->key] = $decoded;
            }
        }

        $resolved = [];
        foreach ($keys as $key) {
            if (array_key_exists($key, $branchOverrides)) {
                $resolved[$key] = $branchOverrides[$key];
            } elseif (array_key_exists($key, $tenantDefaults)) {
                $resolved[$key] = $tenantDefaults[$key];
            } else {
                $resolved[$key] = self::DEFAULT_VALUES[$key] ?? null;
            }
        }

        return $resolved;
    }

    /**
     * @param array<string,mixed> $settings
     */
    private function upsertSettings(int $tenantId, ?int $branchId, array $settings): void
    {
        foreach ($settings as $key => $value) {
            Setting::query()->updateOrCreate(
                [
                    'tenant_id' => $tenantId,
                    'branch_id' => $branchId,
                    'key' => $key,
                ],
                [
                    'value' => $this->encodeValue($value),
                ]
            );
        }
    }

    /**
     * @return array<string,mixed>
     */
    private function buildStructuredSettings(int $tenantId, ?int $branchId): array
    {
        return [
            'scope' => ['tenant_id' => $tenantId, 'branch_id' => $branchId],
            'general' => $this->resolveSettingsValues($tenantId, $branchId, self::GENERAL_KEYS),
            'clinic_profile' => $this->resolveSettingsValues($tenantId, $branchId, self::CLINIC_PROFILE_KEYS),
            'invoice' => $this->resolveSettingsValues($tenantId, $branchId, self::INVOICE_KEYS),
        ];
    }

    private function encodeValue(mixed $value): ?string
    {
        if ($value === null) {
            return null;
        }

        return json_encode($value, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    }

    private function decodeValue(?string $value): mixed
    {
        if ($value === null) {
            return null;
        }

        $decoded = json_decode($value, true);
        if (json_last_error() === JSON_ERROR_NONE) {
            return $decoded;
        }

        return $value;
    }
}
