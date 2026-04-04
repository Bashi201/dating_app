@extends('admin.layout')

@section('title', 'User: ' . $user->name)
@section('page-title', 'User Detail')

@section('content')

    <!-- Breadcrumb -->
    <div style="display:flex;align-items:center;gap:10px;margin-bottom:28px;">
        <a href="{{ route('admin.users.index') }}" class="btn btn-ghost btn-sm" style="text-decoration:none;">
            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="15 18 9 12 15 6"/></svg>
            Users
        </a>
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="var(--text-faint)" stroke-width="2"><polyline points="9 18 15 12 9 6"/></svg>
        <span style="font-size:14px;color:var(--text-muted);">{{ $user->name }}</span>
    </div>

    <div style="display:grid;grid-template-columns:300px 1fr;gap:24px;align-items:start;">

        <!-- ─── Left Column ─────────────────────────────────── -->
        <div style="display:flex;flex-direction:column;gap:20px;">

            <!-- Profile Card -->
            <div class="card card-pad" style="text-align:center;">
                @php $primary = $user->photos->firstWhere('is_primary', true); @endphp
                <div style="position:relative;display:inline-block;margin-bottom:18px;">
                    <img src="{{ $primary?->url ?? 'https://ui-avatars.com/api/?name=' . urlencode($user->name) . '&background=9B1B30&color=fff&size=150' }}"
                        style="width:110px;height:110px;border-radius:50%;object-fit:cover;border:3px solid var(--border);box-shadow:0 0 0 6px rgba(155,27,48,0.12);">
                    @if($user->is_banned)
                        <div style="position:absolute;bottom:4px;right:4px;width:22px;height:22px;border-radius:50%;background:#E74C3C;border:2px solid var(--surface-2);display:flex;align-items:center;justify-content:center;">
                            <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="3"><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/><circle cx="12" cy="12" r="10"/></svg>
                        </div>
                    @else
                        <div style="position:absolute;bottom:4px;right:4px;width:22px;height:22px;border-radius:50%;background:#2ECC71;border:2px solid var(--surface-2);box-shadow:0 0 8px rgba(46,204,113,0.5);"></div>
                    @endif
                </div>

                <h3 style="font-family:'Playfair Display',serif;font-size:20px;color:var(--text);margin-bottom:4px;">{{ $user->name }}</h3>
                <p style="font-size:12px;color:var(--text-muted);margin-bottom:6px;">{{ $user->email }}</p>

                @if($user->is_banned)
                    <span class="badge badge-banned" style="margin-bottom:20px;">Banned Account</span>
                @else
                    <span class="badge badge-active" style="margin-bottom:20px;">Active Account</span>
                @endif

                <div style="margin-bottom:0;">
                    @if($user->is_banned)
                        <form action="{{ route('admin.users.index') }}/{{ $user->id }}/unban" method="POST">
                            @csrf
                            <button type="submit" class="btn btn-success" style="width:100%;justify-content:center;">
                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                                Unban User
                            </button>
                        </form>
                    @else
                        <button onclick="document.getElementById('ban-modal').style.display='flex'" class="btn btn-danger" style="width:100%;justify-content:center;">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg>
                            Ban User
                        </button>
                    @endif
                </div>
            </div>

            <!-- Profile Info -->
            <div class="card card-pad">
                <div style="font-size:10.5px;letter-spacing:2px;text-transform:uppercase;color:var(--text-faint);margin-bottom:18px;">Profile Details</div>
                <div style="display:flex;flex-direction:column;gap:16px;">
                    <div style="display:flex;justify-content:space-between;align-items:center;padding-bottom:14px;border-bottom:1px solid var(--border-light);">
                        <span style="font-size:12px;color:var(--text-faint);">Age</span>
                        <span style="font-size:14px;font-weight:500;color:var(--text);">{{ $user->profile->age ?? '—' }}</span>
                    </div>
                    <div style="display:flex;justify-content:space-between;align-items:center;padding-bottom:14px;border-bottom:1px solid var(--border-light);">
                        <span style="font-size:12px;color:var(--text-faint);">Gender</span>
                        <span style="font-size:14px;font-weight:500;color:var(--text);text-transform:capitalize;">{{ $user->profile->gender ?? '—' }}</span>
                    </div>
                    <div>
                        <div style="font-size:12px;color:var(--text-faint);margin-bottom:8px;">Bio</div>
                        <p style="font-size:13px;color:var(--text-muted);line-height:1.65;">{{ $user->profile->bio ?? 'No bio provided.' }}</p>
                    </div>
                </div>
            </div>

            <!-- Danger Zone -->
            <div style="background:rgba(231,76,60,0.05);border:1px solid rgba(231,76,60,0.2);border-radius:14px;padding:20px;">
                <div style="display:flex;align-items:center;gap:8px;margin-bottom:8px;">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#FF6B6B" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                    <span style="font-size:12px;font-weight:600;color:#FF6B6B;letter-spacing:0.5px;">Danger Zone</span>
                </div>
                <p style="font-size:11.5px;color:rgba(231,76,60,0.6);margin-bottom:16px;line-height:1.6;">Permanently deletes the user, all photos, matches, and messages. This is irreversible.</p>
                <form action="{{ route('admin.users.index') }}/{{ $user->id }}" method="POST"
                    onsubmit="return confirm('Permanently delete {{ addslashes($user->name) }}? This cannot be undone.')">
                    @csrf @method('DELETE')
                    <button type="submit" style="width:100%;background:none;border:1px solid rgba(231,76,60,0.4);color:#FF6B6B;font-family:'DM Sans',sans-serif;font-size:12.5px;font-weight:600;padding:10px;border-radius:10px;cursor:pointer;transition:all 0.15s;display:flex;align-items:center;justify-content:center;gap:7px;"
                        onmouseover="this.style.background='rgba(231,76,60,0.2)'" onmouseout="this.style.background='none'">
                        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 01-2 2H8a2 2 0 01-2-2L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4h6v2"/></svg>
                        Delete Permanently
                    </button>
                </form>
            </div>
        </div>

        <!-- ─── Right Column ─────────────────────────────────── -->
        <div style="display:flex;flex-direction:column;gap:20px;">

            <!-- Reports Against -->
            <div class="card">
                <div class="card-pad" style="border-bottom:1px solid var(--border-light);">
                    <div style="display:flex;align-items:center;justify-content:space-between;">
                        <div style="display:flex;align-items:center;gap:10px;">
                            <div style="width:36px;height:36px;border-radius:10px;background:rgba(231,76,60,0.1);border:1px solid rgba(231,76,60,0.2);display:flex;align-items:center;justify-content:center;">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#FF6B6B" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/></svg>
                            </div>
                            <div>
                                <h3 style="font-size:15px;font-weight:600;color:var(--text);">Reports Against This User</h3>
                                <div style="font-size:12px;color:var(--text-muted);">Safety record</div>
                            </div>
                        </div>
                        <span class="badge badge-banned" style="font-size:12px;padding:5px 14px;">{{ $reports->count() }} Total</span>
                    </div>
                </div>

                @if($reports->isEmpty())
                    <div style="padding:40px;text-align:center;">
                        <div style="font-size:28px;margin-bottom:10px;">✅</div>
                        <p style="font-size:14px;color:var(--text-muted);">No reports found for this user.</p>
                    </div>
                @else
                    <div style="padding:20px;display:flex;flex-direction:column;gap:14px;">
                        @foreach($reports as $report)
                            <div style="padding:16px;border-radius:12px;background:{{ $report->status == 'pending' ? 'rgba(230,126,34,0.07)' : 'rgba(255,255,255,0.02)' }};border:1px solid {{ $report->status == 'pending' ? 'rgba(230,126,34,0.2)' : 'var(--border-light)' }};">
                                <div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:10px;">
                                    <div style="display:flex;align-items:center;gap:8px;">
                                        <div class="avatar avatar-blue" style="width:28px;height:28px;font-size:11px;">{{ substr($report->reporter->name, 0, 1) }}</div>
                                        <div>
                                            <span style="font-size:12.5px;font-weight:500;color:var(--text);">{{ $report->reporter->name }}</span>
                                            <span style="font-size:11px;color:var(--text-faint);"> reported</span>
                                        </div>
                                    </div>
                                    <div style="display:flex;align-items:center;gap:8px;">
                                        @if($report->status == 'pending')
                                            <span class="badge badge-pending">Pending</span>
                                        @else
                                            <span class="badge badge-resolved">Resolved</span>
                                        @endif
                                        <span style="font-size:11px;color:var(--text-faint);">{{ $report->created_at->diffForHumans() }}</span>
                                    </div>
                                </div>
                                <div style="font-size:13px;font-weight:600;color:var(--text);margin-bottom:6px;">{{ str_replace('_', ' ', ucwords($report->reason)) }}</div>
                                @if($report->description)
                                    <p style="font-size:12.5px;color:var(--text-muted);line-height:1.55;margin-bottom:10px;">{{ $report->description }}</p>
                                @endif

                                @if($report->status == 'pending')
                                    <form action="/api/admin/reports/{{ $report->id }}/dismiss" method="POST" style="display:inline;">
                                        @csrf
                                        <button type="submit" class="btn btn-ghost btn-sm">
                                            <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                                            Dismiss
                                        </button>
                                    </form>
                                @else
                                    <span style="font-size:11px;color:var(--text-faint);font-style:italic;">Resolved {{ $report->reviewed_at->format('M d · H:i') }}</span>
                                @endif
                            </div>
                        @endforeach
                    </div>
                @endif
            </div>

            <!-- Photos -->
            <div class="card">
                <div class="card-pad" style="border-bottom:1px solid var(--border-light);">
                    <div style="display:flex;align-items:center;gap:10px;">
                        <div style="width:36px;height:36px;border-radius:10px;background:rgba(155,27,48,0.1);border:1px solid var(--border);display:flex;align-items:center;justify-content:center;">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="var(--crimson-light)" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                        </div>
                        <div>
                            <h3 style="font-size:15px;font-weight:600;color:var(--text);">Photos</h3>
                            <div style="font-size:12px;color:var(--text-muted);">{{ $user->photos->count() }} uploaded</div>
                        </div>
                    </div>
                </div>

                <div class="card-pad">
                    @if($user->photos->isEmpty())
                        <div style="text-align:center;padding:30px;">
                            <p style="font-size:13px;color:var(--text-muted);">No photos uploaded.</p>
                        </div>
                    @else
                        <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:12px;">
                            @foreach($user->photos as $photo)
                                <div style="position:relative;border-radius:12px;overflow:hidden;aspect-ratio:1;group;">
                                    <img src="{{ $photo->url }}" style="width:100%;height:100%;object-fit:cover;display:block;border-radius:12px;border:1px solid var(--border-light);">
                                    @if($photo->is_primary)
                                        <div style="position:absolute;top:6px;left:6px;background:var(--crimson);color:#fff;font-size:9px;font-weight:700;letter-spacing:1px;text-transform:uppercase;padding:3px 8px;border-radius:6px;">Primary</div>
                                    @endif
                                    <!-- Delete overlay -->
                                    <div style="position:absolute;inset:0;background:rgba(0,0,0,0.65);opacity:0;border-radius:12px;display:flex;align-items:center;justify-content:center;transition:opacity 0.2s;cursor:pointer;"
                                        onmouseover="this.style.opacity='1'" onmouseout="this.style.opacity='0'">
                                        <form action="/api/admin/photos/{{ $photo->id }}" method="POST" onsubmit="return confirm('Delete this photo?')" style="display:flex;">
                                            @csrf @method('DELETE')
                                            <button type="submit" style="background:rgba(231,76,60,0.9);border:none;width:38px;height:38px;border-radius:50%;cursor:pointer;display:flex;align-items:center;justify-content:center;color:#fff;transition:background 0.15s;"
                                                onmouseover="this.style.background='#E74C3C'" onmouseout="this.style.background='rgba(231,76,60,0.9)'">
                                                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M9 2a1 1 0 00-.894.553L7.382 4H4a1 1 0 000 2v10a2 2 0 002 2h8a2 2 0 002-2V6a1 1 0 100-2h-3.382l-.724-1.447A1 1 0 0011 2H9zM7 8a1 1 0 012 0v6a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v6a1 1 0 102 0V8a1 1 0 00-1-1z" clip-rule="evenodd"/></svg>
                                            </button>
                                        </form>
                                    </div>
                                </div>
                            @endforeach
                        </div>
                    @endif
                </div>
            </div>

        </div>
    </div>

