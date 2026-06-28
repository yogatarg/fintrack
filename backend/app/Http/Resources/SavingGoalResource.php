<?php
// app/Http/Resources/SavingGoalResource.php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SavingGoalResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'             => $this->id,
            'name'           => $this->name,
            'target_amount'  => (float) $this->target_amount,
            'current_amount' => (float) $this->current_amount,
            'deadline'       => $this->deadline->toDateString(),
            'status'         => $this->status,
            'icon'           => $this->icon,
            'color'          => $this->color,
            // Dari computed attribute di Model
            'progress_percentage' => $this->progress_percentage,
            'remaining_amount'    => $this->remaining_amount,
            'days_remaining'      => $this->days_remaining,
            'monthly_required'    => $this->monthly_required,
            'is_on_track'         => $this->getIsOnTrack(),
        ];
    }

    // Apakah tabungan sesuai jalur target?
    private function getIsOnTrack(): bool
    {
        if ($this->status !== 'active') return false;

        $totalMonths   = max(1, now()->diffInMonths($this->deadline, false));
        if ($totalMonths <= 0) return false;

        // Bulan sudah berjalan sejak goal dibuat
        $monthsElapsed = max(1, $this->created_at->diffInMonths(now()));
        $expectedSaved = ($this->target_amount / ($monthsElapsed + $totalMonths)) * $monthsElapsed;

        return $this->current_amount >= $expectedSaved;
    }
}