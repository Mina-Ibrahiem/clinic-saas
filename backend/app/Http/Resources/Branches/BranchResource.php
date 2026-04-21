<?php

namespace App\Http\Resources\Branches;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class BranchResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'tenant_id' => $this->tenant_id,
            'name' => $this->name,
            'code' => $this->code,
            'phone' => $this->phone,
            'email' => $this->email,
            'address' => $this->address,
            'status' => $this->status?->value ?? $this->status,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
            'stats' => [
                'users_count' => (int) ($this->users_count ?? 0),
                'patients_count' => (int) ($this->patients_count ?? 0),
                'doctors_count' => (int) ($this->doctors_count ?? 0),
                'appointments_count' => (int) ($this->appointments_count ?? 0),
                'invoices_count' => (int) ($this->invoices_count ?? 0),
            ],
            'tenant' => $this->whenLoaded('tenant', function () {
                return [
                    'id' => $this->tenant?->id,
                    'uuid' => $this->tenant?->uuid,
                    'name' => $this->tenant?->name,
                    'slug' => $this->tenant?->slug,
                ];
            }),
        ];
    }
}
