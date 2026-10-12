<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Storage;

/**
 * Menyajikan berkas unggahan panel admin (gambar, video) lewat API, sehingga
 * tidak bergantung pada "php artisan storage:link". Mendukung header Range
 * (BinaryFileResponse) agar video dapat diputar dan digeser.
 */
class FileController extends Controller
{
    private const ALLOWED_FOLDERS = [
        'cover-banner',
        'konten-edukasi',
        'gambar-kegiatan',
        'masjid-profile',
        'profil-pict',
    ];

    public function show(string $path)
    {
        $folder = explode('/', $path)[0];
        abort_unless(
            in_array($folder, self::ALLOWED_FOLDERS, true)
                && !str_contains($path, '..')
                && !str_contains($path, "\0"),
            404
        );

        $disk = Storage::disk(config('filesystems.default'));
        abort_unless($disk->exists($path), 404);

        return response()->file($disk->path($path), [
            'Cache-Control' => 'public, max-age=3600',
        ]);
    }
}
