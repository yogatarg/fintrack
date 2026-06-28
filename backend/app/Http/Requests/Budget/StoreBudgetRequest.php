<?php
// app/Http/Requests/Budget/StoreBudgetRequest.php

namespace App\Http\Requests\Budget;

use Illuminate\Foundation\Http\FormRequest;
use App\Rules\ValidBudgetPeriod;
class StoreBudgetRequest extends FormRequest
{
    public function authorize(): bool
    {return true;}

    public function rules(): array
    {
        return [
            'category_id'  => ['required', 'exists:categories,id'],
            'amount'       => ['required', 'numeric', 'min:1000'],
            'period_start' => ['required', 'date'],
            'period_end'   => ['required', 'date', new ValidBudgetPeriod()],
        ];
    }

    public function messages(): array
    {
        return [
            'period_end.after' => 'Tanggal akhir harus setelah tanggal mulai.',
        ];
    }
}
