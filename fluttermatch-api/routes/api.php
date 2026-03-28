<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\PhotoController;
use App\Http\Controllers\DiscoveryController;
use App\Http\Controllers\LikeController;
use App\Http\Controllers\MatchController;
use App\Http\Controllers\MessageController;
use Illuminate\Support\Facades\Route;

// ─── Public Routes (no auth needed) ──────────────────────
Route::middleware('throttle:6,1')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login',    [AuthController::class, 'login']);
});

// ─── Password Reset ───────────────────────────────────────
Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
Route::post('/reset-password',  [AuthController::class, 'resetPassword']);

// ─── Email Verification ───────────────────────────────────
Route::get('/email/verify/{id}/{hash}', function (
    \Illuminate\Http\Request $request,
    $id,
    $hash
) {
    $user = \App\Models\User::find($id);

    // Check user exists and hash matches
    if (!$user || !hash_equals(
        (string) $hash,
        sha1($user->getEmailForVerification())
    )) {
        return response()->json([
            'success' => false,
            'message' => 'Invalid verification link.',
        ], 400);
    }

    // Check link is not expired
    if (!$request->hasValidSignature()) {
        return response()->json([
            'success' => false,
            'message' => 'Verification link has expired. Please request a new one.',
        ], 401);
    }

    // Already verified
    if ($user->hasVerifiedEmail()) {
        return response()->json([
            'success' => true,
            'message' => 'Email already verified.',
        ], 200);
    }

    // ✅ Mark as verified — updates email_verified_at in DB
    $user->markEmailAsVerified();

    return response()->json([
        'success' => true,
        'message' => 'Email verified successfully! You can now sign in.',
    ], 200);

})->name('verification.verify');

// ─── Resend Verification Email ────────────────────────────
Route::post('/email/resend', function (\Illuminate\Http\Request $request) {
    $request->validate(['email' => 'required|email']);

    $user = \App\Models\User::where('email', $request->email)->first();

    if (!$user) {
        return response()->json([
            'success' => false,
            'message' => 'No account found with this email.',
        ], 404);
    }

    if ($user->hasVerifiedEmail()) {
        return response()->json([
            'success' => false,
            'message' => 'Email already verified.',
        ], 400);
    }

    $user->sendEmailVerificationNotification();

    return response()->json([
        'success' => true,
        'message' => 'Verification link sent!',
    ], 200);

})->middleware('throttle:6,1');

// ─── Protected Routes (Sanctum token required) ────────────
Route::middleware(['auth:sanctum'])->group(function () {

    // Auth
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me',      [AuthController::class, 'me']);

    // Profile
    Route::get('/profile', [ProfileController::class, 'show']);
    Route::put('/profile', [ProfileController::class, 'update']);

    // Photos
    Route::post  ('/profile/photos',                 [PhotoController::class, 'upload']);
    Route::delete('/profile/photos/{photo}',         [PhotoController::class, 'destroy']);
    Route::patch ('/profile/photos/{photo}/primary', [PhotoController::class, 'setPrimary']);

    // Discovery
    Route::get ('/discover',       [DiscoveryController::class, 'index']);
    Route::post('/like/{user}',    [LikeController::class, 'like']);
    Route::post('/dislike/{user}', [LikeController::class, 'dislike']);

    // Matches
    Route::get('/matches', [MatchController::class, 'index']);

    // Messages
    Route::get ('/matches/{match}/messages', [MessageController::class, 'index']);
    Route::post('/matches/{match}/messages', [MessageController::class, 'store']);
    Route::post('/matches/{match}/read',     [MessageController::class, 'markRead']);

    // We'll add more routes here in next steps:
    // Safety
});