<?php
// app/Repositories/Contracts/BudgetRepositoryInterface.php

namespace App\Repositories\Contracts;

use App\Models\Budget;
use Illuminate\Database\Eloquent\Collection;

interface BudgetRepositoryInterface
{
    public function allByUser(int $userId): Collection;
    public function findByUser(int $id, int $userId): Budget;
    public function findActiveByCategoryAndDate(int $userId, int $categoryId, string $date): ?Budget;
    public function create(array $data): Budget;
    public function update(Budget $budget, array $data): Budget;
    public function delete(Budget $budget): void;
    public function syncSpentAmount(int $userId, int $categoryId, string $periodStart, string $periodEnd): void;
    public function syncAllActiveByUser(int $userId): void;
}
