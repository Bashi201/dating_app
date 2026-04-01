<?php

namespace App\Http\Controllers;

use App\Models\Block;
use App\Models\UserMatch;
use App\Models\Report;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;

class SafetyController extends Controller
{
    public function block(Request $request, User $user)
    {
        $me = $request->user();

        if ($me->id === $user->id) {
            return response()->json(['message' => 'Cannot block yourself'], 422);
        }

        Block::firstOrCreate([
            'blocker_id' => $me->id,
            'blocked_id' => $user->id,
        ]);

        // Deactivate any active match between them
        $u1 = min($me->id, $user->id);
        $u2 = max($me->id, $user->id);

        UserMatch::where('user1_id', $u1)
            ->where('user2_id', $u2)
            ->update(['is_active' => false]);

        // Invalidate discovery cache for both users
        Cache::forget("discover:{$me->id}");
        Cache::forget("discover:{$user->id}");

        return response()->json(['message' => 'User blocked']);
    }

    public function unblock(Request $request, User $user)
    {
        $me = $request->user();

        Block::where('blocker_id', $me->id)
            ->where('blocked_id', $user->id)
            ->delete();

        Cache::forget("discover:{$me->id}");

        return response()->json(['message' => 'User unblocked']);
    }

    public function blockedUsers(Request $request)
    {
        $blocked = $request->user()
            ->blocks()
            ->with('blocked:id,name')
            ->get()
            ->map(fn($b) => [
                'id' => $b->blocked->id,
                'name' => $b->blocked->name,
            ]);

        return response()->json(['blocked_users' => $blocked]);
    }

    public function report(Request $request, User $user)
    {
        $me = $request->user();

        if ($me->id === $user->id) {
            return response()->json(['message' => 'Cannot report yourself'], 422);
        }

        $request->validate([
            'reason' => 'required|in:inappropriate_photos,harassment,fake_profile,spam,underage,other',
            'description' => 'nullable|string|max:500',
        ]);

        Report::firstOrCreate(
            ['reporter_id' => $me->id, 'reported_id' => $user->id],
            [
                'reason' => $request->reason,
                'description' => $request->description,
                'status' => 'pending',
            ]
        );

        return response()->json(['message' => 'Report submitted. Thank you.']);
    }
}