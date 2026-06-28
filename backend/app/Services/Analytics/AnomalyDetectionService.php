<?php
// app/Services/Analytics/AnomalyDetectionService.php

namespace App\Services\Analytics;

use App\Models\Transaction;
use Carbon\Carbon;
use Illuminate\Support\Collection;

class AnomalyDetectionService
{
    // Transaksi dianggap anomali jika > rata-rata + 2 * standar deviasi
    private const Z_SCORE_THRESHOLD = 2.0;

    public function analyze(int $userId): Collection
    {
        $recentTransactions = Transaction::with('category')
            ->where('user_id', $userId)
            ->where('type', 'expense')
            ->whereDate('transaction_date', '>=', Carbon::now()->subDays(7))
            ->get();

        return $recentTransactions
            ->filter(fn(Transaction $t) => $this->isAnomaly($t, $userId))
            ->map(fn(Transaction $t) => $this->buildAnomalyReport($t, $userId))
            ->values();
    }

    private function isAnomaly(Transaction $transaction, int $userId): bool
    {
        [$mean, $stdDev, $hasEnoughData] = $this->getCategoryStats(
            $userId,
            $transaction->category_id
        );

        if (! $hasEnoughData) {
            return false;
        }

        $zScore = ($transaction->amount - $mean) / $stdDev;

        return $zScore > self::Z_SCORE_THRESHOLD;
    }

    private function getCategoryStats(int $userId, int $categoryId): array
    {
        $amounts = Transaction::where('user_id', $userId)
            ->where('category_id', $categoryId)
            ->where('type', 'expense')
            ->whereDate('transaction_date', '>=', Carbon::now()->subDays(90))
            ->pluck('amount')
            ->map(fn($a) => (float) $a);

        // Minimal 5 data agar statistik bermakna, bukan 3
        if ($amounts->count() < 5) {
            return [0, 0, false];
        }

        $mean   = $amounts->average();
        $stdDev = $this->calculateStdDev($amounts->toArray(), $mean);

        // StdDev terlalu kecil = data terlalu seragam, skip
        if ($stdDev < 100) {
            return [0, 0, false];
        }

        return [$mean, $stdDev, true];
    }

    private function calculateStdDev(array $values, float $mean): float
    {
        $count = count($values);
        if ($count < 2) {
            return 0;
        }

        $variance = array_sum(array_map(fn($v) => pow($v - $mean, 2), $values)) / ($count - 1);

        return sqrt($variance);
    }

    private function buildAnomalyReport(Transaction $transaction, int $userId): array
    {
        [$mean, $stdDev] = $this->getCategoryStats($userId, $transaction->category_id);
        $deviation       = $stdDev > 0
            ? round(($transaction->amount - $mean) / $stdDev, 1)
            : 0;

        return [
            'transaction_id'   => $transaction->id,
            'category_name'    => $transaction->category->name ?? '-',
            'amount'           => (float) $transaction->amount,
            'normal_average'   => round($mean, 2),
            'deviation_score'  => $deviation,
            'transaction_date' => $transaction->transaction_date->toDateString(),
            'message'          => "Pengeluaran {$transaction->category->name} pada " .
            $transaction->transaction_date->format('d M Y') .
            " jauh di atas pola normal Anda.",
        ];
    }
}
