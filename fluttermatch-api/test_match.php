<?php
require "vendor/autoload.php";
$app = require_once "bootstrap/app.php";
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$me = App\Models\User::find(2);
$m = App\Models\UserMatch::with(["user1", "user2"])->first();
echo "Match ID: {$m->id}\n";
echo "User1 ID: {$m->user1_id}\n";
echo "User2 ID: {$m->user2_id}\n";
echo "Me ID: {$me->id}\n";

$resource = new App\Http\Resources\MatchResource($m, $me->id);
$result = $resource->resolve();
echo json_encode($result, JSON_PRETTY_PRINT);
