<?php
// app/Models/Block.php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Block extends Model
{
    use HasFactory;

    public $timestamps = false;

    protected $fillable = [
        'blocker_id',
        'blocked_id',
    ];

    protected $casts = [
        'created_at' => 'datetime',
    ];

    // ─── Relationships ───────────────────────────────────

    public function blocker()
    {
        return $this->belongsTo(User::class, 'blocker_id');
    }

    public function blocked()
    {
        return $this->belongsTo(User::class, 'blocked_id');
    }
}