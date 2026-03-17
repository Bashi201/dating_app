<?php
// app/Models/Match.php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Match extends Model
{
    use HasFactory;

    // Avoid conflict with PHP's built-in Match keyword
    protected $table = 'matches';

    public $timestamps = false;

    protected $fillable = [
        'user1_id',
        'user2_id',
        'is_active',
    ];

    protected $casts = [
        'is_active'  => 'boolean',
        'matched_at' => 'datetime',
    ];

    // ─── Relationships ───────────────────────────────────

    public function user1()
    {
        return $this->belongsTo(User::class, 'user1_id')
                    ->with(['profile', 'primaryPhoto']);
    }

    public function user2()
    {
        return $this->belongsTo(User::class, 'user2_id')
                    ->with(['profile', 'primaryPhoto']);
    }

    public function messages()
    {
        return $this->hasMany(Message::class)->orderBy('created_at', 'asc');
    }

    public function latestMessage()
    {
        return $this->hasOne(Message::class)->latestOfMany('created_at');
    }

    // ─── Scopes ──────────────────────────────────────────

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    // Get all matches for a given user (they can be user1 OR user2)
    public function scopeForUser($query, int $userId)
    {
        return $query->where('user1_id', $userId)
                     ->orWhere('user2_id', $userId);
    }

    // ─── Helper Methods ──────────────────────────────────

    // Given one user's ID, return the OTHER user in the match
    public function getOtherUser(int $myId): User
    {
        return $this->user1_id === $myId
            ? $this->user2
            : $this->user1;
    }

    // Canonical ordering — always store lower ID as user1
    public static function getOrdered(int $a, int $b): array
    {
        return $a < $b ? [$a, $b] : [$b, $a];
    }

    // Check if a user is part of this match (for authorization)
    public function involvesUser(int $userId): bool
    {
        return $this->user1_id === $userId
            || $this->user2_id === $userId;
    }
}