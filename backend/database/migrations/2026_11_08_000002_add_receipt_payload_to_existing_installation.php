<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (! Schema::hasColumn('notification_receipts', 'recipient_id')) {
            Schema::table('notification_receipts', function (Blueprint $t) {
                $t->unsignedBigInteger('recipient_id');
                $t->json('payload');
            });
        }
    }

    public function down(): void
    { /* Foundational columns are removed with the receipt table. */
    }
};
