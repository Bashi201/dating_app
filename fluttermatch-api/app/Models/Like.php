<?php
// app/Models/Like.php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Like extends Model
{
    use HasFactory;

    public $timestamps = false;            // only has created_at

    protected $fillable = [
        'liker_id',
        'liked_id',
    ];

    protected $casts = [
        'created_at' => 'datetime',
    ];

    // ─── Relationships ───────────────────────────────────

    public function liker()
    {
        return $this->belongsTo(User::class, 'liker_id');
    }

    public function liked()
    {
        return $this->belongsTo(User::class, 'liked_id');
    }

    // ─── Static Helpers ──────────────────────────────────

    // Check if two users mutually liked each other
    public static function isMutual(int $userId1, int $userId2): bool
    {
        $forward  = static::where('liker_id', $userId1)
                          ->where('liked_id', $userId2)
                          ->exists();

        $backward = static::where('liker_id', $userId2)
                          ->where('liked_id', $userId1)
                          ->exists();

        return $forward && $backward;
    }

    // Check if a user has already liked another user
    public static function alreadyLiked(int $likerId, int $likedId): bool
    {
        return static::where('liker_id', $likerId)
                     ->where('liked_id', $likedId)
                     ->exists();
    }
}