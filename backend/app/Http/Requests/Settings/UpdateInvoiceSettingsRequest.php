<?php

namespace App\Http\Requests\Settings;

use Illuminate\Foundation\Http\FormRequest;

class UpdateInvoiceSettingsRequest extends FormRequest
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
            'invoice_prefix' => ['sometimes', 'nullable', 'string', 'max:20'],
            'invoice_due_days' => ['sometimes', 'nullable', 'integer', 'min:0', 'max:365'],
            'tax_default' => ['sometimes', 'nullable', 'numeric', 'min:0', 'max:100'],
            'invoice_footer' => ['sometimes', 'nullable', 'string'],
        ];
    }
}
