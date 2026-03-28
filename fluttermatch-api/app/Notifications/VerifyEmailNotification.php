<?php

namespace App\Notifications;

use Illuminate\Auth\Notifications\VerifyEmail;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\URL;

class VerifyEmailNotification extends VerifyEmail
{
    public function toMail($notifiable): MailMessage
    {
        $verificationUrl = $this->verificationUrl($notifiable);

        return (new MailMessage)
            ->subject('Verify Your Email - FlutterMatch')
            ->greeting('Hello ' . $notifiable->name . '!')
            ->line('Please verify your email address by clicking below.')
            ->action('Verify Email', $verificationUrl)
            ->line('This link expires in 60 minutes.')
            ->line('If you did not create an account, ignore this email.');
    }

    protected function verificationUrl($notifiable): string
    {
        // Build signed Laravel verification URL
        $temporarySignedUrl = URL::temporarySignedRoute(
            'verification.verify',
            Carbon::now()->addMinutes(
                Config::get('auth.verification.expire', 60)
            ),
            [
                'id'   => $notifiable->getKey(),
                'hash' => sha1($notifiable->getEmailForVerification()),
            ]
        );

        // Extract path + query from Laravel URL
        $parsedUrl = parse_url($temporarySignedUrl);
        $pathQuery = $parsedUrl['path'] . '?' . $parsedUrl['query'];

        // Point to Flutter Web verify screen
        return config('app.frontend_url')
            . '/verify-email'
            . '?redirect=' . urlencode($pathQuery);
    }
}