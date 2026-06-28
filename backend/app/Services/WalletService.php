<?php
// app/Services/WalletService.php

namespace App\Services;

use App\Models\Wallet;
use App\Repositories\Contracts\WalletRepositoryInterface;
use Illuminate\Database\Eloquent\Collection;

class WalletService
{
    public function __construct(
        private WalletRepositoryInterface $walletRepository
    ) {}

    public function getUserWallets(int $userId): Collection
    {
        return $this->walletRepository->allByUser($userId);
    }

    public function createWallet(int $userId, array $data): Wallet
    {
        return $this->walletRepository->create(array_merge($data, [
            'user_id' => $userId,
        ]));
    }

    public function updateWallet(int $walletId, int $userId, array $data): Wallet
    {
        $wallet = $this->walletRepository->findByUser($walletId, $userId);
        return $this->walletRepository->update($wallet, $data);
    }

    public function deleteWallet(int $walletId, int $userId): void
    {
        $wallet = $this->walletRepository->findByUser($walletId, $userId);

        // Cegah hapus wallet jika masih ada transaksi aktif
        if ($wallet->transactions()->exists()) {
            throw new \Exception('Wallet tidak dapat dihapus karena masih memiliki transaksi.');
        }

        $this->walletRepository->delete($wallet);
    }

    public function updateBalance(int $walletId): void
    {
        $this->walletRepository->updateBalance($walletId);
    }
}
