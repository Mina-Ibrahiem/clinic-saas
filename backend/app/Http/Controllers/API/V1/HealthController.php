<?php

namespace App\Http\Controllers\API\V1;

use App\Http\Controllers\API\ApiController;
use Illuminate\Http\JsonResponse;
use OpenApi\Attributes as OA;

#[OA\Tag(name: 'System')]
class HealthController extends ApiController
{
    #[OA\Get(
        path: '/v1/health',
        summary: 'Service health',
        tags: ['System'],
        responses: [
            new OA\Response(response: 200, description: 'OK'),
        ]
    )]
    public function index(): JsonResponse
    {
        return $this->ok([
            'service' => 'clinic-api',
            'version' => 'v1',
            'status' => 'ok',
        ]);
    }
}
