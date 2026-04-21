<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureHasPermission
{
    public function handle(Request $request, Closure $next, string $permissions): Response
    {
        $user = $request->user();
        if ($user === null) {
            return response()->json([
                'success' => false,
                'message' => 'Authentication required.',
                'data' => null,
            ], Response::HTTP_UNAUTHORIZED);
        }

        $required = collect(explode('|', $permissions))
            ->map(fn (string $permission) => trim($permission))
            ->filter()
            ->values()
            ->all();

        if ($required === [] || $user->hasPermission($required)) {
            return $next($request);
        }

        return response()->json([
            'success' => false,
            'message' => 'You do not have the required permission.',
            'data' => null,
            'errors' => [
                'permissions' => $required,
            ],
        ], Response::HTTP_FORBIDDEN);
    }
}
