@extends('admin.layout')

@section('content')
<div class="flex justify-between items-center mb-6">
    <h2 class="text-2xl font-bold text-gray-800">Pending Safety Reports</h2>
    <span class="bg-gray-200 text-gray-700 px-3 py-1 rounded-full text-sm font-bold">{{ $reports->total() }} Remaining</span>
</div>

@if($reports->isEmpty())
<div class="bg-white p-12 rounded-2xl shadow text-center">
    <div class="text-5xl mb-4">🎉</div>
    <h3 class="text-xl font-bold text-gray-800">All Clear!</h3>
    <p class="text-gray-500">There are no pending reports to review right now.</p>
</div>
@else
<div class="grid grid-cols-2 gap-6">
    @foreach($reports as $report)
    <div class="bg-white p-6 rounded-xl shadow-sm border-l-4 border-orange-400 hover:shadow-md transition">
        <div class="flex justify-between items-start mb-4">
            <div>
                <span class="text-[10px] font-bold uppercase tracking-widest text-orange-500 bg-orange-50 px-2 py-0.5 rounded">Pending Review</span>
                <div class="text-gray-400 text-[11px] mt-1">{{ $report->created_at->format('M d, Y - H:i') }}</div>
            </div>
            <div class="flex -space-x-3">
                <div class="w-8 h-8 rounded-full bg-blue-100 border-2 border-white flex items-center justify-center text-xs font-bold text-blue-600" title="Reporter: {{ $report->reporter->name }}">
                    {{ substr($report->reporter->name, 0, 1) }}
                </div>
                <div class="w-8 h-8 rounded-full bg-red-100 border-2 border-white flex items-center justify-center text-xs font-bold text-red-600" title="Reported: {{ $report->reported->name }}">
                    {{ substr($report->reported->name, 0, 1) }}
                </div>
            </div>
        </div>

        <div class="flex gap-4 mb-4">
            <div class="flex-shrink-0">
                @php $photo = $report->reported->photos->firstWhere('is_primary', true) ?? $report->reported->photos->first(); @endphp
                <img src="{{ $photo?->url ?? 'https://via.placeholder.com/80' }}" class="w-20 h-20 rounded-lg object-cover">
            </div>
            <div class="flex-1">
                <div class="text-sm text-gray-500">Reported User</div>
                <div class="font-bold text-gray-800">{{ $report->reported->name }}</div>
                <div class="text-xs text-gray-400">{{ $report->reported->email }}</div>
                <div class="mt-2 bg-gray-50 p-2 rounded text-sm font-medium text-red-700">
                    Reason: {{ str_replace('_', ' ', ucwords($report->reason)) }}
                </div>
            </div>
        </div>

        <div class="mb-6">
            <div class="text-sm text-gray-400 mb-1">Description</div>
            <p class="text-sm text-gray-700 italic border-l-2 pl-3 border-gray-100">
                "{{ $report->description ?: 'No detail provided' }}"
            </p>
        </div>

        <div class="flex gap-3 mt-auto pt-4 border-t">
            <a href="/admin/users/{{ $report->reported_id }}" class="flex-1 px-4 py-2 border rounded-lg text-center text-sm font-bold hover:bg-gray-50 transition">View Profile</a>
            <form action="/api/admin/reports/{{ $report->id }}/dismiss" method="POST" class="flex-1">
                @csrf
                <button type="submit" class="w-full px-4 py-2 bg-gray-100 text-gray-700 rounded-lg text-sm font-bold hover:bg-gray-200 transition">Dismiss</button>
            </form>
            <button onclick="openBanModal({{ $report->id }}, '{{ $report->reported->name }}')" class="flex-1 px-4 py-2 bg-red-500 text-white rounded-lg text-sm font-bold hover:bg-red-600 transition shadow-sm">Ban User</button>
        </div>
    </div>
    @endforeach
</div>
<div class="mt-8">
    {{ $reports->links() }}
</div>
@endif

<!-- Resolve Modal -->
<div id="resolve-modal" class="fixed inset-0 bg-black/60 items-center justify-center z-50 hidden">
    <div class="bg-white p-8 rounded-2xl w-[450px] shadow-2xl">
        <h3 class="text-xl font-bold mb-2">Resolve Report & Ban User</h3>
        <p class="text-sm text-gray-500 mb-6">Banning <span id="target-user-name" class="font-bold text-red-600"></span> will resolve this report and all other pending reports against them.</p>
        
        <form id="action-form" method="POST">
            @csrf
            <label class="block text-sm text-gray-500 mb-2">Official Ban Reason</label>
            <textarea name="reason" required class="w-full border rounded-xl p-3 h-32 focus:ring-2 focus:ring-red-500 outline-none mb-6"></textarea>
            
            <div class="flex gap-3">
                <button type="button" onclick="document.getElementById('resolve-modal').style.display='none'" class="flex-1 px-4 py-3 border rounded-xl hover:bg-gray-50 transition">Cancel</button>
                <button type="submit" class="flex-1 px-4 py-3 bg-red-600 text-white rounded-xl hover:bg-red-700 font-bold shadow-lg transition">Apply Ban & Resolve</button>
            </div>
        </form>
    </div>
</div>

<script>
    function openBanModal(reportId, name) {
        document.getElementById('target-user-name').innerText = name;
        document.getElementById('action-form').action = '/api/admin/reports/' + reportId + '/action';
        document.getElementById('resolve-modal').style.display = 'flex';
    }
</script>
@endsection
