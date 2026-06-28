<?php
// app/Http/Requests/Wallet/UpdateWalletRequest.php

namespace App\Http\Requests\Wallet;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateWalletRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'name'  => ['sometimes', 'string', 'max:255'],
            'type'  => ['sometimes', Rule::in(['cash', 'bank', 'e-wallet', 'investment'])],
            'icon'  => ['nullable', 'string'],
            'color' => ['nullable', 'string', 'regex:/^#[0-9A-Fa-f]{6}$/'],
            // balance tidak bisa diubah langsung — hanya via transaksi
        ];
    }
}