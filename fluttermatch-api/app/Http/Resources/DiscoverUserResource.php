<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class DiscoverUserResource extends JsonResource
{
    public function toArray($request): array
    {
        $primaryPhoto = $this->photos->firstWhere('is_primary', true)
                     ?? $this->photos->first();

        return [
            'id'           => $this->id,
            'name'         => $this->name,
            'age'          => $this->profile?->age,
            'city'         => $this->profile?->city,
            'bio'          => $this->profile?->bio,
            'interests'    => $this->profile?->interests ?? [],
            'primary_photo'=> $primaryPhoto?->url,
            'distance_km'  => $this->distance_km ?? null,
        ];
    }
}