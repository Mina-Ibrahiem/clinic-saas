<?php

namespace App\Http\Controllers\API\V1;

use App\Http\Controllers\API\ApiController;
use Illuminate\Http\JsonResponse;
use OpenApi\Attributes as OA;

#[OA\Tag(name: 'System')]
class MetaController extends ApiController
{
    #[OA\Get(path: '/meta/app', summary: 'Application meta information', tags: ['System'])]
    public function app(): JsonResponse
    {
        return $this->success('App metadata fetched successfully.', [
            'app_name' => config('app.name'),
            'environment' => config('app.env'),
            'api_version' => 'v1',
            'timezone' => config('app.timezone'),
            'status' => 'ok',
        ]);
    }
}
