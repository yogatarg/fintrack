<?php
// app/Repositories/Contracts/SavingGoalRepositoryInterface.php

namespace App\Repositories\Contracts;

use App\Models\SavingGoal;
use Illuminate\Database\Eloquent\Collection;

interface SavingGoalRepositoryInterface
{
    public function allByUser(int $userId, ?string $status): Collection;
    public function findByUser(int $id, int $userId): SavingGoal;
    public function create(array $data): SavingGoal;
    public function update(SavingGoal $goal, array $data): SavingGoal;
    public function delete(SavingGoal $goal): void;
}