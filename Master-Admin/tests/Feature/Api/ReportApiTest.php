<?php

namespace Tests\Feature\Api;

use App\Models\Report;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class ReportApiTest extends TestCase
{
    use RefreshDatabase;

    private function user(string $name, bool $admin = false): User
    {
        static $n = 0;
        $n++;

        return User::create([
            'name' => $name,
            'email' => "u{$n}@x.com",
            'no_hp' => '08120000' . str_pad((string) $n, 4, '0', STR_PAD_LEFT),
            'profil_pict' => '',
            'password' => Hash::make('Rahasia#123'),
            'is_admin' => $admin,
            'status' => 1,
        ]);
    }

    private function as(User $user): self
    {
        $this->app['auth']->forgetGuards();

        return $this->actingAs($user, 'sanctum');
    }

    public function test_harus_masuk_untuk_mengirim_atau_melihat_laporan(): void
    {
        $this->postJson('/api/reports', ['message' => 'Halo ada masalah'])->assertUnauthorized();
        $this->getJson('/api/reports/mine')->assertUnauthorized();
        $this->getJson('/api/reports')->assertUnauthorized();
    }

    public function test_jamaah_mengirim_laporan_dan_melihatnya_sendiri(): void
    {
        $siti = $this->user('Siti');
        $budi = $this->user('Budi');

        $this->as($siti)->postJson('/api/reports', ['message' => '  Jadwal sholat tidak muncul  '])
            ->assertCreated()
            ->assertJsonPath('message', 'Jadwal sholat tidak muncul')
            ->assertJsonPath('status', 0)
            ->assertJsonPath('user_name', 'Siti');
        $this->as($budi)->postJson('/api/reports', ['message' => 'Foto profil gagal diunggah'])->assertCreated();

        $mine = $this->as($siti)->getJson('/api/reports/mine')->assertOk();
        $mine->assertJsonCount(1);
        $mine->assertJsonPath('0.message', 'Jadwal sholat tidak muncul');
    }

    public function test_isi_laporan_divalidasi_dengan_pesan_indonesia(): void
    {
        $siti = $this->user('Siti');

        $this->as($siti)->postJson('/api/reports', ['message' => ''])
            ->assertStatus(422)
            ->assertJsonPath('errors.message.0', 'Isi laporan wajib diisi.');
        $this->as($siti)->postJson('/api/reports', ['message' => 'ab'])
            ->assertStatus(422)
            ->assertJsonPath('errors.message.0', 'Isi laporan minimal 5 karakter.');
        $this->as($siti)->postJson('/api/reports', ['message' => str_repeat('a', 1001)])
            ->assertStatus(422)
            ->assertJsonPath('errors.message.0', 'Isi laporan maksimal 1000 karakter.');
        $this->assertSame(0, Report::count());
    }

    public function test_hanya_admin_yang_melihat_semua_laporan(): void
    {
        $siti = $this->user('Siti');
        $budi = $this->user('Budi');
        $admin = $this->user('Admin', true);
        Report::create(['user_id' => $siti->id, 'message' => 'Laporan pertama', 'status' => 0]);
        Report::create(['user_id' => $budi->id, 'message' => 'Laporan kedua', 'status' => 0]);

        $this->as($siti)->getJson('/api/reports')->assertForbidden();

        $list = $this->as($admin)->getJson('/api/reports')->assertOk();
        $list->assertJsonCount(2);
        // Terbaru di atas, lengkap dengan pengirimnya.
        $list->assertJsonPath('0.message', 'Laporan kedua');
        $list->assertJsonPath('0.user_name', 'Budi');
        $list->assertJsonPath('1.user_name', 'Siti');
    }

    public function test_admin_menandai_selesai_dan_menghapus_laporan(): void
    {
        $siti = $this->user('Siti');
        $admin = $this->user('Admin', true);
        $report = Report::create(['user_id' => $siti->id, 'message' => 'Laporan pertama', 'status' => 0]);

        $this->as($siti)->patchJson("/api/reports/{$report->id}", ['status' => 1])->assertForbidden();
        $this->as($siti)->deleteJson("/api/reports/{$report->id}")->assertForbidden();
        $this->assertSame(0, $report->fresh()->status);

        $this->as($admin)->patchJson("/api/reports/{$report->id}", ['status' => 1])
            ->assertOk()
            ->assertJsonPath('status', 1);
        $this->as($admin)->patchJson("/api/reports/{$report->id}", ['status' => 7])
            ->assertStatus(422)
            ->assertJsonPath('errors.status.0', 'Status tidak valid.');

        // Jamaah melihat status terbaru laporannya.
        $this->as($siti)->getJson('/api/reports/mine')->assertJsonPath('0.status', 1);

        $this->as($admin)->deleteJson("/api/reports/{$report->id}")->assertOk();
        $this->assertSame(0, Report::count());
        $this->as($admin)->deleteJson("/api/reports/{$report->id}")->assertNotFound();
        $this->as($admin)->patchJson("/api/reports/{$report->id}", ['status' => 1])->assertNotFound();
    }
}
