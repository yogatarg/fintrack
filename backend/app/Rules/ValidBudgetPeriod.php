<?php
// app/Rules/ValidBudgetPeriod.php

namespace App\Rules;

use Closure;
use Illuminate\Contracts\Validation\DataAwareRule;
use Illuminate\Contracts\Validation\ValidationRule;

class ValidBudgetPeriod implements ValidationRule, DataAwareRule
{
    private array $data = [];

    public function setData(array $data): static
    {
        $this->data = $data;
        return $this;
    }

    public function validate(string $attribute, mixed $value, Closure $fail): void
    {
        $start = $this->data['period_start'] ?? null;

        if (!$start) return;

        if (strtotime($value) <= strtotime($start)) {
            $fail('Tanggal akhir harus setelah tanggal mulai.');
        }

        // Maksimum periode 1 tahun
        $maxEnd = date('Y-m-d', strtotime($start . ' +1 year'));
        if (strtotime($value) > strtotime($maxEnd)) {
            $fail('Periode budget maksimal 1 tahun.');
        }
    }
}