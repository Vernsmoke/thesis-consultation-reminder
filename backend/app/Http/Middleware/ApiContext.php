<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class ApiContext
{
    public function handle(Request $r, Closure $next)
    {
        $correlation = (string) Str::uuid();
        $r->attributes->set('correlation_id', $correlation);
        if (! $r->is('api/login')) {
            $session = DB::table('api_sessions')->where('token_hash', hash('sha256', $r->bearerToken() ?? ''))->where('expires_at', '>', now())->first();
            if (! $session) {
                return response()->json(['message' => 'Sign in required.', 'correlation_id' => $correlation], 401)->header('X-Correlation-ID', $correlation);
            }
            $r->attributes->set('actor', DB::table('users')->find($session->user_id));
        }
        $response = $next($r);

        return $response->header('X-Correlation-ID', $correlation)->header('Cache-Control', 'no-store');
    }
}