@endsection

@push('modals')
    <!-- Ban Modal -->
    <div id="ban-modal" class="modal-overlay">
        <div class="modal-box">
            <div style="display:flex;align-items:center;gap:14px;margin-bottom:6px;">
                <div style="width:42px;height:42px;border-radius:12px;background:rgba(231,76,60,0.15);border:1px solid rgba(231,76,60,0.3);display:flex;align-items:center;justify-content:center;">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#FF6B6B" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg>
                </div>
                <div>
                    <h3 class="modal-title">Ban {{ $user->name }}</h3>
                </div>
            </div>
            <p class="modal-subtitle">This will restrict their access to the Lovi platform. The reason may be shown to the user.</p>

            <form action="{{ route('admin.users.index') }}/{{ $user->id }}/ban" method="POST">
                @csrf
                <label class="form-label">Reason for Ban</label>
                <textarea name="reason" required class="form-textarea" placeholder="Provide an official reason for this ban…"></textarea>

                <div style="display:flex;gap:12px;margin-top:24px;">
                    <button type="button" onclick="document.getElementById('ban-modal').style.display='none'" class="btn btn-ghost" style="flex:1;justify-content:center;">
                        Cancel
                    </button>
                    <button type="submit" class="btn" style="flex:1;justify-content:center;background:#E74C3C;color:#fff;border:1px solid #E74C3C;box-shadow:0 4px 20px rgba(231,76,60,0.4);">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg>
                        Confirm Ban
                    </button>
                </div>
            </form>
        </div>
    </div>
@endpush

@push('scripts')
    <script>
    document.getElementById('ban-modal').addEventListener('click', function(e) {
        if (e.target === this) this.style.display = 'none';
    });
    </script>
@endpush