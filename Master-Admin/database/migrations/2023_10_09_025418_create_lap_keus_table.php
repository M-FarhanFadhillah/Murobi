<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('lap_keus', function (Blueprint $table) {
            $table->id();
            //0 : Debit, 1 : Kredit
            $table->integer('cashflow');
            $table->string('note');
            $table->date('date');
            $table->float('saldo_awal', 20, 2);
            $table->float('kas', 20, 2);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('lap_keus');
    }
};
