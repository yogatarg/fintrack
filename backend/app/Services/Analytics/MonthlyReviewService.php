<?php
// app/Services/Analytics/MonthlyReviewService.php

namespace App\Services\Analytics;

use App\DTOs\MonthlyReviewDTO;
use App\Models\Transaction;
use Carbon\Carbon;

class MonthlyReviewService
{
    public function analyze(int $userId, ?string $yearMonth = null): MonthlyReviewDTO
    {
        try {
            $date = $yearMonth
                ? Carbon::createFromFormat('Y-m', $yearMonth)->startOfMonth()
                : Carbon::now()->subMonth()->startOfMonth();
        } catch (\Exception $e) {
            // Fallback ke bulan lalu jika format tidak valid
            $date = Carbon::now()->subMonth()->startOfMonth();
        }

        // Cegah request bulan yang akan datang
        if ($date->isFuture()) {
            $date = Carbon::now()->subMonth()->startOfMonth();
        }

        $income  = $this->getMonthlyTotal($userId, $date, 'income');
        $expense = $this->getMonthlyTotal($userId, $date, 'expense');
        $saving  = max(0, $income - $expense);

        return new MonthlyReviewDTO(
            period: $date->format('Y-m'),
            total_income: $income,
            total_expense: $expense,
            total_saving: $saving,
            top_categories: $this->getTopCategories($userId, $date),
            increased_categories: $this->getIncreasedCategories($userId, $date),
            saving_rate: $income > 0 ? round(($saving / $income) * 100, 1) : 0,
        );
    }

    private function getMonthlyTotal(int $userId, Carbon $date, string $type): float
    {
        return (float) Transaction::where('user_id', $userId)
            ->where('type', $type)
            ->whereMonth('transaction_date', $date->month)
            ->whereYear('transaction_date', $date->year)
            ->sum('amount');
    }

    private function getTopCategories(int $userId, Carbon $date): array
    {
        return Transaction::with('category')
            ->where('user_id', $userId)
            ->where('type', 'expense')
            ->whereMonth('transaction_date', $date->month)
            ->whereYear('transaction_date', $date->year)
            ->selectRaw('category_id, SUM(amount) as total')
            ->groupBy('category_id')
            ->orderByDesc('total')
            ->limit(5)
            ->get()
            ->map(fn($item) => [
                'category_name' => $item->category->name ?? '-',
                'total'         => (float) $item->total,
            ])
            ->toArray();
    }

    private function getIncreasedCategories(int $userId, Carbon $date): array
    {
        $prevDate = $date->copy()->subMonth();

        $current  = $this->getCategoryTotals($userId, $date);
        $previous = $this->getCategoryTotals($userId, $prevDate);

        return $current
            ->filter(function ($total, $categoryId) use ($previous) {
                $prevTotal = $previous->get($categoryId, 0);
                return $prevTotal > 0 && $total > $prevTotal;
            })
            ->map(function ($total, $categoryId) use ($previous) {
                $prevTotal    = $previous->get($categoryId, 0);
                $increaseRate = round((($total - $prevTotal) / $prevTotal) * 100, 1);

                return [
                    'category_id'   => $categoryId,
                    'current_total' => $total,
                    'prev_total'    => $prevTotal,
                    'increase_rate' => $increaseRate,
                ];
            })
            ->sortByDesc('increase_rate')
            ->values()
            ->toArray();
    }

    private function getCategoryTotals(int $userId, Carbon $date): \Illuminate\Support\Collection
    {
        return Transaction::where('user_id', $userId)
            ->where('type', 'expense')
            ->whereMonth('transaction_date', $date->month)
            ->whereYear('transaction_date', $date->year)
            ->selectRaw('category_id, SUM(amount) as total')
            ->groupBy('category_id')
            ->get()
            ->pluck('total', 'category_id')
            ->map(fn($v) => (float) $v);
    }
}
