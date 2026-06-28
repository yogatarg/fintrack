<?php
// database/migrations/2024_01_01_000002_create_wallets_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('wallets', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->enum('type', ['cash', 'bank', 'e-wallet', 'investment'])->default('cash');
            $table->decimal('balance', 15, 2)->default(0);
            $table->string('currency', 3)->default('IDR');
            $table->string('icon')->nullable();
            $table->string('color', 7)->nullable(); // hex color
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('wallets');
    }
};