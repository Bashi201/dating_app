<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Cloudinary\Cloudinary;
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function index(Request $request)
    {
        $users = User::with('profile')
            ->when(
                $request->search,
                fn($q) =>
                $q->where('name', 'like', "%{$request->search}%")
                    ->orWhere('email', 'like', "%{$request->search}%")
            )
            ->when($request->banned === 'true', fn($q) => $q->where('is_banned', true))
            ->when($request->banned === 'false', fn($q) => $q->where('is_banned', false))
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        if ($request->wantsJson()) {
            return response()->json($users);
        }

        return view('admin.users.index', compact('users'));
    }

    public function show(User $user)
    {
        $user->load(['profile', 'photos', 'reportsReceived.reporter']);

        if (request()->wantsJson()) {
            return response()->json([
                'user' => $user,
                'reports' => $user->reportsReceived,
            ]);
        }

        return view('admin.users.show', ['user' => $user, 'reports' => $user->reportsReceived]);
    }

    public function ban(Request $request, User $user)
    {
        $request->validate(['reason' => 'required|string|max:255']);

        $user->update([
            'is_banned' => true,
            'ban_reason' => $request->reason,
        ]);

        // Revoke all tokens immediately
        $user->tokens()->delete();

        return response()->json(['message' => "User {$user->name} banned."]);
    }

    public function unban(User $user)
    {
        $user->update(['is_banned' => false, 'ban_reason' => null]);

        return response()->json(['message' => "User {$user->name} unbanned."]);
    }

    public function destroy(User $user)
    {
        // Delete all Cloudinary photos first
        $cloudinary = new Cloudinary(env('CLOUDINARY_URL'));

        foreach ($user->photos as $photo) {
            try {
                $cloudinary->uploadApi()->destroy($photo->cloudinary_id);
            } catch (\Exception $e) {
                // Continue even if Cloudinary fails
            }
        }

        // Revoke tokens then delete user (cascades through DB)
        $user->tokens()->delete();
        $user->delete();

        return response()->json(['message' => 'User permanently deleted.']);
    }
}