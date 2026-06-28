<?php
// app/Http/Requests/Category/StoreCategoryRequest.php

namespace App\Http\Requests\Category;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreCategoryRequest extends FormRequest
{
    public function authorize(): bool
    {return true;}

    public function rules(): array
    {
        return [
            'name'  => ['required', 'string', 'max:255'],
            'type'  => ['required', Rule::in(['income', 'expense'])],
            'icon'  => ['nullable', 'string'],
            'color' => ['nullable', 'string', 'regex:/^#[0-9A-Fa-f]{6}$/'],
        ];
    }
}
