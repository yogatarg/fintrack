<?php
// app/Repositories/TransactionRepository.php

namespace App\Repositories;

use App\Models\Transaction;
use App\Repositories\Contracts\TransactionRepositoryInterface;
use Illuminate\Pagination\LengthAwarePaginator;

class TransactionRepository implements TransactionRepositoryInterface
{
    public function paginateByUser(int $userId, array $filters): LengthAwarePaginator
    {
        return Transaction::with(['wallet', 'category'])
            ->where('user_id', $userId)
            ->when(isset($filters['type']),        fn($q) => $q->where('type', $filters['type']))
            ->when(isset($filters['wallet_id']),   fn($q) => $q->where('wallet_id', $filters['wallet_id']))
            ->when(isset($filters['category_id']), fn($q) => $q->where('category_id', $filters['category_id']))
            ->when(isset($filters['start_date']),  fn($q) => $q->whereDate('transaction_date', '>=', $filters['start_date']))
            ->when(isset($filters['end_date']),    fn($q) => $q->whereDate('transaction_date', '<=', $filters['end_date']))
            ->orderBy('transaction_date', 'desc')
            ->orderBy('created_at', 'desc')
            ->paginate(15);
    }

    public function findByUser(int $id, int $userId): Transaction
    {
        return Transaction::with(['wallet', 'category'])
            ->where('id', $id)
            ->where('user_id', $userId)
            ->firstOrFail();
    }

    public function create(array $data): Transaction
    {
        return Transaction::create($data);
    }

    public function update(Transaction $transaction, array $data): Transaction
    {
        $transaction->update($data);
        return $transaction->fresh(['wallet', 'category']);
    }

    public function delete(Transaction $transaction): void
    {
        $transaction->delete();
    }
}