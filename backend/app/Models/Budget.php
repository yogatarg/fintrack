<?php
// app/Models/Budget.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Carbon;

/**
 * @property Carbon|null $period_start
 * @property Carbon|null $period_end
 */

class Budget extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'category_id',
        'amount',
        'spent_amount',
        'period_start',
        'period_end',
    ];

    protected $casts = [
        'amount'       => 'decimal:2',
        'spent_amount' => 'decimal:2',
        'period_start' => 'date',
        'period_end'   => 'date',
    ];

    // Relations
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    // Computed attributes
    public function getRemainingAmountAttribute(): float
    {
        return $this->amount - $this->spent_amount;
    }

    public function getUsagePercentageAttribute(): float
    {
        if ($this->amount <= 0) {
            return 0;
        }

        return round(($this->spent_amount / $this->amount) * 100, 2);
    }

    public function getIsOverBudgetAttribute(): bool
    {
        return $this->spent_amount > $this->amount;
    }
}
