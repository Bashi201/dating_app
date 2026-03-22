<?php
require "vendor/autoload.php";
$app = require_once "bootstrap/app.php";
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$user = App\Models\User::find(2);
$token = $user->createToken('test_token')->plainTextToken;

$ch = curl_init('http://127.0.0.1:8000/api/matches');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Authorization: Bearer ' . $token,
    'Accept: application/json',
]);
$response = curl_exec($ch);
curl_close($ch);

echo json_encode(json_decode($response, true), JSON_PRETTY_PRINT);
