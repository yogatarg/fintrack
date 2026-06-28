<?php
// app/Services/Analytics/NoSpendDayService.php

namespace App\Services\Analytics;

use App\Models\Transaction;
use Carbon\Carbon;
use Illuminate\Support\Collection;

class NoSpendDayService
{
    public function analyze(int $userId): array
    {
        $today        = Carbon::today();
        $startOfMonth = $today->copy()->startOfMonth();

        $spendDaysThisMonth = $this->getSpendDays($userId, $startOfMonth, $today);
        $totalDaysThisMonth = $today->day;
        $noSpendThisMonth   = $totalDaysThisMonth - $spendDaysThisMonth;

        $currentStreak = $this->getCurrentStreak($userId, $today);
        $longestStreak = $this->getLongestStreak($userId);

        return [
            'no_spend_days_this_month' => $noSpendThisMonth,
            'spend_days_this_month'    => $spendDaysThisMonth,
            'total_days_this_month'    => $totalDaysThisMonth,
            'current_streak'           => $currentStreak,
            'longest_streak'           => $longestStreak,
            'message'                  => $this->buildMessage($noSpendThisMonth, $currentStreak),
        ];
    }

    private function getSpendDays(int $userId, Carbon $start, Carbon $end): int
    {
        return Transaction::where('user_id', $userId)
            ->where('type', 'expense')
            ->whereBetween('transaction_date', [$start, $end])
            ->distinct('transaction_date')
            ->count('transaction_date');
    }

    private function getCurrentStreak(int $userId, Carbon $today): int
    {
        // Ambil semua hari dengan pengeluaran dalam 365 hari terakhir — 1 query
        $spendDates = Transaction::where('user_id', $userId)
            ->where('type', 'expense')
            ->whereDate('transaction_date', '>=', $today->copy()->subDays(365))
            ->whereDate('transaction_date', '<=', $today)
            ->distinct('transaction_date')
            ->orderByDesc('transaction_date')
            ->pluck('transaction_date')
            ->map(fn($d) => Carbon::parse($d)->toDateString())
            ->toArray();

        // Jika hari ini ada pengeluaran, streak = 0
        if (in_array($today->toDateString(), $spendDates)) {
            return 0;
        }

        $streak = 0;
        $date   = $today->copy()->subDay();

        // Iterasi di memory, bukan ke DB
        while (true) {
            if (in_array($date->toDateString(), $spendDates)) {
                break;
            }

            $streak++;
            $date->subDay();

            if ($streak > 365) {
                break;
            }

        }

        return $streak;
    }

    private function getLongestStreak(int $userId): int
    {
        // Ambil semua hari yang punya pengeluaran dalam 1 tahun terakhir
        $spendDates = Transaction::where('user_id', $userId)
            ->where('type', 'expense')
            ->whereDate('transaction_date', '>=', Carbon::now()->subYear())
            ->distinct('transaction_date')
            ->pluck('transaction_date')
            ->map(fn($d) => Carbon::parse($d)->toDateString())
            ->sort()
            ->values();

        if ($spendDates->isEmpty()) {
            return (int) Carbon::now()->subYear()->diffInDays(Carbon::now());
        }

        return $this->calculateLongestGap($spendDates);
    }

    private function calculateLongestGap(Collection $spendDates): int
    {
        $longest = 0;

        for ($i = 0; $i < $spendDates->count() - 1; $i++) {
            $gap = Carbon::parse($spendDates[$i])->diffInDays(
                Carbon::parse($spendDates[$i + 1])
            ) - 1;

            $longest = max($longest, $gap);
        }

        return $longest;
    }

    private function buildMessage(int $noSpendDays, int $streak): string
    {
        if ($streak > 0) {
            return "Hebat! Anda sedang dalam streak {$streak} hari tanpa pengeluaran.";
        }

        return "Bulan ini Anda memiliki {$noSpendDays} hari tanpa pengeluaran. Terus pertahankan!";
    }
}
