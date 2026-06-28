<?php
// app/Http/Requests/Transaction/UpdateTransactionRequest.php

namespace App\Http\Requests\Transaction;

use Illuminate\Foundation\Http\FormRequest;

class UpdateTransactionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'wallet_id'        => ['sometimes', 'integer', 'exists:wallets,id'],
            'category_id'      => ['sometimes', 'integer', 'exists:categories,id'],
            'type'             => ['sometimes', 'string', 'in:income,expense'],
            'amount'           => ['sometimes', 'numeric', 'min:0.01'],
            'note'             => ['sometimes', 'nullable', 'string'],
            'transaction_date' => ['sometimes', 'date'],
        ];
    }
}
