<?php

return ['paths' => ['api/*'], 'allowed_methods' => ['GET', 'POST', 'PATCH', 'OPTIONS'],
    'allowed_origins' => ['http://127.0.0.1:8080', 'http://localhost:8080'],
    'allowed_origins_patterns' => [], 'allowed_headers' => ['Content-Type', 'Authorization', 'Idempotency-Key', 'Accept'],
    'exposed_headers' => ['X-Correlation-ID'], 'max_age' => 600, 'supports_credentials' => false];
