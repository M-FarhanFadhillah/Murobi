<?php

namespace Tests\Feature\Api;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class AuthApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        config(['filesystems.default' => 'public']);
        Storage::fake('public');
    }

    private function makeUser(array $overrides = []): User
    {
        return User::create(array_merge([
            'name' => 'Ahmad Al Farizi',
            'email' => 'ahmad@gmail.com',
            'no_hp' => '081994851234',
            'profil_pict' => '',
            'password' => Hash::make('Rahasia#123'),
            'is_admin' => false,
            'status' => 1,
        ], $overrides));
    }

    private function validRegistration(array $overrides = []): array
    {
        return array_merge([
            'name' => 'Budi Santoso',
            'email' => 'Budi@Contoh.com',
            'no_hp' => '081311112222',
            'password' => 'Rahasia#123',
        ], $overrides);
    }

    private function loginToken(string $login = 'ahmad@gmail.com', string $password = 'Rahasia#123'): string
    {
        return $this->postJson('/api/login', ['login' => $login, 'password' => $password])
            ->assertOk()
            ->json('token');
    }

    // PNG 1x1 piksel sungguhan (PHP di mesin uji tidak punya ekstensi GD untuk image()).
    private function fakePhoto(string $name): UploadedFile
    {
        $png = base64_decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==');

        return UploadedFile::fake()->createWithContent($name, $png);
    }

    private function authed(string $token): self
    {
        // Guard menyimpan pengguna selama satu aplikasi; reset agar token dibaca ulang.
        $this->app['auth']->forgetGuards();

        return $this->withHeader('Authorization', 'Bearer ' . $token);
    }

    public function test_register_membuat_akun_menunggu_persetujuan_dengan_hash(): void
    {
        $response = $this->postJson('/api/register', $this->validRegistration());

        $response->assertCreated()
            ->assertJsonPath('user.status', 0)
            ->assertJsonPath('user.is_admin', false)
            ->assertJsonPath('user.email', 'budi@contoh.com')
            ->assertJsonMissingPath('user.password');

        $user = User::where('email', 'budi@contoh.com')->first();
        $this->assertNotNull($user);
        $this->assertTrue(Hash::check('Rahasia#123', $user->password));
        $this->assertNotSame('Rahasia#123', $user->password);
    }

    public function test_register_menolak_data_tidak_valid_dengan_pesan_indonesia(): void
    {
        $this->makeUser(['email' => 'budi@contoh.com', 'no_hp' => '081311112222']);

        $this->postJson('/api/register', $this->validRegistration())
            ->assertStatus(422)
            ->assertJsonPath('errors.email.0', 'Email sudah terdaftar.')
            ->assertJsonPath('errors.no_hp.0', 'Nomor telepon sudah terdaftar.');

        $this->postJson('/api/register', $this->validRegistration([
            'email' => 'lain@contoh.com',
            'no_hp' => '12345',
            'password' => 'pendek',
            'name' => 'Al',
        ]))
            ->assertStatus(422)
            ->assertJsonPath('errors.no_hp.0', 'Gunakan format 08xxxxxxxxxx atau +62xxxxxxxxxx.')
            ->assertJsonPath('errors.password.0', 'Kata sandi minimal 8 karakter.')
            ->assertJsonPath('errors.name.0', 'Nama minimal 3 karakter.');
    }

    public function test_akun_menunggu_atau_ditolak_tidak_bisa_masuk(): void
    {
        $this->makeUser(['status' => 0]);
        $this->postJson('/api/login', ['login' => 'ahmad@gmail.com', 'password' => 'Rahasia#123'])
            ->assertForbidden()
            ->assertJsonPath('message', 'Akun Anda menunggu persetujuan admin.');

        User::query()->update(['status' => 2]);
        $this->postJson('/api/login', ['login' => 'ahmad@gmail.com', 'password' => 'Rahasia#123'])
            ->assertForbidden()
            ->assertJsonPath('message', 'Pendaftaran Anda ditolak oleh admin.');
    }

    public function test_login_dengan_email_atau_nomor_hp_mengembalikan_token(): void
    {
        $this->makeUser();

        $byEmail = $this->postJson('/api/login', [
            'login' => '  AHMAD@gmail.com ',
            'password' => 'Rahasia#123',
        ]);
        $byEmail->assertOk()
            ->assertJsonPath('token_type', 'Bearer')
            ->assertJsonPath('user.name', 'Ahmad Al Farizi')
            ->assertJsonMissingPath('user.password');
        $this->assertNotEmpty($byEmail->json('token'));

        $this->postJson('/api/login', ['login' => '081994851234', 'password' => 'Rahasia#123'])
            ->assertOk();
    }

    public function test_login_gagal_memberi_401(): void
    {
        $this->makeUser();

        $this->postJson('/api/login', ['login' => 'ahmad@gmail.com', 'password' => 'salah'])
            ->assertUnauthorized()
            ->assertJsonPath('message', 'ID atau kata sandi salah.');
        $this->postJson('/api/login', ['login' => 'tidak@ada.com', 'password' => 'Rahasia#123'])
            ->assertUnauthorized();
        $this->postJson('/api/login', ['login' => 'ahmad@gmail.com'])
            ->assertStatus(422);
    }

    public function test_kata_sandi_polos_data_lama_diterima_dan_tidak_diubah(): void
    {
        $user = $this->makeUser(['password' => 'qwerty123']);

        $this->postJson('/api/login', ['login' => 'ahmad@gmail.com', 'password' => 'qwerty123'])
            ->assertOk();
        $this->postJson('/api/login', ['login' => 'ahmad@gmail.com', 'password' => 'QWERTY123'])
            ->assertUnauthorized();

        // Login web membandingkan kata sandi polos, jadi nilainya harus tetap sama.
        $this->assertSame('qwerty123', $user->fresh()->password);
    }

    public function test_endpoint_terlindungi_menjawab_json_401_walau_tanpa_header_accept(): void
    {
        $this->get('/api/me')->assertUnauthorized()->assertJsonStructure(['message']);
        $this->post('/api/logout')->assertUnauthorized();
    }

    public function test_me_dan_logout(): void
    {
        $this->makeUser();
        $token = $this->loginToken();

        $this->authed($token)->getJson('/api/me')
            ->assertOk()
            ->assertJsonPath('user.email', 'ahmad@gmail.com');

        $this->authed($token)->postJson('/api/logout')->assertOk();
        $this->assertDatabaseCount('personal_access_tokens', 0);

        $this->authed($token)->getJson('/api/me')->assertUnauthorized();
    }

    public function test_ubah_data_diri_dan_keunikan_email(): void
    {
        $this->makeUser();
        $this->makeUser(['name' => 'Orang Lain', 'email' => 'lain@gmail.com', 'no_hp' => '081200000000']);
        $token = $this->loginToken();

        $this->authed($token)->patchJson('/api/me', [
            'name' => 'Ahmad Fadhillah',
            'email' => 'ahmad@gmail.com', // email sendiri boleh sama
            'no_hp' => '+6281999999999',
        ])->assertOk()
            ->assertJsonPath('user.name', 'Ahmad Fadhillah')
            ->assertJsonPath('user.no_hp', '+6281999999999');

        $this->authed($token)->patchJson('/api/me', ['email' => 'lain@gmail.com'])
            ->assertStatus(422)
            ->assertJsonPath('errors.email.0', 'Email sudah terdaftar.');
        $this->authed($token)->patchJson('/api/me', ['no_hp' => 'abc'])
            ->assertStatus(422);
    }

    public function test_unggah_foto_profil_dan_hapus_foto_lama(): void
    {
        $this->makeUser();
        $token = $this->loginToken();

        $first = $this->authed($token)->post('/api/me/photo', [
            'profil_pict' => $this->fakePhoto('foto.png'),
        ], ['Accept' => 'application/json'])->assertOk();
        $firstPath = $first->json('user.profil_pict');
        $this->assertStringStartsWith('profil-pict/', $firstPath);
        $this->assertNotNull($first->json('user.profil_pict_url'));
        Storage::disk('public')->assertExists($firstPath);

        $second = $this->authed($token)->post('/api/me/photo', [
            'profil_pict' => $this->fakePhoto('baru.png'),
        ], ['Accept' => 'application/json'])->assertOk();
        Storage::disk('public')->assertMissing($firstPath);
        Storage::disk('public')->assertExists($second->json('user.profil_pict'));

        $this->authed($token)->post('/api/me/photo', [
            'profil_pict' => UploadedFile::fake()->create('dokumen.pdf', 10),
        ], ['Accept' => 'application/json'])->assertStatus(422);
    }

    public function test_ubah_kata_sandi(): void
    {
        $user = $this->makeUser(['password' => 'qwerty123']); // data lama (polos)
        $token = $this->loginToken('ahmad@gmail.com', 'qwerty123');

        $this->authed($token)->postJson('/api/me/password', [
            'old_password' => 'salah',
            'new_password' => 'KataSandi#Baru1',
        ])->assertStatus(422)->assertJsonPath('errors.old_password.0', 'Kata sandi lama salah.');

        $this->authed($token)->postJson('/api/me/password', [
            'old_password' => 'qwerty123',
            'new_password' => 'qwerty123',
        ])->assertStatus(422);

        $this->authed($token)->postJson('/api/me/password', [
            'old_password' => 'qwerty123',
            'new_password' => 'pendek',
        ])->assertStatus(422)->assertJsonPath('errors.new_password.0', 'Kata sandi baru minimal 8 karakter.');

        $this->authed($token)->postJson('/api/me/password', [
            'old_password' => 'qwerty123',
            'new_password' => 'KataSandi#Baru1',
        ])->assertOk();

        $this->assertTrue(Hash::check('KataSandi#Baru1', $user->fresh()->password));
        $this->postJson('/api/login', ['login' => 'ahmad@gmail.com', 'password' => 'qwerty123'])
            ->assertUnauthorized();
        $this->postJson('/api/login', ['login' => 'ahmad@gmail.com', 'password' => 'KataSandi#Baru1'])
            ->assertOk();
    }

    public function test_admin_tidak_bisa_mengubah_kata_sandi_lewat_api(): void
    {
        $admin = $this->makeUser(['is_admin' => true, 'password' => 'qwerty123']);
        $token = $this->loginToken('ahmad@gmail.com', 'qwerty123');

        $this->authed($token)->postJson('/api/me/password', [
            'old_password' => 'qwerty123',
            'new_password' => 'KataSandi#Baru1',
        ])->assertForbidden();

        $this->assertSame('qwerty123', $admin->fresh()->password);
    }
}
