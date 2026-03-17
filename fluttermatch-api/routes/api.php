<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\PhotoController;
use Illuminate\Support\Facades\Route;

// ─── Public Routes (no auth needed) ──────────────────────
Route::middleware('throttle:6,1')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login',    [AuthController::class, 'login']);
});

Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);

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

    // We'll add more routes here in next steps:
    // Discovery, Matches, Chat, Safety
});