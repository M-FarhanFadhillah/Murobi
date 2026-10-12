<?php

namespace Tests\Feature\Api;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class AdminContentApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        config(['filesystems.default' => 'public']);
        Storage::fake('public');

        DB::table('masjids')->insert([
            'id' => 1, 'masjid_name' => 'As-Syifa', 'masjid_pict' => 'x.jpg',
            'alamat' => 'Bandar Lampung', 'ketua_masjid' => 'Pak', 'kapasitas' => 100,
            'saldo_awal' => 0, 'kas' => 0, 'created_at' => now(), 'updated_at' => now(),
        ]);
        DB::table('jenis_educations')->insert([
            ['id' => 1, 'jenis_edukasi' => 'Buku', 'slug' => 'buku', 'created_at' => now(), 'updated_at' => now()],
            ['id' => 2, 'jenis_edukasi' => 'Video', 'slug' => 'video', 'created_at' => now(), 'updated_at' => now()],
        ]);
    }

    private function user(bool $admin): User
    {
        return User::create([
            'name' => $admin ? 'Admin' : 'Jamaah',
            'email' => $admin ? 'admin@x.com' : 'jamaah@x.com',
            'no_hp' => $admin ? '081200000001' : '081200000002',
            'profil_pict' => '',
            'password' => Hash::make('Rahasia#123'),
            'is_admin' => $admin,
            'status' => 1,
        ]);
    }

    private function asAdmin(): self
    {
        return $this->actingAs($this->user(true), 'sanctum');
    }

    private function png(string $name = 'poster.png'): UploadedFile
    {
        $png = base64_decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==');

        return UploadedFile::fake()->createWithContent($name, $png);
    }

    private function hdr(): array
    {
        return ['Accept' => 'application/json'];
    }

    // ---- Hak akses ----

    public function test_tanpa_token_ditolak_dan_jamaah_biasa_dilarang(): void
    {
        $this->post('/api/activity', [], $this->hdr())->assertUnauthorized();
        $this->delete('/api/edu/1', [], $this->hdr())->assertUnauthorized();

        $this->actingAs($this->user(false), 'sanctum');
        $this->post('/api/activity', [
            'masjid_id' => 1, 'activity_name' => 'X', 'pict' => $this->png(),
        ], $this->hdr())->assertForbidden()
            ->assertJsonPath('message', 'Hanya admin yang boleh melakukan ini.');
        $this->delete('/api/edu/1', [], $this->hdr())->assertForbidden();
        $this->assertDatabaseCount('activities', 0);
    }

    // ---- Kegiatan ----

    public function test_admin_menambah_mengubah_dan_menghapus_kegiatan(): void
    {
        $created = $this->asAdmin()->post('/api/activity', [
            'masjid_id' => 1,
            'activity_name' => '  Kajian Subuh  ',
            'deskripsi' => 'Setiap Subuh.',
            'pict' => $this->png(),
        ], $this->hdr())->assertCreated()
            ->assertJsonPath('activity_name', 'Kajian Subuh')
            ->assertJsonPath('deskripsi', 'Setiap Subuh.')
            ->assertJsonPath('masjid_name', 'As-Syifa');
        $id = $created->json('id');
        $oldPict = $created->json('pict');
        Storage::disk('public')->assertExists($oldPict);
        $this->assertNotNull($created->json('pict_url'));

        // Ubah teks saja: poster tetap.
        $this->post("/api/activity/$id", ['activity_name' => 'Kajian Maghrib'], $this->hdr())
            ->assertOk()->assertJsonPath('activity_name', 'Kajian Maghrib')
            ->assertJsonPath('pict', $oldPict);
        Storage::disk('public')->assertExists($oldPict);

        // Ganti poster: berkas lama dihapus.
        $updated = $this->post("/api/activity/$id", ['pict' => $this->png('baru.png')], $this->hdr())
            ->assertOk();
        Storage::disk('public')->assertMissing($oldPict);
        Storage::disk('public')->assertExists($updated->json('pict'));

        $this->delete("/api/activity/$id", [], $this->hdr())->assertOk();
        $this->assertDatabaseCount('activities', 0);
        Storage::disk('public')->assertMissing($updated->json('pict'));

        $this->delete("/api/activity/$id", [], $this->hdr())->assertNotFound();
    }

    public function test_kegiatan_validasi_dengan_pesan_indonesia(): void
    {
        $this->asAdmin();

        $this->post('/api/activity', ['masjid_id' => 99, 'activity_name' => 'X', 'pict' => $this->png()], $this->hdr())
            ->assertStatus(422)->assertJsonPath('errors.masjid_id.0', 'Masjid tidak ditemukan.');
        $this->post('/api/activity', ['masjid_id' => 1], $this->hdr())
            ->assertStatus(422)
            ->assertJsonPath('errors.activity_name.0', 'Judul kegiatan wajib diisi.')
            ->assertJsonPath('errors.pict.0', 'Poster kegiatan wajib diunggah.');
        $this->post('/api/activity', [
            'masjid_id' => 1, 'activity_name' => 'X',
            'pict' => UploadedFile::fake()->create('dokumen.pdf', 10),
        ], $this->hdr())->assertStatus(422)->assertJsonPath('errors.pict.0', 'Poster harus berupa gambar.');
        $this->assertDatabaseCount('activities', 0);
    }

    // ---- Edukasi ----

    public function test_admin_menambah_buku_dengan_dan_tanpa_gambar(): void
    {
        $this->asAdmin();

        $with = $this->post('/api/edu', [
            'jenis' => 'book', 'judul' => 'Rukun Islam', 'kategori' => 0,
            'deskripsi' => 'Isi artikel.', 'content' => $this->png('cover.png'),
        ], $this->hdr())->assertCreated()
            ->assertJsonPath('jenis_education_id', 1);
        // Tipe angka (bukan string dari form), sama seperti pada GET daftar.
        $this->assertSame(0, $with->json('kategori'));
        $this->assertSame(1, $with->json('jenis_education_id'));
        Storage::disk('public')->assertExists($with->json('content'));
        $this->assertStringEndsWith($with->json('content'), $with->json('content_url'));

        $without = $this->post('/api/edu', [
            'jenis' => 'book', 'judul' => 'Tanpa gambar', 'kategori' => 1, 'deskripsi' => 'Teks saja.',
        ], $this->hdr())->assertCreated()
            ->assertJsonPath('content', '')
            ->assertJsonPath('content_url', null);

        $list = $this->getJson('/api/edu/book')->assertOk();
        $this->assertCount(2, $list->json());
        $this->assertNotNull($without->json('id'));
    }

    public function test_video_dengan_tautan_atau_berkas_dan_wajib_salah_satunya(): void
    {
        $this->asAdmin();

        $link = $this->post('/api/edu', [
            'jenis' => 'video', 'judul' => 'Video YouTube', 'kategori' => 2,
            'deskripsi' => 'Tonton.', 'video_url' => 'https://youtu.be/dQw4w9WgXcQ',
        ], $this->hdr())->assertCreated()
            ->assertJsonPath('jenis_education_id', 2)
            ->assertJsonPath('content', 'https://youtu.be/dQw4w9WgXcQ')
            ->assertJsonPath('content_url', 'https://youtu.be/dQw4w9WgXcQ');

        $file = $this->post('/api/edu', [
            'jenis' => 'video', 'judul' => 'Video berkas', 'kategori' => 0, 'deskripsi' => 'Tonton.',
            'content' => UploadedFile::fake()->create('v.mp4', 100, 'video/mp4'),
        ], $this->hdr())->assertCreated();
        Storage::disk('public')->assertExists($file->json('content'));

        $this->post('/api/edu', [
            'jenis' => 'video', 'judul' => 'Kosong', 'kategori' => 0, 'deskripsi' => 'x',
        ], $this->hdr())->assertStatus(422)
            ->assertJsonPath('errors.content.0', 'Video wajib berisi berkas atau tautan.');

        $this->post('/api/edu', [
            'jenis' => 'book', 'judul' => 'Buku', 'kategori' => 0, 'deskripsi' => 'x',
            'video_url' => 'https://youtu.be/dQw4w9WgXcQ',
        ], $this->hdr())->assertStatus(422)->assertJsonPath('errors.video_url.0', 'Tautan video hanya untuk materi video.');

        $this->assertCount(2, $this->getJson('/api/edu/video')->json());
        $this->assertNotNull($link->json('id'));
    }

    public function test_edukasi_validasi_jenis_kategori_dan_tipe_berkas(): void
    {
        $this->asAdmin();

        $this->post('/api/edu', ['jenis' => 'x', 'judul' => 'a', 'kategori' => 0, 'deskripsi' => 'b'], $this->hdr())
            ->assertStatus(422)->assertJsonPath('errors.jenis.0', 'Jenis materi harus book atau video.');
        $this->post('/api/edu', ['jenis' => 'book', 'judul' => 'a', 'kategori' => 7, 'deskripsi' => 'b'], $this->hdr())
            ->assertStatus(422)->assertJsonPath('errors.kategori.0', 'Kategori tidak dikenal.');
        $this->post('/api/edu', [
            'jenis' => 'book', 'judul' => 'a', 'kategori' => 0, 'deskripsi' => 'b',
            'content' => UploadedFile::fake()->create('v.mp4', 10, 'video/mp4'),
        ], $this->hdr())->assertStatus(422)->assertJsonPath('errors.content.0', 'Jenis berkas tidak didukung.');
        $this->assertDatabaseCount('education', 0);
    }

    public function test_ubah_dan_hapus_edukasi_membersihkan_berkas_lama(): void
    {
        $this->asAdmin();
        $created = $this->post('/api/edu', [
            'jenis' => 'book', 'judul' => 'Lama', 'kategori' => 0, 'deskripsi' => 'Isi.',
            'content' => $this->png('a.png'),
        ], $this->hdr())->assertCreated();
        $id = $created->json('id');
        $oldFile = $created->json('content');

        $changed = $this->post("/api/edu/$id", ['judul' => 'Baru', 'kategori' => 2], $this->hdr())
            ->assertOk()->assertJsonPath('judul', 'Baru')->assertJsonPath('kategori', 2)
            ->assertJsonPath('deskripsi', 'Isi.')->assertJsonPath('content', $oldFile);
        $this->assertSame(2, $changed->json('kategori'));

        $new = $this->post("/api/edu/$id", ['content' => $this->png('b.png')], $this->hdr())->assertOk();
        Storage::disk('public')->assertMissing($oldFile);
        Storage::disk('public')->assertExists($new->json('content'));

        // Jenis tidak berubah lewat pembaruan.
        $this->post("/api/edu/$id", ['jenis' => 'video', 'judul' => 'Tetap buku'], $this->hdr())->assertOk()
            ->assertJsonPath('jenis_education_id', 1);

        $this->delete("/api/edu/$id", [], $this->hdr())->assertOk();
        Storage::disk('public')->assertMissing($new->json('content'));
        $this->assertDatabaseCount('education', 0);
        $this->delete("/api/edu/$id", [], $this->hdr())->assertNotFound();
    }

    public function test_mengganti_tautan_video_tidak_mencoba_menghapus_berkas(): void
    {
        $this->asAdmin();
        $id = $this->post('/api/edu', [
            'jenis' => 'video', 'judul' => 'V', 'kategori' => 0, 'deskripsi' => 'x',
            'video_url' => 'https://youtu.be/dQw4w9WgXcQ',
        ], $this->hdr())->json('id');

        $this->post("/api/edu/$id", ['video_url' => 'https://youtu.be/aaaaaaaaaaa'], $this->hdr())
            ->assertOk()->assertJsonPath('content_url', 'https://youtu.be/aaaaaaaaaaa');

        $this->delete("/api/edu/$id", [], $this->hdr())->assertOk();
    }
}
