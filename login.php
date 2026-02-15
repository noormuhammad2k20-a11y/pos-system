<?php
session_start();

// If already logged in, redirect to index
if (isset($_SESSION['user_id'])) {
    header('Location: index.php');
    exit;
}

// Handle login form submission via AJAX
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    require_once 'db.php';
    require_once 'classes.php';
    require_once 'csrf_helper.php';

    if (!Csrf::verify($_POST['csrf_token'] ?? '')) {
        echo json_encode(['success' => false, 'message' => 'Security Token Expired. Please refresh.']);
        exit;
    }

    $username = $_POST['username'] ?? '';
    $password = $_POST['password'] ?? '';

    try {
        // Fetch User
        $stmt = $pdo->prepare("SELECT * FROM users WHERE username = ? AND is_active = 1");
        $stmt->execute([$username]);
        $user = $stmt->fetch();

        // Verify Password
        if ($user) {
            // Check Bcrypt
            if (password_verify($password, $user['password_hash'])) {
                // Success - proceed below
            }
            // Fallback: Check MD5 & Upgrade
            elseif ($user['password_hash'] === md5($password)) {
                $newHash = password_hash($password, PASSWORD_BCRYPT);
                $pdo->prepare("UPDATE users SET password_hash = ? WHERE id = ?")->execute([$newHash, $user['id']]);
                $user['password_hash'] = $newHash;
            } else {
                echo json_encode(['success' => false, 'message' => 'Invalid credentials.']);
                exit;
            }

            // Generate Token
            $token = JWTAuth::createToken([
                'user_id' => $user['id'],
                'username' => $user['username'],
                'display_name' => $user['display_name'],
                'role' => $user['role']
            ]);

            // Set Session
            $_SESSION['user_id'] = $user['id'];
            $_SESSION['role'] = $user['role'];

            echo json_encode(['success' => true, 'token' => $token, 'redirect' => 'index.php']);
            exit;
        } else {
            echo json_encode(['success' => false, 'message' => 'Invalid credentials.']);
            exit;
        }
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => 'System error. Please try again.']);
        exit;
    }
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DineFlow | Premium Login</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

    <style>
        :root {
            --primary: #FF6B00;
            --primary-glow: rgba(255, 107, 0, 0.4);
            --bg: #050505;
            --card-glass: rgba(15, 15, 15, 0.75);
            --input-bg: rgba(255, 255, 255, 0.03);
            --border: rgba(255, 255, 255, 0.1);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        /* Smooth Entrance Animations */
        @keyframes cardSlideUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @keyframes contentFadeIn {
            from {
                opacity: 0;
                transform: translateX(-20px);
            }

            to {
                opacity: 1;
                transform: translateX(0);
            }
        }

        @keyframes glowPulse {
            0% {
                transform: scale(1);
                opacity: 0.12;
            }

            50% {
                transform: scale(1.1);
                opacity: 0.18;
            }

            100% {
                transform: scale(1);
                opacity: 0.12;
            }
        }

        body {
            background-color: var(--bg);
            font-family: 'Outfit', sans-serif;
            color: white;
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 15px;
            overflow: hidden;
            background: radial-gradient(circle at 0% 0%, #1a0a00 0%, #050505 50%),
                radial-gradient(circle at 100% 100%, #0a0a0a 0%, #050505 100%);
        }

        /* Pulsing Background Glow */
        body::before {
            content: "";
            position: absolute;
            width: 450px;
            height: 450px;
            background: var(--primary);
            filter: blur(180px);
            top: 5%;
            left: 5%;
            z-index: -1;
            animation: glowPulse 6s infinite ease-in-out;
        }

        .login-card {
            width: 100%;
            max-width: 1000px;
            height: 580px;
            display: flex;
            background: var(--card-glass);
            backdrop-filter: blur(30px);
            border: 1px solid var(--border);
            border-radius: 40px;
            overflow: hidden;
            box-shadow: 0 40px 100px rgba(0, 0, 0, 0.8);
            animation: cardSlideUp 1s cubic-bezier(0.2, 0.8, 0.2, 1);
        }

        .visual-side {
            flex: 1.1;
            position: relative;
            background: url('https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=1500&auto=format&fit=crop') center;
            background-size: cover;
            padding: 50px;
            display: flex;
            flex-direction: column;
            justify-content: flex-end;
        }

        .visual-side::after {
            content: "";
            position: absolute;
            inset: 0;
            background: linear-gradient(to top, #050505 15%, transparent 85%);
        }

        .visual-content {
            position: relative;
            z-index: 2;
            animation: contentFadeIn 0.8s ease-out 0.3s both;
        }

        .visual-content h1 {
            font-size: clamp(2.5rem, 4vw, 3.8rem);
            font-weight: 700;
            line-height: 1;
            margin-bottom: 18px;
            letter-spacing: -1.5px;
            background: linear-gradient(to bottom, #fff, #999);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .tagline {
            display: inline-block;
            background: rgba(255, 107, 0, 0.15);
            color: var(--primary);
            padding: 6px 16px;
            border-radius: 100px;
            font-size: 0.7rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 2px;
            margin-bottom: 20px;
            border: 1px solid rgba(255, 107, 0, 0.2);
        }

        .form-side {
            flex: 0.9;
            padding: 50px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            background: rgba(8, 8, 8, 0.5);
            border-left: 1px solid var(--border);
            animation: contentFadeIn 0.8s ease-out 0.5s both;
        }

        .form-header {
            margin-bottom: 35px;
        }

        .form-header h2 {
            font-size: 1.8rem;
            margin-bottom: 8px;
            font-weight: 600;
            letter-spacing: -0.5px;
        }

        .form-header p {
            color: #777;
            font-size: 0.95rem;
            font-weight: 300;
        }

        .input-wrapper {
            position: relative;
            margin-bottom: 18px;
        }

        .input-wrapper input {
            width: 100%;
            padding: 18px 20px 18px 55px;
            background: var(--input-bg);
            border: 1px solid var(--border);
            border-radius: 20px;
            color: white;
            font-size: 1rem;
            transition: all 0.4s cubic-bezier(0.165, 0.84, 0.44, 1);
            font-family: inherit;
        }

        .input-wrapper i {
            position: absolute;
            left: 22px;
            top: 50%;
            transform: translateY(-50%);
            color: #444;
            transition: 0.3s;
            font-size: 1.1rem;
        }

        .input-wrapper input:focus {
            border-color: var(--primary);
            background: rgba(255, 107, 0, 0.04);
            outline: none;
            box-shadow: 0 0 25px rgba(255, 107, 0, 0.12);
            padding-left: 60px;
        }

        .input-wrapper input:focus+i {
            color: var(--primary);
        }

        .form-actions {
            display: flex;
            align-items: center;
            margin: 10px 0 30px 5px;
            font-size: 0.85rem;
            color: #777;
        }

        .remember-me {
            display: flex;
            align-items: center;
            gap: 10px;
            cursor: pointer;
            transition: 0.2s;
        }

        .remember-me:hover {
            color: #aaa;
        }

        .remember-me input {
            width: 17px;
            height: 17px;
            accent-color: var(--primary);
            cursor: pointer;
        }

        .submit-btn {
            width: 100%;
            padding: 20px;
            background: linear-gradient(135deg, #FF6B00, #E65C00);
            border: none;
            border-radius: 20px;
            color: white;
            font-weight: 700;
            font-size: 1rem;
            cursor: pointer;
            transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            box-shadow: 0 10px 30px var(--primary-glow);
            text-transform: uppercase;
            letter-spacing: 2px;
        }

        .submit-btn:hover {
            transform: translateY(-4px);
            box-shadow: 0 20px 40px var(--primary-glow);
            filter: brightness(1.1);
        }

        .submit-btn:active {
            transform: translateY(-1px);
        }

        #login-error {
            color: #ef4444;
            font-size: 0.9rem;
            text-align: center;
            margin-top: 15px;
            display: none;
            background: rgba(239, 68, 68, 0.1);
            padding: 10px;
            border-radius: 12px;
            border: 1px solid rgba(239, 68, 68, 0.2);
        }

        /* Responsive Fixes */
        @media (max-width: 900px) {
            .visual-side {
                display: none;
            }

            .login-card {
                max-width: 440px;
                height: auto;
                border-radius: 35px;
            }

            .form-side {
                padding: 50px 35px;
                border-left: none;
            }

            body {
                overflow: auto;
                height: auto;
                min-height: 100vh;
            }
        }
    </style>
</head>

<body>

    <div class="login-card">
        <div class="visual-side">
            <div class="visual-content">
                <span class="tagline">The Culinary Standard</span>
                <h1>DineFlow<br>System.</h1>
                <p style="color: #999; max-width: 280px; line-height: 1.6; font-size: 0.95rem; font-weight: 300;">
                    Elevating restaurant management with a touch of modern precision.</p>
            </div>
        </div>

        <div class="form-side">
            <div class="form-header">
                <h2>Welcome Back</h2>
                <p>Please enter your access details.</p>
            </div>

            <form id="loginForm">
                <div class="input-wrapper">
                    <i class="bi bi-envelope-at"></i>
                    <!-- Use text + name="username" as requested -->
                    <input type="text" name="username" placeholder="Username" required>
                    <?php require_once 'csrf_helper.php'; ?>
                    <input type="hidden" name="csrf_token" value="<?= Csrf::generate() ?>">
                </div>

                <div class="input-wrapper">
                    <i class="bi bi-shield-lock"></i>
                    <!-- name="password" -->
                    <input type="password" name="password" placeholder="Password" required>
                </div>

                <div class="form-actions">
                    <label class="remember-me">
                        <input type="checkbox"> Keep me signed in
                    </label>
                </div>

                <button type="submit" class="submit-btn" id="loginBtn">Continue to Dashboard</button>

                <div id="login-error"></div>
            </form>
        </div>
    </div>

    <script>
        document.getElementById('loginForm').addEventListener('submit', async (e) => {
            e.preventDefault();
            const btn = document.getElementById('loginBtn');
            const err = document.getElementById('login-error');
            const originalText = btn.innerText;

            // Reset UI
            err.style.display = 'none';
            btn.innerText = 'Verifying...';
            btn.style.opacity = '0.7';
            btn.disabled = true;

            const formData = new FormData(e.target);

            try {
                const response = await fetch('login.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error('Server Error');

                const data = await response.json();

                if (data.success) {
                    // Success Logic
                    localStorage.setItem('gusto_token', data.token);

                    btn.innerText = 'Redirecting...';
                    err.style.display = 'block';
                    err.style.color = '#10b981'; // Success Green
                    err.style.background = 'rgba(16, 185, 129, 0.1)';
                    err.style.borderColor = 'rgba(16, 185, 129, 0.2)';
                    err.innerText = 'Login Successful!';

                    setTimeout(() => {
                        window.location.href = data.redirect || 'index.php';
                    }, 800);

                } else {
                    // Fail Logic
                    throw new Error(data.message || 'Login failed');
                }

            } catch (error) {
                // Error Logic
                err.innerText = error.message;
                err.style.display = 'block';
                err.style.color = '#ef4444'; // Error Red
                err.style.background = 'rgba(239, 68, 68, 0.1)';
                err.style.borderColor = 'rgba(239, 68, 68, 0.2)';

                btn.innerText = originalText;
                btn.style.opacity = '1';
                btn.disabled = false;
            }
        });
    </script>

</body>

</html>