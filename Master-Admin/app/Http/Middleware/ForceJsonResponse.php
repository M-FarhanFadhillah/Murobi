<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

/**
 * Semua rute /api selalu dijawab dengan JSON, walaupun klien lupa mengirim
 * header "Accept: application/json" (tanpa ini error validasi/401 berupa redirect HTML).
 */
class ForceJsonResponse
{
    public function handle(Request $request, Closure $next)
    {
        $request->headers->set('Accept', 'application/json');

        return $next($request);
    }
}
