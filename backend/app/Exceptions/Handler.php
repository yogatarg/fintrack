<?php
namespace App\Exceptions;

use Illuminate\Foundation\Exceptions\Handler as ExceptionHandler;
use Illuminate\Database\UniqueConstraintViolationException;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;

class Handler extends ExceptionHandler
{
    public function register(): void
    {
        $this->renderable(function (ModelNotFoundException $e) {
            return response()->json(['message' => 'Data tidak ditemukan.'], 404);
        });

        $this->renderable(function (AuthenticationException $e) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        });

        $this->renderable(function (UniqueConstraintViolationException $e, $request) {
            if ($request->expectsJson()) {
                return response()->json(['message' => 'Data duplikat terdeteksi.'], 409);
            }
        });

        $this->renderable(function (\InvalidArgumentException $e, $request) {
            if ($request->expectsJson()) {
                return response()->json(['message' => $e->getMessage()], 422);
            }
        });
    }
}