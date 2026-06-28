<?php
// app/Http/Controllers/Api/AnalyticsController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\Analytics\AnomalyDetectionService;
use App\Services\Analytics\BudgetRiskService;
use App\Services\Analytics\FinancialHealthService;
use App\Services\Analytics\MonthlyReviewService;
use App\Services\Analytics\NoSpendDayService;
use App\Services\Analytics\SavingRecommendationService;
use App\Services\Analytics\SpendingAlertService;
use App\Services\Analytics\SpendingPredictionService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AnalyticsController extends Controller
{
    public function __construct(
        private SpendingAlertService $spendingAlertService,
        private BudgetRiskService $budgetRiskService,
        private SpendingPredictionService $spendingPredictionService,
        private SavingRecommendationService $savingRecommendationService,
        private FinancialHealthService $financialHealthService,
        private AnomalyDetectionService $anomalyDetectionService,
        private MonthlyReviewService $monthlyReviewService,
        private NoSpendDayService $noSpendDayService,
    ) {}

    public function spendingAlert(Request $request): JsonResponse
    {
        $result = $this->spendingAlertService->analyze($request->user()->id);

        return response()->json(['data' => $result->toArray()]);
    }

    public function budgetRisk(Request $request): JsonResponse
    {
        $result = $this->budgetRiskService->analyze($request->user()->id);

        return response()->json(['data' => $result->map(fn($r) => $r->toArray())]);
    }

    public function spendingPrediction(Request $request): JsonResponse
    {
        $result = $this->spendingPredictionService->analyze($request->user()->id);

        return response()->json(['data' => $result]);
    }

    public function savingRecommendation(Request $request): JsonResponse
    {
        $result = $this->savingRecommendationService->analyze($request->user()->id);

        return response()->json(['data' => $result]);
    }

    public function financialHealth(Request $request): JsonResponse
    {
        $result = $this->financialHealthService->analyze($request->user()->id);

        return response()->json(['data' => $result->toArray()]);
    }

    public function anomalyDetection(Request $request): JsonResponse
    {
        $result = $this->anomalyDetectionService->analyze($request->user()->id);

        return response()->json(['data' => $result]);
    }

    public function monthlyReview(Request $request): JsonResponse
    {
        $request->validate([
            'month' => ['nullable', 'date_format:Y-m'],
        ]);

        $result = $this->monthlyReviewService->analyze(
            $request->user()->id,
            $request->query('month')
        );

        return response()->json(['data' => $result->toArray()]);
    }

    public function noSpendDay(Request $request): JsonResponse
    {
        $result = $this->noSpendDayService->analyze($request->user()->id);

        return response()->json(['data' => $result]);
    }
}
