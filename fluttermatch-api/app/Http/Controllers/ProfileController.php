<?php

namespace App\Http\Controllers;

use App\Http\Requests\UpdateProfileRequest;
use App\Http\Resources\ProfileResource;
use Illuminate\Http\Request;

class ProfileController extends Controller
{
    public function show(Request $request)
    {
        $profile = $request->user()->profile()->with('photos')->first();

        return response()->json([
            'profile' => new ProfileResource($profile),
        ]);
    }

    public function update(UpdateProfileRequest $request)
    {
        $user = $request->user();

        // firstOrCreate([]) guarantees a profile record exists before we try
        // to fill it. Users registered before auto-profile-creation was added
        // would hit "fill() on null" with ->first() alone.
        $profile = $user->profile()->firstOrCreate([]);

        $profile->fill($request->validated());

        // Mark complete based on profile fields only — photos are not required here
        if (
            $profile->age &&
            $profile->gender &&
            $profile->interested_in &&
            $profile->bio
        ) {
            $profile->is_complete = true;
        }

        $profile->save();
        $profile->load('photos');

        return response()->json([
            'message' => 'Profile updated successfully',
            'profile' => new ProfileResource($profile),
        ]);
    }
}