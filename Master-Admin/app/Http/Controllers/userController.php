<?php

namespace App\Http\Controllers;

use App\Models\absensi_sholat;
use Illuminate\Http\Request;
use App\Models\User;

class userController extends Controller
{
    public function index(){
        return view('users',[
            "title" => "Pengguna",
            "user_aktif" => User::where('status',1)->count(),
            "pendaftar" => User::where('status',0)->count()
        ]);
    }
    public function listUser(){
        $data = User::all();
        $id_user = '';
        
        return view('userlist',compact('data'),[
            "title" => "Pengguna",
            "user" => User::latest()->filter()->where('status','like', 1)->paginate(20)->withQueryString(),
            "user_id"=> $id_user,
            "absen" => absensi_sholat::where('users_id', 'like', $id_user)->get()
        ]);
    }
    public function dashboard(){
        return view('home',[
            "title" => "Dashboard"
        ]);
    }
    public function validateUser(){
        return view('validateUsers',[
            "title"=>"Pengguna",
            "user" => User::latest()->filter()->where('status','like', 0)->paginate(10)->withQueryString()
        ]);
    }
}
