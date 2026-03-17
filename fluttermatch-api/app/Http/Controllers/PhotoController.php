<?php

namespace App\Http\Controllers;

use App\Http\Resources\PhotoResource;
use App\Models\Photo;
use Cloudinary\Cloudinary;
use Illuminate\Http\Request;

class PhotoController extends Controller
{
    public function upload(Request $request)
    {
        $request->validate([
            'photo' => 'required|image|mimes:jpeg,png,jpg,webp|max:10240',
        ]);

        $user       = $request->user();
        $photoCount = $user->photos()->count();

        if ($photoCount >= 6) {
            return response()->json(['message' => 'Maximum 6 photos allowed'], 422);
        }

        // Instantiate Cloudinary directly from the URL to bypass
        // the facade binding issue when CloudinaryServiceProvider
        // fails to register the engine (e.g. during env misconfiguration).
        $cloudinary = new Cloudinary(env('CLOUDINARY_URL'));

        $result = $cloudinary->uploadApi()->upload(
            $request->file('photo')->getRealPath(),
            [
                'folder'         => 'fluttermatch/users/' . $user->id,
                'transformation' => [
                    ['width' => 800, 'height' => 800, 'crop' => 'fill', 'gravity' => 'face', 'quality' => 'auto'],
                ],
            ]
        );

        // uploadApi()->upload() returns an array-like ApiResponse
        $publicId  = $result['public_id'];
        $secureUrl = $result['secure_url'];

        // Build thumbnail URL manually — avoids relying on the broken helper
        $cloudName    = env('CLOUDINARY_CLOUD_NAME');
        $thumbnailUrl = "https://res.cloudinary.com/{$cloudName}/image/upload/w_200,h_200,c_fill,g_face/{$publicId}";

        $photo = $user->photos()->create([
            'cloudinary_id' => $publicId,
            'url'           => $secureUrl,
            'thumbnail_url' => $thumbnailUrl,
            'is_primary'    => $photoCount === 0, // First photo becomes primary
            'sort_order'    => $photoCount,
        ]);

        $this->checkProfileComplete($user);

        return response()->json([
            'message' => 'Photo uploaded successfully',
            'photo'   => new PhotoResource($photo),
        ], 201);
    }

    public function destroy(Request $request, Photo $photo)
    {
        if ($photo->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $wasPrimary = $photo->is_primary;

        $cloudinary = new Cloudinary(env('CLOUDINARY_URL'));
        $cloudinary->uploadApi()->destroy($photo->cloudinary_id);
        $photo->delete();

        // Promote next photo to primary if needed
        if ($wasPrimary) {
            $request->user()->photos()->orderBy('sort_order')->first()?->update(['is_primary' => true]);
        }

        return response()->json(['message' => 'Photo deleted']);
    }

    public function setPrimary(Request $request, Photo $photo)
    {
        if ($photo->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $request->user()->photos()->update(['is_primary' => false]);
        $photo->update(['is_primary' => true]);

        return response()->json(['message' => 'Primary photo updated']);
    }

    private function checkProfileComplete($user): void
    {
        $profile = $user->profile;

        if (
            $profile->age &&
            $profile->gender &&
            $profile->interested_in &&
            $profile->bio &&
            $user->photos()->where('is_primary', true)->exists()
        ) {
            $profile->update(['is_complete' => true]);
        }
    }
}