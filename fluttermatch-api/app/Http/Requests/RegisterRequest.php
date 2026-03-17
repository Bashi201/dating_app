<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class RegisterRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;    // public endpoint — no auth needed
    }

    public function rules(): array
    {
        return [
            'name'     => ['required', 'string', 'min:2', 'max:100'],
            'email'    => ['required', 'email', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
            // 'confirmed' checks for a matching 'password_confirmation' field
        ];
    }

    public function messages(): array
    {
        return [
            'email.unique'         => 'An account with this email already exists.',
            'password.confirmed'   => 'Passwords do not match.',
            'password.min'         => 'Password must be at least 8 characters.',
        ];
    }
}