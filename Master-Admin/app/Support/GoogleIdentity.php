<?php

namespace App\Support;

use Illuminate\Support\Facades\Http;

/**
 * Memeriksa token Google yang dikirim aplikasi mobile langsung ke Google,
 * sehingga email yang dipakai untuk masuk benar-benar milik pemegang akun Google
 * itu (aplikasi tidak dipercaya mengirim email begitu saja).
 *
 * Client ID yang diterima diatur lewat GOOGLE_CLIENT_ID (boleh beberapa, dipisah
 * koma: ID klien web dan Android). Token dari klien lain ditolak.
 */
class GoogleIdentity
{
    private const TOKENINFO = 'https://oauth2.googleapis.com/tokeninfo';
    private const USERINFO = 'https://www.googleapis.com/oauth2/v3/userinfo';
    private const ISSUERS = ['accounts.google.com', 'https://accounts.google.com'];

    /** @return string[] */
    public static function clientIds(): array
    {
        $raw = (string) config('services.google.client_id');

        return array_values(array_filter(array_map('trim', explode(',', $raw))));
    }

    public static function configured(): bool
    {
        return self::clientIds() !== [];
    }

    /**
     * @return array{sub:string,email:string,name:string}|null null jika token tidak sah
     */
    public static function verify(?string $idToken, ?string $accessToken): ?array
    {
        if ($idToken) {
            return self::fromIdToken($idToken);
        }
        if ($accessToken) {
            return self::fromAccessToken($accessToken);
        }

        return null;
    }

    private static function fromIdToken(string $idToken): ?array
    {
        $response = Http::timeout(10)->get(self::TOKENINFO, ['id_token' => $idToken]);
        if (!$response->successful()) {
            return null;
        }
        $info = $response->json();
        if (!is_array($info)) {
            return null;
        }

        if (!in_array($info['aud'] ?? null, self::clientIds(), true)) {
            return null;
        }
        if (!in_array($info['iss'] ?? null, self::ISSUERS, true)) {
            return null;
        }

        return self::identity($info, $info['name'] ?? null);
    }

    // Peramban (web) hanya memberi access token, bukan id token.
    private static function fromAccessToken(string $accessToken): ?array
    {
        $response = Http::timeout(10)->get(self::TOKENINFO, ['access_token' => $accessToken]);
        if (!$response->successful()) {
            return null;
        }
        $info = $response->json();
        if (!is_array($info)) {
            return null;
        }

        if (!in_array($info['aud'] ?? ($info['azp'] ?? null), self::clientIds(), true)) {
            return null;
        }

        $profile = Http::timeout(10)->withToken($accessToken)->get(self::USERINFO);
        $data = $profile->successful() && is_array($profile->json()) ? $profile->json() : [];

        return self::identity(
            ['sub' => $data['sub'] ?? ($info['sub'] ?? null)] + $data + $info,
            $data['name'] ?? null,
        );
    }

    private static function identity(array $info, ?string $name): ?array
    {
        $email = strtolower(trim((string) ($info['email'] ?? '')));
        $verified = ($info['email_verified'] ?? false);
        $sub = (string) ($info['sub'] ?? '');

        if ($email === '' || $sub === '' || !($verified === true || $verified === 'true')) {
            return null;
        }

        $name = trim((string) $name);
        if ($name === '') {
            $name = explode('@', $email)[0];
        }

        return ['sub' => $sub, 'email' => $email, 'name' => $name];
    }
}
