<?php
// app/Services/BudgetService.php

namespace App\Services;

use App\Models\Budget;
use App\Repositories\Contracts\BudgetRepositoryInterface;
use Carbon\Carbon;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\UniqueConstraintViolationException;
use Illuminate\Support\Facades\DB;

class BudgetService
{
    public function __construct(
        private BudgetRepositoryInterface $budgetRepository
    ) {}

    public function getUserBudgets(int $userId): Collection
    {
        return $this->budgetRepository->allByUser($userId);
    }

    public function createBudget(int $userId, array $data): Budget
    {
        // Layer 1: cek di aplikasi (cepat, user-friendly)
        $existing = $this->budgetRepository->findActiveByCategoryAndDate(
            $userId,
            $data['category_id'],
            $data['period_start']
        );

        if ($existing) {
            throw new \Exception('Budget untuk kategori ini di periode yang sama sudah ada.');
        }

        try {
            return DB::transaction(function () use ($userId, $data) {
                $budget = $this->budgetRepository->create(
                    array_merge($data, ['user_id' => $userId])
                );

                $this->budgetRepository->syncSpentAmount(
                    $userId,
                    $data['category_id'],
                    $data['period_start'],
                    $data['period_end']
                );

                return $budget->fresh(['category']);
            });
        } catch (UniqueConstraintViolationException $e) {
            // Layer 2: tangkap race condition dari DB constraint
            throw new \Exception('Budget untuk kategori ini di periode yang sama sudah ada.');
        }
    }

    public function updateBudget(int $id, int $userId, array $data): Budget
    {
        $budget = $this->budgetRepository->findByUser($id, $userId);

        return DB::transaction(function () use ($budget, $userId, $data) {
            $updated = $this->budgetRepository->update($budget, $data);

            // Jika periode berubah, sync ulang spent_amount
            if (isset($data['period_start']) || isset($data['period_end'])) {
                $this->budgetRepository->syncSpentAmount(
                    $userId,
                    $updated->category_id,
                    Carbon::parse($updated->period_start)->toDateString(),
                    Carbon::parse($updated->period_end)->toDateString()
                );
            }

            return $updated;
        });
    }

    public function deleteBudget(int $id, int $userId): void
    {
        $budget = $this->budgetRepository->findByUser($id, $userId);
        $this->budgetRepository->delete($budget);
    }

    public function syncAllActive(int $userId): void
    {
        $this->budgetRepository->syncAllActiveByUser($userId);
    }
}
