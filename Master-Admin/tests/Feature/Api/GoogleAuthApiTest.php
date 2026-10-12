<?php

namespace Tests\Feature\Api;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

/**
 * Login Google. Panggilan ke Google dipalsukan (Http::fake): tidak ada
 * permintaan sungguhan yang keluar saat tes berjalan.
 */
class GoogleAuthApiTest extends TestCase
{
    use RefreshDatabase;

    private const CLIENT = 'abc123.apps.googleusercontent.com';

    protected function setUp(): void
    {
        parent::setUp();
        config([
            'services.google.client_id' => self::CLIENT . ', lain.apps.googleusercontent.com',
            'services.google.auto_approve' => true,
        ]);
    }

    private function fakeIdToken(array $overrides = [], int $status = 200): void
    {
        Http::fake([
            'oauth2.googleapis.com/tokeninfo*' => Http::response(array_merge([
                'iss' => 'https://accounts.google.com',
                'aud' => self::CLIENT,
                'sub' => '1122334455',
                'email' => 'Siti@Gmail.com',
                'email_verified' => 'true',
                'name' => 'Siti Aminah',
            ], $overrides), $status),
        ]);
    }

    public function test_akun_baru_dibuat_dan_langsung_masuk(): void
    {
        $this->fakeIdToken();

        $response = $this->postJson('/api/auth/google', ['id_token' => 'token-asli'])
            ->assertOk()
            ->assertJsonPath('token_type', 'Bearer')
            ->assertJsonPath('user.email', 'siti@gmail.com')
            ->assertJsonPath('user.name', 'Siti Aminah')
            ->assertJsonPath('user.is_admin', false)
            ->assertJsonPath('user.status', 1)
            // Nomor pengganti tidak pernah sampai ke aplikasi.
            ->assertJsonPath('user.no_hp', '');

        $user = User::where('email', 'siti@gmail.com')->first();
        $this->assertNotNull($user);
        $this->assertSame('google:1122334455', $user->no_hp);

        // Token yang diterima benar-benar dapat dipakai.
        $this->app['auth']->forgetGuards();
        $this->withHeader('Authorization', 'Bearer ' . $response->json('token'))
            ->getJson('/api/me')->assertOk()->assertJsonPath('user.email', 'siti@gmail.com');
    }

    public function test_akun_yang_sudah_ada_dicocokkan_lewat_email_tanpa_membuat_akun_kedua(): void
    {
        User::create([
            'name' => 'Siti Lama', 'email' => 'siti@gmail.com', 'no_hp' => '081234567890',
            'profil_pict' => '', 'password' => Hash::make('Rahasia#123'),
            'is_admin' => false, 'status' => 1,
        ]);
        $this->fakeIdToken();

        $this->postJson('/api/auth/google', ['id_token' => 'token-asli'])
            ->assertOk()
            ->assertJsonPath('user.name', 'Siti Lama')
            ->assertJsonPath('user.no_hp', '081234567890');

        $this->assertSame(1, User::count());
    }

    public function test_status_akun_menunggu_atau_ditolak_tetap_dihormati(): void
    {
        $user = User::create([
            'name' => 'Siti Lama', 'email' => 'siti@gmail.com', 'no_hp' => '081234567890',
            'profil_pict' => '', 'password' => Hash::make('Rahasia#123'),
            'is_admin' => false, 'status' => 0,
        ]);
        $this->fakeIdToken();

        $this->postJson('/api/auth/google', ['id_token' => 'x'])
            ->assertForbidden()
            ->assertJsonPath('message', 'Akun Anda menunggu persetujuan admin.');

        $user->update(['status' => 2]);
        $this->postJson('/api/auth/google', ['id_token' => 'x'])
            ->assertForbidden()
            ->assertJsonPath('message', 'Pendaftaran Anda ditolak oleh admin.');
    }

    public function test_akun_baru_menunggu_persetujuan_bila_persetujuan_otomatis_dimatikan(): void
    {
        config(['services.google.auto_approve' => false]);
        $this->fakeIdToken();

        $this->postJson('/api/auth/google', ['id_token' => 'x'])
            ->assertForbidden()
            ->assertJsonPath('message', 'Akun Anda menunggu persetujuan admin.');
        $this->assertSame(0, (int) User::first()->status);
    }

    public function test_token_dari_aplikasi_lain_atau_email_belum_terverifikasi_ditolak(): void
    {
        $this->fakeIdToken(['aud' => 'aplikasi-orang-lain.apps.googleusercontent.com']);
        $this->postJson('/api/auth/google', ['id_token' => 'x'])
            ->assertUnauthorized()
            ->assertJsonPath('message', 'Akun Google tidak dapat diverifikasi.');

        $this->fakeIdToken(['email_verified' => 'false']);
        $this->postJson('/api/auth/google', ['id_token' => 'x'])->assertUnauthorized();

        $this->fakeIdToken(['iss' => 'https://palsu.example.com']);
        $this->postJson('/api/auth/google', ['id_token' => 'x'])->assertUnauthorized();

        $this->assertSame(0, User::count());
    }

    public function test_token_ditolak_google_atau_kosong(): void
    {
        $this->fakeIdToken(['error' => 'invalid_token'], 400);
        $this->postJson('/api/auth/google', ['id_token' => 'kedaluwarsa'])->assertUnauthorized();

        $this->postJson('/api/auth/google', [])->assertUnauthorized();
        $this->assertSame(0, User::count());
    }

    public function test_tanpa_client_id_di_server_dijawab_belum_dikonfigurasi(): void
    {
        config(['services.google.client_id' => null]);
        Http::fake();

        $this->postJson('/api/auth/google', ['id_token' => 'x'])
            ->assertStatus(503)
            ->assertJsonPath('message', 'Login Google belum dikonfigurasi di server.');
        Http::assertNothingSent();
    }

    public function test_access_token_dari_web_diperiksa_beserta_profilnya(): void
    {
        Http::fake([
            'oauth2.googleapis.com/tokeninfo*' => Http::response([
                'aud' => self::CLIENT,
                'email' => 'budi@gmail.com',
                'email_verified' => 'true',
            ]),
            'www.googleapis.com/oauth2/v3/userinfo' => Http::response([
                'sub' => '998877',
                'name' => 'Budi Santoso',
                'email' => 'budi@gmail.com',
                'email_verified' => true,
            ]),
        ]);

        $this->postJson('/api/auth/google', ['access_token' => 'akses'])
            ->assertOk()
            ->assertJsonPath('user.name', 'Budi Santoso')
            ->assertJsonPath('user.email', 'budi@gmail.com');
    }
}
