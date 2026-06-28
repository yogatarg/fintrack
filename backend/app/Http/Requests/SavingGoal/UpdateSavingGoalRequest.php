<?php
// app/Http/Requests/SavingGoal/UpdateSavingGoalRequest.php

namespace App\Http\Requests\SavingGoal;

use Illuminate\Foundation\Http\FormRequest;

class UpdateSavingGoalRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'name'          => ['sometimes', 'string', 'max:255'],
            'target_amount' => ['sometimes', 'numeric', 'min:1000'],
            'deadline'      => ['sometimes', 'date', 'after:today'],
            'status'        => ['sometimes', 'in:active,completed,cancelled'],
            'icon'          => ['nullable', 'string'],
            'color'         => ['nullable', 'string', 'regex:/^#[0-9A-Fa-f]{6}$/'],
        ];
    }
}