<?php
// app/Http/Resources/BudgetResource.php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class BudgetResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'           => $this->id,
            'amount'       => (float) $this->amount,
            'spent_amount' => (float) $this->spent_amount,
            'period_start' => $this->period_start->toDateString(),
            'period_end'   => $this->period_end->toDateString(),
            'category' => [
                'id'    => $this->category->id,
                'name'  => $this->category->name,
                'icon'  => $this->category->icon,
                'color' => $this->category->color,
            ],
            // Dari computed attribute di Model
            'remaining_amount'  => $this->remaining_amount,
            'usage_percentage'  => $this->usage_percentage,
            'is_over_budget'    => $this->is_over_budget,
            // Untuk Smart Feature Phase 5
            'risk_level'        => $this->getRiskLevel(),
        ];
    }

    // Logika risk level tetap di Resource, bukan Model
    // karena ini concern presentasi, bukan business logic
    private function getRiskLevel(): string
    {
        $percentage  = $this->usage_percentage;
        $periodRatio = $this->getPeriodProgressRatio();

        if ($this->is_over_budget) return 'over';

        // Spending lebih cepat dari periode berjalan
        if ($percentage > ($periodRatio * 100) + 20) return 'high';
        if ($percentage >= 80) return 'medium';

        return 'low';
    }

    private function getPeriodProgressRatio(): float
    {
        $totalDays   = $this->period_start->diffInDays($this->period_end) ?: 1;
        $elapsedDays = $this->period_start->diffInDays(now());
        $elapsedDays = min($elapsedDays, $totalDays);

        return round($elapsedDays / $totalDays, 2);
    }
}