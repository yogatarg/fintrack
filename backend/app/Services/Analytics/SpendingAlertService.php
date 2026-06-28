<?php
// app/Services/Analytics/SpendingAlertService.php

namespace App\Services\Analytics;

use App\DTOs\SpendingAlertDTO;
use App\Models\Transaction;
use Carbon\Carbon;

class SpendingAlertService
{
    // Alert dipicu jika pengeluaran hari ini > rata-rata harian * threshold
    private const ALERT_THRESHOLD = 1.5; // 150% dari rata-rata

    public function analyze(int $userId): SpendingAlertDTO
    {
        $today         = Carbon::today();
        $todaySpending = $this->getTodaySpending($userId, $today);
        $dailyAverage  = $this->getDailyAverage($userId, $today);

        $percentageAbove  = 0;
        $isAlertTriggered = false;
        $message          = 'Pengeluaran hari ini masih dalam batas normal.';

        if ($dailyAverage > 0) {
            $percentageAbove  = round((($todaySpending / $dailyAverage) - 1) * 100, 1);
            $isAlertTriggered = $todaySpending > ($dailyAverage * self::ALERT_THRESHOLD);
        }

        if ($isAlertTriggered) {
            $message = "Pengeluaran hari ini {$percentageAbove}% lebih tinggi dibanding rata-rata harian Anda.";
        } elseif ($todaySpending === 0.0) {
            $message = 'Belum ada pengeluaran hari ini. Pertahankan!';
        }

        return new SpendingAlertDTO(
            is_alert_triggered:       $isAlertTriggered,
            today_spending:           $todaySpending,
            daily_average:            $dailyAverage,
            percentage_above_average: $percentageAbove,
            message:                  $message,
        );
    }

    private function getTodaySpending(int $userId, Carbon $today): float
    {
        return (float) Transaction::where('user_id', $userId)
            ->where('type', 'expense')
            ->whereDate('transaction_date', $today)
            ->sum('amount');
    }

    private function getDailyAverage(int $userId, Carbon $today): float
    {
        // Rata-rata dari 30 hari terakhir, exclude hari ini
        $startDate = $today->copy()->subDays(30);
        $endDate   = $today->copy()->subDay();

        $totalExpense = (float) Transaction::where('user_id', $userId)
            ->where('type', 'expense')
            ->whereBetween('transaction_date', [$startDate, $endDate])
            ->sum('amount');

        // Hitung hari aktual yang memiliki data (bukan selalu 30)
        $activeDays = Transaction::where('user_id', $userId)
            ->where('type', 'expense')
            ->whereBetween('transaction_date', [$startDate, $endDate])
            ->distinct('transaction_date')
            ->count('transaction_date');

        return $activeDays > 0 ? round($totalExpense / $activeDays, 2) : 0;
    }
}