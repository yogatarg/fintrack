<?php
// app/Http/Requests/Budget/UpdateBudgetRequest.php

namespace App\Http\Requests\Budget;

use Illuminate\Foundation\Http\FormRequest;

class UpdateBudgetRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'amount'       => ['sometimes', 'numeric', 'min:1000'],
            'period_start' => ['sometimes', 'date'],
            'period_end'   => ['sometimes', 'date', 'after:period_start'],
        ];
    }
}