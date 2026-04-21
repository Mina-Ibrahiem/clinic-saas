<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Doctors link to users when they authenticate; user_id nullable for external / locum records.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('doctors', function (Blueprint $table) {
            $table->id();
            $table->foreignId('tenant_id')->constrained()->cascadeOnDelete();
            $table->foreignId('branch_id')->constrained()->restrictOnDelete();
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $table->string('doctor_code', 32)->nullable();
            $table->string('full_name');
            $table->string('specialization');
            $table->string('license_number')->nullable();
            $table->decimal('consultation_fee', 12, 2)->nullable();
            $table->text('bio')->nullable();
            $table->string('status', 32)->default('active')->index();
            $table->timestamps();
            $table->softDeletes();

            $table->unique(['tenant_id', 'doctor_code']);
            $table->index(['tenant_id', 'branch_id', 'status']);
            $table->index('user_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('doctors');
    }
};
