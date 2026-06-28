<?php
// app/Http/Requests/SavingGoal/StoreSavingGoalRequest.php

namespace App\Http\Requests\SavingGoal;

use Illuminate\Foundation\Http\FormRequest;

class StoreSavingGoalRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'name'          => ['required', 'string', 'max:255'],
            'target_amount' => ['required', 'numeric', 'min:1000'],
            'deadline'      => ['required', 'date', 'after:today'],
            'icon'          => ['nullable', 'string'],
            'color'         => ['nullable', 'string', 'regex:/^#[0-9A-Fa-f]{6}$/'],
        ];
    }
}