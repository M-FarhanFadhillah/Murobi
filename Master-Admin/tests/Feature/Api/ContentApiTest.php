<?php

namespace Tests\Feature\Api;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class ContentApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        config(['filesystems.default' => 'public']);
        Storage::fake('public');
    }

    private function masjid(int $id, string $name, string $pict = 'masjid-profile/m.jpg'): void
    {
        DB::table('masjids')->insert([
            'id' => $id, 'masjid_name' => $name, 'masjid_pict' => $pict,
            'alamat' => 'Bandar Lampung', 'ketua_masjid' => 'Pak Ketua',
            'kapasitas' => 500, 'saldo_awal' => 1000, 'kas' => 2000,
            'created_at' => now(), 'updated_at' => now(),
        ]);
    }

    public function test_banner_hanya_yang_aktif_dan_menyertakan_cover_url(): void
    {
        Storage::disk('public')->put('cover-banner/a.jpg', 'gambar');
        foreach ([
            ['judul' => 'Aktif', 'cover' => 'cover-banner/a.jpg', 'status' => true],
            ['judul' => 'Aktif tanpa berkas', 'cover' => 'cover-banner/hilang.jpg', 'status' => true],
            ['judul' => 'Nonaktif', 'cover' => 'cover-banner/a.jpg', 'status' => false],
        ] as $row) {
            DB::table('banners')->insert($row + [
                'deskripsi' => 'd', 'kategori' => 1,
                'created_at' => now(), 'updated_at' => now(),
            ]);
        }

        $response = $this->getJson('/api/banner')->assertOk();
        $response->assertJsonCount(2);
        $this->assertSame(['Aktif', 'Aktif tanpa berkas'], collect($response->json())->pluck('judul')->all());

        // Field lama tetap ada.
        $response->assertJsonStructure([['id', 'judul', 'deskripsi', 'cover', 'kategori', 'status', 'created_at', 'updated_at', 'cover_url']]);
        $this->assertStringEndsWith('/api/files/cover-banner/a.jpg', $response->json('0.cover_url'));
        $this->assertNull($response->json('1.cover_url'));
    }

    public function test_edukasi_dipisah_buku_dan_video(): void
    {
        Storage::disk('public')->put('konten-edukasi/v.mp4', 'video');
        DB::table('jenis_educations')->insert([
            ['id' => 1, 'jenis_edukasi' => 'Buku', 'slug' => 'buku', 'created_at' => now(), 'updated_at' => now()],
            ['id' => 2, 'jenis_edukasi' => 'Video', 'slug' => 'video', 'created_at' => now(), 'updated_at' => now()],
        ]);
        foreach ([
            [1, 'Buku A', 1, 'konten-edukasi/hilang.jpg'],
            [2, 'Video B', 0, 'konten-edukasi/v.mp4'],
        ] as [$jenis, $judul, $kategori, $content]) {
            DB::table('education')->insert([
                'jenis_education_id' => $jenis, 'judul' => $judul, 'kategori' => $kategori,
                'content' => $content, 'deskripsi' => 'desk',
                'created_at' => now(), 'updated_at' => now(),
            ]);
        }

        $book = $this->getJson('/api/edu/book')->assertOk();
        $book->assertJsonCount(1)->assertJsonPath('0.judul', 'Buku A')->assertJsonPath('0.content_url', null);

        $video = $this->getJson('/api/edu/video')->assertOk();
        $video->assertJsonCount(1)
            ->assertJsonPath('0.judul', 'Video B')
            ->assertJsonPath('0.kategori', 0)
            ->assertJsonPath('0.content', 'konten-edukasi/v.mp4');
        $this->assertStringEndsWith('/api/files/konten-edukasi/v.mp4', $video->json('0.content_url'));
    }

    public function test_masjid_daftar_dan_satuan_tetap_berbentuk_larik(): void
    {
        Storage::disk('public')->put('masjid-profile/m.jpg', 'foto');
        $this->masjid(1, 'As-Syifa');
        $this->masjid(2, 'Al-Furqon', 'masjid-profile/hilang.jpg');

        $this->getJson('/api/masjid')->assertOk()->assertJsonCount(2)
            ->assertJsonPath('0.masjid_name', 'As-Syifa')
            ->assertJsonPath('1.masjid_pict_url', null);

        $one = $this->getJson('/api/masjid/1')->assertOk();
        $one->assertJsonCount(1)->assertJsonPath('0.masjid_name', 'As-Syifa');
        $this->assertStringEndsWith('/api/files/masjid-profile/m.jpg', $one->json('0.masjid_pict_url'));

        $this->getJson('/api/masjid/999')->assertOk()->assertExactJson([]);
    }

    public function test_kegiatan_terbaru_di_atas_dengan_filter_masjid(): void
    {
        Storage::disk('public')->put('gambar-kegiatan/k.jpg', 'poster');
        $this->masjid(1, 'As-Syifa');
        $this->masjid(2, 'Al-Furqon');
        foreach ([
            [1, 'Kajian Lama', '2024-01-01 08:00:00', 'gambar-kegiatan/k.jpg'],
            [1, 'Kajian Baru', '2024-03-01 08:00:00', 'test123'],
            [2, 'Pengajian Furqon', '2024-02-01 08:00:00', 'gambar-kegiatan/k.jpg'],
        ] as [$masjidId, $nama, $waktu, $pict]) {
            DB::table('activities')->insert([
                'masjid_id' => $masjidId, 'activity_name' => $nama, 'decription' => 'Deskripsi ' . $nama,
                'categories' => 0, 'pict' => $pict, 'created_at' => $waktu, 'updated_at' => $waktu,
            ]);
        }

        $all = $this->getJson('/api/activity')->assertOk();
        $this->assertSame(
            ['Kajian Baru', 'Pengajian Furqon', 'Kajian Lama'],
            collect($all->json())->pluck('activity_name')->all()
        );
        $all->assertJsonPath('0.pict_url', null) // "test123" bukan berkas yang ada
            ->assertJsonPath('0.masjid_name', 'As-Syifa')
            ->assertJsonPath('0.deskripsi', 'Deskripsi Kajian Baru')
            ->assertJsonPath('0.decription', 'Deskripsi Kajian Baru');
        $this->assertStringEndsWith('/api/files/gambar-kegiatan/k.jpg', $all->json('1.pict_url'));

        $this->getJson('/api/activity?masjid_id=2')->assertOk()
            ->assertJsonCount(1)
            ->assertJsonPath('0.activity_name', 'Pengajian Furqon');
        $this->getJson('/api/activity?masjid_id=abc')->assertStatus(422);
    }

    public function test_berkas_disajikan_hanya_dari_folder_yang_diizinkan(): void
    {
        Storage::disk('public')->put('cover-banner/a.txt', '0123456789');
        Storage::disk('public')->put('rahasia/data.txt', 'jangan dibuka');

        $this->get('/api/files/cover-banner/a.txt')->assertOk();
        $this->get('/api/files/cover-banner/tidak-ada.jpg')->assertNotFound();
        $this->get('/api/files/rahasia/data.txt')->assertNotFound();
        $this->get('/api/files/cover-banner/..%2Frahasia%2Fdata.txt')->assertNotFound();
        $this->get('/api/files/..%2F.env')->assertNotFound();
    }

    public function test_berkas_mendukung_range_untuk_video(): void
    {
        Storage::disk('public')->put('konten-edukasi/v.mp4', '0123456789');

        $response = $this->withHeader('Range', 'bytes=2-5')->get('/api/files/konten-edukasi/v.mp4');

        $response->assertStatus(206);
        $response->assertHeader('Content-Range', 'bytes 2-5/10');

        // BinaryFileResponse mengirim potongan berkas lewat sendContent().
        ob_start();
        $response->baseResponse->sendContent();
        $this->assertSame('2345', ob_get_clean());
    }
}
