<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpKernel\Exception\HttpExceptionInterface;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        api: __DIR__.'/../routes/api.php',
        web: __DIR__.'/../routes/web.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        // Laravel handles CORS globally.
    })
    ->withExceptions(function (Exceptions $exceptions) {
        $exceptions->shouldRenderJsonWhen(fn ($request) => $request->is('api/*'));
        $exceptions->render(function (Throwable $e, Request $r) {
            if (! $r->is('api/*')) {
                return null;
            }
            $status = $e instanceof ValidationException ? 422 : ($e instanceof HttpExceptionInterface ? $e->getStatusCode() : 500);
            $body = ['message' => $status >= 500 ? 'Service unavailable. Retry safely or contact the coordinator.' : ($e->getMessage() ?: 'Request rejected.'), 'correlation_id' => $r->attributes->get('correlation_id')];
            if ($e instanceof ValidationException) {
                $body['errors'] = $e->errors();
            }

            return response()->json($body, $status)->header('X-Correlation-ID', $r->attributes->get('correlation_id', ''))->header('Cache-Control', 'no-store');
        });
    })->create();
