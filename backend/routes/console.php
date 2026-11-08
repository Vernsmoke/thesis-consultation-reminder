<?php

use App\Services\Automation;
use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('consultations:tick', function (Automation $automation) {
    $automation->scan();
    $this->line(json_encode($automation->work()));
})->purpose('Scan due consultation work and process a bounded simulated-delivery batch');
Schedule::command('consultations:tick')->everyMinute()->withoutOverlapping(5);

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');
