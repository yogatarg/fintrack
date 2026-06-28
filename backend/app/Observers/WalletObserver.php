<?php
namespace App\Observers;

use App\Models\Wallet;

class WalletObserver
{
    public function deleting(Wallet $wallet): void
    {
        // Soft delete semua transaksi terkait
        $wallet->transactions()->get()->each(fn($t) => $t->delete());
    }

    public function restoring(Wallet $wallet): void
    {
        // Restore transaksi yang ikut terhapus
        $wallet->transactions()->onlyTrashed()->get()->each(fn($t) => $t->restore());
    }
}
