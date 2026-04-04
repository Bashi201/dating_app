<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lovi Admin — @yield('title', 'Dashboard')</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,700;1,400&family=DM+Sans:opsz,wght@9..40,300;9..40,400;9..40,500;9..40,600&display=swap" rel="stylesheet">
    <style>
        :root {
            --crimson:       #9B1B30;
            --crimson-mid:   #B52237;
            --crimson-light: #C0392B;
            --crimson-glow:  rgba(155,27,48,0.35);
            --surface:       #0C0507;
            --surface-2:     #140809;
            --surface-3:     #1E0C0F;
            --surface-card:  rgba(255,255,255,0.028);
            --border:        rgba(155,27,48,0.2);
            --border-light:  rgba(255,255,255,0.06);
            --text:          #F5EAE8;
            --text-muted:    rgba(245,234,232,0.45);
            --text-faint:    rgba(245,234,232,0.22);
            --sidebar-w:     260px;
            --success:       #2ECC71;
            --warning:       #E67E22;
            --danger:        #E74C3C;
        }

        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        html, body { height: 100%; }

        body {
            font-family: 'DM Sans', sans-serif;
            background: var(--surface);
            color: var(--text);
            display: flex;
        }

        /* ── Sidebar ─────────────────────────────────── */
        .sidebar {
            width: var(--sidebar-w);
            min-height: 100vh;
            background: var(--surface-2);
            border-right: 1px solid var(--border);
            display: flex;
            flex-direction: column;
            position: fixed;
            top: 0; left: 0; bottom: 0;
            z-index: 100;
            overflow: hidden;
        }

        /* Subtle radial glow at top */
        .sidebar::before {
            content: '';
            position: absolute;
            top: -60px; left: -60px;
            width: 260px; height: 260px;
            background: radial-gradient(circle, rgba(155,27,48,0.25) 0%, transparent 70%);
            pointer-events: none;
        }

        .sidebar-logo {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 28px 24px 24px;
            border-bottom: 1px solid var(--border);
            position: relative;
        }

        .logo-icon { width: 40px; height: 40px; flex-shrink: 0; }

        .logo-wordmark {
            font-family: 'Playfair Display', serif;
            font-size: 22px;
            color: var(--text);
            letter-spacing: -0.3px;
        }
        .logo-wordmark em {
            color: var(--crimson-light);
            font-style: normal;
        }
        .logo-badge {
            font-size: 9px;
            letter-spacing: 2px;
            text-transform: uppercase;
            color: var(--text-faint);
            margin-top: 1px;
        }

        .sidebar-nav { flex: 1; padding: 20px 12px; overflow-y: auto; }

        .nav-section-label {
            font-size: 9.5px;
            letter-spacing: 2.2px;
            text-transform: uppercase;
            color: var(--text-faint);
            padding: 0 12px;
            margin-bottom: 8px;
            margin-top: 16px;
        }
        .nav-section-label:first-child { margin-top: 0; }

        .nav-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 11px 14px;
            border-radius: 10px;
            color: var(--text-muted);
            text-decoration: none;
            font-size: 13.5px;
            font-weight: 500;
            transition: all 0.18s;
            position: relative;
            margin-bottom: 2px;
        }
        .nav-item:hover { background: rgba(255,255,255,0.045); color: var(--text); }
        .nav-item.active {
            background: linear-gradient(120deg, rgba(155,27,48,0.35), rgba(155,27,48,0.12));
            color: var(--text);
            border: 1px solid rgba(155,27,48,0.3);
        }
        .nav-item.active::before {
            content: '';
            position: absolute;
            left: 0; top: 25%; bottom: 25%;
            width: 3px;
            background: var(--crimson-light);
            border-radius: 0 3px 3px 0;
        }

        .nav-icon {
            width: 18px; height: 18px;
            opacity: 0.7;
            flex-shrink: 0;
        }
        .nav-item.active .nav-icon { opacity: 1; }

        .nav-badge {
            margin-left: auto;
            background: var(--crimson);
            color: #fff;
            font-size: 10px;
            font-weight: 600;
            padding: 2px 7px;
            border-radius: 20px;
            min-width: 20px;
            text-align: center;
        }

        .sidebar-footer {
            padding: 20px 12px 24px;
            border-top: 1px solid var(--border);
        }
        .admin-chip {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 10px 12px;
            border-radius: 10px;
            background: var(--surface-card);
            border: 1px solid var(--border-light);
            margin-bottom: 12px;
        }
        .admin-avatar {
            width: 32px; height: 32px;
            border-radius: 50%;
            background: var(--crimson);
            display: flex; align-items: center; justify-content: center;
            font-size: 13px; font-weight: 700;
            color: #fff;
            flex-shrink: 0;
        }
        .admin-name { font-size: 13px; font-weight: 500; }
        .admin-role { font-size: 10px; color: var(--text-faint); letter-spacing: 0.5px; }

        .logout-btn {
            display: flex;
            align-items: center;
            gap: 10px;
            width: 100%;
            padding: 10px 14px;
            border-radius: 10px;
            background: none;
            border: 1px solid var(--border);
            color: var(--text-muted);
            font-family: 'DM Sans', sans-serif;
            font-size: 13px;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.18s;
        }
        .logout-btn:hover { background: rgba(231,76,60,0.12); border-color: var(--danger); color: #ff6b6b; }

        /* ── Main ──────────────────────────────────────── */
        .main {
            margin-left: var(--sidebar-w);
            flex: 1;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .topbar {
            height: 64px;
            border-bottom: 1px solid var(--border-light);
            display: flex;
            align-items: center;
            padding: 0 32px;
            gap: 16px;
            background: rgba(12,5,7,0.85);
            backdrop-filter: blur(12px);
            position: sticky; top: 0;
            z-index: 50;
        }

        .topbar-title {
            font-family: 'Playfair Display', serif;
            font-size: 18px;
            font-weight: 400;
            color: var(--text);
        }

        .topbar-right { margin-left: auto; display: flex; align-items: center; gap: 12px; }

        .topbar-pill {
            display: flex; align-items: center; gap: 6px;
            padding: 6px 14px;
            background: var(--surface-card);
            border: 1px solid var(--border-light);
            border-radius: 20px;
            font-size: 12px;
            color: var(--text-muted);
        }
        .status-dot {
            width: 7px; height: 7px;
            border-radius: 50%;
            background: var(--success);
            box-shadow: 0 0 6px var(--success);
            animation: pulse-dot 2s ease-in-out infinite;
        }
        @keyframes pulse-dot {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }

        .page-content { padding: 32px; flex: 1; }

        /* ── Cards & Components ──────────────────────── */
        .card {
            background: var(--surface-card);
            border: 1px solid var(--border-light);
            border-radius: 16px;
            overflow: hidden;
            transition: border-color 0.2s, box-shadow 0.2s;
        }
        .card:hover { border-color: var(--border); box-shadow: 0 8px 32px rgba(0,0,0,0.3); }
        .card-pad { padding: 24px; }

        /* Report card accent */
        .report-card { border-left: 3px solid var(--warning); }
        .report-card:hover { border-left-color: var(--crimson-light); }

        /* Badges */
        .badge {
            display: inline-flex; align-items: center;
            font-size: 10.5px; font-weight: 600;
            letter-spacing: 0.5px;
            padding: 3px 10px;
            border-radius: 20px;
        }
        .badge-pending { background: rgba(230,126,34,0.15); color: #F0A04A; border: 1px solid rgba(230,126,34,0.3); }
        .badge-active  { background: rgba(46,204,113,0.12); color: #52D68A; border: 1px solid rgba(46,204,113,0.25); }
        .badge-banned  { background: rgba(231,76,60,0.12);  color: #FF6B6B; border: 1px solid rgba(231,76,60,0.25); }
        .badge-resolved{ background: rgba(255,255,255,0.06); color: var(--text-muted); border: 1px solid var(--border-light); }

        /* Buttons */
        .btn {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 9px 18px;
            border-radius: 10px;
            font-family: 'DM Sans', sans-serif;
            font-size: 13px; font-weight: 500;
            border: none; cursor: pointer;
            text-decoration: none;
            transition: all 0.15s;
        }
        .btn-ghost { background: rgba(255,255,255,0.05); color: var(--text-muted); border: 1px solid var(--border-light); }
        .btn-ghost:hover { background: rgba(255,255,255,0.09); color: var(--text); }
        .btn-danger { background: rgba(231,76,60,0.18); color: #FF6B6B; border: 1px solid rgba(231,76,60,0.35); }
        .btn-danger:hover { background: var(--danger); color: #fff; box-shadow: 0 4px 20px rgba(231,76,60,0.45); }
        .btn-success { background: rgba(46,204,113,0.12); color: #52D68A; border: 1px solid rgba(46,204,113,0.3); }
        .btn-success:hover { background: var(--success); color: #fff; }
        .btn-primary { background: linear-gradient(135deg, var(--crimson), var(--crimson-light)); color: #fff; box-shadow: 0 4px 16px rgba(155,27,48,0.4); }
        .btn-primary:hover { box-shadow: 0 6px 24px rgba(155,27,48,0.6); transform: translateY(-1px); }
        .btn-sm { padding: 6px 14px; font-size: 12px; border-radius: 8px; }

        /* Modal */
        .modal-overlay {
            position: fixed; inset: 0;
            background: rgba(0,0,0,0.75);
            backdrop-filter: blur(6px);
            display: none; align-items: center; justify-content: center;
            z-index: 200;
        }
        .modal-box {
            background: var(--surface-3);
            border: 1px solid var(--border);
            border-radius: 20px;
            padding: 36px;
            width: 460px;
            max-width: 95vw;
            box-shadow: 0 40px 80px rgba(0,0,0,0.7), 0 0 40px var(--crimson-glow);
            animation: modalIn 0.3s cubic-bezier(0.34,1.56,0.64,1);
        }
        @keyframes modalIn {
            from { opacity: 0; transform: scale(0.92) translateY(16px); }
            to   { opacity: 1; transform: scale(1) translateY(0); }
        }
        .modal-title { font-family: 'Playfair Display', serif; font-size: 22px; margin-bottom: 8px; }
        .modal-subtitle { font-size: 13px; color: var(--text-muted); margin-bottom: 24px; }

        /* Form elements */
        .form-input, .form-textarea {
            width: 100%;
            background: rgba(255,255,255,0.04);
            border: 1px solid var(--border-light);
            border-radius: 10px;
            padding: 12px 16px;
            color: var(--text);
            font-family: 'DM Sans', sans-serif;
            font-size: 14px;
            outline: none;
            transition: all 0.2s;
        }
        .form-input:focus, .form-textarea:focus {
            border-color: var(--crimson-mid);
            background: rgba(155,27,48,0.07);
            box-shadow: 0 0 0 3px rgba(155,27,48,0.12);
        }
        .form-input::placeholder, .form-textarea::placeholder { color: var(--text-faint); }
        .form-textarea { resize: vertical; min-height: 110px; }
        .form-label {
            display: block;
            font-size: 11px; letter-spacing: 1.5px;
            text-transform: uppercase;
            color: var(--text-muted);
            margin-bottom: 8px;
        }

        /* Table */
        .data-table { width: 100%; border-collapse: collapse; }
        .data-table th {
            padding: 14px 20px;
            font-size: 10.5px; letter-spacing: 1.5px;
            text-transform: uppercase;
            color: var(--text-faint);
            text-align: left;
            font-weight: 500;
            border-bottom: 1px solid var(--border-light);
        }
        .data-table td {
            padding: 16px 20px;
            border-bottom: 1px solid rgba(255,255,255,0.03);
            font-size: 14px;
            color: var(--text);
            vertical-align: middle;
        }
        .data-table tr:last-child td { border-bottom: none; }
        .data-table tbody tr { transition: background 0.15s; }
        .data-table tbody tr:hover { background: rgba(255,255,255,0.025); }

        /* Avatar initials */
        .avatar {
            width: 38px; height: 38px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-weight: 700; font-size: 14px;
            flex-shrink: 0;
        }
        .avatar-crimson { background: rgba(155,27,48,0.25); color: var(--crimson-light); border: 1px solid rgba(155,27,48,0.3); }
        .avatar-blue    { background: rgba(52,152,219,0.2);  color: #5DADE2; border: 1px solid rgba(52,152,219,0.3); }
        .avatar-orange  { background: rgba(230,126,34,0.2);  color: #F0A04A; border: 1px solid rgba(230,126,34,0.3); }

        /* Stat cards */
        .stat-card {
            background: var(--surface-card);
            border: 1px solid var(--border-light);
            border-radius: 14px;
            padding: 20px 24px;
            position: relative;
            overflow: hidden;
        }
        .stat-card::after {
            content: '';
            position: absolute;
            bottom: 0; right: 0;
            width: 80px; height: 80px;
            border-radius: 50%;
            background: radial-gradient(circle, rgba(155,27,48,0.15) 0%, transparent 70%);
        }
        .stat-val { font-family: 'Playfair Display', serif; font-size: 32px; color: var(--text); }
        .stat-label { font-size: 12px; color: var(--text-muted); margin-top: 4px; letter-spacing: 0.5px; }

        /* Search input */
        .search-wrap { position: relative; }
        .search-wrap svg { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: var(--text-faint); }
        .search-input {
            background: rgba(255,255,255,0.04);
            border: 1px solid var(--border-light);
            border-radius: 10px;
            padding: 10px 16px 10px 40px;
            color: var(--text);
            font-family: 'DM Sans', sans-serif;
            font-size: 13.5px;
            outline: none;
            transition: all 0.2s;
            width: 240px;
        }
        .search-input:focus { border-color: var(--border); background: rgba(255,255,255,0.06); }
        .search-input::placeholder { color: var(--text-faint); }

        /* Select */
        .form-select {
            background: rgba(255,255,255,0.04);
            border: 1px solid var(--border-light);
            border-radius: 10px;
            padding: 10px 16px;
            color: var(--text);
            font-family: 'DM Sans', sans-serif;
            font-size: 13.5px;
            outline: none;
            cursor: pointer;
            -webkit-appearance: none;
        }
        .form-select:focus { border-color: var(--border); }
        option { background: #1E0C0F; }

        /* Pagination */
        .pagination { display: flex; gap: 6px; align-items: center; padding: 20px 24px; }
        .page-btn {
            width: 34px; height: 34px; border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
            font-size: 13px; background: rgba(255,255,255,0.04);
            border: 1px solid var(--border-light); color: var(--text-muted);
            text-decoration: none; transition: all 0.15s; cursor: pointer;
        }
        .page-btn:hover { background: rgba(255,255,255,0.08); color: var(--text); }
        .page-btn.active { background: var(--crimson); color: #fff; border-color: var(--crimson); }

        /* Scrollbar */
        ::-webkit-scrollbar { width: 5px; }
        ::-webkit-scrollbar-track { background: transparent; }
        ::-webkit-scrollbar-thumb { background: rgba(155,27,48,0.3); border-radius: 3px; }

        /* Page entry animation */
        .page-content > * { animation: fadeUp 0.4s cubic-bezier(0.16,1,0.3,1) both; }
        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(10px); }
            to   { opacity: 1; transform: translateY(0); }
        }
    </style>
    @stack('styles')
</head>
<body>

<!-- ─── Sidebar ─────────────────────────────────────────── -->
<aside class="sidebar">
    <div class="sidebar-logo">
        <svg class="logo-icon" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
            <ellipse cx="38" cy="65" rx="29" ry="27" fill="#D63651"/>
            <ellipse cx="38" cy="65" rx="29" ry="27" fill="url(#sl1)"/>
            <ellipse cx="62" cy="65" rx="26" ry="24" fill="#B52237"/>
            <ellipse cx="62" cy="65" rx="26" ry="24" fill="url(#sl2)"/>
            <circle cx="30" cy="55" r="7" fill="rgba(255,200,200,0.3)"/>
            <circle cx="55" cy="56" r="5.5" fill="rgba(255,200,200,0.25)"/>
            <path d="M35 37 Q33 22 30 16" stroke="#7A4A2A" stroke-width="3" stroke-linecap="round"/>
            <path d="M60 40 Q62 24 66 18" stroke="#7A4A2A" stroke-width="3" stroke-linecap="round"/>
            <defs>
                <radialGradient id="sl1" cx="32%" cy="35%"><stop offset="0%" stop-color="#F06070"/><stop offset="100%" stop-color="#B52237" stop-opacity="0"/></radialGradient>
                <radialGradient id="sl2" cx="32%" cy="35%"><stop offset="0%" stop-color="#E05060"/><stop offset="100%" stop-color="#9B1B30" stop-opacity="0"/></radialGradient>
            </defs>
        </svg>
        <div>
            <div class="logo-wordmark">lo<em>vi</em></div>
            <div class="logo-badge">Admin Console</div>
        </div>
    </div>

    <nav class="sidebar-nav">
        <div class="nav-section-label">Moderation</div>
        <a href="{{ route('admin.reports.index') }}" class="nav-item {{ request()->routeIs('admin.reports.*') ? 'active' : '' }}">
            <svg class="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
            Safety Reports
            {{-- <span class="nav-badge">{{ $pendingCount ?? '' }}</span> --}}
        </a>

        <div class="nav-section-label">Users</div>
        <a href="{{ route('admin.users.index') }}" class="nav-item {{ request()->routeIs('admin.users.*') ? 'active' : '' }}">
            <svg class="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 00-3-3.87"/><path d="M16 3.13a4 4 0 010 7.75"/></svg>
            User Management
        </a>
    </nav>

    <div class="sidebar-footer">
        <div class="admin-chip">
            <div class="admin-avatar">A</div>
            <div>
                <div class="admin-name">Administrator</div>
                <div class="admin-role">Super Admin</div>
            </div>
        </div>
        <a href="/admin/logout" class="logout-btn" onclick="event.preventDefault(); document.getElementById('logout-form').submit();">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
            Sign Out
        </a>
        <form id="logout-form" action="/admin/logout" method="POST" style="display:none">@csrf</form>
    </div>
</aside>

<!-- ─── Main ─────────────────────────────────────────────── -->
<div class="main">
    <header class="topbar">
        <span class="topbar-title">@yield('page-title', 'Dashboard')</span>
        <div class="topbar-right">
            <div class="topbar-pill">
                <span class="status-dot"></span>
                Live
            </div>
            <div class="topbar-pill">
                {{ now()->format('d M Y') }}
            </div>
        </div>
    </header>

    <div class="page-content">
        @if(session('success'))
            <div style="background:rgba(46,204,113,0.1);border:1px solid rgba(46,204,113,0.25);color:#52D68A;border-radius:10px;padding:14px 20px;margin-bottom:24px;font-size:13.5px;display:flex;align-items:center;gap:10px;">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                {{ session('success') }}
            </div>
        @endif

        @if(session('error'))
            <div style="background:rgba(231,76,60,0.1);border:1px solid rgba(231,76,60,0.25);color:#FF6B6B;border-radius:10px;padding:14px 20px;margin-bottom:24px;font-size:13.5px;display:flex;align-items:center;gap:10px;">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
                {{ session('error') }}
            </div>
        @endif

        @yield('content')
    </div>
</div>

@stack('modals')
@stack('scripts')
</body>
</html>