<?php
// app/Services/Analytics/SpendingPredictionService.php

namespace App\Services\Analytics;

use App\Models\Transaction;
use Carbon\Carbon;

class SpendingPredictionService
{
    public function analyze(int $userId): array
    {
        $today          = Carbon::today();
        $startOfMonth   = $today->copy()->startOfMonth();
        $endOfMonth     = $today->copy()->endOfMonth();
        $dayOfMonth     = $today->day;
        $totalDaysMonth = $endOfMonth->day;
        $daysRemaining  = $totalDaysMonth - $dayOfMonth;

        $currentSpending = (float) Transaction::where('user_id', $userId)
            ->where('type', 'expense')
            ->whereBetween('transaction_date', [$startOfMonth, $today])
            ->sum('amount');

        // Guard: hari pertama atau belum ada pengeluaran
        if ($dayOfMonth === 0 || $currentSpending === 0.0) {
            return [
                'current_spending'      => 0.0,
                'daily_average'         => 0.0,
                'predicted_total'       => 0.0,
                'last_month_spending'   => $this->getLastMonthSpending($userId, $today),
                'percentage_difference' => 0.0,
                'days_remaining'        => $daysRemaining,
                'message'               => 'Belum ada data pengeluaran bulan ini untuk membuat prediksi.',
            ];
        }

        $dailyAverage      = round($currentSpending / $dayOfMonth, 2);
        $predictedTotal    = round($currentSpending + ($dailyAverage * $daysRemaining), 2);
        $lastMonthSpending = $this->getLastMonthSpending($userId, $today);

        $percentageDiff = $lastMonthSpending > 0
            ? round((($predictedTotal - $lastMonthSpending) / $lastMonthSpending) * 100, 1)
            : 0;

        return [
            'current_spending'      => $currentSpending,
            'daily_average'         => $dailyAverage,
            'predicted_total'       => $predictedTotal,
            'last_month_spending'   => $lastMonthSpending,
            'percentage_difference' => $percentageDiff,
            'days_remaining'        => $daysRemaining,
            'message'               => $this->buildMessage($predictedTotal, $lastMonthSpending, $percentageDiff),
        ];
    }

    private function getLastMonthSpending(int $userId, Carbon $today): float
    {
        $lastMonth = $today->copy()->subMonth();

        return (float) Transaction::where('user_id', $userId)
            ->where('type', 'expense')
            ->whereMonth('transaction_date', $lastMonth->month)
            ->whereYear('transaction_date', $lastMonth->year)
            ->sum('amount');
    }

    private function buildMessage(float $predicted, float $lastMonth, float $diff): string
    {
        if ($lastMonth === 0.0) {
            return 'Prediksi pengeluaran bulan ini sebesar Rp' . number_format($predicted, 0, ',', '.');
        }

        $direction = $diff >= 0 ? 'lebih tinggi' : 'lebih rendah';
        $absDiff   = abs($diff);

        return "Prediksi pengeluaran bulan ini Rp" . number_format($predicted, 0, ',', '.') .
            ", {$absDiff}% {$direction} dibanding bulan lalu.";
    }
}
