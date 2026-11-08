<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;

class ProvisionSecureExchangeKey extends Command
{
    protected $signature = 'secure-exchange:key {--rotate : Add a new active key and retain only the previous key for in-flight envelopes}';

    protected $description = 'Provision or rotate the ignored local secure-exchange keyring';

    public function handle(): int
    {
        $path = (string) config('secure_exchange.keyring_file');
        if ($path === '') {
            $this->error('Configure SECURE_EXCHANGE_KEYRING_FILE or use the protected storage default.');

            return self::FAILURE;
        }
        $existing = $this->read($path);
        if ($existing === null) {
            return self::FAILURE;
        }
        if ($existing && ! $this->option('rotate')) {
            $this->info('Keyring already exists; no key material was changed.');

            return self::SUCCESS;
        }
        $previousId = $existing['active_key_id'] ?? null;
        $previousKey = $previousId ? ($existing['keys'][$previousId] ?? null) : null;
        $keyId = 'local-'.now('UTC')->format('YmdHis');
        $ring = [
            'active_key_id' => $keyId,
            'keys' => [$keyId => base64_encode(random_bytes(32))],
            'created_at' => now('UTC')->format('Y-m-d\TH:i:s\Z'),
        ];
        if ($previousId && is_string($previousKey)) {
            $ring['keys'][$previousId] = $previousKey;
        }
        $directory = dirname($path);
        if (! is_dir($directory) && ! mkdir($directory, 0700, true) && ! is_dir($directory)) {
            $this->error('Unable to create the protected keyring directory.');

            return self::FAILURE;
        }
        $temporary = $path.'.tmp';
        $json = json_encode($ring, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR).PHP_EOL;
        if (file_put_contents($temporary, $json, LOCK_EX) === false || ! rename($temporary, $path)) {
            @unlink($temporary);
            $this->error('Unable to write the protected keyring.');

            return self::FAILURE;
        }
        @chmod($path, 0600);
        $this->info($previousId ? 'Secure-exchange key rotated; previous key retained temporarily.' : 'Secure-exchange key provisioned.');
        $this->warn('Back up the protected keyring separately. Never stage, print, or screenshot its contents.');

        return self::SUCCESS;
    }

    private function read(string $path): ?array
    {
        if (! is_file($path)) {
            return [];
        }
        try {
            $value = json_decode((string) file_get_contents($path), true, 4, JSON_THROW_ON_ERROR);
        } catch (\Throwable) {
            $this->error('Existing keyring is unreadable. Repair it before rotation.');

            return null;
        }

        return is_array($value) ? $value : [];
    }
}
