<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $t) {
            $t->string('role')->default('student');
        });
        Schema::create('api_sessions', function (Blueprint $t) {
            $t->id();
            $t->foreignId('user_id')->constrained();
            $t->string('token_hash', 64)->unique();
            $t->timestamp('expires_at');
        });
        Schema::create('consultations', function (Blueprint $t) {
            $t->id();
            $t->foreignId('student_id')->constrained('users');
            $t->foreignId('adviser_id')->constrained('users');
            $t->foreignId('panel_id')->nullable()->constrained('users');
            $t->text('agenda');
            $t->dateTime('scheduled_at');
            $t->string('status')->default('requested');
            $t->timestamps();
        });
        Schema::create('action_items', function (Blueprint $t) {
            $t->id();
            $t->foreignId('consultation_id')->constrained();
            $t->text('description');
            $t->dateTime('due_at');
            $t->string('status')->default('open');
            $t->timestamps();
        });
        Schema::create('idempotency_keys', function (Blueprint $t) {
            $t->id();
            $t->foreignId('user_id')->constrained();
            $t->string('request_key', 80);
            $t->string('payload_hash', 64);
            $t->unsignedBigInteger('consultation_id');
            $t->unique(['user_id', 'request_key']);
        });
        Schema::create('outbox', function (Blueprint $t) {
            $t->id();
            $t->string('event_key', 160)->unique();
            $t->string('kind');
            $t->unsignedBigInteger('entity_id');
            $t->string('status')->default('pending');
            $t->unsignedInteger('attempts')->default(0);
            $t->dateTime('available_at');
            $t->string('correlation_id', 36);
            $t->string('failure_code')->nullable();
            $t->string('simulation')->default('success');
            $t->text('resolution')->nullable();
            $t->timestamps();
            $t->index(['status', 'available_at']);
        });
        Schema::create('notification_receipts', function (Blueprint $t) {
            $t->id();
            $t->foreignId('outbox_id')->unique()->constrained('outbox');
            $t->string('kind');
            $t->unsignedBigInteger('recipient_id');
            $t->json('payload');
            $t->dateTime('delivered_at');
        });
        Schema::create('workflow_audits', function (Blueprint $t) {
            $t->id();
            $t->string('event');
            $t->unsignedBigInteger('entity_id')->nullable();
            $t->unsignedBigInteger('actor_id')->nullable();
            $t->string('correlation_id', 36);
            $t->json('metadata');
            $t->timestamp('created_at');
        });
    }

    public function down(): void
    {
        foreach (['workflow_audits', 'notification_receipts', 'outbox', 'idempotency_keys', 'action_items', 'consultations', 'api_sessions'] as $table) {
            Schema::dropIfExists($table);
        }
        Schema::table('users', fn (Blueprint $t) => $t->dropColumn('role'));
    }
};
