<?php

namespace App\Console\Commands;

use App\Services\Automation;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class Week13Evidence extends Command
{
    protected $signature = 'week13:evidence';

    protected $description = 'Run real-time controlled simulated-delivery evidence without deleting existing data';

    public function handle(Automation $automation): int
    {
        if (! app()->environment('local')) {
            $this->error('Local controlled environment only.');

            return 1;
        }
        $run = 'evidence:'.now()->format('YmdHis');
        $start = microtime(true);
        $steps = [];
        foreach (['success', 'transient', 'permanent', 'timeout'] as $mode) {
            $automation->enqueue($run.':'.$mode, 'progress_summary', DB::table('users')->where('email', 'student@example.test')->value('id'));
            DB::table('outbox')->where('event_key', $run.':'.$mode)->update(['simulation' => $mode]);
        }
        // Real wait/backoff; this command never changes the clock or resets attempts.
        do {
            $metric = $automation->work();
            $rows = DB::table('outbox')->where('event_key', 'like', $run.':%')->get(['id', 'event_key', 'status', 'attempts', 'available_at', 'failure_code', 'correlation_id']);
            $steps[] = ['executed_at_utc' => now()->toIso8601String(), 'metrics' => $metric, 'events' => $rows];
            $pending = $rows->whereIn('status', ['pending', 'retry'])->count();
            if ($pending) {
                sleep(5);
            }
        } while ($pending && microtime(true) - $start < 300);
        $ids = $rows->pluck('id');
        $result = ['run' => $run, 'build' => 'uncommitted Week 13 working tree', 'transport' => 'controlled simulated database receipt',
            'captured_at_manila' => now()->timezone('Asia/Manila')->toIso8601String(), 'elapsed_seconds' => round(microtime(true) - $start, 2),
            'predictions' => ['success' => 'one receipt one attempt', 'transient' => 'one receipt two attempts', 'permanent' => 'manual_review first attempt', 'timeout' => 'manual_review third attempt'],
            'steps' => $steps, 'final' => $rows, 'receipts' => DB::table('notification_receipts')->whereIn('outbox_id', $ids)->get(),
            'audits' => DB::table('workflow_audits')->whereIn('entity_id', $ids)->where('event', 'like', 'outbox.%')->get()];
        $path = base_path('../submissions/week-13/logs/controlled-delivery.json');
        file_put_contents($path, json_encode($result, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES));
        $this->line(json_encode(['result_file' => $path, 'elapsed_seconds' => $result['elapsed_seconds'], 'pending' => $pending, 'final' => $rows]));

        return $pending ? 1 : 0;
    }
}
