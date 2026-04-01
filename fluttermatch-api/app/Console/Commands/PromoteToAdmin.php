<?php

namespace App\Console\Commands;

use App\Models\User;
use Illuminate\Console\Command;

class PromoteToAdmin extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'user:admin {email}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Promote a user to administrator role';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $email = $this->argument('email');
        $user = User::where('email', $email)->first();

        if (!$user) {
            $this->error("User not found with email: {$email}");
            return 1;
        }

        $user->update(['role' => 'admin']);

        $this->info("User {$user->name} ({$email}) has been promoted to Admin.");
        return 0;
    }
}
