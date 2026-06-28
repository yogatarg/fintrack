<?php
// app/DTOs/MonthlyReviewDTO.php

namespace App\DTOs;

class MonthlyReviewDTO
{
    public function __construct(
        public readonly string $period,
        public readonly float  $total_income,
        public readonly float  $total_expense,
        public readonly float  $total_saving,
        public readonly array  $top_categories,
        public readonly array  $increased_categories,
        public readonly float  $saving_rate,
    ) {}

    public function toArray(): array
    {
        return [
            'period'                => $this->period,
            'total_income'          => $this->total_income,
            'total_expense'         => $this->total_expense,
            'total_saving'          => $this->total_saving,
            'saving_rate'           => $this->saving_rate,
            'top_categories'        => $this->top_categories,
            'increased_categories'  => $this->increased_categories,
        ];
    }
}