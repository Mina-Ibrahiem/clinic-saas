<?php

namespace App\Http\Controllers\API\V1;

use App\Http\Controllers\API\ApiController;
use App\Services\Analytics\DashboardService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

#[OA\Tag(name: 'Dashboard')]
class DashboardController extends ApiController
{
    public function __construct(
        private readonly DashboardService $dashboardService
    ) {
    }

    #[OA\Get(path: '/dashboard/overview', summary: 'Dashboard overview metrics', tags: ['Dashboard'])]
    public function overview(Request $request): JsonResponse
    {
        return $this->success(
            'Dashboard overview fetched successfully.',
            $this->dashboardService->overview($request->user(), $request)
        );
    }

    #[OA\Get(path: '/dashboard/revenue-summary', summary: 'Dashboard revenue summary', tags: ['Dashboard'])]
    public function revenueSummary(Request $request): JsonResponse
    {
        return $this->success(
            'Revenue summary fetched successfully.',
            $this->dashboardService->revenueSummary($request->user(), $request)
        );
    }

    #[OA\Get(path: '/dashboard/appointments-summary', summary: 'Dashboard appointments summary', tags: ['Dashboard'])]
    public function appointmentsSummary(Request $request): JsonResponse
    {
        return $this->success(
            'Appointments summary fetched successfully.',
            $this->dashboardService->appointmentsSummary($request->user(), $request)
        );
    }
}
