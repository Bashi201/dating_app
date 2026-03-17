<?php
// app/Models/Photo.php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Photo extends Model
{
    use HasFactory;

    public $timestamps = false;            // only has created_at

    protected $fillable = [
        'user_id',
        'cloudinary_id',
        'url',
        'thumbnail_url',
        'is_primary',
        'sort_order',
    ];

    protected $casts = [
        'is_primary'  => 'boolean',
        'created_at'  => 'datetime',
    ];

    // ─── Relationships ───────────────────────────────────

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // ─── Scopes ──────────────────────────────────────────

    public function scopePrimary($query)
    {
        return $query->where('is_primary', true);
    }
}