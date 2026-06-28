<?php
namespace App\Providers;

use App\Models\Transaction;
use App\Models\Wallet;
use App\Observers\BudgetSyncObserver;
use App\Observers\TransactionObserver;
use App\Observers\WalletObserver;
use App\Repositories\CategoryRepository;
use App\Repositories\TransactionRepository;
use App\Repositories\WalletRepository;
use App\Repositories\BudgetRepository;
use App\Repositories\SavingGoalRepository;
use App\Repositories\Contracts\BudgetRepositoryInterface;
use App\Repositories\Contracts\SavingGoalRepositoryInterface;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->bind('App\\Repositories\\Contracts\\WalletRepositoryInterface', WalletRepository::class);
        $this->app->bind('App\\Repositories\\Contracts\\CategoryRepositoryInterface', CategoryRepository::class);
        $this->app->bind('App\\Repositories\\Contracts\\TransactionRepositoryInterface', TransactionRepository::class);
        $this->app->bind(BudgetRepositoryInterface::class, BudgetRepository::class);
        $this->app->bind(SavingGoalRepositoryInterface::class, SavingGoalRepository::class);
    }

    public function boot(): void
    {
        Wallet::observe(WalletObserver::class);
        Transaction::observe(TransactionObserver::class);
        Transaction::observe(BudgetSyncObserver::class);
    }
}
