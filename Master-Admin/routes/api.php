<?php

use App\Http\Controllers\Api\ActivityController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BannerController;
use App\Http\Controllers\Api\EducationController;
use App\Http\Controllers\Api\FileController;
use App\Http\Controllers\Api\LapkeuController;
use App\Http\Controllers\Api\MasjidController;
use App\Http\Controllers\Api\ReportController;
use App\Http\Controllers\Api\userController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/
Route::get('/lapkeu/{id}', [LapkeuController::class, 'lapkeu']); //id masjid
Route::get('/banner', [BannerController::class, 'banner']); 
Route::get('/edu/book', [EducationController::class, 'book']);
Route::get('/edu/video', [EducationController::class, 'video']);
Route::get('/masjid', [MasjidController::class, 'index']);
Route::get('/masjid/{id}', [MasjidController::class, 'masjid']);
Route::get('/user/{id}', [userController::class, 'user']);

// ---- Ditambahkan untuk aplikasi mobile (lihat docs/API.md) ----
Route::get('/activity', [ActivityController::class, 'index']);
Route::get('/files/{path}', [FileController::class, 'show'])->where('path', '.*');

Route::post('/register', [AuthController::class, 'register'])->middleware('throttle:10,1');
Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:10,1');
Route::post('/auth/google', [AuthController::class, 'google'])->middleware('throttle:10,1');

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);
    Route::patch('/me', [AuthController::class, 'updateMe']);
    Route::post('/me/photo', [AuthController::class, 'updatePhoto']);
    Route::post('/me/password', [AuthController::class, 'changePassword']);

    // Laporan masalah: jamaah mengirim dan melihat laporannya sendiri.
    Route::post('/reports', [ReportController::class, 'store'])->middleware('throttle:20,1');
    Route::get('/reports/mine', [ReportController::class, 'mine']);

    // Kelola konten dari aplikasi: hanya admin. Pembaruan memakai POST (multipart)
    // karena PHP tidak membaca berkas pada PATCH/PUT.
    Route::middleware('admin')->group(function () {
        Route::post('/activity', [ActivityController::class, 'store']);
        Route::post('/activity/{id}', [ActivityController::class, 'update'])->whereNumber('id');
        Route::delete('/activity/{id}', [ActivityController::class, 'destroy'])->whereNumber('id');

        Route::post('/edu', [EducationController::class, 'store']);
        Route::post('/edu/{id}', [EducationController::class, 'update'])->whereNumber('id');
        Route::delete('/edu/{id}', [EducationController::class, 'destroy'])->whereNumber('id');

        // Laporan masalah dari semua jamaah.
        Route::get('/reports', [ReportController::class, 'index']);
        Route::patch('/reports/{id}', [ReportController::class, 'update'])->whereNumber('id');
        Route::delete('/reports/{id}', [ReportController::class, 'destroy'])->whereNumber('id');
    });
});
