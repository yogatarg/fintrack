<?php
// app/DTOs/SpendingAlertDTO.php

namespace App\DTOs;

class SpendingAlertDTO
{
    public function __construct(
        public readonly bool   $is_alert_triggered,
        public readonly float  $today_spending,
        public readonly float  $daily_average,
        public readonly float  $percentage_above_average,
        public readonly string $message,
    ) {}

    public function toArray(): array
    {
        return [
            'is_alert_triggered'      => $this->is_alert_triggered,
            'today_spending'          => $this->today_spending,
            'daily_average'           => $this->daily_average,
            'percentage_above_average'=> $this->percentage_above_average,
            'message'                 => $this->message,
        ];
    }
}