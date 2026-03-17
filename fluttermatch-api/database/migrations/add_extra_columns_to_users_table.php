<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->enum('role', ['user', 'admin'])->default('user')->after('password');
            $table->boolean('is_banned')->default(false)->after('role');
            $table->text('ban_reason')->nullable()->after('is_banned');
            $table->timestamp('last_active_at')->nullable()->after('email_verified_at');

            $table->index('role');
            $table->index('is_banned');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['role', 'is_banned', 'ban_reason', 'last_active_at']);
        });
    }
};