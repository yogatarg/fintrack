<?php
namespace App\Observers;

use App\Models\Transaction;
use App\Services\WalletService;

class TransactionObserver
{
    public function __construct(private WalletService $walletService) {}

    public function created(Transaction $transaction): void
    {
        $this->walletService->updateBalance($transaction->wallet_id);
    }

    public function updated(Transaction $transaction): void
    {
        // Jika wallet berubah, update kedua wallet
        if ($transaction->wasChanged('wallet_id')) {
            $this->walletService->updateBalance($transaction->getOriginal('wallet_id'));
        }
        $this->walletService->updateBalance($transaction->wallet_id);
    }

    public function deleted(Transaction $transaction): void
    {
        $this->walletService->updateBalance($transaction->wallet_id);
    }
}