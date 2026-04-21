<?php

namespace App\Http\Controllers\API\V1;

use App\Http\Controllers\API\ApiController;
use App\Http\Requests\Settings\UpdateClinicProfileSettingsRequest;
use App\Http\Requests\Settings\UpdateInvoiceSettingsRequest;
use App\Http\Requests\Settings\UpdateSettingsRequest;
use App\Http\Resources\Settings\SettingsResource;
use App\Models\Setting;
use App\Services\Settings\SettingsService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

#[OA\Tag(name: 'Settings')]
class SettingsController extends ApiController
{
    public function __construct(
        private readonly SettingsService $settingsService
    ) {
    }

    #[OA\Get(path: '/settings', summary: 'Get full settings', tags: ['Settings'])]
    public function index(Request $request): JsonResponse
    {
        $this->authorize('viewAny', Setting::class);

        $data = $this->settingsService->getAll($request->user(), $request);

        return $this->success('Settings fetched successfully.', SettingsResource::make($data)->resolve());
    }

    #[OA\Put(path: '/settings', summary: 'Update settings', tags: ['Settings'])]
    public function update(UpdateSettingsRequest $request): JsonResponse
    {
        $this->authorize('update', Setting::class);

        $data = $this->settingsService->updateAll($request->user(), $request->validated());

        return $this->success('Settings updated successfully.', SettingsResource::make($data)->resolve());
    }

    #[OA\Get(path: '/settings/clinic-profile', summary: 'Get clinic profile settings', tags: ['Settings'])]
    public function clinicProfile(Request $request): JsonResponse
    {
        $this->authorize('viewAny', Setting::class);

        $data = $this->settingsService->getClinicProfile($request->user(), $request);

        return $this->success('Clinic profile settings fetched successfully.', $data);
    }

    #[OA\Put(path: '/settings/clinic-profile', summary: 'Update clinic profile settings', tags: ['Settings'])]
    public function updateClinicProfile(UpdateClinicProfileSettingsRequest $request): JsonResponse
    {
        $this->authorize('update', Setting::class);

        $data = $this->settingsService->updateClinicProfile($request->user(), $request->validated());

        return $this->success('Clinic profile settings updated successfully.', $data);
    }

    #[OA\Get(path: '/settings/invoice', summary: 'Get invoice settings', tags: ['Settings'])]
    public function invoice(Request $request): JsonResponse
    {
        $this->authorize('viewAny', Setting::class);

        $data = $this->settingsService->getInvoice($request->user(), $request);

        return $this->success('Invoice settings fetched successfully.', $data);
    }

    #[OA\Put(path: '/settings/invoice', summary: 'Update invoice settings', tags: ['Settings'])]
    public function updateInvoice(UpdateInvoiceSettingsRequest $request): JsonResponse
    {
        $this->authorize('update', Setting::class);

        $data = $this->settingsService->updateInvoice($request->user(), $request->validated());

        return $this->success('Invoice settings updated successfully.', $data);
    }
}
