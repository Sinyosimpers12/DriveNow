<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Kreait\Firebase\Factory;
use Illuminate\Support\Facades\Http;
use GuzzleHttp\Client;




class FirebaseController extends Controller
{
    protected $database;

    public function __construct()
    {
        // Inisialisasi koneksi ke Firebase (hanya untuk menggunakan Firebase SDK)
        $this->database = (new Factory)
            ->withServiceAccount(storage_path('firebase_credentials.json'))  // Lokasi file kredensial
            ->withDatabaseUri('https://pa-test-da05d-default-rtdb.asia-southeast1.firebasedatabase.app/') 
            ->createDatabase();

        $this->firebaseUrl = env('https://pa-test-da05d-default-rtdb.asia-southeast1.firebasedatabase.app/kendaraan');
    }

    // Ambil data kendaraan dan hitung jumlahnya
    public function getKendaraan()
    {
        // Ambil data kendaraan dari Firebase
        $kendaraan = $this->database->getReference('Kendaraan')->getValue();

        // Hitung jumlah kendaraan
        $jumlahKendaraan = count($kendaraan); // Menghitung jumlah item dalam array

        // Kirim data kendaraan dan jumlah kendaraan ke tampilan
        return view('kendaraan', compact('kendaraan', 'jumlahKendaraan'));
    }


    public function getKendaraanTersedia()
{
    // Ambil data kendaraan dari Firebase
    $kendaraan = $this->database->getReference('Kendaraan')->getValue();

    // Filter kendaraan dengan status 'Tersedia'
    $kendaraanTersedia = array_filter($kendaraan, function ($kendaraan) {
        return isset($kendaraan['status']) && $kendaraan['status'] === 'Tersedia';
    });

    // Hitung jumlah kendaraan dengan status 'Tersedia'
    $jumlahKendaraanTersedia = count($kendaraanTersedia);

    // Kirim data kendaraan yang tersedia dan jumlahnya ke tampilan
    return view('kendaraan', [
        'kendaraanTersedia' => $kendaraanTersedia,
        'jumlahKendaraanTersedia' => $jumlahKendaraanTersedia
    ]);
}

// Method to save new vehicle data to Firebase
public function saveKendaraan(Request $request)
{
    $data = [
        'name' => $request->input('name'),
        'brand' => $request->input('brand'),
        'category' => $request->input('category'),
        'cc' => $request->input('cc'),
        'model' => $request->input('model'),
        'price' => $request->input('price'),
        'price2' => $request->input('price2'),
        'status' => 'Tersedia',
        'image_url' => $request->input('image')
    ];

    // Push new vehicle data to Firebase
    $this->database->getReference('Kendaraan')->push($data);

    // Redirect with success message
    return redirect()->route('kendaraan.index')->with('success', 'Data berhasil disimpan!');
}



// Method untuk menampilkan dashboard
public function dashboard()
{
    // Ambil data kendaraan dari Firebase
    $kendaraan = $this->database->getReference('Kendaraan')->getValue();

    // Hitung jumlah kendaraan
    $jumlahKendaraan = count($kendaraan);

    // Filter kendaraan dengan status 'Tersedia'
    $kendaraanTersedia = array_filter($kendaraan, function ($kendaraan) {
        return isset($kendaraan['status']) && $kendaraan['status'] === 'Tersedia';
    });

    // Hitung jumlah kendaraan dengan status 'Tersedia'
    $jumlahKendaraanTersedia = count($kendaraanTersedia);

    // Kirim data kendaraan dan jumlahnya ke tampilan
   

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
    
    return view('dashboard', [
        'kendaraan' => $kendaraan,
        'jumlahKendaraan' => $jumlahKendaraan,
        'jumlahKendaraanTersedia' => $jumlahKendaraanTersedia,
        'waitingConfirmationCount' => $waitingConfirmationCount,
        'totalCompletedPrice' => $totalCompletedPrice
    ]);
    

}

    public function delete($key)
    {
        $firebaseUrl = "https://pa-test-da05d-default-rtdb.asia-southeast1.firebasedatabase.app/Kendaraan/$key.json";

        $client = new Client();
        $response = $client->delete($firebaseUrl);

        if ($response->getStatusCode() == 200) {
            return redirect()->route('kendaraan.index')->with('success', 'Data berhasil dihapus!');
        } else {
            return redirect()->route('kendaraan.index')->with('failed', 'Data Gagal dihapus!');
        }
    }
    

    public function edit(Request $request, $key)
    {
        // Ambil data dari form dan hapus _token dan _method
        $data = $request->except('_token', '_method');

        // Ambil status dari radio button, jika tidak ada, defaultkan ke 'Tersedia'
        $data['status'] = $request->input('status', 'Tersedia');

        // Membuat instance Guzzle HTTP client
        $client = new Client();

        // URL Firebase untuk memperbarui data
        $firebaseUrl = "https://pa-test-da05d-default-rtdb.asia-southeast1.firebasedatabase.app/Kendaraan/{$key}.json";

        try {
            // Kirim permintaan PUT ke Firebase
            $response = $client->put($firebaseUrl, [
                'json' => $data
            ]);

            // Cek apakah permintaan berhasil
            if ($response->getStatusCode() == 200) {
                return redirect()->route('kendaraan.index')->with('success', 'Kendaraan berhasil diperbarui.');
            } else {
                return redirect()->route('kendaraan.index')->with('error', 'Gagal memperbarui kendaraan.');
            }
        } catch (\Exception $e) {
            // Jika terjadi error
            return redirect()->route('kendaraan.index')->with('error', 'Terjadi kesalahan: ' . $e->getMessage());
        }
    }

    

    
}
