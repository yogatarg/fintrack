<?php
// app/DTOs/BudgetRiskDTO.php

namespace App\DTOs;

class BudgetRiskDTO
{
    public function __construct(
        public readonly int    $budget_id,
        public readonly string $category_name,
        public readonly float  $usage_percentage,
        public readonly float  $period_progress_percentage,
        public readonly string $risk_level,   // low | medium | high | over
        public readonly string $message,
    ) {}

    public function toArray(): array
    {
        return [
            'budget_id'                  => $this->budget_id,
            'category_name'              => $this->category_name,
            'usage_percentage'           => $this->usage_percentage,
            'period_progress_percentage' => $this->period_progress_percentage,
            'risk_level'                 => $this->risk_level,
            'message'                    => $this->message,
        ];
    }
}