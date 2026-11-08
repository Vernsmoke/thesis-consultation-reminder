<?php

namespace App\Services;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class Audit
{
    public static function record(string $event, ?int $entity, string $correlation, array $metadata = [], ?int $actor = null): void
    {
        // Deliberately allowlist metadata at each call site. Never include request bodies or credentials.
        DB::table('workflow_audits')->insert(['event' => $event, 'entity_id' => $entity, 'actor_id' => $actor,
            'correlation_id' => $correlation, 'metadata' => json_encode($metadata), 'created_at' => now()]);
        Log::info('workflow', ['event' => $event, 'entity_id' => $entity, 'correlation_id' => $correlation] + $metadata);
    }
}
