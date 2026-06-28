<?php
// app/Repositories/SavingGoalRepository.php

namespace App\Repositories;

use App\Models\SavingGoal;
use App\Repositories\Contracts\SavingGoalRepositoryInterface;
use Illuminate\Database\Eloquent\Collection;

class SavingGoalRepository implements SavingGoalRepositoryInterface
{
    public function allByUser(int $userId, ?string $status = null): Collection
    {
        return SavingGoal::where('user_id', $userId)
            ->when($status, fn($q) => $q->where('status', $status))
            ->orderBy('deadline', 'asc')
            ->get();
    }

    public function findByUser(int $id, int $userId): SavingGoal
    {
        return SavingGoal::where('id', $id)
            ->where('user_id', $userId)
            ->firstOrFail();
    }

    public function create(array $data): SavingGoal
    {
        return SavingGoal::create($data);
    }

    public function update(SavingGoal $goal, array $data): SavingGoal
    {
        $goal->update($data);
        return $goal->fresh();
    }

    public function delete(SavingGoal $goal): void
    {
        $goal->delete();
    }
}