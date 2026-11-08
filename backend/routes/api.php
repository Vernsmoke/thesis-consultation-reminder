<?php

use App\Http\Controllers\ConsultationController as C;
use App\Http\Middleware\ApiContext;
use Illuminate\Support\Facades\Route;

Route::middleware(ApiContext::class)->group(function () {
    Route::post('/login', [C::class, 'login'])->middleware('throttle:10,1');
    Route::post('/logout', [C::class, 'logout']);
    Route::get('/consultations', [C::class, 'index']);
    Route::post('/consultations', [C::class, 'store']);
    Route::patch('/consultations/{id}', [C::class, 'transition'])->whereNumber('id');
    Route::post('/consultations/{id}/actions', [C::class, 'addAction'])->whereNumber('id');
    Route::patch('/actions/{id}/complete', [C::class, 'completeAction'])->whereNumber('id');
    Route::get('/automation', [C::class, 'automation']);
    Route::post('/automation/{id}/resolve', [C::class, 'resolve'])->whereNumber('id');
});
