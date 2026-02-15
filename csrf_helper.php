<?php

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

class Csrf
{
    /**
     * Generate a CSRF token and store it in the session.
     *
     * @return string
     */
    public static function generate()
    {
        if (empty($_SESSION['csrf_token'])) {
            $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
        }
        return $_SESSION['csrf_token'];
    }

    /**
     * Verify the CSRF token.
     *
     * @param string|null $token
     * @return bool
     */
    public static function verify($token)
    {
        if (isset($_SESSION['csrf_token']) && hash_equals($_SESSION['csrf_token'], $token)) {
            return true;
        }
        return false;
    }
}
