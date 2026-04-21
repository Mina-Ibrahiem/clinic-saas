<?php

namespace App\Http\Requests\Settings;

use Illuminate\Foundation\Http\FormRequest;

class UpdateClinicProfileSettingsRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'tenant_id' => ['nullable', 'integer', 'exists:tenants,id'],
            'branch_id' => ['nullable', 'integer', 'exists:branches,id'],
            'clinic_name' => ['sometimes', 'nullable', 'string', 'max:255'],
            'clinic_phone' => ['sometimes', 'nullable', 'string', 'max:64'],
            'clinic_email' => ['sometimes', 'nullable', 'email:rfc', 'max:255'],
            'clinic_address' => ['sometimes', 'nullable', 'string'],
            'timezone' => ['sometimes', 'nullable', 'string', 'max:64'],
            'currency' => ['sometimes', 'nullable', 'string', 'size:3'],
            'branding_logo_url' => ['sometimes', 'nullable', 'url', 'max:2048'],
            'branding_primary_color' => ['sometimes', 'nullable', 'string', 'max:32'],
        ];
    }
}
