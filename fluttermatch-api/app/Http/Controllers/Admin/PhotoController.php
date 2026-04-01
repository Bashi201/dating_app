<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Photo;
use Cloudinary\Cloudinary;

class PhotoController extends Controller
{
    public function destroy(Photo $photo)
    {
        // Same pattern as existing PhotoController — direct instantiation
        $cloudinary = new Cloudinary(env('CLOUDINARY_URL'));

        try {
            $cloudinary->uploadApi()->destroy($photo->cloudinary_id);
        } catch (\Exception $e) {
            // Log but continue — remove from DB regardless
        }

        $wasPrimary = $photo->is_primary;
        $userId = $photo->user_id;

        $photo->delete();

        // Promote next photo if deleted one was primary
        if ($wasPrimary) {
            Photo::where('user_id', $userId)
                ->orderBy('sort_order')
                ->first()
                    ?->update(['is_primary' => true]);
        }

        return response()->json(['message' => 'Photo deleted by admin.']);
    }
}