<?php
// routes/api.php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BudgetController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\SavingGoalController;
use App\Http\Controllers\Api\TransactionController;
use App\Http\Controllers\Api\AnalyticsController;
use App\Http\Controllers\Api\WalletController;
use Illuminate\Support\Facades\Route;

// Public routes
Route::prefix('auth')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
});

// Protected routes
Route::middleware('auth:sanctum')->group(function () {

    Route::prefix('auth')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::get('/profile', [AuthController::class, 'profile']);
        Route::put('/profile', [AuthController::class, 'updateProfile']);
    });

    Route::prefix('analytics')->group(function () {
        Route::get('spending-alert', [AnalyticsController::class, 'spendingAlert']);
        Route::get('budget-risk', [AnalyticsController::class, 'budgetRisk']);
        Route::get('spending-prediction', [AnalyticsController::class, 'spendingPrediction']);
        Route::get('saving-recommendation', [AnalyticsController::class, 'savingRecommendation']);
        Route::get('financial-health', [AnalyticsController::class, 'financialHealth']);
        Route::get('anomaly-detection', [AnalyticsController::class, 'anomalyDetection']);
        Route::get('monthly-review', [AnalyticsController::class, 'monthlyReview']);
        Route::get('no-spend-day', [AnalyticsController::class, 'noSpendDay']);
    });

    Route::apiResource('wallets', WalletController::class);
    Route::apiResource('categories', CategoryController::class);
    Route::apiResource('transactions', TransactionController::class);
    Route::apiResource('budgets', BudgetController::class);
    Route::post('budgets/sync', [BudgetController::class, 'sync']);
    Route::apiResource('saving-goals', SavingGoalController::class);
    Route::post('saving-goals/{id}/add-progress', [SavingGoalController::class, 'addProgress']);
    Route::get('dashboard', [DashboardController::class, 'index']);
});
