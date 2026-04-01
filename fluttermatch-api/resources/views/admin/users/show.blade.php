@extends('admin.layout')

@section('content')
<div class="mb-6 flex items-center gap-4">
    <a href="{{ route('admin.users.index') }}" class="text-gray-500 hover:text-pink-500">← Back to Users</a>
    <h2 class="text-2xl font-bold text-gray-800">User Detail: {{ $user->name }}</h2>
</div>

<div class="grid grid-cols-3 gap-6">
    <!-- Profile Card -->
    <div class="col-span-1 space-y-6">
        <div class="bg-white p-6 rounded-xl shadow">
            <div class="flex flex-col items-center mb-6">
                @php $primary = $user->photos->firstWhere('is_primary', true); @endphp
                <img src="{{ $primary?->url ?? 'https://via.placeholder.com/150' }}" class="w-32 h-32 rounded-full object-cover border-4 border-pink-50 mb-4">
                <h3 class="text-xl font-bold">{{ $user->name }}</h3>
                <p class="text-gray-500">{{ $user->email }}</p>
                <div class="mt-4">
                    @if($user->is_banned)
                    <form action="{{ route('admin.users.index') }}/{{ $user->id }}/unban" method="POST">
                        @csrf
                        <button type="submit" class="bg-green-500 text-white px-6 py-2 rounded-lg hover:bg-green-600 w-full transition">Unban User</button>
                    </form>
                    @else
                    <button onclick="document.getElementById('ban-modal').style.display='flex'" class="bg-red-500 text-white px-6 py-2 rounded-lg hover:bg-red-600 w-full transition">Ban User</button>
                    @endif
                </div>
            </div>

            <div class="space-y-4 border-t pt-4">
                <div>
                    <span class="text-sm text-gray-400 block">Age</span>
                    <span class="font-medium">{{ $user->profile->age ?? 'N/A' }}</span>
                </div>
                <div>
                    <span class="text-sm text-gray-400 block">Gender</span>
                    <span class="font-medium capitalize">{{ $user->profile->gender ?? 'N/A' }}</span>
                </div>
                <div>
                    <span class="text-sm text-gray-400 block">Bio</span>
                    <p class="text-sm text-gray-700 leading-relaxed">{{ $user->profile->bio ?? 'No bio provided' }}</p>
                </div>
            </div>
        </div>

        <div class="bg-red-50 p-6 rounded-xl border border-red-100">
            <h4 class="text-red-700 font-bold mb-2">Danger Zone</h4>
            <p class="text-xs text-red-600 mb-4">Permanently deleting a user will remove all their photos, matches, and messages. This cannot be undone.</p>
            <form action="{{ route('admin.users.index') }}/{{ $user->id }}" method="POST" onsubmit="return confirm('REALLY delete this user forever?')">
                @csrf
                @method('DELETE')
                <button type="submit" class="text-red-700 border border-red-200 bg-white px-4 py-2 rounded-lg hover:bg-red-700 hover:text-white transition w-full text-sm font-bold">Delete User Permanently</button>
            </form>
        </div>
    </div>

    <!-- Reports & Activity -->
    <div class="col-span-2 space-y-6">
        <div class="bg-white p-6 rounded-xl shadow">
            <h3 class="text-lg font-bold mb-4 flex items-center gap-2">
                🚨 Reports Against This User
                <span class="bg-red-100 text-red-600 px-2 py-0.5 rounded text-sm">{{ $reports->count() }}</span>
            </h3>
            @if($reports->isEmpty())
            <p class="text-gray-400 text-sm italic">No reports found for this user.</p>
            @else
            <div class="space-y-4">
                @foreach($reports as $report)
                <div class="p-4 border rounded-lg {{ $report->status == 'pending' ? 'bg-orange-50 border-orange-100' : 'bg-gray-50' }}">
                    <div class="flex justify-between items-start mb-2">
                        <span class="text-xs font-bold uppercase tracking-wider text-gray-400">Reported by {{ $report->reporter->name }}</span>
                        <span class="text-xs text-gray-400">{{ $report->created_at->diffForHumans() }}</span>
                    </div>
                    <div class="font-bold text-gray-800 mb-1">Reason: {{ str_replace('_', ' ', ucwords($report->reason)) }}</div>
                    <p class="text-sm text-gray-600 mb-3">{{ $report->description ?: 'No additional details.' }}</p>
                    
                    @if($report->status == 'pending')
                    <div class="flex gap-2">
                        <form action="/api/admin/reports/{{ $report->id }}/dismiss" method="POST">
                            @csrf
                            <button type="submit" class="text-xs bg-white border px-3 py-1 rounded hover:bg-gray-100 transition">Dismiss</button>
                        </form>
                    </div>
                    @else
                    <span class="text-xs italic text-gray-400">Resolved at {{ $report->reviewed_at->format('M d, H:i') }}</span>
                    @endif
                </div>
                @endforeach
            </div>
            @endif
        </div>

        <div class="bg-white p-6 rounded-xl shadow">
            <h3 class="text-lg font-bold mb-4">📸 Photos</h3>
            <div class="grid grid-cols-4 gap-4">
                @foreach($user->photos as $photo)
                <div class="relative group">
                    <img src="{{ $photo->url }}" class="aspect-square w-full rounded-lg object-cover">
                    <div class="absolute inset-0 bg-black/50 opacity-0 group-hover:opacity-100 transition flex items-center justify-center rounded-lg">
                        <form action="/api/admin/photos/{{ $photo->id }}" method="POST" onsubmit="return confirm('Delete this photo?')">
                            @csrf
                            @method('DELETE')
                            <button type="submit" class="bg-red-500 text-white p-2 rounded-full hover:bg-red-600">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                                    <path fill-rule="evenodd" d="M9 2a1 1 0 00-.894.553L7.382 4H4a1 1 0 000 2v10a2 2 0 002 2h8a2 2 0 002-2V6a1 1 0 100-2h-3.382l-.724-1.447A1 1 0 0011 2H9zM7 8a1 1 0 012 0v6a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v6a1 1 0 102 0V8a1 1 0 00-1-1z" clip-rule="evenodd" />
                                </svg>
                            </button>
                        </form>
                    </div>
                    @if($photo->is_primary)
                    <span class="absolute top-2 left-2 bg-pink-500 text-white text-[10px] px-2 py-0.5 rounded shadow-sm font-bold uppercase">Primary</span>
                    @endif
                </div>
                @endforeach
            </div>
        </div>
    </div>
</div>

<!-- Ban Modal -->
<div id="ban-modal" class="fixed inset-0 bg-black/60 items-center justify-center z-50 hidden">
    <div class="bg-white p-8 rounded-2xl w-[400px] shadow-2xl">
        <h3 class="text-xl font-bold mb-4">Ban {{ $user->name }}</h3>
        <form action="{{ route('admin.users.index') }}/{{ $user->id }}/ban" method="POST">
            @csrf
            <label class="block text-sm text-gray-500 mb-2">Reason for ban (will be shown to user)</label>
            <textarea name="reason" required class="w-full border rounded-xl p-3 h-32 focus:ring-2 focus:ring-red-500 outline-none mb-6"></textarea>
            <div class="flex gap-3">
                <button type="button" onclick="document.getElementById('ban-modal').style.display='none'" class="flex-1 px-4 py-3 border rounded-xl hover:bg-gray-50">Cancel</button>
                <button type="submit" class="flex-1 px-4 py-3 bg-red-500 text-white rounded-xl hover:bg-red-600 font-bold">Ban User</button>
            </div>
        </form>
    </div>
</div>
@endsection
