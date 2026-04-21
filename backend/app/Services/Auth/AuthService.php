<?php

namespace App\Services\Auth;

use App\Enums\UserStatus;
use App\Http\Resources\Auth\AuthUserResource;
use App\Models\User;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use PHPOpenSourceSaver\JWTAuth\JWTGuard;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;

class AuthService
{
    /**
     * @param array{email:string,password:string} $credentials
     * @return array<string,mixed>
     */
    public function login(array $credentials): array
    {
        $user = User::query()
            ->withTrashed()
            ->where('email', $credentials['email'])
            ->first();

        if ($user === null || !Hash::check($credentials['password'], $user->password)) {
            throw new AuthenticationException('Invalid email or password.');
        }

        if ($user->trashed()) {
            throw new AccessDeniedHttpException('User account is deleted.');
        }

        if ($user->status !== UserStatus::Active) {
            throw new AccessDeniedHttpException('User account is inactive.');
        }

        $token = $this->guard()->login($user);

        $user->forceFill(['last_login_at' => now()])->save();
        $user->refresh();

        return $this->buildTokenPayload($token, $user);
    }

    /**
     * @return array<string,mixed>
     */
    public function me(): array
    {
        $user = $this->guard()->user();
        if ($user === null) {
            throw new AuthenticationException('Authentication required.');
        }

        return AuthUserResource::make($user)->resolve();
    }

    /**
     * @return array<string,mixed>
     */
    public function refresh(): array
    {
        $token = $this->guard()->refresh();
        $user = $this->guard()->setToken($token)->user();

        if ($user === null) {
            throw new AuthenticationException('Authentication required.');
        }

        return $this->buildTokenPayload($token, $user);
    }

    public function logout(): void
    {
        $this->guard()->logout(true);
    }

    /**
     * @return array<string,mixed>
     */
    private function buildTokenPayload(string $token, User $user): array
    {
        return [
            'access_token' => $token,
            'token_type' => 'bearer',
            'expires_in' => $this->guard()->factory()->getTTL() * 60,
            'user' => AuthUserResource::make($user)->resolve(),
            'roles' => $user->roleSlugs()->all(),
            'permissions' => $user->permissionSlugs()->all(),
            'tenant' => $user->tenant ? [
                'id' => $user->tenant->id,
                'uuid' => $user->tenant->uuid,
                'name' => $user->tenant->name,
            ] : null,
            'branch' => $user->branch ? [
                'id' => $user->branch->id,
                'name' => $user->branch->name,
                'code' => $user->branch->code,
            ] : null,
        ];
    }

    private function guard(): JWTGuard
    {
        /** @var JWTGuard $guard */
        $guard = Auth::guard('api');

        return $guard;
    }
}
