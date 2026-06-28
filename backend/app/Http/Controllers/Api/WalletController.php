<?php
// app/Http/Controllers/Api/WalletController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Wallet\StoreWalletRequest;
use App\Http\Requests\Wallet\UpdateWalletRequest;
use App\Http\Resources\WalletResource;
use App\Services\WalletService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WalletController extends Controller
{
    public function __construct(private WalletService $walletService) {}

    public function index(Request $request): JsonResponse
    {
        $wallets = $this->walletService->getUserWallets($request->user()->id);

        return response()->json([
            'data' => WalletResource::collection($wallets),
        ]);
    }

    public function store(StoreWalletRequest $request): JsonResponse
    {
        $wallet = $this->walletService->createWallet(
            $request->user()->id,
            $request->validated()
        );

        return response()->json([
            'message' => 'Wallet berhasil dibuat.',
            'data'    => new WalletResource($wallet),
        ], 201);
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $wallet = $this->walletService->getUserWallets($request->user()->id)
            ->firstOrFail();

        return response()->json([
            'data' => new WalletResource($wallet),
        ]);
    }

    public function update(UpdateWalletRequest $request, int $id): JsonResponse
    {
        $wallet = $this->walletService->updateWallet(
            $id,
            $request->user()->id,
            $request->validated()
        );

        return response()->json([
            'message' => 'Wallet berhasil diperbarui.',
            'data'    => new WalletResource($wallet),
        ]);
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $this->walletService->deleteWallet($id, $request->user()->id);

        return response()->json([
            'message' => 'Wallet berhasil dihapus.',
        ]);
    }
}