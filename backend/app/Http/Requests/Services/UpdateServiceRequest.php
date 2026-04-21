<?php

namespace App\Http\Requests\Services;

use App\Enums\ServiceStatus;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateServiceRequest extends FormRequest
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
            'name' => ['sometimes', 'required', 'string', 'max:255'],
            'code' => ['sometimes', 'nullable', 'string', 'max:64'],
            'description' => ['sometimes', 'nullable', 'string'],
            'price' => ['sometimes', 'required', 'numeric', 'min:0'],
            'duration_minutes' => ['sometimes', 'nullable', 'integer', 'min:1', 'max:1440'],
            'status' => ['sometimes', 'nullable', Rule::enum(ServiceStatus::class)],
            'tenant_id' => ['sometimes', 'nullable', 'integer', 'exists:tenants,id'],
            'branch_id' => ['sometimes', 'nullable', 'integer', 'exists:branches,id'],
        ];
    }
}
