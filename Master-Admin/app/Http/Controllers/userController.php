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
        $User = User::latest()->where('status','like', 1);
        $data = User::all();
        $id_user = '';
        
        if(request('search')){
            $User->where('name','like', '%' . request('search') . '%');
        }
        return view('userlist',compact('data'),[
            "title" => "Pengguna",
            "user" => $User->get(),
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
        $User = User::latest()->where('status','like', 0);
        if(request('search')){
            $User->where('name','like', '%' . request('search') . '%');
        }
        return view('validateUsers',[
            "title"=>"Pengguna",
            "user" => $User->get()
        ]);
    }
}
