<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Resources\ReportResource;
use App\Models\Report;
use App\Models\User;
use Illuminate\Http\Request;

class ReportController extends Controller
{
    public function index(Request $request)
    {
        $reports = Report::with([
            'reporter:id,name,email',
            'reported:id,name,email',
            'reported.photos',
        ])
            ->where('status', 'pending')
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        if ($request->wantsJson()) {
            return response()->json([
                'reports' => ReportResource::collection($reports->items()),
                'meta' => [
                    'total' => $reports->total(),
                    'current_page' => $reports->currentPage(),
                    'last_page' => $reports->lastPage(),
                ],
            ]);
        }

        return view('admin.reports.index', compact('reports'));
    }

    public function dismiss(Request $request, Report $report)
    {
        $report->update([
            'status' => 'dismissed',
            'reviewed_by' => $request->user()->id,
            'reviewed_at' => now(),
        ]);

        return response()->json(['message' => 'Report dismissed.']);
    }

    public function action(Request $request, Report $report)
    {
        $request->validate(['reason' => 'required|string|max:255']);

        // Ban the reported user
        $reported = User::find($report->reported_id);
        $reported->update([
            'is_banned' => true,
            'ban_reason' => $request->reason,
        ]);
        $reported->tokens()->delete();

        // Mark report as reviewed
        $report->update([
            'status' => 'reviewed',
            'reviewed_by' => $request->user()->id,
            'reviewed_at' => now(),
        ]);

        // Also dismiss all other pending reports against this user
        Report::where('reported_id', $reported->id)
            ->where('status', 'pending')
            ->update(['status' => 'reviewed', 'reviewed_at' => now()]);

        return response()->json(['message' => "User banned and report resolved."]);
    }
}