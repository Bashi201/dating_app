<?php

namespace App\Notifications;

use Illuminate\Auth\Notifications\VerifyEmail;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\URL;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;

class VerifyEmailNotification extends VerifyEmail implements ShouldQueue
{
    use Queueable;

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
        // Generates a direct signed API URL that the emulator browser can open.
        // e.g. http://10.0.2.2:8000/api/email/verify/{id}/{hash}?expires=...&signature=...
        // When the user opens this in the emulator's Chrome, it immediately verifies
        // the email in the database. They then tap "I've Verified My Email" in the app.
        return URL::temporarySignedRoute(
            'verification.verify',
            Carbon::now()->addMinutes(
                Config::get('auth.verification.expire', 60)
            ),
            [
                'id'   => $notifiable->getKey(),
                'hash' => sha1($notifiable->getEmailForVerification()),
            ]
        );
    }
}