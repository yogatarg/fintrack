<?php
// app/Services/Analytics/BudgetRiskService.php

namespace App\Services\Analytics;

use App\DTOs\BudgetRiskDTO;
use App\Models\Budget;
use Carbon\Carbon;
use Illuminate\Support\Collection;

class BudgetRiskService
{
    public function analyze(int $userId): Collection
    {
        $today         = Carbon::today();
        $activeBudgets = Budget::with('category')
            ->where('user_id', $userId)
            ->where('period_start', '<=', $today)
            ->where('period_end', '>=', $today)
            ->get();

        return $activeBudgets->map(fn(Budget $budget) => $this->analyzeBudget($budget, $today));
    }

    private function analyzeBudget(Budget $budget, Carbon $today): BudgetRiskDTO
    {
        $usagePercentage  = $budget->usage_percentage;
        $periodRatio      = $this->getPeriodRatio($budget, $today);
        $periodPercentage = round($periodRatio * 100, 1);
        $riskLevel        = $this->determineRiskLevel($usagePercentage, $periodPercentage, $budget->is_over_budget);
        $message          = $this->buildMessage($budget, $usagePercentage, $periodPercentage, $riskLevel);

        return new BudgetRiskDTO(
            budget_id: $budget->id,
            category_name: $budget->category->name,
            usage_percentage: $usagePercentage,
            period_progress_percentage: $periodPercentage,
            risk_level: $riskLevel,
            message: $message,
        );
    }

    private function getPeriodRatio(Budget $budget, Carbon $today): float
    {
        $totalDays   = max(1, Carbon::parse($budget->period_start)->diffInDays(Carbon::parse($budget->period_end)));
        $elapsedDays = min(Carbon::parse($budget->period_start)->diffInDays($today), $totalDays);

        return round($elapsedDays / $totalDays, 4);
    }

    private function determineRiskLevel(float $usage, float $period, bool $isOver): string
    {
        if ($isOver) {
            return 'over';
        }

        if ($usage > $period + 20) {
            return 'high';
        }
        // Jauh di atas proporsi waktu
        if ($usage >= 80) {
            return 'medium';
        }

        return 'low';
    }

    private function buildMessage(Budget $budget, float $usage, float $period, string $risk): string
    {
        $name = $budget->category->name;

        return match ($risk) {
            'over' => "Budget {$name} telah melebihi batas! Terpakai {$usage}% dari total budget.",
            'high' => "Budget {$name} telah terpakai {$usage}% padahal periode baru berjalan {$period}%.",
            'medium' => "Budget {$name} hampir habis, sudah terpakai {$usage}%.",
            default => "Budget {$name} masih aman, terpakai {$usage}%.",
        };
    }
}
