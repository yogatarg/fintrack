<?php
// app/Repositories/Contracts/TransactionRepositoryInterface.php

namespace App\Repositories\Contracts;

use App\Models\Transaction;
use Illuminate\Pagination\LengthAwarePaginator;

interface TransactionRepositoryInterface
{
    public function paginateByUser(int $userId, array $filters): LengthAwarePaginator;
    public function findByUser(int $id, int $userId): Transaction;
    public function create(array $data): Transaction;
    public function update(Transaction $transaction, array $data): Transaction;
    public function delete(Transaction $transaction): void;
}