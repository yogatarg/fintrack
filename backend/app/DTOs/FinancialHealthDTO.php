<?php
// app/DTOs/FinancialHealthDTO.php

namespace App\DTOs;

class FinancialHealthDTO
{
    public function __construct(
        public readonly int    $score,            // 0-100
        public readonly string $grade,            // A/B/C/D/F
        public readonly float  $budget_compliance,
        public readonly float  $saving_consistency,
        public readonly float  $expense_ratio,
        public readonly float  $financial_stability,
        public readonly array  $insights,
    ) {}

    public function toArray(): array
    {
        return [
            'score'                => $this->score,
            'grade'                => $this->grade,
            'budget_compliance'    => $this->budget_compliance,
            'saving_consistency'   => $this->saving_consistency,
            'expense_ratio'        => $this->expense_ratio,
            'financial_stability'  => $this->financial_stability,
            'insights'             => $this->insights,
        ];
    }
}