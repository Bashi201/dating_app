<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('reports', function (Blueprint $table) {
            $table->id();
            $table->foreignId('reporter_id')
                  ->constrained('users')
                  ->cascadeOnDelete();
            $table->foreignId('reported_id')
                  ->constrained('users')
                  ->cascadeOnDelete();

            $table->enum('reason', [
                'spam',
                'harassment',
                'fake_profile',
                'inappropriate_photos',
                'underage',
                'other',
            ]);
            $table->text('description')->nullable();

            $table->enum('status', ['pending', 'reviewed', 'dismissed'])
                  ->default('pending');
            $table->foreignId('reviewed_by')
                  ->nullable()
                  ->constrained('users')
                  ->nullOnDelete();
            $table->timestamp('reviewed_at')->nullable();

            $table->timestamps();

            $table->index('status');
            $table->index('reported_id');
            $table->index('reporter_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('reports');
    }
};