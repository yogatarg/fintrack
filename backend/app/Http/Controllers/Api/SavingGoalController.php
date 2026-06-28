<?php
// app/Http/Controllers/Api/SavingGoalController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\SavingGoal\AddProgressRequest;
use App\Http\Requests\SavingGoal\StoreSavingGoalRequest;
use App\Http\Requests\SavingGoal\UpdateSavingGoalRequest;
use App\Http\Resources\SavingGoalResource;
use App\Services\SavingGoalService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SavingGoalController extends Controller
{
    public function __construct(private SavingGoalService $savingGoalService) {}

    public function index(Request $request): JsonResponse
    {
        $status = $request->query('status'); // ?status=active
        $goals  = $this->savingGoalService->getUserGoals($request->user()->id, $status);

        return response()->json([
            'data' => SavingGoalResource::collection($goals),
        ]);
    }

    public function store(StoreSavingGoalRequest $request): JsonResponse
    {
        $goal = $this->savingGoalService->createGoal(
            $request->user()->id,
            $request->validated()
        );

        return response()->json([
            'message' => 'Saving goal berhasil dibuat.',
            'data'    => new SavingGoalResource($goal),
        ], 201);
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $goals = $this->savingGoalService->getUserGoals($request->user()->id);
        $goal  = $goals->firstWhere('id', $id);

        abort_if(!$goal, 404, 'Saving goal tidak ditemukan.');

        return response()->json([
            'data' => new SavingGoalResource($goal),
        ]);
    }

    public function update(UpdateSavingGoalRequest $request, int $id): JsonResponse
    {
        $goal = $this->savingGoalService->updateGoal(
            $id,
            $request->user()->id,
            $request->validated()
        );

        return response()->json([
            'message' => 'Saving goal berhasil diperbarui.',
            'data'    => new SavingGoalResource($goal),
        ]);
    }

    public function addProgress(AddProgressRequest $request, int $id): JsonResponse
    {
        $goal = $this->savingGoalService->addProgress(
            $id,
            $request->user()->id,
            $request->validated('amount')
        );

        return response()->json([
            'message' => 'Progress berhasil ditambahkan.',
            'data'    => new SavingGoalResource($goal),
        ]);
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $this->savingGoalService->deleteGoal($id, $request->user()->id);

        return response()->json([
            'message' => 'Saving goal berhasil dihapus.',
        ]);
    }
}