@extends('admin.layout')

@section('content')
<div class="flex justify-between items-center mb-6">
    <h2 class="text-2xl font-bold text-gray-800">User Management</h2>
    <form action="{{ route('admin.users.index') }}" method="GET" class="flex gap-2">
        <input type="text" name="search" placeholder="Search name/email..." value="{{ request('search') }}" 
            class="px-4 py-2 border rounded-lg focus:ring-2 focus:ring-pink-500 outline-none">
        <select name="banned" onchange="this.form.submit()" class="px-4 py-2 border rounded-lg outline-none">
            <option value="">All Users</option>
            <option value="true" {{ request('banned') == 'true' ? 'selected' : '' }}>Banned</option>
            <option value="false" {{ request('banned') == 'false' ? 'selected' : '' }}>Active</option>
        </select>
        <button type="submit" class="bg-pink-500 text-white px-4 py-2 rounded-lg hover:bg-pink-600">Search</button>
    </form>
</div>

<div class="bg-white rounded-xl shadow overflow-hidden">
    <table class="w-full text-left border-collapse">
        <thead>
            <tr class="bg-gray-50 border-b">
                <th class="px-6 py-4 text-sm font-semibold text-gray-600">User</th>
                <th class="px-6 py-4 text-sm font-semibold text-gray-600">Status</th>
                <th class="px-6 py-4 text-sm font-semibold text-gray-600">Joined</th>
                <th class="px-6 py-4 text-sm font-semibold text-gray-600">Actions</th>
            </tr>
        </thead>
        <tbody>
            @foreach($users as $user)
            <tr class="border-b hover:bg-gray-50 transition">
                <td class="px-6 py-4">
                    <div class="flex items-center gap-3">
                        <div class="w-10 h-10 rounded-full bg-pink-100 flex items-center justify-center text-pink-500 font-bold">
                            {{ substr($user->name, 0, 1) }}
                        </div>
                        <div>
                            <div class="font-medium text-gray-800">{{ $user->name }}</div>
                            <div class="text-xs text-gray-500">{{ $user->email }}</div>
                        </div>
                    </div>
                </td>
                <td class="px-6 py-4">
                    @if($user->is_banned)
                    <span class="px-2 py-1 text-xs font-semibold bg-red-100 text-red-600 rounded-full">Banned</span>
                    @else
                    <span class="px-2 py-1 text-xs font-semibold bg-green-100 text-green-600 rounded-full">Active</span>
                    @endif
                </td>
                <td class="px-6 py-4 text-sm text-gray-600">
                    {{ $user->created_at->format('M d, Y') }}
                </td>
                <td class="px-6 py-4">
                    <div class="flex gap-2">
                        <a href="{{ route('admin.users.index') }}/{{ $user->id }}" class="text-blue-500 hover:underline text-sm font-medium">View Detail</a>
                    </div>
                </td>
            </tr>
            @endforeach
        </tbody>
    </table>
    <div class="p-4">
        {{ $users->links() }}
    </div>
</div>
@endsection
