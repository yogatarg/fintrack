<?php
// config/cors.php

return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    'allowed_methods' => ['*'],
    'allowed_origins' => ['*'], // untuk development saja
    'allowed_headers' => ['*'],
    'supports_credentials' => false,
];