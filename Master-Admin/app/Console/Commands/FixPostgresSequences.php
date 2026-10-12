<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

/**
 * Basis data PostgreSQL yang dipulihkan dari cadangan SQL sering menyimpan baris dengan id eksplisit
 * tanpa menaikkan penghitung id (sequence). Akibatnya menambah data baru gagal dengan
 * "duplicate key value violates unique constraint ..._pkey". Perintah ini menaikkan setiap sequence
 * ke id tertinggi di tabelnya. Isi tabel tidak diubah.
 *
 *   php artisan db:fix-sequences --dry-run   (hanya melaporkan)
 *   php artisan db:fix-sequences             (memperbaiki)
 */
class FixPostgresSequences extends Command
{
    protected $signature = 'db:fix-sequences {--dry-run : Hanya melaporkan, tidak mengubah apa pun}';

    protected $description = 'PostgreSQL: samakan sequence id dengan id tertinggi tiap tabel (setelah restore cadangan)';

    public function handle(): int
    {
        if (DB::connection()->getDriverName() !== 'pgsql') {
            $this->info('Hanya untuk PostgreSQL; koneksi saat ini bukan pgsql, tidak ada yang dilakukan.');

            return self::SUCCESS;
        }

        $dry = (bool) $this->option('dry-run');
        $tables = DB::select(
            "select table_name from information_schema.columns
             where table_schema = 'public' and column_name = 'id' order by table_name"
        );

        $fixed = 0;
        foreach ($tables as $t) {
            $table = $t->table_name;
            $seq = DB::selectOne("select pg_get_serial_sequence(?, 'id') as s", ['public.' . $table])->s;
            if (!$seq) {
                continue;
            }

            $max = (int) DB::table($table)->max('id');
            $row = DB::selectOne("select last_value, is_called from {$seq}");
            $next = $row->is_called ? ((int) $row->last_value + 1) : (int) $row->last_value;

            if ($next > $max) {
                $this->line(sprintf('  %-24s ok (id berikutnya %d)', $table, $next));
                continue;
            }

            $this->warn(sprintf('  %-24s TERTINGGAL (id tertinggi %d, id berikutnya %d)', $table, $max, $next));
            if (!$dry) {
                DB::statement("select setval('{$seq}', {$max}, true)");
                $this->info(sprintf('    -> diperbaiki, id berikutnya sekarang %d', $max + 1));
            }
            $fixed++;
        }

        $this->line($dry ? "Dry run: {$fixed} tabel perlu diperbaiki." : "Selesai: {$fixed} tabel diperbaiki.");

        return self::SUCCESS;
    }
}
