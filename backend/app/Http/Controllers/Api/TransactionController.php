<?php
// app/Http/Controllers/Api/TransactionController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Transaction\StoreTransactionRequest;
use App\Http\Requests\Transaction\UpdateTransactionRequest;
use App\Http\Resources\TransactionResource;
use App\Services\TransactionService;
use App\Repositories\Contracts\TransactionRepositoryInterface;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TransactionController extends Controller
{
    public function __construct(
    private TransactionService $transactionService,
    private TransactionRepositoryInterface $transactionRepository
) {}

    public function index(Request $request): JsonResponse
    {
        $filters = $request->only([
            'type', 'wallet_id', 'category_id', 'start_date', 'end_date'
        ]);

        $transactions = $this->transactionService->getTransactions(
            $request->user()->id,
            $filters
        );

        return response()->json([
            'data' => TransactionResource::collection($transactions),
            'meta' => [
                'current_page' => $transactions->currentPage(),
                'last_page'    => $transactions->lastPage(),
                'per_page'     => $transactions->perPage(),
                'total'        => $transactions->total(),
            ],
        ]);
    }

    public function store(StoreTransactionRequest $request): JsonResponse
    {
        $transaction = $this->transactionService->createTransaction(
            $request->user()->id,
            $request->validated()
        );

        return response()->json([
            'message' => 'Transaksi berhasil ditambahkan.',
            'data'    => new TransactionResource($transaction),
        ], 201);
    }

    public function show(Request $request, int $id): JsonResponse
{
    $transaction = $this->transactionRepository->findByUser($id, $request->user()->id);

    return response()->json([
        'data' => new TransactionResource($transaction),
    ]);
}

    public function update(UpdateTransactionRequest $request, int $id): JsonResponse
    {
        $transaction = $this->transactionService->updateTransaction(
            $id,
            $request->user()->id,
            $request->validated()
        );

        return response()->json([
            'message' => 'Transaksi berhasil diperbarui.',
            'data'    => new TransactionResource($transaction),
        ]);
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $this->transactionService->deleteTransaction($id, $request->user()->id);

        return response()->json([
            'message' => 'Transaksi berhasil dihapus.',
        ]);
    }
}