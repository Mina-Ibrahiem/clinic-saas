<?php

namespace App\Http\Controllers\API\V1;

use App\Http\Controllers\API\ApiController;
use App\Services\Analytics\ReportsService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

#[OA\Tag(name: 'Reports')]
class ReportController extends ApiController
{
    public function __construct(
        private readonly ReportsService $reportsService
    ) {
    }

    #[OA\Get(path: '/reports/revenue', summary: 'Revenue report', tags: ['Reports'])]
    public function revenue(Request $request): JsonResponse
    {
        return $this->success('Revenue report fetched successfully.', $this->reportsService->revenue($request->user(), $request));
    }

    #[OA\Get(path: '/reports/payments', summary: 'Payments report', tags: ['Reports'])]
    public function payments(Request $request): JsonResponse
    {
        return $this->success('Payments report fetched successfully.', $this->reportsService->payments($request->user(), $request));
    }

    #[OA\Get(path: '/reports/appointments', summary: 'Appointments report', tags: ['Reports'])]
    public function appointments(Request $request): JsonResponse
    {
        return $this->success('Appointments report fetched successfully.', $this->reportsService->appointments($request->user(), $request));
    }

    #[OA\Get(path: '/reports/patients', summary: 'Patients report', tags: ['Reports'])]
    public function patients(Request $request): JsonResponse
    {
        return $this->success('Patients report fetched successfully.', $this->reportsService->patients($request->user(), $request));
    }

    #[OA\Get(path: '/reports/doctors', summary: 'Doctors report', tags: ['Reports'])]
    public function doctors(Request $request): JsonResponse
    {
        return $this->success('Doctors report fetched successfully.', $this->reportsService->doctors($request->user(), $request));
    }

    #[OA\Get(path: '/reports/services', summary: 'Services report', tags: ['Reports'])]
    public function services(Request $request): JsonResponse
    {
        return $this->success('Services report fetched successfully.', $this->reportsService->services($request->user(), $request));
    }
}
