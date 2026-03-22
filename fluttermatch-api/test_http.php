<?php
require "vendor/autoload.php";
$app = require_once "bootstrap/app.php";
$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);

$request = Illuminate\Http\Request::create('/api/matches', 'GET');
// Log in as user 2
$app->make('auth')->guard('sanctum')->setUser(App\Models\User::find(2));
$request->setUserResolver(function() { return App\Models\User::find(2); });

$response = $kernel->handle($request);
echo "STATUS: " . $response->getStatusCode() . "\n";
echo "CONTENT: " . $response->getContent() . "\n";
