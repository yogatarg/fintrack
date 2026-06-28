<?php
// database/migrations/2024_01_01_000005_create_budgets_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('budgets', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('category_id')->constrained()->cascadeOnDelete();
            $table->decimal('amount', 15, 2);
            $table->decimal('spent_amount', 15, 2)->default(0);
            $table->date('period_start');
            $table->date('period_end');
            $table->timestamps();
            $table->softDeletes();

            // Satu budget per kategori per periode
            $table->unique(['user_id', 'category_id', 'period_start', 'period_end']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('budgets');
    }
};