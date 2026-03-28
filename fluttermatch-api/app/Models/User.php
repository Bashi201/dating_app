<?php

namespace App\Models;

use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use App\Notifications\ResetPasswordNotification;
use App\Notifications\VerifyEmailNotification;

class User extends Authenticatable implements MustVerifyEmail
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
        'role',
        'is_banned',
        'ban_reason',
        'last_active_at',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'last_active_at'    => 'datetime',
        'is_banned'         => 'boolean',
        'password'          => 'hashed',
    ];

    // ─── Relationships ───────────────────────────────────

    public function profile()
    {
        return $this->hasOne(Profile::class);
    }

    public function photos()
    {
        return $this->hasMany(Photo::class)->orderBy('sort_order');
    }

    public function primaryPhoto()
    {
        return $this->hasOne(Photo::class)->where('is_primary', true);
    }

    public function likesGiven()
    {
        return $this->hasMany(Like::class, 'liker_id');
    }

    public function likesReceived()
    {
        return $this->hasMany(Like::class, 'liked_id');
    }

    public function matches()
    {
        return \App\Models\UserMatch::where('user1_id', $this->id)
                    ->orWhere('user2_id', $this->id)
                    ->where('is_active', true);
    }

    public function blocks()
    {
        return $this->hasMany(Block::class, 'blocker_id');
    }

    public function reports()
    {
        return $this->hasMany(Report::class, 'reporter_id');
    }

    // ─── Helper Scopes ───────────────────────────────────

    public function scopeActive($query)
    {
        return $query->where('is_banned', false);
    }

    public function scopeAdmins($query)
    {
        return $query->where('role', 'admin');
    }

    // ─── Helper Methods ──────────────────────────────────

    public function isAdmin(): bool
    {
        return $this->role === 'admin';
    }

    public function isBanned(): bool
    {
        return $this->is_banned;
    }

    public function hasBlockedUser(int $userId): bool
    {
        return $this->blocks()->where('blocked_id', $userId)->exists();
    }

    public function updateLastActive(): void
    {
        $this->update(['last_active_at' => now()]);
    }

    // ─── Custom Notifications ─────────────────────────────

    // Sends verify email with Flutter deep link
    public function sendEmailVerificationNotification(): void
    {
        $this->notify(new VerifyEmailNotification());
    }

    // Sends reset password email with Flutter deep link
    public function sendPasswordResetNotification($token): void
    {
        $this->notify(new ResetPasswordNotification($token));
    }
}