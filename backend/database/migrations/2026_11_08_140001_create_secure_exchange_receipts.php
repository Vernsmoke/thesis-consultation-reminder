<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('secure_exchange_receipts', function (Blueprint $table) {
            $table->id();
            $table->uuid('message_id')->unique();
            $table->string('key_id', 40);
            $table->foreignId('recipient_user_id')->constrained('users');
            $table->foreignId('consultation_id')->constrained('consultations');
            $table->string('payload_hash', 64);
            $table->timestamp('accepted_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('secure_exchange_receipts');
    }
};
