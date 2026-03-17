<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('profiles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')
                  ->unique()
                  ->constrained()
                  ->cascadeOnDelete();

            $table->text('bio')->nullable();
            $table->unsignedTinyInteger('age')->nullable();
            $table->string('gender', 30)->nullable();
            $table->string('interested_in', 30)->nullable();

            $table->decimal('latitude', 10, 8)->nullable();
            $table->decimal('longitude', 11, 8)->nullable();
            $table->string('city', 100)->nullable();

            $table->json('interests')->nullable();

            $table->string('instagram', 100)->nullable();
            $table->string('spotify', 100)->nullable();

            $table->boolean('is_complete')->default(false);
            $table->boolean('show_me')->default(true);
            $table->unsignedTinyInteger('min_age')->default(18);
            $table->unsignedTinyInteger('max_age')->default(40);
            $table->unsignedInteger('max_distance')->default(50);

            $table->timestamps();

            $table->index(['show_me', 'age']);
            $table->index(['latitude', 'longitude']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('profiles');
    }
};