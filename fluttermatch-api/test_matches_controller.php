<?php
require "vendor/autoload.php";
$app = require_once "bootstrap/app.php";
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$me = App\Models\User::find(2);

$matches = App\Models\UserMatch::with([
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

$res = $matches->map(fn($m) => (new App\Http\Resources\MatchResource($m, $me->id))->resolve());

echo json_encode($res, JSON_PRETTY_PRINT);
