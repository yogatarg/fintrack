<?php
// app/Repositories/WalletRepository.php

namespace App\Repositories;

use App\Models\Transaction;
use App\Models\Wallet;
use App\Repositories\Contracts\WalletRepositoryInterface;
use Illuminate\Database\Eloquent\Collection;

class WalletRepository implements WalletRepositoryInterface
{
    public function allByUser(int $userId): Collection
    {
        return Wallet::where('user_id', $userId)->get();
    }

    public function findByUser(int $id, int $userId): Wallet
    {
        return Wallet::where('id', $id)
            ->where('user_id', $userId)
            ->firstOrFail();
    }

    public function create(array $data): Wallet
    {
        return Wallet::create($data);
    }

    public function update(Wallet $wallet, array $data): Wallet
    {
        $wallet->update($data);
        return $wallet->fresh();
    }

    public function delete(Wallet $wallet): void
    {
        $wallet->delete();
    }

    public function updateBalance(int $walletId): void
    {
        $wallet = Wallet::findOrFail($walletId);

        $income  = Transaction::where('wallet_id', $walletId)->where('type', 'income')->sum('amount');
        $expense = Transaction::where('wallet_id', $walletId)->where('type', 'expense')->sum('amount');

        $wallet->update(['balance' => $income - $expense]);
    }
}
