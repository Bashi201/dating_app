<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('likes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('liker_id')
                  ->constrained('users')
                  ->cascadeOnDelete();
            $table->foreignId('liked_id')
                  ->constrained('users')
                  ->cascadeOnDelete();

            $table->timestamp('created_at')->useCurrent();

            $table->unique(['liker_id', 'liked_id']);

            $table->index('liker_id');
            $table->index('liked_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('likes');
    }
};