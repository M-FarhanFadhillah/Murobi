<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class MasjidController extends Controller
{
    public function index(){
        return response()->json($this->withUrls(\App\Models\masjid::get()));
    }
    public function masjid($id){
        return response()->json($this->withUrls(\App\Models\masjid::where('id',$id)->get()));
    }

    // Menambahkan masjid_pict_url (alamat foto) tanpa mengubah field yang sudah ada.
    private function withUrls($items)
    {
        return $items->map(fn ($item) => array_merge($item->toArray(), [
            'masjid_pict_url' => \App\Support\FileUrl::for($item->masjid_pict),
        ]));
    }
}
