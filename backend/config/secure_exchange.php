<?php

return [
    'algorithm' => 'aes-256-gcm',
    'active_key_id' => env('SECURE_EXCHANGE_KEY_ID', 'local-v1'),
    'keys' => [
        env('SECURE_EXCHANGE_KEY_ID', 'local-v1') => env('SECURE_EXCHANGE_KEY'),
    ],
    'keyring_file' => env('SECURE_EXCHANGE_KEYRING_FILE', storage_path('app/private/secure-exchange-keyring.json')),
    'sender' => 'thesis-consultation-api',
    'ttl_seconds' => (int) env('SECURE_EXCHANGE_TTL_SECONDS', 300),
    'clock_skew_seconds' => 30,
];
