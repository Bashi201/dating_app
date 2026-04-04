@extends('admin.layout')

@section('title', 'User Management')
@section('page-title', 'User Management')

@section('content')

    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:28px;">
        <div>
            <h2 style="font-family:'Playfair Display',serif;font-size:26px;font-weight:400;color:var(--text);">All Members
            </h2>
            <p style="font-size:13px;color:var(--text-muted);margin-top:4px;">Manage and review user accounts</p>
        </div>

        <!-- Search & Filter -->
        <form action="{{ route('admin.users.index') }}" method="GET" style="display:flex;gap:10px;align-items:center;">
            <div class="search-wrap">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <circle cx="11" cy="11" r="8" />
                    <line x1="21" y1="21" x2="16.65" y2="16.65" />
                </svg>
                <input type="text" name="search" class="search-input" placeholder="Search name or email…"
                    value="{{ request('search') }}">
            </div>
            <select name="banned" class="form-select" onchange="this.form.submit()" style="padding:10px 16px;">
                <option value="">All Users</option>
                <option value="false" {{ request('banned') == 'false' ? 'selected' : '' }}>Active</option>
                <option value="true" {{ request('banned') == 'true' ? 'selected' : '' }}>Banned</option>
            </select>
            <button type="submit" class="btn btn-primary btn-sm">
                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                    <circle cx="11" cy="11" r="8" />
                    <line x1="21" y1="21" x2="16.65" y2="16.65" />
                </svg>
                Search
            </button>
        </form>
    </div>

    <!-- Stats row -->
    <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:16px;margin-bottom:28px;">
        <div class="stat-card">
            <div class="stat-val">{{ $users->total() }}</div>
            <div class="stat-label">Total Members</div>
        </div>
        <div class="stat-card">
            <div class="stat-val" style="color:#52D68A;">{{ $users->where('is_banned', false)->count() }}</div>
            <div class="stat-label">Active Accounts</div>
        </div>
        <div class="stat-card">
            <div class="stat-val" style="color:#FF6B6B;">{{ $users->where('is_banned', true)->count() }}</div>
            <div class="stat-label">Banned Accounts</div>
        </div>
    </div>

    <!-- Table -->
    <div class="card" style="overflow:visible;">
        @if($users->isEmpty())
            <div style="padding:60px 40px;text-align:center;">
                <div style="font-size:36px;margin-bottom:16px;">🔍</div>
                <p style="font-size:15px;font-weight:500;color:var(--text);margin-bottom:6px;">No users found</p>
                <p style="font-size:13px;color:var(--text-muted);">Try adjusting your search or filter criteria.</p>
            </div>
        @else
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Member</th>
                        <th>Status</th>
                        <th>Joined</th>
                        <th style="text-align:right;">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($users as $user)
                        <tr>
                            <td>
                                <div style="display:flex;align-items:center;gap:14px;">
                                    <div class="avatar avatar-crimson">{{ substr($user->name, 0, 1) }}</div>
                                    <div>
                                        <div style="font-weight:500;font-size:14px;color:var(--text);">{{ $user->name }}</div>
                                        <div style="font-size:12px;color:var(--text-muted);margin-top:2px;">{{ $user->email }}</div>
                                    </div>
                                </div>
                            </td>
                            <td>
                                @if($user->is_banned)
                                    <span class="badge badge-banned">Banned</span>
                                @else
                                    <span class="badge badge-active">Active</span>
                                @endif
                            </td>
                            <td>
                                <div style="font-size:13px;color:var(--text-muted);">{{ $user->created_at->format('M d, Y') }}</div>
                                <div style="font-size:11px;color:var(--text-faint);margin-top:2px;">
                                    {{ $user->created_at->diffForHumans() }}</div>
                            </td>
                            <td style="text-align:right;">
                                <a href="{{ route('admin.users.index') }}/{{ $user->id }}" class="btn btn-ghost btn-sm"
                                    style="text-decoration:none;">
                                    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                        stroke-width="2">
                                        <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
                                        <circle cx="12" cy="12" r="3" />
                                    </svg>
                                    View Detail
                                </a>
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
            <div class="pagination">
                {{ $users->links() }}
            </div>
        @endif
    </div>

@endsection