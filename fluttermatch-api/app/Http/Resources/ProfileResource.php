<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class ProfileResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id'            => $this->id,
            'user_id'       => $this->user_id,
            'bio'           => $this->bio,
            'age'           => $this->age,
            'gender'        => $this->gender,
            'interested_in' => $this->interested_in,
            'city'          => $this->city,
            'lat'           => $this->latitude,
            'lng'           => $this->longitude,
            'interests'     => $this->interests ?? [],
            'instagram'     => $this->instagram,
            'spotify'       => $this->spotify,
            'min_age'       => $this->min_age ?? 18,
            'max_age'       => $this->max_age ?? 99,
            'max_distance'  => $this->max_distance ?? 50,
            'show_me'       => $this->show_me,
            'is_complete'   => $this->is_complete,
            'photos'        => PhotoResource::collection($this->whenLoaded('photos')),
        ];
    }
}