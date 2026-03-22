<?php

namespace App\Http\Controllers;

use App\Events\MessageSent;
use App\Http\Resources\MessageResource;
use App\Models\Match as UserMatch;
use Illuminate\Http\Request;

class MessageController extends Controller
{
    public function index(Request $request, UserMatch $match)
    {
        if (!$match->involvesUser($request->user()->id)) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        // Mark messages from the other person as read
        $match->messages()
              ->where('sender_id', '!=', $request->user()->id)
              ->where('is_read', false)
              ->update(['is_read' => true, 'read_at' => now()]);

        $messages = $match->messages()
                          ->orderBy('created_at', 'asc')
                          ->get();

        return response()->json([
            'messages' => MessageResource::collection($messages),
        ]);
    }

    public function store(Request $request, UserMatch $match)
    {
        if (!$match->involvesUser($request->user()->id)) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $request->validate(['body' => 'required|string|max:1000']);

        $message = $match->messages()->create([
            'sender_id' => $request->user()->id,
            'body'      => $request->body,
            'is_read'   => false,
        ]);

        // Broadcast to the private channel
        broadcast(new MessageSent($message));

        return response()->json([
            'message' => new MessageResource($message),
        ], 201);
    }

    public function markRead(Request $request, UserMatch $match)
    {
        if (!$match->involvesUser($request->user()->id)) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $match->messages()
              ->where('sender_id', '!=', $request->user()->id)
              ->where('is_read', false)
              ->update(['is_read' => true, 'read_at' => now()]);

        return response()->json(['message' => 'Marked as read']);
    }
}