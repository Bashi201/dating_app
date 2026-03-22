<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class MatchResource extends JsonResource
{
    private int $myId;

    public function __construct($resource, int $myId)
    {
        parent::__construct($resource);
        $this->myId = $myId;
    }

    public function toArray($request): array
    {
        $other       = $this->getOtherUser($this->myId);
        $lastMessage = $this->latestMessage;
        $unread      = $this->messages()
                            ->where('sender_id', '!=', $this->myId)
                            ->where('is_read', false)
                            ->count();

        $primaryPhoto = $other->photos
                              ->firstWhere('is_primary', true)
                              ?? $other->photos->first();

        return [
            'id'          => $this->id,
            'matched_at'  => $this->matched_at?->toISOString(),
            'other_user'  => [
                'id'        => $other->id,
                'name'      => $other->name,
                'photo_url' => $primaryPhoto?->url,
            ],
            'last_message' => $lastMessage ? [
                'body'       => $lastMessage->body,
                'is_mine'    => $lastMessage->sender_id === $this->myId,
                'created_at' => $lastMessage->created_at->toISOString(),
            ] : null,
            'unread_count' => $unread,
        ];
    }
}