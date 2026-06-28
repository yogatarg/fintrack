<?php
// app/Services/SavingGoalService.php

namespace App\Services;

use App\Models\SavingGoal;
use App\Repositories\Contracts\SavingGoalRepositoryInterface;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\DB;

class SavingGoalService
{
    public function __construct(
        private SavingGoalRepositoryInterface $savingGoalRepository
    ) {}

    public function getUserGoals(int $userId, ?string $status = null): Collection
    {
        return $this->savingGoalRepository->allByUser($userId, $status);
    }

    public function createGoal(int $userId, array $data): SavingGoal
    {
        return $this->savingGoalRepository->create(
            array_merge($data, [
                'user_id'        => $userId,
                'current_amount' => 0,
                'status'         => 'active',
            ])
        );
    }

    public function updateGoal(int $id, int $userId, array $data): SavingGoal
    {
        $goal = $this->savingGoalRepository->findByUser($id, $userId);

        // Cegah edit goal yang sudah selesai/dibatalkan
        if (in_array($goal->status, ['completed', 'cancelled'])) {
            throw new \Exception("Goal dengan status '{$goal->status}' tidak dapat diubah.");
        }

        return $this->savingGoalRepository->update($goal, $data);
    }

    // app/Services/SavingGoalService.php — addProgress() diperbarui

    public function addProgress(int $id, int $userId, float $amount): SavingGoal
    {
        if ($amount <= 0) {
            throw new \InvalidArgumentException('Jumlah progress harus lebih dari 0.');
        }

        return DB::transaction(function () use ($id, $userId, $amount) {
            $goal = SavingGoal::where('id', $id)
                ->where('user_id', $userId)
                ->lockForUpdate()
                ->firstOrFail();

            if ($goal->status !== 'active') {
                throw new \Exception("Hanya goal aktif yang dapat ditambah progress-nya.");
            }

            $newAmount = min(
                $goal->current_amount + $amount,
                $goal->target_amount
            );

            $status = $newAmount >= $goal->target_amount ? 'completed' : 'active';

            return $this->savingGoalRepository->update($goal, [
                'current_amount' => $newAmount,
                'status'         => $status,
            ]);
        });
    }

    public function deleteGoal(int $id, int $userId): void
    {
        $goal = $this->savingGoalRepository->findByUser($id, $userId);

        // Soft delete saja — data histori tetap tersimpan
        $this->savingGoalRepository->delete($goal);
    }
}
