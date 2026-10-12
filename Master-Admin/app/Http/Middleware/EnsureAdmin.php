<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

/**
 * Hanya akun admin (users.is_admin = true) yang boleh mengelola konten lewat API.
 * Dipasang setelah auth:sanctum.
 */
class EnsureAdmin
{
    public function handle(Request $request, Closure $next)
    {
        $user = $request->user();

        if (!$user || !$user->is_admin) {
            return response()->json(['message' => 'Hanya admin yang boleh melakukan ini.'], 403);
        }

        return $next($request);
    }
}
