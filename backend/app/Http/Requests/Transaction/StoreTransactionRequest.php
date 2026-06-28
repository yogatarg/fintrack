<?php
// app/Http/Requests/Transaction/StoreTransactionRequest.php

namespace App\Http\Requests\Transaction;

use Illuminate\Foundation\Http\FormRequest;

class StoreTransactionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'wallet_id'        => ['required', 'integer', 'exists:wallets,id'],
            'category_id'      => ['required', 'integer', 'exists:categories,id'],
            'type'             => ['required', 'string', 'in:income,expense'],
            'amount'           => ['required', 'numeric', 'min:0.01'],
            'note'             => ['sometimes', 'nullable', 'string'],
            'transaction_date' => ['required', 'date'],
        ];
    }
}
