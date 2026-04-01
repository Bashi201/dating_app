<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FlutterMatch Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>

<body class="bg-gray-100 font-sans">
    <div class="flex min-h-screen">
        <!-- Sidebar -->
        <aside class="w-64 bg-white shadow-md">
            <div class="p-6 border-b">
                <h1 class="text-xl font-bold text-pink-500">💘 FM Admin</h1>
            </div>
            <nav class="p-4 flex flex-col h-[calc(100vh-100px)]">
                <div class="space-y-1 flex-1">
                    <a href="{{ route('admin.users.index') }}"
                        class="flex items-center gap-3 px-4 py-2 rounded-lg text-gray-700 hover:bg-pink-50 hover:text-pink-600 appearance-none">
                        👥 Users
                    </a>
                    <a href="{{ route('admin.reports.index') }}"
                        class="flex items-center gap-3 px-4 py-2 rounded-lg text-gray-700 hover:bg-pink-50 hover:text-pink-600 appearance-none">
                        🚨 Reports
                    </a>
                </div>

                <div class="pt-4 border-t">
                    <form action="{{ route('admin.logout') }}" method="POST">
                        @csrf
                        <button type="submit" 
                            class="flex w-full items-center gap-3 px-4 py-2 rounded-lg text-red-600 hover:bg-red-50 transition">
                            Logout
                        </button>
                    </form>
                </div>
            </nav>
        </aside>

        <!-- Content -->
        <main class="flex-1 p-8">
            @yield('content')
        </main>
    </div>
</body>

</html>