<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;

class userController extends Controller
{
    public function index(){
        return view('users',[
            "title" => "Pengguna"
        ]);
    }
    public function listUser(){
        $User = User::latest()->where('status','like', 1);
        $data = User::all();
        
        if(request('search')){
            $User->where('name','like', '%' . request('search') . '%');
        }
        return view('userlist',compact('data'),[
            "title" => "Pengguna",
            "user" => $User->get()
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
