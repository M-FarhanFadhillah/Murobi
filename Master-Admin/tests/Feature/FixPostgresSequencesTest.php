<?php

namespace Tests\Feature;

use Tests\TestCase;

class FixPostgresSequencesTest extends TestCase
{
    // Tes berjalan di SQLite (lihat phpunit.xml): perintah harus aman dan tidak mengubah apa pun.
    public function test_pada_koneksi_selain_pgsql_perintah_tidak_melakukan_apa_apa(): void
    {
        $this->artisan('db:fix-sequences')
            ->expectsOutputToContain('Hanya untuk PostgreSQL')
            ->assertSuccessful();

        $this->artisan('db:fix-sequences --dry-run')->assertSuccessful();
    }
}
