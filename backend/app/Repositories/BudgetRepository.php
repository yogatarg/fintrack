<?php
// app/Repositories/BudgetRepository.php

namespace App\Repositories;

use App\Models\Budget;
use App\Models\Transaction;
use App\Repositories\Contracts\BudgetRepositoryInterface;
use Illuminate\Database\Eloquent\Collection;

class BudgetRepository implements BudgetRepositoryInterface
{
    public function allByUser(int $userId): Collection
    {
        return Budget::with('category')
            ->where('user_id', $userId)
            ->orderBy('period_start', 'desc')
            ->get();
    }

    public function findByUser(int $id, int $userId): Budget
    {
        return Budget::with('category')
            ->where('id', $id)
            ->where('user_id', $userId)
            ->firstOrFail();
    }

    public function findActiveByCategoryAndDate(int $userId, int $categoryId, string $date): ?Budget
    {
        return Budget::where('user_id', $userId)
            ->where('category_id', $categoryId)
            ->where('period_start', '<=', $date)
            ->where('period_end', '>=', $date)
            ->first();
    }

    public function create(array $data): Budget
    {
        return Budget::create($data);
    }

    public function update(Budget $budget, array $data): Budget
    {
        $budget->update($data);
        return $budget->fresh(['category']);
    }

    public function delete(Budget $budget): void
    {
        $budget->delete();
    }

    public function syncSpentAmount(int $userId, int $categoryId, string $periodStart, string $periodEnd): void
    {
        $spent = Transaction::where('user_id', $userId)
            ->where('category_id', $categoryId)
            ->where('type', 'expense')
            ->whereBetween('transaction_date', [$periodStart, $periodEnd])
            ->sum('amount');

        Budget::where('user_id', $userId)
            ->where('category_id', $categoryId)
            ->where('period_start', $periodStart)
            ->where('period_end', $periodEnd)
            ->update(['spent_amount' => $spent]);
    }

    public function syncAllActiveByUser(int $userId): void
    {
        $activeBudgets = Budget::where('user_id', $userId)
            ->where('period_start', '<=', now()->toDateString())
            ->where('period_end', '>=', now()->toDateString())
            ->get();

        foreach ($activeBudgets as $budget) {
            $this->syncSpentAmount(
                $userId,
                $budget->category_id,
                $budget->period_start->toDateString(),
                $budget->period_end->toDateString()
            );
        }
    }
}
