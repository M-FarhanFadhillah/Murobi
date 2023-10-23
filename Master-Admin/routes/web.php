<?php

use App\Http\Controllers\ActivityController;
use App\Http\Controllers\userController;
use App\Http\Controllers\educationController;
use App\Http\Controllers\bannerController;
use App\Http\Controllers\masjidController;
use App\Http\Controllers\LapKeuController;
use App\Http\Controllers\AdminsController;
use App\Models\activity;
use App\Models\admins;
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
Route::get('/test', function () {
    return view('FRZiswafmasjid',[
        "title" => "Masjid",
    ]);
});

Route::get('/', [adminsController::class, 'index']);
Route::get('/home', [userController::class, 'dashboard']);
Route::get('/masjid', [masjidController::class, 'index']);
Route::get('/listmasjid', [masjidController::class, 'listMasjid']);
// Routes Register Masjid Baru
Route::post('/listmasjid', [masjidController::class, 'store']);
Route::get('/users', [userController::class, 'index']);
Route::get('/listUser', [userController::class, 'listUser']);
// Routes Register Jamaah Baru
Route::post('/listUser', [userController::class, 'store']);
Route::get('/validateRegist', [userController::class, 'validateUser']);
Route::get('/banner', [bannerController::class, 'index']);
// Routes Register banner Baru
Route::post('/banner', [bannerController::class, 'store']);
Route::get('/edu', [educationController::class, 'index']);
// Routes Register Content Education Baru
Route::post('/edu', [educationController::class, 'store']);
Route::get('/financereport', [LapKeuController::class, 'index']);
Route::get('/lapkeu/{id}/{masjid_name}', [LapKeuController::class, 'lapkeu']);
Route::post('/lapkeu/{id}', [LapKeuController::class, 'store']);
Route::get('/ziswaf/{id}/{masjid_name}', [LapKeuController::class, 'ziswaf']);
// Route::get('/ziswaf', [LapKeuController::class, 'ziswaf']);
Route::get('/activity', [activityController::class, 'index']);
Route::get('/activity/{id}/{masjid_name}', [activityController::class, 'listActivity']);
Route::post('/activity/{id}', [activityController::class, 'store']);
// Route::get('/activitylist', [activityController::class, 'listActivity']);

