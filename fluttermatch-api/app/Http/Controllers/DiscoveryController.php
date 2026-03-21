<?php

namespace App\Http\Controllers;

use App\Http\Resources\DiscoverUserResource;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

class DiscoveryController extends Controller
{
    public function index(Request $request)
    {
        $me      = $request->user();
        $profile = $me->profile;

        if (!$profile) {
            return response()->json(['users' => []]);
        }

        $cacheKey = "discover:{$me->id}";

        $users = Cache::remember($cacheKey, now()->addMinutes(5), function () use ($me, $profile) {

            // IDs to exclude: self + already liked/disliked + blocked
            $likedIds   = $me->likesGiven()->pluck('liked_id');
            $blockedIds = $me->blocks()->pluck('blocked_id');
            $excludeIds = $likedIds->merge($blockedIds)->push($me->id)->unique();

            // Gender filter
            $genderFilter = match ($profile->interested_in) {
                'male'    => ['male'],
                'female'  => ['female'],
                default   => ['male', 'female', 'non_binary', 'other'],
            };

            $query = User::with(['profile', 'photos'])
                ->join('profiles', 'users.id', '=', 'profiles.user_id')
                ->whereNotIn('users.id', $excludeIds)
                ->where('users.is_banned', false)
                ->where('profiles.is_complete', true)
                ->where('profiles.show_me', true)
                ->whereIn('profiles.gender', $genderFilter)
                ->whereBetween('profiles.age', [
                    $profile->min_age ?? 18,
                    $profile->max_age ?? 99,
                ])
                ->select('users.*');

            // Distance filter (Haversine) — only if we have lat/lng
            if ($profile->lat && $profile->lng) {
                $lat      = $profile->lat;
                $lng      = $profile->lng;
                $maxDist  = $profile->max_distance ?? 50;

                $query->selectRaw("
                    (6371 * acos(
                        cos(radians(?)) * cos(radians(profiles.lat))
                        * cos(radians(profiles.lng) - radians(?))
                        + sin(radians(?)) * sin(radians(profiles.lat))
                    )) AS distance_km
                ", [$lat, $lng, $lat])
                ->whereNotNull('profiles.lat')
                ->whereNotNull('profiles.lng')
                ->having('distance_km', '<=', $maxDist)
                ->orderBy('distance_km');
            } else {
                $query->orderBy('users.last_active_at', 'desc');
            }

            return $query->limit(20)->get();
        });

        return response()->json([
            'users' => DiscoverUserResource::collection($users),
        ]);
    }
}