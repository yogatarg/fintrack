<?php
// app/Http/Resources/TransactionResource.php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TransactionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'               => $this->id,
            'type'             => $this->type,
            'amount'           => (float) $this->amount,
            'note'             => $this->note,
            'transaction_date' => $this->transaction_date->toDateString(),
            'wallet'           => [
                'id'   => $this->wallet->id,
                'name' => $this->wallet->name,
                'type' => $this->wallet->type,
            ],
            'category' => [
                'id'    => $this->category->id,
                'name'  => $this->category->name,
                'type'  => $this->category->type,
                'icon'  => $this->category->icon,
                'color' => $this->category->color,
            ],
            'created_at' => $this->created_at->toDateTimeString(),
        ];
    }
}