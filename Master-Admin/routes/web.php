<?php

use App\Http\Controllers\ActivityController;
use App\Http\Controllers\userController;
use App\Http\Controllers\educationController;
use App\Http\Controllers\bannerController;
use App\Http\Controllers\masjidController;
use App\Http\Controllers\LapKeuController;
use App\Models\activity;
use App\Models\banner;
use App\Models\masjid;
use App\Models\User;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/


Route::get('/', function () {
    return view('login',[
        "title" => "Login",
    ]);
});

Route::get('/home', [userController::class, 'dashboard']);
Route::get('/masjid', [masjidController::class, 'index']);
Route::get('/listmasjid', [masjidController::class, 'listMasjid']);
Route::get('/users', [userController::class, 'index']);
Route::get('/listUser', [userController::class, 'listUser']);
Route::get('/listUser/{id}', [userController::class, 'userSpesific']);
Route::get('/validateRegist', [userController::class, 'validateUser']);
Route::get('/banner', [bannerController::class, 'index']);
Route::get('/edu', [educationController::class, 'index']);
Route::get('/financereport', [LapKeuController::class, 'index']);
Route::get('/lapkeu', [LapKeuController::class, 'lapkeu']);
Route::get('/ziswaf', [LapKeuController::class, 'ziswaf']);
Route::get('/activity', [activityController::class, 'index']);
Route::get('/activitylist', [activityController::class, 'listActivity']);

