<?php

namespace App\Console\Commands;

use App\Services\Automation;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class Week13Fixtures extends Command
{
    protected $signature = 'week13:fixtures';

    protected $description = 'Add clearly labeled fictional due records and capture all four automation triggers';

    public function handle(Automation $automation): int
    {
        if (! app()->environment('local')) {
            $this->error('Local controlled fixtures only.');

            return 1;
        }
        $student = DB::table('users')->where('email', 'student@example.test')->value('id');
        $adviser = DB::table('users')->where('email', 'adviser@example.test')->value('id');
        if (! $student || ! $adviser) {
            $this->error('Seed fictional users first.');

            return 1;
        }
        $run = 'fixture:'.now()->format('YmdHis');
        $ids = DB::transaction(function () use ($student, $adviser, $run) {
            $ids = [];
            foreach (['future' => now()->addHours(2), 'past' => now()->subHours(2)] as $case => $time) {
                $ids[$case] = DB::table('consultations')->insertGetId(['student_id' => $student, 'adviser_id' => $adviser,
                    'agenda' => "CONTROLLED FIXTURE $run $case - automation trigger demonstration", 'scheduled_at' => $time, 'status' => 'confirmed', 'created_at' => now(), 'updated_at' => now()]);
            }
            $ids['action'] = DB::table('action_items')->insertGetId(['consultation_id' => $ids['past'], 'description' => "CONTROLLED FIXTURE $run overdue action",
                'due_at' => now()->subMinutes(5), 'status' => 'open', 'created_at' => now(), 'updated_at' => now()]);

            return $ids;
        });
        $automation->scan();
        $first = DB::table('outbox')->count();
        $automation->scan();
        $second = DB::table('outbox')->count();
        $metrics = $automation->work();
        $events = DB::table('outbox')->whereIn('event_key', ["reminder:{$ids['future']}", "missed:{$ids['past']}", "deadline:{$ids['action']}"])
            ->orWhere('event_key', 'like', 'summary:%:'.now()->timezone('Asia/Manila')->toDateString())->get();
        $data = ['run' => $run, 'captured_at_manila' => now()->timezone('Asia/Manila')->toIso8601String(),
            'build' => 'uncommitted Week 13 working tree', 'fixture_note' => 'Past scheduled/due timestamps are intentional test data, not backdated creation or evidence.',
            'fixture_ids' => $ids, 'scan_count_first' => $first, 'scan_count_second' => $second, 'metrics' => $metrics, 'events' => $events,
            'receipts' => DB::table('notification_receipts')->whereIn('outbox_id', $events->pluck('id'))->get()];
        file_put_contents(base_path('../submissions/week-13/logs/four-automation-triggers.json'), json_encode($data, JSON_PRETTY_PRINT));
        $this->line(json_encode(['run' => $run, 'scan_count_first' => $first, 'scan_count_second' => $second, 'metrics' => $metrics, 'kinds' => $events->pluck('kind')->unique()->values()]));

        return 0;
    }
}
