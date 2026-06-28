<?php
// app/Repositories/Contracts/CategoryRepositoryInterface.php

namespace App\Repositories\Contracts;

use App\Models\Category;
use Illuminate\Database\Eloquent\Collection;

interface CategoryRepositoryInterface
{
    public function allByUser(int $userId, ?string $type): Collection;
    public function findByUser(int $id, int $userId): Category;
    public function create(array $data): Category;
    public function update(Category $category, array $data): Category;
    public function delete(Category $category): void;
}