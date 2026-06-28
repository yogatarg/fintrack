<?php
// app/Repositories/CategoryRepository.php

namespace App\Repositories;

use App\Models\Category;
use App\Repositories\Contracts\CategoryRepositoryInterface;
use Illuminate\Database\Eloquent\Collection;

class CategoryRepository implements CategoryRepositoryInterface
{
    public function allByUser(int $userId, ?string $type = null): Collection
    {
        return Category::forUser($userId)
            ->when($type, fn($q) => $q->where('type', $type))
            ->get();
    }

    public function findByUser(int $id, int $userId): Category
    {
        // Boleh akses kategori default (user_id null) atau milik sendiri
        return Category::where('id', $id)
            ->where(fn($q) => $q->where('user_id', $userId)->orWhereNull('user_id'))
            ->firstOrFail();
    }

    public function create(array $data): Category
    {
        return Category::create($data);
    }

    public function update(Category $category, array $data): Category
    {
        $category->update($data);
        return $category->fresh();
    }

    public function delete(Category $category): void
    {
        $category->delete();
    }
}