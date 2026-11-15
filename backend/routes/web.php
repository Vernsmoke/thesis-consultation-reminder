<?php

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/ready', function () {
    $started = hrtime(true);

    try {
        $host = (string) config('database.connections.mysql.host');
        $port = (int) config('database.connections.mysql.port');
        $timeout = (float) env('DB_READY_SOCKET_TIMEOUT', 1);
        $socket = @stream_socket_client("tcp://{$host}:{$port}", $errorCode, $errorMessage, $timeout);
        if (! is_resource($socket)) {
            throw new RuntimeException('Database socket is unavailable.');
        }
        fclose($socket);
        DB::select('select 1');
        $ready = true;
        $status = 200;
    } catch (Throwable $exception) {
        $ready = false;
        $status = 503;
        Log::warning('readiness', [
            'ready' => false,
            'dependency' => 'database',
            'exception' => $exception::class,
        ]);
    }

    return response()->json([
        'status' => $ready ? 'ready' : 'not_ready',
        'checks' => ['database' => $ready ? 'up' : 'down'],
        'duration_ms' => round((hrtime(true) - $started) / 1_000_000, 2),
    ], $status)->withHeaders([
        'Cache-Control' => 'no-store',
        'X-Content-Type-Options' => 'nosniff',
    ]);
});
