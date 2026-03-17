<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'               => $this->id,
            'name'             => $this->name,
            'email'            => $this->email,
            'role'             => $this->role,
            'email_verified'   => !is_null($this->email_verified_at),
            'profile_complete' => $this->profile?->is_complete ?? false,
            'last_active_at'   => $this->last_active_at?->toISOString(),
            'created_at'       => $this->created_at->toISOString(),
            // password is NEVER included — hidden in User model
        ];
    }
}