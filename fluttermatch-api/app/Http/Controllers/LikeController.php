<?php

namespace App\Http\Controllers;

use App\Models\Like;
use App\Models\UserMatch; // Removed former PHP 8 'Match' keyword alias
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;

class LikeController extends Controller
{
    public function like(Request $request, User $user)
    {
        $me = $request->user();

        if ($me->id === $user->id) {
            return response()->json(['message' => 'Cannot like yourself'], 422);
        }

        // Idempotent — don't double-insert
        if (Like::alreadyLiked($me->id, $user->id)) {
            return response()->json(['message' => 'Already liked', 'matched' => false]);
        }

        Like::create([
            'liker_id' => $me->id,
            'liked_id' => $user->id,
        ]);

        // Invalidate discovery cache so this user won't reappear
        Cache::forget("discover:{$me->id}");

        // Check for mutual like
        $matched = Like::isMutual($me->id, $user->id);
        $matchId = null;

        if ($matched) {
            // Ensure user1_id < user2_id (schema constraint)
            $u1 = min($me->id, $user->id);
            $u2 = max($me->id, $user->id);

            $match = UserMatch::firstOrCreate(
                ['user1_id' => $u1, 'user2_id' => $u2],
                ['matched_at' => now(), 'is_active' => true]
            );

            $matchId = $match->id;
        }

        return response()->json([
            'matched'  => $matched,
            'match_id' => $matchId,
        ]);
    }

    public function dislike(Request $request, User $user)
    {
        $me = $request->user();

        // Record the pass so we don't show this user again
        Like::firstOrCreate([
            'liker_id' => $me->id,
            'liked_id' => $user->id,
        ]);

        Cache::forget("discover:{$me->id}");

        return response()->json(['message' => 'Passed']);
    }
}