<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - FlutterMatch Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50 flex items-center justify-center min-h-screen">
    <div class="max-w-md w-full bg-white p-8 rounded-2xl shadow-xl border">
        <div class="text-center mb-8">
            <h1 class="text-3xl font-bold text-pink-500 mb-2">💘 FM Admin</h1>
            <p class="text-gray-500">Sign in to manage the system</p>
        </div>

        <form method="POST" action="/admin/login" class="space-y-6">
            @csrf
            <div>
                <label for="email" class="block text-sm font-medium text-gray-700 mb-1">Email Address</label>
                <input type="email" id="email" name="email" required 
                    class="block w-full px-4 py-3 rounded-xl border border-gray-300 focus:ring-2 focus:ring-pink-500 focus:outline-none transition">
                @error('email')
                    <span class="text-red-500 text-xs mt-1">{{ $message }}</span>
                @enderror
            </div>

            <div>
                <label for="password" class="block text-sm font-medium text-gray-700 mb-1">Password</label>
                <input type="password" id="password" name="password" required 
                    class="block w-full px-4 py-3 rounded-xl border border-gray-300 focus:ring-2 focus:ring-pink-500 focus:outline-none transition">
            </div>

            <div class="flex items-center">
                <input type="checkbox" id="remember" name="remember" class="h-4 w-4 text-pink-600 focus:ring-pink-500 border-gray-300 rounded">
                <label for="remember" class="ml-2 block text-sm text-gray-700">Remember me</label>
            </div>

            <button type="submit" 
                class="w-full bg-pink-500 text-white font-bold py-3 rounded-xl hover:bg-pink-600 focus:outline-none focus:ring-4 focus:ring-pink-200 transition">
                Sign In
            </button>
        </form>
    </div>
</body>
</html>
