<?php

return ['paths' => ['api/*'], 'allowed_methods' => ['GET', 'POST', 'PATCH', 'OPTIONS'],
    'allowed_origins' => ['https://localhost:8444'],
    'allowed_origins_patterns' => [], 'allowed_headers' => ['Content-Type', 'Authorization', 'Idempotency-Key', 'Accept'],
    'exposed_headers' => ['X-Correlation-ID'], 'max_age' => 600, 'supports_credentials' => false];
