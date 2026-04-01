<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class ReportResource extends JsonResource
{
    public function toArray($request): array
    {
        $reportedPhoto = $this->reported->photos
            ->firstWhere('is_primary', true)
            ?? $this->reported->photos->first();

        return [
            'id' => $this->id,
            'reason' => $this->reason,
            'description' => $this->description,
            'status' => $this->status,
            'created_at' => $this->created_at->toISOString(),
            'reporter' => [
                'id' => $this->reporter->id,
                'name' => $this->reporter->name,
                'email' => $this->reporter->email,
            ],
            'reported' => [
                'id' => $this->reported->id,
                'name' => $this->reported->name,
                'email' => $this->reported->email,
                'photo_url' => $reportedPhoto?->url,
            ],
        ];
    }
}