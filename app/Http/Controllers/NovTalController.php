<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\Http;

class NovTalController extends Controller
{
    public function hitung()
    {
        // URL API Firebase
        $apiUrl = "https://pa-test-da05d-default-rtdb.asia-southeast1.firebasedatabase.app/pesanan.json";

        // Ambil data dari API Firebase
        $response = Http::get($apiUrl);
        $data = $response->json();

        // Inisialisasi variabel
        $waitingConfirmationCount = 0;
        $totalCompletedPrice = 0;

        // Iterasi data untuk menghitung jumlah dan total
        if ($data) {
            foreach ($data as $pesanan) {
                if (isset($pesanan['statusPemesanan'])) {
                    if ($pesanan['statusPemesanan'] === 'Menunggu Konfirmasi') {
                        $waitingConfirmationCount++;
                    }

                    if ($pesanan['statusPemesanan'] === 'Selesai' && isset($pesanan['totalHarga'])) {
                        $totalCompletedPrice += $pesanan['totalHarga'];
                    }
                }
            }
        }

        // Kirim data ke view
        return view('dashboard', compact('waitingConfirmationCount', 'totalCompletedPrice'));
    }
}
