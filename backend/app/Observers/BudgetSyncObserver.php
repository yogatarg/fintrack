<?php
// app/Observers/BudgetSyncObserver.php — versi final

namespace App\Observers;

use App\Models\Transaction;
use App\Repositories\Contracts\BudgetRepositoryInterface;
use Carbon\Carbon;

class BudgetSyncObserver
{
    public function __construct(
        private BudgetRepositoryInterface $budgetRepository
    ) {}

    public function created(Transaction $transaction): void
    {
        $this->syncIfExpense($transaction);
    }

    public function updated(Transaction $transaction): void
    {
        // Jika kategori berubah, sync budget kategori lama
        if ($transaction->wasChanged('category_id')) {
            $this->syncByCategory(
                $transaction->user_id,
                $transaction->getOriginal('category_id'),
                $transaction->getOriginal('transaction_date')
            );
        }

        $this->syncIfExpense($transaction);
    }

    public function deleted(Transaction $transaction): void
    {
        $this->syncIfExpense($transaction);
    }

    private function syncIfExpense(Transaction $transaction): void
    {
        if ($transaction->type !== 'expense') {
            return;
        }

        $this->syncByCategory(
            $transaction->user_id,
            $transaction->category_id,
            $transaction->transaction_date
        );
    }

    private function syncByCategory(int $userId, int $categoryId, $date): void
    {
        $dateStr = Carbon::parse($date)->toDateString();

        $budget = $this->budgetRepository->findActiveByCategoryAndDate(
            $userId,
            $categoryId,
            $dateStr
        );

        if (! $budget) {
            return;
        }

        $this->budgetRepository->syncSpentAmount(
            $userId,
            $categoryId,
            Carbon::parse($budget->period_start)->toDateString(),
            Carbon::parse($budget->period_end)->toDateString()
        );
    }
}
