<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lovi Admin — Sign In</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,700;1,400&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <style>
        :root {
            --crimson: #9B1B30;
            --crimson-light: #C0392B;
            --crimson-glow: rgba(155, 27, 48, 0.4);
            --surface: #0F0608;
            --surface-2: #1A0A0D;
            --surface-3: rgba(255,255,255,0.04);
            --border: rgba(155, 27, 48, 0.25);
            --text: #F5EAE8;
            --text-muted: rgba(245,234,232,0.45);
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: 'DM Sans', sans-serif;
            background: var(--surface);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            position: relative;
        }

        /* Ambient background blobs */
        .bg-blob {
            position: fixed;
            border-radius: 50%;
            filter: blur(100px);
            pointer-events: none;
            animation: drift 12s ease-in-out infinite alternate;
        }
        .blob-1 { width: 500px; height: 500px; background: rgba(155,27,48,0.18); top: -120px; left: -150px; animation-delay: 0s; }
        .blob-2 { width: 350px; height: 350px; background: rgba(155,27,48,0.10); bottom: -80px; right: -80px; animation-delay: -6s; }
        .blob-3 { width: 200px; height: 200px; background: rgba(192,57,43,0.08); top: 50%; left: 55%; animation-delay: -3s; }

        @keyframes drift {
            0% { transform: translate(0,0) scale(1); }
            100% { transform: translate(30px, 20px) scale(1.08); }
        }

        /* Noise overlay */
        body::after {
            content: '';
            position: fixed;
            inset: 0;
            background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)' opacity='1'/%3E%3C/svg%3E");
            opacity: 0.03;
            pointer-events: none;
            z-index: 0;
        }

        .login-card {
            position: relative;
            z-index: 10;
            width: 100%;
            max-width: 420px;
            margin: 1rem;
            background: var(--surface-2);
            border: 1px solid var(--border);
            border-radius: 24px;
            padding: 48px 40px;
            box-shadow: 0 0 0 1px rgba(255,255,255,0.03), 0 40px 80px rgba(0,0,0,0.7), 0 0 60px var(--crimson-glow);
            animation: cardIn 0.7s cubic-bezier(0.16,1,0.3,1) both;
        }

        @keyframes cardIn {
            from { opacity: 0; transform: translateY(24px) scale(0.97); }
            to   { opacity: 1; transform: translateY(0) scale(1); }
        }

        /* Logo */
        .logo-wrap {
            display: flex;
            align-items: center;
            gap: 14px;
            margin-bottom: 36px;
            animation: fadeUp 0.6s 0.1s both;
        }

        .lovi-svg { width: 52px; height: 52px; flex-shrink: 0; }

        .logo-text {
            font-family: 'Playfair Display', serif;
            font-size: 28px;
            color: var(--text);
            letter-spacing: -0.5px;
            line-height: 1;
        }
        .logo-text span { color: var(--crimson-light); }
        .logo-sub {
            font-size: 11px;
            color: var(--text-muted);
            letter-spacing: 2.5px;
            text-transform: uppercase;
            margin-top: 3px;
        }

        /* Divider */
        .divider {
            height: 1px;
            background: var(--border);
            margin-bottom: 32px;
            animation: fadeUp 0.6s 0.2s both;
        }

        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(12px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .field-group { animation: fadeUp 0.6s 0.3s both; }
        .field-group + .field-group { margin-top: 20px; animation-delay: 0.38s; }

        label {
            display: block;
            font-size: 11px;
            font-weight: 500;
            letter-spacing: 1.8px;
            text-transform: uppercase;
            color: var(--text-muted);
            margin-bottom: 8px;
        }

        input[type="email"],
        input[type="password"] {
            width: 100%;
            background: var(--surface-3);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 14px 18px;
            color: var(--text);
            font-family: 'DM Sans', sans-serif;
            font-size: 15px;
            outline: none;
            transition: border-color 0.2s, box-shadow 0.2s, background 0.2s;
        }
        input[type="email"]:focus,
        input[type="password"]:focus {
            border-color: var(--crimson-light);
            background: rgba(155,27,48,0.08);
            box-shadow: 0 0 0 3px rgba(155,27,48,0.15);
        }
        input::placeholder { color: rgba(245,234,232,0.2); }

        .error-msg {
            font-size: 12px;
            color: #ff6b6b;
            margin-top: 6px;
        }

        .remember-row {
            display: flex;
            align-items: center;
            gap: 10px;
            margin: 24px 0;
            animation: fadeUp 0.6s 0.45s both;
        }
        .remember-row input[type="checkbox"] {
            width: 16px; height: 16px;
            accent-color: var(--crimson-light);
            cursor: pointer;
        }
        .remember-row label {
            font-size: 13px;
            letter-spacing: 0;
            text-transform: none;
            color: var(--text-muted);
            margin: 0;
            cursor: pointer;
        }

        .btn-signin {
            width: 100%;
            background: linear-gradient(135deg, var(--crimson) 0%, #C0392B 100%);
            color: #fff;
            font-family: 'DM Sans', sans-serif;
            font-size: 14px;
            font-weight: 600;
            letter-spacing: 1.5px;
            text-transform: uppercase;
            border: none;
            border-radius: 12px;
            padding: 16px;
            cursor: pointer;
            position: relative;
            overflow: hidden;
            transition: transform 0.15s, box-shadow 0.15s;
            box-shadow: 0 8px 30px rgba(155,27,48,0.5);
            animation: fadeUp 0.6s 0.52s both;
        }
        .btn-signin::before {
            content: '';
            position: absolute;
            inset: 0;
            background: linear-gradient(135deg, rgba(255,255,255,0.12), transparent);
            opacity: 0;
            transition: opacity 0.2s;
        }
        .btn-signin:hover { transform: translateY(-1px); box-shadow: 0 12px 40px rgba(155,27,48,0.65); }
        .btn-signin:hover::before { opacity: 1; }
        .btn-signin:active { transform: translateY(0); }

        .footer-note {
            text-align: center;
            margin-top: 28px;
            font-size: 11px;
            color: var(--text-muted);
            letter-spacing: 0.5px;
            animation: fadeUp 0.6s 0.6s both;
        }
    </style>
</head>
<body>
    <div class="bg-blob blob-1"></div>
    <div class="bg-blob blob-2"></div>
    <div class="bg-blob blob-3"></div>

    <div class="login-card">
        <div class="logo-wrap">
            <!-- Lovi fruit SVG inline -->
            <svg class="lovi-svg" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
                <ellipse cx="38" cy="62" rx="30" ry="28" fill="#E8425A"/>
                <ellipse cx="38" cy="62" rx="30" ry="28" fill="url(#g1)"/>
                <ellipse cx="62" cy="62" rx="27" ry="25" fill="#C0392B"/>
                <ellipse cx="62" cy="62" rx="27" ry="25" fill="url(#g2)"/>
                <circle cx="30" cy="52" r="8" fill="rgba(255,200,200,0.35)"/>
                <circle cx="55" cy="53" r="6" fill="rgba(255,200,200,0.3)"/>
                <!-- stems -->
                <path d="M35 34 Q33 20 30 14" stroke="#7A4A2A" stroke-width="3.5" stroke-linecap="round"/>
                <path d="M60 37 Q62 22 66 16" stroke="#7A4A2A" stroke-width="3.5" stroke-linecap="round"/>
                <defs>
                    <radialGradient id="g1" cx="35%" cy="35%">
                        <stop offset="0%" stop-color="#F06070"/>
                        <stop offset="100%" stop-color="#C0392B" stop-opacity="0"/>
                    </radialGradient>
                    <radialGradient id="g2" cx="35%" cy="35%">
                        <stop offset="0%" stop-color="#E05060"/>
                        <stop offset="100%" stop-color="#9B1B30" stop-opacity="0"/>
                    </radialGradient>
                </defs>
            </svg>
            <div>
                <div class="logo-text">lo<span>vi</span></div>
                <div class="logo-sub">Admin Console</div>
            </div>
        </div>

        <div class="divider"></div>

        <form method="POST" action="/admin/login">
            @csrf

            <div class="field-group">
                <label for="email">Email Address</label>
                <input type="email" id="email" name="email" required
                    placeholder="admin@lovi.app" autocomplete="email">
                @error('email')
                    <div class="error-msg">{{ $message }}</div>
                @enderror
            </div>

            <div class="field-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" required
                    placeholder="••••••••••" autocomplete="current-password">
            </div>

            <div class="remember-row">
                <input type="checkbox" id="remember" name="remember">
                <label for="remember">Keep me signed in</label>
            </div>

            <button type="submit" class="btn-signin">Sign In</button>
        </form>

        <div class="footer-note">Lovi Dating App &mdash; Admin Portal &copy; {{ date('Y') }}</div>
    </div>
</body>
</html>