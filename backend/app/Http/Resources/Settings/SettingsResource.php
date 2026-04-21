<?php

namespace App\Http\Resources\Settings;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SettingsResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'scope' => $this['scope'] ?? null,
            'general' => $this['general'] ?? [],
            'clinic_profile' => $this['clinic_profile'] ?? [],
            'invoice' => $this['invoice'] ?? [],
        ];
    }
}
