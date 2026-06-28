<?php
// app/Http/Controllers/Api/BudgetController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Budget\StoreBudgetRequest;
use App\Http\Requests\Budget\UpdateBudgetRequest;
use App\Http\Resources\BudgetResource;
use App\Services\BudgetService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BudgetController extends Controller
{
    public function __construct(private BudgetService $budgetService)
    {}

    public function index(Request $request): JsonResponse
    {
        $budgets = $this->budgetService->getUserBudgets($request->user()->id);

        return response()->json([
            'data' => BudgetResource::collection($budgets),
        ]);
    }

    public function store(StoreBudgetRequest $request): JsonResponse
    {
        $budget = $this->budgetService->createBudget(
            $request->user()->id,
            $request->validated()
        );

        return response()->json([
            'message' => 'Budget berhasil dibuat.',
            'data'    => new BudgetResource($budget),
        ], 201);
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $budget = $this->budgetService->getUserBudgets($request->user()->id)
            ->firstWhere('id', $id);

        abort_if(! $budget, 404, 'Budget tidak ditemukan.');

        return response()->json([
            'data' => new BudgetResource($budget),
        ]);
    }

    public function update(UpdateBudgetRequest $request, int $id): JsonResponse
    {
        $budget = $this->budgetService->updateBudget(
            $id,
            $request->user()->id,
            $request->validated()
        );

        return response()->json([
            'message' => 'Budget berhasil diperbarui.',
            'data'    => new BudgetResource($budget),
        ]);
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $this->budgetService->deleteBudget($id, $request->user()->id);

        return response()->json([
            'message' => 'Budget berhasil dihapus.',
        ]);
    }

    public function sync(Request $request): JsonResponse
    {
        $this->budgetService->syncAllActive($request->user()->id);

        return response()->json(['message' => 'Budget berhasil disinkronkan.']);
    }

}
