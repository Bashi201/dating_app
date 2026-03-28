<?php

namespace App\Http\Controllers;

use App\Http\Requests\RegisterRequest;
use App\Http\Requests\LoginRequest;
use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Facades\Hash;
class AuthController extends Controller
{
    // ─── POST /api/register ──────────────────────────────
    public function register(RegisterRequest $request): JsonResponse
    {
        // Create user — password auto-hashed by model cast
        $user = User::create([
            'name'     => $request->name,
            'email'    => $request->email,
            'password' => $request->password,
        ]);

        // Create empty profile record ready for setup
        $user->profile()->create();

        // Send email verification
        $user->sendEmailVerificationNotification();

        // Issue Sanctum token
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Account created! Please verify your email.',
            'data'    => [
                'token'      => $token,
                'token_type' => 'Bearer',
                'user'       => new UserResource($user),
            ],
        ], 201);
    }

    // ─── POST /api/login ─────────────────────────────────
    public function login(LoginRequest $request): JsonResponse
    {
        // Attempt authentication
        if (!Auth::attempt($request->only('email', 'password'))) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid email or password.',
            ], 401);
        }

        $user = Auth::user();

        // Reject banned users immediately
        if ($user->isBanned()) {
            return response()->json([
                'success' => false,
                'message' => 'Your account has been suspended.',
                'reason'  => $user->ban_reason,
            ], 403);
        }

        // Update last active timestamp
        $user->updateLastActive();

        // Revoke old tokens (single device login)
        // Comment this out if you want multi-device support
        $user->tokens()->delete();

        // Issue fresh token
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'data'    => [
                'token'      => $token,
                'token_type' => 'Bearer',
                'user'       => new UserResource($user),
            ],
        ]);
    }

    // ─── POST /api/logout ────────────────────────────────
    public function logout(Request $request): JsonResponse
    {
        // Delete ONLY the current device token
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logged out successfully.',
        ]);
    }

    // ─── GET /api/me ─────────────────────────────────────
    public function me(Request $request): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data'    => new UserResource($request->user()),
        ]);
    }

 // ─── POST /api/forgot-password ───────────────────────
public function forgotPassword(Request $request): JsonResponse
{
    $request->validate(['email' => 'required|email']);

    $status = Password::sendResetLink(
        $request->only('email')
    );

    if ($status === Password::RESET_LINK_SENT) {
        return response()->json([
            'success' => true,
            'message' => 'If this email exists, a reset link has been sent.',
        ], 200);
    }

    return response()->json([
        'success' => false,
        'message' => __($status),
    ], 422);
}
// ─── POST /api/reset-password ────────────────────────
public function resetPassword(Request $request): JsonResponse
{
    $request->validate([
        'token'                 => 'required',
        'email'                 => 'required|email',
        'password'              => 'required|min:8|confirmed',
        'password_confirmation' => 'required',
    ]);

    $status = Password::reset(
        $request->only('email', 'password', 'password_confirmation', 'token'),
        function ($user, $password) {
            $user->forceFill([
                'password' => Hash::make($password),
            ])->save();
        }
    );

    if ($status === Password::PASSWORD_RESET) {
        return response()->json([
            'success' => true,
            'message' => 'Password has been reset successfully.',
        ], 200);
    }

    return response()->json([
        'success' => false,
        'message' => __($status),
    ], 422);
}
}