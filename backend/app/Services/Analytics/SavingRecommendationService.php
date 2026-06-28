<?php
// app/Services/Analytics/SavingRecommendationService.php

namespace App\Services\Analytics;

use App\Models\SavingGoal;
use Carbon\Carbon;
use Illuminate\Support\Collection;

class SavingRecommendationService
{
    public function analyze(int $userId): Collection
    {
        return SavingGoal::where('user_id', $userId)
            ->where('status', 'active')
            ->get()
            ->map(fn(SavingGoal $goal) => $this->buildRecommendation($goal));
    }

    private function buildRecommendation(SavingGoal $goal): array
    {
        $monthsRemaining = max(1, now()->diffInMonths($goal->deadline));
        $remaining       = $goal->remaining_amount;
        $monthlyRequired = round($remaining / $monthsRemaining, 2);
        $weeklyRequired  = round($remaining / max(1, now()->diffInWeeks($goal->deadline)), 2);
        $isAchievable    = $monthsRemaining > 0 && $remaining > 0;

        return [
            'goal_id'          => $goal->id,
            'goal_name'        => $goal->name,
            'target_amount'    => (float) $goal->target_amount,
            'current_amount'   => (float) $goal->current_amount,
            'remaining_amount' => (float) $remaining,
            'deadline'         => Carbon::parse($goal->deadline)->toDateString(),
            'months_remaining' => $monthsRemaining,
            'monthly_required' => $monthlyRequired,
            'weekly_required'  => $weeklyRequired,
            'is_achievable'    => $isAchievable,
            'message'          => $this->buildMessage($goal, $monthlyRequired, $monthsRemaining),
        ];
    }

    private function buildMessage(SavingGoal $goal, float $monthly, int $months): string
    {
        $name    = $goal->name;
        $target  = 'Rp' . number_format((float) $goal->target_amount, 0, ',', '.');
        $monthly = 'Rp' . number_format($monthly, 0, ',', '.');

        return "Untuk mencapai target {$name} {$target} dalam {$months} bulan, " .
            "Anda perlu menabung {$monthly} per bulan.";
    }
}
