<?php

use App\Http\Middleware\EnsureHasPermission;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Auth\AuthenticationException;
use PHPOpenSourceSaver\JWTAuth\Exceptions\JWTException;
use PHPOpenSourceSaver\JWTAuth\Exceptions\TokenExpiredException;
use PHPOpenSourceSaver\JWTAuth\Exceptions\TokenInvalidException;
use Symfony\Component\HttpFoundation\Response;
use Illuminate\Validation\ValidationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\HttpKernel\Exception\HttpExceptionInterface;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->alias([
            'permission' => EnsureHasPermission::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->render(function (AuthenticationException $exception) {
            $message = $exception->getMessage();

            return response()->json([
                'success' => false,
                'message' => $message !== '' && $message !== 'Unauthenticated.'
                    ? $message
                    : 'Authentication required.',
                'data' => null,
                'errors' => null,
            ], Response::HTTP_UNAUTHORIZED);
        });

        $exceptions->render(function (ValidationException $exception) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed.',
                'data' => null,
                'errors' => $exception->errors(),
            ], Response::HTTP_UNPROCESSABLE_ENTITY);
        });

        $exceptions->render(function (AuthorizationException $exception) {
            return response()->json([
                'success' => false,
                'message' => $exception->getMessage() ?: 'You are not authorized to perform this action.',
                'data' => null,
                'errors' => null,
            ], Response::HTTP_FORBIDDEN);
        });

        $exceptions->render(function (AccessDeniedHttpException $exception) {
            return response()->json([
                'success' => false,
                'message' => $exception->getMessage() ?: 'Access denied.',
                'data' => null,
                'errors' => null,
            ], Response::HTTP_FORBIDDEN);
        });

        $exceptions->render(function (ModelNotFoundException|NotFoundHttpException $exception) {
            return response()->json([
                'success' => false,
                'message' => 'Resource not found.',
                'data' => null,
                'errors' => null,
            ], Response::HTTP_NOT_FOUND);
        });

        $exceptions->render(function (HttpExceptionInterface $exception) {
            return response()->json([
                'success' => false,
                'message' => $exception->getMessage() !== '' ? $exception->getMessage() : 'Request failed.',
                'data' => null,
                'errors' => null,
            ], $exception->getStatusCode());
        });

        $exceptions->render(function (TokenExpiredException|TokenInvalidException|JWTException $exception) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid or expired token.',
                'data' => null,
                'errors' => null,
            ], Response::HTTP_UNAUTHORIZED);
        });

        $exceptions->render(function (\Throwable $exception, \Illuminate\Http\Request $request) {
            if (! $request->is('api/*')) {
                return null;
            }

            return response()->json([
                'success' => false,
                'message' => 'Unexpected server error.',
                'data' => null,
                'errors' => config('app.debug') ? ['exception' => $exception->getMessage()] : null,
            ], Response::HTTP_INTERNAL_SERVER_ERROR);
        });
    })->create();
