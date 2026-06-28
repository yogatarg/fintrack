<?php
// app/Services/DashboardService.php

namespace App\Services;

use App\Models\Transaction;
use App\Models\Wallet;
use Carbon\Carbon;
use Illuminate\Support\Collection;

class DashboardService
{
    public function getSummary(int $userId): array
    {
        $now = Carbon::now();

        return [
            'total_balance'        => $this->getTotalBalance($userId),
            'monthly_income'       => $this->getMonthlyIncome($userId, $now),
            'monthly_expense'      => $this->getMonthlyExpense($userId, $now),
            'monthly_net'          => $this->getMonthlyNet($userId, $now),
            'expense_by_category'  => $this->getExpenseByCategory($userId, $now),
            'monthly_trend'        => $this->getMonthlyTrend($userId),
        ];
    }

    private function getTotalBalance(int $userId): float
    {
        return (float) Wallet::where('user_id', $userId)->sum('balance');
    }

    private function getMonthlyIncome(int $userId, Carbon $date): float
    {
        return (float) Transaction::where('user_id', $userId)
            ->where('type', 'income')
            ->whereMonth('transaction_date', $date->month)
            ->whereYear('transaction_date', $date->year)
            ->sum('amount');
    }

    private function getMonthlyExpense(int $userId, Carbon $date): float
    {
        return (float) Transaction::where('user_id', $userId)
            ->where('type', 'expense')
            ->whereMonth('transaction_date', $date->month)
            ->whereYear('transaction_date', $date->year)
            ->sum('amount');
    }

    private function getMonthlyNet(int $userId, Carbon $date): float
    {
        return $this->getMonthlyIncome($userId, $date)
             - $this->getMonthlyExpense($userId, $date);
    }

    private function getExpenseByCategory(int $userId, Carbon $date): Collection
    {
        return Transaction::with('category')
            ->where('user_id', $userId)
            ->where('type', 'expense')
            ->whereMonth('transaction_date', $date->month)
            ->whereYear('transaction_date', $date->year)
            ->selectRaw('category_id, SUM(amount) as total')
            ->groupBy('category_id')
            ->get()
            ->map(fn($item) => [
                'category_id'   => $item->category_id,
                'category_name' => $item->category->name ?? '-',
                'color'         => $item->category->color ?? '#607D8B',
                'total'         => (float) $item->total,
            ]);
    }

    private function getMonthlyTrend(int $userId): Collection
    {
        // 6 bulan terakhir
        return collect(range(5, 0))->map(function ($monthsAgo) use ($userId) {
            $date = Carbon::now()->subMonths($monthsAgo);

            $income  = (float) Transaction::where('user_id', $userId)
                ->where('type', 'income')
                ->whereMonth('transaction_date', $date->month)
                ->whereYear('transaction_date', $date->year)
                ->sum('amount');

            $expense = (float) Transaction::where('user_id', $userId)
                ->where('type', 'expense')
                ->whereMonth('transaction_date', $date->month)
                ->whereYear('transaction_date', $date->year)
                ->sum('amount');

            return [
                'month'   => $date->format('Y-m'),
                'label'   => $date->translatedFormat('M Y'),
                'income'  => $income,
                'expense' => $expense,
                'net'     => $income - $expense,
            ];
        });
    }
}