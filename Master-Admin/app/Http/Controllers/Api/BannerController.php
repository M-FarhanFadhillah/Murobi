<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class BannerController extends Controller
{
    public function banner(){
        $banner = \App\Models\banner::where('status', true)->get()
            ->map(fn ($item) => array_merge($item->toArray(), [
                'cover_url' => \App\Support\FileUrl::for($item->cover),
            ]));
        return response()->json($banner);

    }
}
