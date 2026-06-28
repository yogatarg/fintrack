<?php
// app/Http/Controllers/Api/CategoryController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Category\StoreCategoryRequest;
use App\Http\Requests\Category\UpdateCategoryRequest;
use App\Http\Resources\CategoryResource;
use App\Services\CategoryService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    public function __construct(private CategoryService $categoryService) {}

    public function index(Request $request): JsonResponse
    {
        $type       = $request->query('type'); // ?type=income atau ?type=expense
        $categories = $this->categoryService->getUserCategories($request->user()->id, $type);

        return response()->json([
            'data' => CategoryResource::collection($categories),
        ]);
    }

    public function store(StoreCategoryRequest $request): JsonResponse
    {
        $category = $this->categoryService->createCategory(
            $request->user()->id,
            $request->validated()
        );

        return response()->json([
            'message' => 'Kategori berhasil dibuat.',
            'data'    => new CategoryResource($category),
        ], 201);
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $category = $this->categoryService->getUserCategories($request->user()->id)
            ->firstWhere('id', $id);

        abort_if(!$category, 404, 'Kategori tidak ditemukan.');

        return response()->json([
            'data' => new CategoryResource($category),
        ]);
    }

    public function update(UpdateCategoryRequest $request, int $id): JsonResponse
    {
        $category = $this->categoryService->updateCategory(
            $id,
            $request->user()->id,
            $request->validated()
        );

        return response()->json([
            'message' => 'Kategori berhasil diperbarui.',
            'data'    => new CategoryResource($category),
        ]);
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $this->categoryService->deleteCategory($id, $request->user()->id);

        return response()->json([
            'message' => 'Kategori berhasil dihapus.',
        ]);
    }
}