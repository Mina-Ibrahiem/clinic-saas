<?php

namespace App\Http\Resources\Auth;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AuthUserResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $this->resource->loadMissing(['roles.permissions', 'tenant', 'branch', 'doctorProfile']);

        $roles = $this->resource->roles;
        $permissions = $roles
            ->flatMap(fn ($role) => $role->permissions)
            ->pluck('slug')
            ->unique()
            ->values();

        return [
            'id' => $this->resource->id,
            'full_name' => $this->resource->full_name,
            'email' => $this->resource->email,
            'phone' => $this->resource->phone,
            'avatar' => $this->resource->avatar,
            'status' => $this->resource->status?->value ?? (string) $this->resource->status,
            'last_login_at' => $this->resource->last_login_at,
            'roles' => $roles->map(fn ($role) => [
                'id' => $role->id,
                'name' => $role->name,
                'slug' => $role->slug,
            ])->values(),
            'permissions' => $permissions,
            'tenant' => $this->resource->tenant ? [
                'id' => $this->resource->tenant->id,
                'uuid' => $this->resource->tenant->uuid,
                'name' => $this->resource->tenant->name,
                'slug' => $this->resource->tenant->slug,
                'status' => $this->resource->tenant->status?->value ?? (string) $this->resource->tenant->status,
            ] : null,
            'branch' => $this->resource->branch ? [
                'id' => $this->resource->branch->id,
                'name' => $this->resource->branch->name,
                'code' => $this->resource->branch->code,
                'status' => $this->resource->branch->status?->value ?? (string) $this->resource->branch->status,
            ] : null,
        ];
    }
}
