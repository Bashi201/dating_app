<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class PhotoResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id'            => $this->id,
            'url'           => $this->url,
            'thumbnail_url' => $this->thumbnail_url,
            'is_primary'    => $this->is_primary,
            'sort_order'    => $this->sort_order,
        ];
    }
}