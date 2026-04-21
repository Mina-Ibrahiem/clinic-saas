<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Key/value configuration. Prefer tenant-wide keys; use branch_id for branch overrides.
 * Application layer should enforce uniqueness (tenant + optional branch + key).
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('settings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('tenant_id')->nullable()->constrained()->cascadeOnDelete();
            $table->foreignId('branch_id')->nullable()->constrained()->nullOnDelete();
            $table->string('key', 191);
            $table->text('value')->nullable();
            $table->timestamps();

            $table->index(['tenant_id', 'key']);
            $table->index(['tenant_id', 'branch_id', 'key']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('settings');
    }
};
