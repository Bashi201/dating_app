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
//REST PASSWORD
Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
Route::post('/reset-password', [AuthController::class, 'resetPassword']);

// Email Verification Route (required for sendEmailVerificationNotification)
Route::get('/email/verify/{id}/{hash}', function (\Illuminate\Http\Request $request, $id, $hash) {
    $user = \App\Models\User::find($id);
    if (! $user || ! hash_equals((string) $hash, sha1($user->getEmailForVerification()))) {
        return response()->json(['message' => 'Invalid verification link'], 400);
    }
    if (! $request->hasValidSignature()) {
        return response()->json(['message' => 'Invalid/Expired url provided.'], 401);
    }
    if (! $user->hasVerifiedEmail()) {
        $user->markEmailAsVerified();
    }
    return response()->json(['message' => 'Email verified successfully']);
})->name('verification.verify');

// ─── Protected Routes (Sanctum token required) ────────────
Route::middleware(['auth:sanctum'])->group(function () {

    // Auth
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me',      [AuthController::class, 'me']);

    // Profile
    Route::get('/profile', [ProfileController::class, 'show']);
    Route::put('/profile', [ProfileController::class, 'update']);

    // Photos
    Route::post  ('/profile/photos',                [PhotoController::class, 'upload']);
    Route::delete('/profile/photos/{photo}',        [PhotoController::class, 'destroy']);
    Route::patch ('/profile/photos/{photo}/primary',[PhotoController::class, 'setPrimary']);

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