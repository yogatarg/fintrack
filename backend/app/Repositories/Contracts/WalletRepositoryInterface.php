<?php
// app/Repositories/Contracts/WalletRepositoryInterface.php

namespace App\Repositories\Contracts;

use App\Models\Wallet;
use Illuminate\Database\Eloquent\Collection;

interface WalletRepositoryInterface
{
    public function allByUser(int $userId): Collection;
    public function findByUser(int $id, int $userId): Wallet;
    public function create(array $data): Wallet;
    public function update(Wallet $wallet, array $data): Wallet;
    public function delete(Wallet $wallet): void;
    public function updateBalance(int $walletId): void;
}
