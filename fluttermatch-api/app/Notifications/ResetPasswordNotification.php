use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;

class ResetPasswordNotification extends Notification implements ShouldQueue
{
    use Queueable;

    public string $token;

    public function __construct(string $token)
    {
        $this->token = $token;
    }

    public function via($notifiable): array
    {
        return ['mail'];
    }

    public function toMail($notifiable): MailMessage
    {
        // Builds the Flutter Web reset URL
        // e.g. http://localhost:8080/reset-password?token=xxx&email=yyy
        $url = config('app.frontend_url') . '/reset-password'
            . '?token=' . $this->token
            . '&email=' . urlencode($notifiable->email);

        return (new MailMessage)
            ->subject('Reset Your Password - FlutterMatch')
            ->greeting('Hello ' . $notifiable->name . '!')
            ->line('You requested a password reset for your FlutterMatch account.')
            ->action('Reset Password', $url)
            ->line('This link expires in 60 minutes.')
            ->line('If you did not request this, ignore this email — your password will not change.');
    }
}