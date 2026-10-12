<?php

namespace Tests;

use Illuminate\Contracts\Console\Kernel;

trait CreatesApplication
{
    /**
     * Creates the application.
     *
     * @return \Illuminate\Foundation\Application
     */
    public function createApplication()
    {
        $app = require __DIR__.'/../bootstrap/app.php';

        $app->make(Kernel::class)->bootstrap();

        // Pengaman: tes memakai RefreshDatabase yang MENGHAPUS seluruh tabel.
        // Tolak berjalan bila koneksinya bukan SQLite sementara, agar database
        // asli (PostgreSQL di .env) tidak pernah ikut terhapus.
        if (config('database.default') !== 'sqlite') {
            throw new \RuntimeException(
                'Tes menolak berjalan: koneksi database "'.config('database.default').'" bukan sqlite. '
                .'Jalankan lewat phpunit.xml (DB_CONNECTION=sqlite, DB_DATABASE=:memory:).'
            );
        }

        return $app;
    }
}
