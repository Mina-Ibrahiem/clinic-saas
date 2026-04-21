<?php

namespace App\Http\Controllers\API\V1;

use App\Http\Controllers\API\ApiController;
use App\Http\Requests\Auth\LoginRequest;
use App\Services\Auth\AuthService;
use Illuminate\Http\JsonResponse;
use OpenApi\Attributes as OA;

#[OA\Tag(name: 'Authentication')]
class AuthController extends ApiController
{
    public function __construct(
        private readonly AuthService $authService
    ) {
    }

    #[OA\Post(
        path: '/auth/login',
        summary: 'Authenticate user and issue JWT token',
        tags: ['Authentication'],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                required: ['email', 'password'],
                properties: [
                    new OA\Property(property: 'email', type: 'string', format: 'email'),
                    new OA\Property(property: 'password', type: 'string'),
                ]
            )
        ),
        responses: [
            new OA\Response(response: 200, description: 'Login success'),
            new OA\Response(response: 401, description: 'Invalid credentials'),
            new OA\Response(response: 403, description: 'Inactive/deleted account'),
        ]
    )]
    public function login(LoginRequest $request): JsonResponse
    {
        $payload = $this->authService->login($request->validated());

        return $this->success('Login successful.', $payload);
    }

    #[OA\Post(path: '/auth/logout', summary: 'Logout current JWT token', tags: ['Authentication'])]
    public function logout(): JsonResponse
    {
        $this->authService->logout();

        return $this->success('Logout successful.');
    }

    #[OA\Post(path: '/auth/refresh', summary: 'Refresh JWT token', tags: ['Authentication'])]
    public function refresh(): JsonResponse
    {
        $payload = $this->authService->refresh();

        return $this->success('Token refreshed successfully.', $payload);
    }

    #[OA\Get(path: '/auth/me', summary: 'Current authenticated user profile', tags: ['Authentication'])]
    public function me(): JsonResponse
    {
        return $this->success('Authenticated user profile.', $this->authService->me());
    }
}
