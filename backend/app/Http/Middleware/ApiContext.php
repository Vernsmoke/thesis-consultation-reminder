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
                return $this->headers(response()->json(['message' => 'Sign in required.', 'correlation_id' => $correlation], 401), $correlation, $r);
            }
            $r->attributes->set('actor', DB::table('users')->find($session->user_id));
        }
        $response = $next($r);

        return $this->headers($response, $correlation, $r);
    }

    private function headers($response, string $correlation, Request $request)
    {
        $response->header('X-Correlation-ID', $correlation)
            ->header('Cache-Control', 'no-store')
            ->header('X-Content-Type-Options', 'nosniff')
            ->header('Referrer-Policy', 'no-referrer')
            ->header('Content-Security-Policy', "default-src 'none'; frame-ancestors 'none'")
            ->header('Permissions-Policy', 'camera=(), microphone=(), geolocation=()')
            // Browsers ignore HSTS received over plain HTTP. Emitting it on
            // every API response keeps error and success paths consistent,
            // while the documented deployment contract still requires HTTPS.
            ->header('Strict-Transport-Security', 'max-age=31536000');

        return $response;
    }
}
