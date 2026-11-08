<?php

namespace App\Services;

use Carbon\CarbonImmutable;
use Illuminate\Support\Str;
use Symfony\Component\HttpKernel\Exception\HttpException;

class SecureExchange
{
    private const NONCE_BYTES = 12;

    private const TAG_BYTES = 16;

    public function create(array $payload, int $recipientUserId): array
    {
        $keyId = $this->activeKeyId();
        $key = $this->key($keyId);
        $issued = CarbonImmutable::now('UTC');
        $expires = $issued->addSeconds((int) config('secure_exchange.ttl_seconds', 300));
        $aad = [
            'version' => 1,
            'key_id' => $keyId,
            'message_id' => (string) Str::uuid(),
            'issued_at' => $issued->format('Y-m-d\TH:i:s\Z'),
            'expires_at' => $expires->format('Y-m-d\TH:i:s\Z'),
            'sender' => (string) config('secure_exchange.sender'),
            'recipient_user_id' => $recipientUserId,
        ];
        $nonce = random_bytes(self::NONCE_BYTES);
        $tag = '';
        $ciphertext = openssl_encrypt(
            json_encode($payload, JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR),
            (string) config('secure_exchange.algorithm'),
            $key,
            OPENSSL_RAW_DATA,
            $nonce,
            $tag,
            $this->aad($aad),
            self::TAG_BYTES,
        );
        if ($ciphertext === false || strlen($tag) !== self::TAG_BYTES) {
            throw new HttpException(503, 'Secure exchange temporarily unavailable.');
        }

        return $aad + [
            'nonce' => base64_encode($nonce),
            'ciphertext' => base64_encode($ciphertext),
            'tag' => base64_encode($tag),
        ];
    }

    public function open(array $envelope): array
    {
        $issued = $this->time($envelope['issued_at']);
        $expires = $this->time($envelope['expires_at']);
        $now = CarbonImmutable::now('UTC');
        $ttl = (int) config('secure_exchange.ttl_seconds', 300);
        $skew = (int) config('secure_exchange.clock_skew_seconds', 30);
        if ($issued->greaterThan($now->addSeconds($skew)) || $expires->lessThanOrEqualTo($now) || $expires->greaterThan($issued->addSeconds($ttl))) {
            throw new HttpException(422, 'Envelope is expired or has an invalid validity window.');
        }
        if ((int) $envelope['version'] !== 1 || ! hash_equals((string) config('secure_exchange.sender'), (string) $envelope['sender'])) {
            throw new HttpException(422, 'Envelope metadata is invalid.');
        }
        $nonce = base64_decode((string) $envelope['nonce'], true);
        $ciphertext = base64_decode((string) $envelope['ciphertext'], true);
        $tag = base64_decode((string) $envelope['tag'], true);
        if ($nonce === false || strlen($nonce) !== self::NONCE_BYTES || $ciphertext === false || $tag === false || strlen($tag) !== self::TAG_BYTES) {
            throw new HttpException(422, 'Envelope encoding is invalid.');
        }
        $aad = array_intersect_key($envelope, array_flip(['version', 'key_id', 'message_id', 'issued_at', 'expires_at', 'sender', 'recipient_user_id']));
        $plaintext = openssl_decrypt(
            $ciphertext,
            (string) config('secure_exchange.algorithm'),
            $this->key((string) $envelope['key_id']),
            OPENSSL_RAW_DATA,
            $nonce,
            $tag,
            $this->aad($aad),
        );
        if ($plaintext === false) {
            throw new HttpException(422, 'Envelope authentication failed.');
        }
        try {
            $payload = json_decode($plaintext, true, 8, JSON_THROW_ON_ERROR);
        } catch (\JsonException) {
            throw new HttpException(422, 'Envelope payload is invalid.');
        }
        if (! is_array($payload)) {
            throw new HttpException(422, 'Envelope payload is invalid.');
        }

        return $payload;
    }

    private function aad(array $values): string
    {
        return json_encode($values, JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR);
    }

    private function key(string $keyId): string
    {
        $encoded = $this->keyring()['keys'][$keyId] ?? config('secure_exchange.keys.'.$keyId);
        if (! is_string($encoded) || $encoded === '') {
            throw new HttpException(503, 'Secure exchange temporarily unavailable.');
        }
        $key = base64_decode($encoded, true);
        if ($key === false || strlen($key) !== 32) {
            throw new HttpException(503, 'Secure exchange temporarily unavailable.');
        }

        return $key;
    }

    private function activeKeyId(): string
    {
        return (string) ($this->keyring()['active_key_id'] ?? config('secure_exchange.active_key_id'));
    }

    private function keyring(): array
    {
        $path = (string) config('secure_exchange.keyring_file');
        if ($path === '' || ! is_file($path)) {
            return [];
        }
        $raw = @file_get_contents($path);
        if ($raw === false) {
            throw new HttpException(503, 'Secure exchange temporarily unavailable.');
        }
        try {
            $ring = json_decode($raw, true, 4, JSON_THROW_ON_ERROR);
        } catch (\JsonException) {
            throw new HttpException(503, 'Secure exchange temporarily unavailable.');
        }

        return is_array($ring) ? $ring : [];
    }

    private function time(string $value): CarbonImmutable
    {
        try {
            return CarbonImmutable::createFromFormat('Y-m-d\TH:i:s\Z', $value, 'UTC');
        } catch (\Throwable) {
            throw new HttpException(422, 'Envelope timestamp is invalid.');
        }
    }
}
