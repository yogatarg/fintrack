<?php
// database/seeders/DefaultCategorySeeder.php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;

class DefaultCategorySeeder extends Seeder
{
    public function run(): void
    {
        $categories = [
            // Income
            ['name' => 'Gaji',         'type' => 'income',  'icon' => 'wallet',       'color' => '#4CAF50'],
            ['name' => 'Freelance',    'type' => 'income',  'icon' => 'laptop',        'color' => '#8BC34A'],
            ['name' => 'Investasi',    'type' => 'income',  'icon' => 'trending-up',   'color' => '#009688'],
            ['name' => 'Bonus',        'type' => 'income',  'icon' => 'gift',          'color' => '#00BCD4'],
            ['name' => 'Lainnya',      'type' => 'income',  'icon' => 'plus-circle',   'color' => '#607D8B'],

            // Expense
            ['name' => 'Makanan',      'type' => 'expense', 'icon' => 'utensils',      'color' => '#F44336'],
            ['name' => 'Transport',    'type' => 'expense', 'icon' => 'car',           'color' => '#FF5722'],
            ['name' => 'Belanja',      'type' => 'expense', 'icon' => 'shopping-bag',  'color' => '#E91E63'],
            ['name' => 'Tagihan',      'type' => 'expense', 'icon' => 'file-text',     'color' => '#9C27B0'],
            ['name' => 'Hiburan',      'type' => 'expense', 'icon' => 'music',         'color' => '#3F51B5'],
            ['name' => 'Kesehatan',    'type' => 'expense', 'icon' => 'heart',         'color' => '#2196F3'],
            ['name' => 'Pendidikan',   'type' => 'expense', 'icon' => 'book',          'color' => '#03A9F4'],
            ['name' => 'Lainnya',      'type' => 'expense', 'icon' => 'more-horizontal','color' => '#607D8B'],
        ];

        foreach ($categories as $category) {
            Category::firstOrCreate(
                ['name' => $category['name'], 'type' => $category['type'], 'user_id' => null],
                array_merge($category, ['user_id' => null, 'is_default' => true])
            );
        }
    }
}