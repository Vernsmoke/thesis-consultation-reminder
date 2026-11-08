<?php

namespace App\Services;

use Illuminate\Support\Facades\DB;

class SimulatedTransport
{
    public function deliver(object $event, int $attempt): string
    {
        // In-process transport: no network or credentials. Injection is CLI/test-only.
        if ($event->simulation === 'permanent') {
            return 'permanent';
        }
        if ($event->simulation === 'timeout' || ($event->simulation === 'transient' && $attempt === 1)) {
            return 'transient';
        }
        $recipient = $event->entity_id;
        $payload = ['kind' => $event->kind, 'entity_id' => $event->entity_id];
        if ($event->kind === 'progress_summary') {
            $ids = DB::table('consultations')->where('student_id', $recipient)->pluck('id');
            $payload += ['meetings_completed' => DB::table('consultations')->whereIn('id', $ids)->where('status', 'completed')->count(),
                'meetings_missed' => DB::table('consultations')->whereIn('id', $ids)->where('status', 'missed')->count(),
                'open_actions' => DB::table('action_items')->whereIn('consultation_id', $ids)->where('status', 'open')->count()];
        } elseif ($event->kind === 'action_deadline') {
            $a = DB::table('action_items')->find($event->entity_id);
            $recipient = DB::table('consultations')->find($a->consultation_id)->student_id;
            $payload['due_at'] = $a->due_at;
        } elseif (in_array($event->kind, ['consultation_reminder', 'missed_session'])) {
            $c = DB::table('consultations')->find($event->entity_id);
            $recipient = $c->student_id;
            $payload['scheduled_at'] = $c->scheduled_at;
        }
        DB::table('notification_receipts')->insertOrIgnore(['outbox_id' => $event->id, 'kind' => $event->kind, 'recipient_id' => $recipient, 'payload' => json_encode($payload), 'delivered_at' => now()]);

        return 'success';
    }
}
