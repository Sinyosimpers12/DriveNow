<?php

use App\Http\Controllers\ProfileController;
use App\Http\Controllers\FirebaseController;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Http;
use Illuminate\Http\Request;
use App\Http\Controllers\PembayaranController;
use App\Http\Controllers\PesananController;
use App\Http\Controllers\NovTalController;


Route::get('/', function () {
    return view('welcome');
});

Route::get('/dashboard', function () {
    return view('dashboard');
})->middleware(['auth', 'verified'])->name('dashboard');

Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
});
// Jalur 
Route::post('/kendaraan', [FirebaseController::class, 'saveKendaraan'])->name('kendaraan.save');
Route::post('/kendaraan/save', [FirebaseController::class, 'saveKendaraan'])->name('kendaraan.save');


Route::post('/kendaraan', [FirebaseController::class, 'uploadImage'])->name('kendaraan.uploadImage');
Route::get('/kendaraan', [FirebaseController::class, 'getKendaraan'])->name('kendaraan.index');

Route::delete('/kendaraan/{key}', [FirebaseController::class, 'delete'])->name('kendaraan.delete');
Route::put('/kendaraan/{key}', [FirebaseController::class, 'edit'])->name('kendaraan.update');

Route::get('/pembayaran', [PembayaranController::class, 'edit'])->name('pembayaran.edit');
Route::patch('/pembayaran', [PembayaranController::class, 'update'])->name('pembayaran.update');

Route::get('/pesanan', [PesananController::class, 'index'])->name('pesanan.index');


Route::get('/cards', function () {
    return view('cards'); // Ganti 'cards' dengan nama file blade Anda
})->name('cards');

// Utilities
Route::get('/utilities/color', function () {
    return view('utilities.color'); // Ganti 'utilities.color' dengan struktur folder Anda
})->name('utilities.color');

Route::get('/utilities/border', function () {
    return view('utilities.border');
})->name('utilities.border');

Route::get('/utilities/animation', function () {
    return view('utilities.animation');
})->name('utilities.animation');

Route::get('/utilities/other', function () {
    return view('utilities.other');
})->name('utilities.other');

// Pages
Route::get('/login', function () {
    return view('auth.login');
})->name('login');

Route::get('/register', function () {
    return view('auth.register');
})->name('register');

Route::get('/forgot-password', function () {
    return view('auth.forgot-password');
})->name('forgot-password');

Route::get('/404', function () {
    return view('errors.404');
})->name('404');

Route::get('/blank', function () {
    return view('blank');
})->name('blank');

// Charts
Route::get('/charts', function () {
    return view('charts');
})->name('charts');

// Tables
Route::get('/tables', function () {
    return view('tables');
})->name('tables');



//api

Route::get('/dashboard', [FirebaseController::class, 'dashboard'])->name('dashboard');


require __DIR__.'/auth.php';
