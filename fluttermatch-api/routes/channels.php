<?php

use Illuminate\Support\Facades\Broadcast;

Broadcast::channel('match.{matchId}', function ($user, $matchId) {
    $match = \App\Models\Match::find($matchId);
    return $match && $match->involvesUser($user->id);
});