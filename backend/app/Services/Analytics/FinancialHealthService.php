<?php
// app/Services/Analytics/FinancialHealthService.php

namespace App\Services\Analytics;

use App\DTOs\FinancialHealthDTO;
use App\Models\Budget;
use App\Models\SavingGoal;
use App\Models\Transaction;
use Carbon\Carbon;

class FinancialHealthService
{
    public function analyze(int $userId): FinancialHealthDTO
    {
        $budgetCompliance   = $this->getBudgetComplianceScore($userId);
        $savingConsistency  = $this->getSavingConsistencyScore($userId);
        $expenseRatio       = $this->getExpenseRatioScore($userId);
        $financialStability = $this->getFinancialStabilityScore($userId);

        // Bobot skor
        $score = (int) round(
            ($budgetCompliance * 0.30) +
            ($savingConsistency * 0.25) +
            ($expenseRatio * 0.25) +
            ($financialStability * 0.20)
        );

        return new FinancialHealthDTO(
            score: $score,
            grade: $this->getGrade($score),
            budget_compliance: $budgetCompliance,
            saving_consistency: $savingConsistency,
            expense_ratio: $expenseRatio,
            financial_stability: $financialStability,
            insights: $this->buildInsights($budgetCompliance, $savingConsistency, $expenseRatio, $financialStability),
        );
    }

    // Skor 0-100: berapa % budget yang tidak melebihi batas
    // app/Services/Analytics/FinancialHealthService.php — update semua private method

    private function getBudgetComplianceScore(int $userId): float
    {
        $budgets = Budget::where('user_id', $userId)
            ->where('period_start', '>=', now()->subMonths(3))
            ->get();

        // Belum ada budget → netral, bukan 0
        if ($budgets->isEmpty()) {
            return 50.0;
        }

        $compliant = $budgets->filter(fn($b) => ! $b->is_over_budget)->count();
        return round(($compliant / $budgets->count()) * 100, 1);
    }

    private function getSavingConsistencyScore(int $userId): float
    {
        $months        = 3;
        $positiveMonth = 0;
        $hasAnyData    = false;

        for ($i = 0; $i < $months; $i++) {
            $date = Carbon::now()->subMonths($i);

            $income = (float) Transaction::where('user_id', $userId)
                ->where('type', 'income')
                ->whereMonth('transaction_date', $date->month)
                ->whereYear('transaction_date', $date->year)
                ->sum('amount');

            $expense = (float) Transaction::where('user_id', $userId)
                ->where('type', 'expense')
                ->whereMonth('transaction_date', $date->month)
                ->whereYear('transaction_date', $date->year)
                ->sum('amount');

            // Skip bulan yang belum ada data sama sekali
            if ($income === 0.0 && $expense === 0.0) {
                continue;
            }

            $hasAnyData = true;
            if ($income > $expense) {
                $positiveMonth++;
            }

        }

        // Belum ada data transaksi sama sekali → netral
        if (! $hasAnyData) {
            return 50.0;
        }

        return round(($positiveMonth / $months) * 100, 1);
    }

    private function getExpenseRatioScore(int $userId): float
    {
        $date = Carbon::now();

        $income = (float) Transaction::where('user_id', $userId)
            ->where('type', 'income')
            ->whereMonth('transaction_date', $date->month)
            ->whereYear('transaction_date', $date->year)
            ->sum('amount');

        $expense = (float) Transaction::where('user_id', $userId)
            ->where('type', 'expense')
            ->whereMonth('transaction_date', $date->month)
            ->whereYear('transaction_date', $date->year)
            ->sum('amount');

        // Belum ada income bulan ini → netral
        if ($income <= 0) {
            return 50.0;
        }

        $ratio = $expense / $income;
        return round(max(0, min(100, (1 - $ratio) * 100 + 30)), 1);
    }

    private function getFinancialStabilityScore(int $userId): float
    {
        $activeGoals = SavingGoal::where('user_id', $userId)
            ->where('status', 'active')
            ->get();

        // Belum ada saving goal → netral
        if ($activeGoals->isEmpty()) {
            return 50.0;
        }

        $onTrack = $activeGoals->filter(fn($g) => $g->progress_percentage >= 30)->count();
        return round(($onTrack / $activeGoals->count()) * 100, 1);
    }

    private function getGrade(int $score): string
    {
        return match (true) {
            $score >= 85 => 'A',
            $score >= 70 => 'B',
            $score >= 55 => 'C',
            $score >= 40 => 'D',
            default      => 'F',
        };
    }

    private function buildInsights(float $budget, float $saving, float $expense, float $stability): array
    {
        $insights = [];

        if ($budget < 60) {
            $insights[] = 'Beberapa budget Anda melebihi batas. Coba evaluasi pengeluaran per kategori.';
        }

        if ($saving < 60) {
            $insights[] = 'Konsistensi menabung perlu ditingkatkan. Coba sisihkan dana di awal bulan.';
        }

        if ($expense < 40) {
            $insights[] = 'Rasio pengeluaran terhadap pemasukan cukup tinggi. Pertimbangkan memangkas pengeluaran tidak prioritas.';
        }

        if ($stability < 50) {
            $insights[] = 'Progress saving goal Anda masih rendah. Tambahkan setoran rutin ke goal aktif Anda.';
        }

        if (empty($insights)) {
            $insights[] = 'Kondisi keuangan Anda sangat baik! Pertahankan kebiasaan ini.';
        }

        return $insights;
    }
}
