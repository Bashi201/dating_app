<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateProfileRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'bio'           => 'nullable|string|max:500',
            'age'           => 'nullable|integer|min:18|max:100',
            'gender'        => 'nullable|in:male,female,non_binary,other',
            'interested_in' => 'nullable|in:male,female,everyone',
            'city'          => 'nullable|string|max:100',
            'latitude'      => 'nullable|numeric|between:-90,90',
            'longitude'     => 'nullable|numeric|between:-180,180',
            'interests'     => 'nullable|array|max:10',
            'interests.*'   => 'string|max:30',
            'instagram'     => 'nullable|string|max:50',
            'spotify'       => 'nullable|string|max:50',
            'min_age'       => 'nullable|integer|min:18|max:100',
            'max_age'       => 'nullable|integer|min:18|max:100|gte:min_age',
            'max_distance'  => 'nullable|integer|min:1|max:500',
            'show_me'       => 'nullable|boolean',
        ];
    }
}