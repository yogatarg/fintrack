<?php
// app/Http/Requests/SavingGoal/AddProgressRequest.php

namespace App\Http\Requests\SavingGoal;

use Illuminate\Foundation\Http\FormRequest;

class AddProgressRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'amount' => ['required', 'numeric', 'min:1000'],
            'note'   => ['nullable', 'string', 'max:255'],
        ];
    }
}