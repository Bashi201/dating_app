@extends('admin.layout')

@section('title', 'Safety Reports')
@section('page-title', 'Safety Reports')

@section('content')

    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:28px;">
        <div>
            <h2 style="font-family:'Playfair Display',serif;font-size:26px;font-weight:400;color:var(--text);">Pending
                Review</h2>
            <p style="font-size:13px;color:var(--text-muted);margin-top:4px;">Reports requiring your attention</p>
        </div>
        <div style="display:flex;align-items:center;gap:12px;">
            <div
                style="background:rgba(230,126,34,0.12);border:1px solid rgba(230,126,34,0.3);border-radius:20px;padding:7px 18px;font-size:13px;color:#F0A04A;font-weight:600;display:flex;align-items:center;gap:7px;">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                    <path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z" />
                </svg>
                {{ $reports->total() }} Remaining
            </div>
        </div>
    </div>

    @if($reports->isEmpty())
        <div
            style="display:flex;flex-direction:column;align-items:center;justify-content:center;padding:80px 40px;background:var(--surface-card);border:1px solid var(--border-light);border-radius:20px;text-align:center;">
            <div style="font-size:52px;margin-bottom:20px;">🍒</div>
            <h3 style="font-family:'Playfair Display',serif;font-size:22px;color:var(--text);margin-bottom:8px;">All Clear!</h3>
            <p style="font-size:14px;color:var(--text-muted);">No pending reports right now. The community is safe.</p>
        </div>
    @else

        <div style="display:grid;grid-template-columns:repeat(2,1fr);gap:20px;">
            @foreach($reports as $report)
                @php $photo = $report->reported->photos->firstWhere('is_primary', true) ?? $report->reported->photos->first(); @endphp
                <div class="card report-card" style="animation-delay:{{ $loop->index * 0.06 }}s">
                    <div class="card-pad">
                        <!-- Header row -->
                        <div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:20px;">
                            <div>
                                <span class="badge badge-pending">Pending Review</span>
                                <div
                                    style="font-size:11px;color:var(--text-faint);margin-top:7px;display:flex;align-items:center;gap:5px;">
                                    <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                        stroke-width="2">
                                        <circle cx="12" cy="12" r="10" />
                                        <polyline points="12 6 12 12 16 14" />
                                    </svg>
                                    {{ $report->created_at->format('M d, Y · H:i') }}
                                </div>
                            </div>
                            <!-- Reporter vs Reported avatars -->
                            <div style="display:flex;align-items:center;gap:-8px;">
                                <div style="display:flex;align-items:center;gap:2px;">
                                    <div class="avatar avatar-blue" style="width:32px;height:32px;font-size:12px;"
                                        title="Reporter: {{ $report->reporter->name }}">{{ substr($report->reporter->name, 0, 1) }}
                                    </div>
                                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="var(--text-faint)"
                                        stroke-width="2">
                                        <line x1="5" y1="12" x2="19" y2="12" />
                                        <polyline points="12 5 19 12 12 19" />
                                    </svg>
                                    <div class="avatar"
                                        style="width:32px;height:32px;font-size:12px;background:rgba(231,76,60,0.2);color:#FF6B6B;border:1px solid rgba(231,76,60,0.3);"
                                        title="Reported: {{ $report->reported->name }}">{{ substr($report->reported->name, 0, 1) }}
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Reported user info -->
                        <div
                            style="display:flex;gap:16px;margin-bottom:18px;padding:16px;background:rgba(255,255,255,0.025);border:1px solid var(--border-light);border-radius:12px;">
                            <img src="{{ $photo?->url ?? 'https://ui-avatars.com/api/?name=' . urlencode($report->reported->name) . '&background=9B1B30&color=fff&size=80' }}"
                                style="width:72px;height:72px;border-radius:10px;object-fit:cover;flex-shrink:0;border:2px solid var(--border);">
                            <div style="flex:1;min-width:0;">
                                <div style="font-size:11px;color:var(--text-faint);margin-bottom:3px;">Reported User</div>
                                <div style="font-weight:600;font-size:15px;color:var(--text);margin-bottom:2px;">
                                    {{ $report->reported->name }}</div>
                                <div
                                    style="font-size:12px;color:var(--text-muted);margin-bottom:10px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">
                                    {{ $report->reported->email }}</div>
                                <div
                                    style="display:inline-flex;align-items:center;gap:5px;background:rgba(231,76,60,0.1);border:1px solid rgba(231,76,60,0.2);border-radius:6px;padding:4px 10px;font-size:11.5px;font-weight:600;color:#FF8080;">
                                    <svg width="10" height="10" viewBox="0 0 24 24" fill="currentColor">
                                        <path
                                            d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z" />
                                    </svg>
                                    {{ str_replace('_', ' ', ucwords($report->reason)) }}
                                </div>
                            </div>
                        </div>

                        <!-- Description -->
                        @if($report->description)
                            <div
                                style="margin-bottom:20px;padding:12px 16px;border-left:2px solid var(--border);border-radius:0 8px 8px 0;background:rgba(255,255,255,0.02);">
                                <div
                                    style="font-size:10.5px;letter-spacing:1.5px;text-transform:uppercase;color:var(--text-faint);margin-bottom:6px;">
                                    Description</div>
                                <p style="font-size:13px;color:var(--text-muted);line-height:1.6;font-style:italic;">
                                    "{{ $report->description }}"</p>
                            </div>
                        @else
                            <div
                                style="margin-bottom:20px;padding:10px 16px;border-left:2px solid var(--border-light);border-radius:0 8px 8px 0;">
                                <p style="font-size:13px;color:var(--text-faint);font-style:italic;">No description provided.</p>
                            </div>
                        @endif

                        <!-- Actions -->
                        <div style="display:flex;gap:10px;padding-top:16px;border-top:1px solid var(--border-light);">
                            <a href="/admin/users/{{ $report->reported_id }}" class="btn btn-ghost btn-sm"
                                style="flex:1;justify-content:center;text-decoration:none;">
                                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
                                    <circle cx="12" cy="12" r="3" />
                                </svg>
                                View Profile
                            </a>
                            <form action="/api/admin/reports/{{ $report->id }}/dismiss" method="POST" style="flex:1;">
                                @csrf
                                <button type="submit" class="btn btn-ghost btn-sm" style="width:100%;justify-content:center;">
                                    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                        stroke-width="2">
                                        <polyline points="20 6 9 17 4 12" />
                                    </svg>
                                    Dismiss
                                </button>
                            </form>
                            <button onclick="openBanModal({{ $report->id }}, '{{ addslashes($report->reported->name) }}')"
                                class="btn btn-danger btn-sm" style="flex:1;justify-content:center;">
                                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <circle cx="12" cy="12" r="10" />
                                    <line x1="4.93" y1="4.93" x2="19.07" y2="19.07" />
                                </svg>
                                Ban User
                            </button>
                        </div>
                    </div>
                </div>
            @endforeach
        </div>

        <div style="margin-top:32px;">
            {{ $reports->links() }}
        </div>
    @endif

