<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\activity;
use App\Support\FileUrl;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ActivityController extends Controller
{
    /**
     * Kegiatan masjid, terbaru di atas. Parameter opsional: masjid_id.
     */
    public function index(Request $request): JsonResponse
    {
        $request->validate(['masjid_id' => ['nullable', 'integer']]);

        $query = activity::query()
            ->with('masjid')
            ->orderByDesc('created_at')
            ->orderByDesc('id');

        if ($request->filled('masjid_id')) {
            $query->where('masjid_id', $request->integer('masjid_id'));
        }

        return response()->json($query->get()->map(fn (activity $item) => self::present($item)));
    }

    /**
     * Menambah kegiatan (admin). multipart/form-data dengan poster `pict`.
     */
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'masjid_id' => ['required', 'integer', 'exists:masjids,id'],
            'activity_name' => ['required', 'string', 'max:255'],
            'deskripsi' => ['nullable', 'string', 'max:5000'],
            'categories' => ['nullable', 'integer', 'between:0,2'],
            'pict' => ['required', 'image', 'max:4096'],
        ], self::messages());

        $item = activity::create([
            'masjid_id' => $data['masjid_id'],
            'activity_name' => trim($data['activity_name']),
            // "decription" adalah ejaan asli kolom di database.
            'decription' => trim($data['deskripsi'] ?? ''),
            'categories' => $data['categories'] ?? 0,
            'pict' => $request->file('pict')->store('gambar-kegiatan'),
        ]);

        return response()->json(self::present($item->load('masjid')), 201);
    }

    /**
     * Mengubah kegiatan (admin). Dikirim lewat POST (multipart) karena PHP tidak
     * membaca berkas pada PATCH. Semua field opsional; `pict` baru mengganti yang lama.
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $item = activity::findOrFail($id);

        $data = $request->validate([
            'masjid_id' => ['sometimes', 'integer', 'exists:masjids,id'],
            'activity_name' => ['sometimes', 'string', 'max:255'],
            'deskripsi' => ['sometimes', 'nullable', 'string', 'max:5000'],
            'categories' => ['sometimes', 'integer', 'between:0,2'],
            'pict' => ['sometimes', 'image', 'max:4096'],
        ], self::messages());

        $old = null;
        if ($request->hasFile('pict')) {
            $old = $item->pict;
            $item->pict = $request->file('pict')->store('gambar-kegiatan');
        }
        if (array_key_exists('masjid_id', $data)) {
            $item->masjid_id = $data['masjid_id'];
        }
        if (array_key_exists('activity_name', $data)) {
            $item->activity_name = trim($data['activity_name']);
        }
        if (array_key_exists('deskripsi', $data)) {
            $item->decription = trim($data['deskripsi'] ?? '');
        }
        if (array_key_exists('categories', $data)) {
            $item->categories = $data['categories'];
        }
        $item->save();

        if ($old) {
            Storage::disk(config('filesystems.default'))->delete($old);
        }

        return response()->json(self::present($item->load('masjid')));
    }

    public function destroy(int $id): JsonResponse
    {
        $item = activity::findOrFail($id);
        $pict = $item->pict;
        $item->delete();

        if ($pict) {
            Storage::disk(config('filesystems.default'))->delete($pict);
        }

        return response()->json(['message' => 'Kegiatan dihapus.']);
    }

    private static function present(activity $item): array
    {
        return [
            'id' => $item->id,
            'masjid_id' => $item->masjid_id,
            'masjid_name' => optional($item->masjid)->masjid_name,
            'activity_name' => $item->activity_name,
            'decription' => $item->decription,
            'deskripsi' => $item->decription,
            'categories' => (int) $item->categories,
            'pict' => $item->pict,
            'pict_url' => FileUrl::for($item->pict),
            'created_at' => $item->created_at,
            'updated_at' => $item->updated_at,
        ];
    }

    private static function messages(): array
    {
        return [
            'masjid_id.required' => 'Masjid wajib dipilih.',
            'masjid_id.exists' => 'Masjid tidak ditemukan.',
            'activity_name.required' => 'Judul kegiatan wajib diisi.',
            'pict.required' => 'Poster kegiatan wajib diunggah.',
            'pict.image' => 'Poster harus berupa gambar.',
            'pict.max' => 'Ukuran poster maksimal 4 MB.',
            'pict.uploaded' => 'Poster gagal diunggah. Ukuran maksimal 4 MB.',
        ];
    }
}
