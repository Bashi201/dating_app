<?php
// app/Models/Profile.php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Profile extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'bio',
        'age',
        'gender',
        'interested_in',
        'latitude',
        'longitude',
        'city',
        'interests',
        'instagram',
        'spotify',
        'is_complete',
        'show_me',
        'min_age',
        'max_age',
        'max_distance',
    ];

    protected $casts = [
        'interests'   => 'array',
        'is_complete' => 'boolean',
        'show_me'     => 'boolean',
        'latitude'    => 'decimal:8',
        'longitude'   => 'decimal:8',
    ];

    // ─── Relationships ───────────────────────────────────

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Added: photos relationship via shared user_id
    public function photos()
    {
        return $this->hasMany(Photo::class, 'user_id', 'user_id');
    }

    // ─── Helper Methods ──────────────────────────────────

    public function markComplete(): void
    {
        $this->update(['is_complete' => true]);
    }

    public function isComplete(): bool
    {
        return !empty($this->bio)
            && !empty($this->age)
            && !empty($this->gender);
    }
}