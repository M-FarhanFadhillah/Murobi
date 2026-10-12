<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Support\FileUrl;
use App\Support\GoogleIdentity;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;
use Laravel\Sanctum\PersonalAccessToken;

/**
 * Akun jamaah untuk aplikasi mobile. Lihat docs/API.md.
 *
 * Status akun (kolom users.status): 0 = menunggu persetujuan admin,
 * 1 = disetujui, 2 = ditolak.
 */
class AuthController extends Controller
{
    private const PHONE_REGEX = '/^(\+62|0)[0-9]{8,13}$/';
    private const GOOGLE_PHONE_PREFIX = 'google:';

    public function register(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'min:3', 'max:255'],
            'email' => ['required', 'email', 'max:255', self::uniqueEmail()],
            'no_hp' => ['required', 'regex:' . self::PHONE_REGEX, 'unique:users,no_hp'],
            'password' => ['required', 'string', 'min:8', 'max:255'],
        ], self::messages());

        $user = User::create([
            'name' => trim($data['name']),
            'email' => strtolower(trim($data['email'])),
            'no_hp' => trim($data['no_hp']),
            'password' => Hash::make($data['password']),
            // Kolom profil_pict tidak boleh null; foto diunggah lewat POST /api/me/photo.
            'profil_pict' => '',
            'is_admin' => false,
            'status' => 0,
        ]);

        return response()->json([
            'message' => 'Pendaftaran berhasil. Akun Anda menunggu persetujuan admin.',
            'user' => self::userPayload($user),
        ], 201);
    }

    public function login(Request $request): JsonResponse
    {
        $data = $request->validate([
            'login' => ['required', 'string', 'max:255'],
            'password' => ['required', 'string', 'max:255'],
            'device_name' => ['nullable', 'string', 'max:100'],
        ], self::messages());

        $login = trim($data['login']);
        $user = User::whereRaw('lower(email) = ?', [strtolower($login)])
            ->orWhere('no_hp', $login)
            ->first();

        if (!$user || !self::passwordMatches($user, $data['password'])) {
            return response()->json(['message' => 'ID atau kata sandi salah.'], 401);
        }
        if ((int) $user->status === 0) {
            return response()->json(['message' => 'Akun Anda menunggu persetujuan admin.'], 403);
        }
        if ((int) $user->status === 2) {
            return response()->json(['message' => 'Pendaftaran Anda ditolak oleh admin.'], 403);
        }

        $token = $user->createToken($data['device_name'] ?? 'mobile')->plainTextToken;

        return response()->json([
            'token' => $token,
            'token_type' => 'Bearer',
            'user' => self::userPayload($user),
        ]);
    }

    /**
     * Masuk dengan akun Google. Aplikasi mengirim id_token (Android) atau
     * access_token (web); keduanya diperiksa langsung ke Google. Akun dicocokkan
     * lewat email, dan dibuat bila belum ada.
     */
    public function google(Request $request): JsonResponse
    {
        $data = $request->validate([
            'id_token' => ['nullable', 'string', 'max:4096'],
            'access_token' => ['nullable', 'string', 'max:4096'],
            'device_name' => ['nullable', 'string', 'max:100'],
        ]);

        if (!GoogleIdentity::configured()) {
            return response()->json(['message' => 'Login Google belum dikonfigurasi di server.'], 503);
        }

        $identity = GoogleIdentity::verify($data['id_token'] ?? null, $data['access_token'] ?? null);
        if (!$identity) {
            return response()->json(['message' => 'Akun Google tidak dapat diverifikasi.'], 401);
        }

        $user = User::whereRaw('lower(email) = ?', [$identity['email']])->first();
        if (!$user) {
            $user = User::create([
                'name' => $identity['name'],
                'email' => $identity['email'],
                // Kolom no_hp wajib dan unik, sedangkan akun Google belum punya nomor.
                // Nilai pengganti ini tidak ditampilkan; jamaah mengisinya di Profil.
                'no_hp' => self::GOOGLE_PHONE_PREFIX . $identity['sub'],
                'profil_pict' => '',
                // Kata sandi acak yang tidak diketahui siapa pun: akun ini hanya
                // bisa dimasuki lewat Google (atau setelah "lupa kata sandi").
                'password' => Hash::make(Str::random(40)),
                'is_admin' => false,
                'status' => config('services.google.auto_approve') ? 1 : 0,
            ]);
        }

        if ((int) $user->status === 0) {
            return response()->json(['message' => 'Akun Anda menunggu persetujuan admin.'], 403);
        }
        if ((int) $user->status === 2) {
            return response()->json(['message' => 'Pendaftaran Anda ditolak oleh admin.'], 403);
        }

        $token = $user->createToken($data['device_name'] ?? 'mobile')->plainTextToken;

        return response()->json([
            'token' => $token,
            'token_type' => 'Bearer',
            'user' => self::userPayload($user),
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $token = $request->user()->currentAccessToken();
        if ($token instanceof PersonalAccessToken) {
            $token->delete();
        }

        return response()->json(['message' => 'Berhasil keluar.']);
    }

    public function me(Request $request): JsonResponse
    {
        return response()->json(['user' => self::userPayload($request->user())]);
    }

    public function updateMe(Request $request): JsonResponse
    {
        $user = $request->user();
        $data = $request->validate([
            'name' => ['sometimes', 'required', 'string', 'min:3', 'max:255'],
            'email' => [
                'sometimes', 'required', 'email', 'max:255',
                self::uniqueEmail($user->id),
            ],
            'no_hp' => [
                'sometimes', 'required', 'regex:' . self::PHONE_REGEX,
                Rule::unique('users', 'no_hp')->ignore($user->id),
            ],
        ], self::messages());

        if (isset($data['name'])) {
            $data['name'] = trim($data['name']);
        }
        if (isset($data['email'])) {
            $data['email'] = strtolower(trim($data['email']));
        }
        if (isset($data['no_hp'])) {
            $data['no_hp'] = trim($data['no_hp']);
        }

        $user->update($data);

        return response()->json(['user' => self::userPayload($user->fresh())]);
    }

    public function updatePhoto(Request $request): JsonResponse
    {
        $request->validate([
            'profil_pict' => ['required', 'image', 'max:2048'],
        ], [
            'profil_pict.required' => 'Foto wajib dipilih.',
            'profil_pict.image' => 'Berkas harus berupa gambar.',
            'profil_pict.max' => 'Ukuran foto maksimal 2 MB.',
        ]);

        $user = $request->user();
        $disk = Storage::disk(config('filesystems.default'));
        $old = $user->profil_pict;

        $user->update([
            'profil_pict' => $request->file('profil_pict')->store('profil-pict'),
        ]);

        // Hapus foto lama hanya jika memang berada di folder foto profil.
        if ($old && str_starts_with($old, 'profil-pict/') && !str_contains($old, '..')) {
            $disk->delete($old);
        }

        return response()->json(['user' => self::userPayload($user->fresh())]);
    }

    public function changePassword(Request $request): JsonResponse
    {
        $user = $request->user();

        // Kata sandi admin disimpan polos dan dibaca langsung oleh login panel web,
        // jadi mengubahnya di sini akan memutus login web. Lihat docs/API.md.
        if ($user->is_admin) {
            return response()->json([
                'message' => 'Kata sandi admin diubah melalui panel admin web.',
            ], 403);
        }

        $data = $request->validate([
            'old_password' => ['required', 'string'],
            'new_password' => ['required', 'string', 'min:8', 'max:255', 'different:old_password'],
        ], self::messages());

        if (!self::passwordMatches($user, $data['old_password'])) {
            return response()->json([
                'message' => 'Kata sandi lama salah.',
                'errors' => ['old_password' => ['Kata sandi lama salah.']],
            ], 422);
        }

        $user->update(['password' => Hash::make($data['new_password'])]);

        return response()->json(['message' => 'Kata sandi berhasil diubah.']);
    }

    /**
     * Data bawaan panel admin menyimpan kata sandi polos; akun baru dari API
     * memakai hash bcrypt. Keduanya diterima, dan data yang tersimpan tidak diubah.
     */
    private static function passwordMatches(User $user, string $plain): bool
    {
        $stored = (string) $user->password;

        if (preg_match('/^\$2[aby]\$/', $stored)) {
            return Hash::check($plain, $stored);
        }

        return $stored !== '' && hash_equals($stored, $plain);
    }

    public static function userPayload(User $user): array
    {
        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'no_hp' => str_starts_with((string) $user->no_hp, self::GOOGLE_PHONE_PREFIX) ? '' : $user->no_hp,
            'profil_pict' => $user->profil_pict,
            'profil_pict_url' => FileUrl::for($user->profil_pict),
            'is_admin' => (bool) $user->is_admin,
            'status' => (int) $user->status,
        ];
    }

    /**
     * Email unik tanpa membedakan huruf besar-kecil. Data lama dari panel admin
     * bisa tersimpan dengan huruf campuran, dan aturan "unique" bawaan Laravel
     * membandingkan persis sehingga lolos lalu gagal di constraint database.
     */
    private static function uniqueEmail(?int $ignoreId = null): \Closure
    {
        return function (string $attribute, $value, \Closure $fail) use ($ignoreId) {
            $query = User::whereRaw('lower(email) = ?', [strtolower(trim((string) $value))]);
            if ($ignoreId !== null) {
                $query->where('id', '!=', $ignoreId);
            }
            if ($query->exists()) {
                $fail('Email sudah terdaftar.');
            }
        };
    }

    private static function messages(): array
    {
        return [
            'required' => ':attribute wajib diisi.',
            'name.min' => 'Nama minimal 3 karakter.',
            'email.email' => 'Format email tidak valid.',
            'email.unique' => 'Email sudah terdaftar.',
            'no_hp.regex' => 'Gunakan format 08xxxxxxxxxx atau +62xxxxxxxxxx.',
            'no_hp.unique' => 'Nomor telepon sudah terdaftar.',
            'password.min' => 'Kata sandi minimal 8 karakter.',
            'new_password.min' => 'Kata sandi baru minimal 8 karakter.',
            'new_password.different' => 'Kata sandi baru harus berbeda dari yang lama.',
        ];
    }
}
