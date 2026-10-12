<?php

namespace App\Support;

use Illuminate\Support\Facades\Storage;

class FileUrl
{
    /**
     * Alamat lengkap sebuah berkas unggahan (mis. "cover-banner/abc.jpg") yang
     * dilayani oleh GET /api/files/{path}. Mengembalikan null jika path kosong
     * atau berkasnya tidak ada di disk, supaya klien tidak menampilkan gambar rusak.
     */
    public static function for(?string $path): ?string
    {
        if (!$path || str_contains($path, '..')) {
            return null;
        }
        if (!Storage::disk(config('filesystems.default'))->exists($path)) {
            return null;
        }

        $encoded = implode('/', array_map('rawurlencode', explode('/', $path)));

        return url('api/files/' . $encoded);
    }
}
