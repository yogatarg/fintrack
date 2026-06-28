<?php 
// app/Services/CategoryService.php

namespace App\Services;

use App\Models\Category;
use App\Repositories\Contracts\CategoryRepositoryInterface;
use Illuminate\Database\Eloquent\Collection;

class CategoryService
{
    public function __construct(
        private CategoryRepositoryInterface $categoryRepository
    ) {}

    public function getUserCategories(int $userId, ?string $type = null): Collection
    {
        return $this->categoryRepository->allByUser($userId, $type);
    }

    public function createCategory(int $userId, array $data): Category
    {
        return $this->categoryRepository->create(array_merge($data, [
            'user_id'    => $userId,
            'is_default' => false,
        ]));
    }

    public function updateCategory(int $categoryId, int $userId, array $data): Category
    {
        $category = $this->categoryRepository->findByUser($categoryId, $userId);

        if ($category->is_default) {
            throw new \Exception('Kategori default sistem tidak dapat diubah.');
        }

        return $this->categoryRepository->update($category, $data);
    }

    public function deleteCategory(int $categoryId, int $userId): void
    {
        $category = $this->categoryRepository->findByUser($categoryId, $userId);

        if ($category->is_default) {
            throw new \Exception('Kategori default sistem tidak dapat dihapus.');
        }

        if ($category->transactions()->exists()) {
            throw new \Exception('Kategori tidak dapat dihapus karena masih digunakan transaksi.');
        }

        $this->categoryRepository->delete($category);
    }
}