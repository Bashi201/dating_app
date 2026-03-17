<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('matches', function (Blueprint $table) {
            $table->id();

            $table->foreignId('user1_id')
                  ->constrained('users')
                  ->cascadeOnDelete();
            $table->foreignId('user2_id')
                  ->constrained('users')
                  ->cascadeOnDelete();

            $table->timestamp('matched_at')->useCurrent();
            $table->boolean('is_active')->default(true);

            $table->unique(['user1_id', 'user2_id']);

            $table->index('user1_id');
            $table->index('user2_id');
            $table->index('is_active');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('matches');
    }
};