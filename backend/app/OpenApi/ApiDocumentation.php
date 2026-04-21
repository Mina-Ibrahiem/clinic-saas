<?php

namespace App\OpenApi;

use OpenApi\Attributes as OA;

#[OA\Info(
    version: '1.0.0',
    title: 'Clinic API',
    description: 'REST API for the Clinic Management System (UAE SMB clinics).'
)]
#[OA\Server(
    url: '/api',
    description: 'API (relative to APP_URL)'
)]
class ApiDocumentation
{
}
