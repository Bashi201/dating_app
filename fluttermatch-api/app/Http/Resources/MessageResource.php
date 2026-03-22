<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class MessageResource extends JsonResource
{
    public function toArray($request): array
    {
        $myId = auth()->id();

        return [
            'id'         => $this->id,
            'match_id'   => $this->match_id,
            'sender_id'  => $this->sender_id,
            'body'       => $this->body,
            'is_mine'    => $this->sender_id === $myId,
            'is_read'    => $this->is_read,
            'created_at' => $this->created_at->toISOString(),
        ];
    }
}