@endsection

@push('modals')
    <!-- Ban Modal -->
    <div id="resolve-modal" class="modal-overlay">
        <div class="modal-box">
            <div style="display:flex;align-items:center;gap:14px;margin-bottom:6px;">
                <div
                    style="width:42px;height:42px;border-radius:12px;background:rgba(231,76,60,0.15);border:1px solid rgba(231,76,60,0.3);display:flex;align-items:center;justify-content:center;">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#FF6B6B" stroke-width="2">
                        <circle cx="12" cy="12" r="10" />
                        <line x1="4.93" y1="4.93" x2="19.07" y2="19.07" />
                    </svg>
                </div>
                <h3 class="modal-title">Ban User</h3>
            </div>
            <p class="modal-subtitle">
                Banning <strong id="target-user-name" style="color:#FF8080;"></strong> will resolve this report and all
                pending reports against them.
            </p>

            <form id="action-form" method="POST">
                @csrf
                <label class="form-label">Official Ban Reason</label>
                <textarea name="reason" required class="form-textarea"
                    placeholder="Describe the reason for this ban. This may be shown to the user."></textarea>

                <div style="display:flex;gap:12px;margin-top:24px;">
                    <button type="button" onclick="document.getElementById('resolve-modal').style.display='none'"
                        class="btn btn-ghost" style="flex:1;justify-content:center;">
                        Cancel
                    </button>
                    <button type="submit" class="btn btn-danger"
                        style="flex:1;justify-content:center;background:var(--danger);color:#fff;border-color:var(--danger);box-shadow:0 4px 20px rgba(231,76,60,0.4);">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                            stroke-width="2.5">
                            <circle cx="12" cy="12" r="10" />
                            <line x1="4.93" y1="4.93" x2="19.07" y2="19.07" />
                        </svg>
                        Apply Ban & Resolve
                    </button>
                </div>
            </form>
        </div>
    </div>
@endpush

@push('scripts')
    <script>
        function openBanModal(reportId, name) {
            document.getElementById('target-user-name').innerText = name;
            document.getElementById('action-form').action = '/api/admin/reports/' + reportId + '/action';
            document.getElementById('resolve-modal').style.display = 'flex';
        }
        document.getElementById('resolve-modal').addEventListener('click', function (e) {
            if (e.target === this) this.style.display = 'none';
        });
    </script>
@endpush