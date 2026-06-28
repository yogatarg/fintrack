<?php
// app/Services/TransactionService.php

namespace App\Services;

use App\Models\Transaction;
use App\Models\Wallet;
use App\Repositories\Contracts\TransactionRepositoryInterface;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\DB;

class TransactionService
{
    public function __construct(
        private TransactionRepositoryInterface $transactionRepository
    ) {}

    public function getTransactions(int $userId, array $filters): LengthAwarePaginator
    {
        return $this->transactionRepository->paginateByUser($userId, $filters);
    }

    public function createTransaction(int $userId, array $data): Transaction
    {
        return DB::transaction(function () use ($userId, $data) {
            // Verifikasi wallet milik user
            $wallet = Wallet::where('id', $data['wallet_id'])
                ->where('user_id', $userId)
                ->lockForUpdate()
                ->firstOrFail();

            $transaction = $this->transactionRepository->create(
                array_merge($data, ['user_id' => $userId])
            );

            // Observer TransactionObserver & BudgetSyncObserver
            // otomatis terpicu setelah create

            return $transaction->load(['wallet', 'category']);
        });
    }

    public function updateTransaction(int $id, int $userId, array $data): Transaction
    {
        return DB::transaction(function () use ($id, $userId, $data) {
            $transaction = $this->transactionRepository->findByUser($id, $userId);

            // Jika wallet berubah, verifikasi wallet baru milik user
            if (isset($data['wallet_id']) && $data['wallet_id'] !== $transaction->wallet_id) {
                Wallet::where('id', $data['wallet_id'])
                    ->where('user_id', $userId)
                    ->lockForUpdate()
                    ->firstOrFail();
            }

            return $this->transactionRepository->update($transaction, $data);
        });
    }

    public function deleteTransaction(int $id, int $userId): void
    {
        DB::transaction(function () use ($id, $userId) {
            $transaction = $this->transactionRepository->findByUser($id, $userId);
            $this->transactionRepository->delete($transaction);
        });
    }
}