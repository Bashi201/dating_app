<?php

namespace App\Http\Controllers;

use App\Http\Resources\MatchResource;
use App\Models\Match as UserMatch;
use Illuminate\Http\Request;

class MatchController extends Controller
{
    public function index(Request $request)
    {
        $me = $request->user();

        $matches = UserMatch::with([
                        'user1.photos',
                        'user2.photos',
                        'latestMessage',
                    ])
                    ->active()
                    ->forUser($me->id)
                    ->get()
                    ->sortByDesc(fn($m) =>
                        $m->latestMessage?->created_at ?? $m->matched_at
                    )
                    ->values();

        return response()->json([
            'matches' => $matches->map(fn($m) => (new MatchResource($m, $me->id))->resolve()),
        ]);
    }
}