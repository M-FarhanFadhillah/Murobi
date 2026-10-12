<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Report;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Laporan masalah dari jamaah. Jamaah mengirim dan melihat laporannya sendiri;
 * admin melihat semua laporan, menandai selesai, dan menghapus. Lihat docs/API.md.
 *
 * Status laporan: 0 = baru, 1 = sudah ditangani.
 */
class ReportController extends Controller
{
    private const MESSAGES = [
        'message.required' => 'Isi laporan wajib diisi.',
        'message.min' => 'Isi laporan minimal 5 karakter.',
        'message.max' => 'Isi laporan maksimal 1000 karakter.',
        'status.required' => 'Status wajib diisi.',
        'status.in' => 'Status tidak valid.',
    ];

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'message' => ['required', 'string', 'min:5', 'max:1000'],
        ], self::MESSAGES);

        $report = Report::create([
            'user_id' => $request->user()->id,
            'message' => trim($data['message']),
            'status' => 0,
        ]);

        return response()->json(self::present($report->load('user')), 201);
    }

    // Laporan milik akun yang sedang masuk, terbaru di atas.
    public function mine(Request $request): JsonResponse
    {
        $reports = Report::with('user')
            ->where('user_id', $request->user()->id)
            ->orderByDesc('id')
            ->limit(100)
            ->get();

        return response()->json($reports->map(fn (Report $r) => self::present($r))->values());
    }

    // Admin: semua laporan jamaah, terbaru di atas.
    public function index(): JsonResponse
    {
        $reports = Report::with('user')->orderByDesc('id')->limit(200)->get();

        return response()->json($reports->map(fn (Report $r) => self::present($r))->values());
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $data = $request->validate([
            'status' => ['required', 'integer', 'in:0,1'],
        ], self::MESSAGES);

        $report = Report::with('user')->find($id);
        if (!$report) {
            return response()->json(['message' => 'Laporan tidak ditemukan.'], 404);
        }
        $report->update(['status' => (int) $data['status']]);

        return response()->json(self::present($report->fresh('user')));
    }

    public function destroy(int $id): JsonResponse
    {
        $report = Report::find($id);
        if (!$report) {
            return response()->json(['message' => 'Laporan tidak ditemukan.'], 404);
        }
        $report->delete();

        return response()->json(['message' => 'Laporan dihapus.']);
    }

    private static function present(Report $report): array
    {
        return [
            'id' => $report->id,
            'user_id' => $report->user_id,
            'user_name' => $report->user?->name ?? 'Akun dihapus',
            'user_email' => $report->user?->email ?? '',
            'message' => $report->message,
            'status' => (int) $report->status,
            'created_at' => $report->created_at?->toIso8601String(),
        ];
    }
}
