<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">

    <title>{{ config('app.name', 'DriveNow') }}</title>
    <link href="{{asset('vendor/fontawesome-free/css/all.min.css')}}" rel="stylesheet" type="text/css">
    <link href="https://fonts.googleapis.com/css?family=Nunito:200,200i,300,300i,400,400i,600,600i,700,700i,800,800i,900,900i"
          rel="stylesheet">
    <link href="{{asset('css/sb-admin-2.min.css')}}" rel="stylesheet">
</head>
<body class="font-sans antialiased">

<div id="wrapper">
    @include('layouts.partial.sidebar')

    <div id="content-wrapper" class="d-flex flex-column">
        @include('layouts.partial.navbar')

        <!-- Begin Page Content -->
        <div class="container-fluid">
            <!-- Page Heading -->
            <h1 class="h3 mb-2 text-gray-800">Data Pesanan</h1>
            <p class="mb-4">Data pesanan yang diambil dari Firebase.</p>

            <!-- Tabel Pesanan Masuk -->
            <div class="card shadow mb-4">
                <div class="card-header py-3">
                    <h6 class="m-0 font-weight-bold text-primary">Daftar Pesanan Yang Masuk</h6>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-bordered" id="pesananTable" width="100%" cellspacing="0">
                            <thead>
                                <tr>
                                    <th>Nama Penyewa</th>
                                    <th>Nama Penyewa</th>
                                    <th>Jenis Kendaraan</th>
                                    <th>Total Pembayaran</th>
                                    <th>Alamat Penyewaan</th>
                                    <th>Metode Pembayaran</th>
                                    <th>Tangal Pemesanan</th>
                                    <th>Detail Pesanan</th>
                                    <th>Terima Pesanan</th>
                                    <th>Tolak Pesanan</th>
                                </tr>
                            </thead>
                            <tbody id="pesananData">
                                <!-- Data akan dimuat di sini -->
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Tabel Pesanan Berlangsung -->
            <div class="card shadow mb-4">
                <div class="card-header py-3">
                    <h6 class="m-0 font-weight-bold text-success">Pesanan Berlangsung - Jika Ada Pesanan Overtime akan berwarna merah</h6>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-bordered" id="pesananBerlangsungTable" width="100%" cellspacing="0">
                            <thead>
                                <tr>
                                    <th>ID Pesanan</th>
                                    <th>Nama Penyewa</th>
                                    <th>Jenis Kendaraan</th>
                                    <th>Total Harga</th>
                                    <th>Alamat Penyewaan</th>
                                    <th>Status Pembayaran</th>
                                    <th>Tanggal Return</th>
                                    <th>Detail</th>
                                    <th>Aksi</th>
                                    
                                </tr>
                            </thead>
                            <tbody id="pesananBerlangsungData">
                                <!-- Data akan dimuat di sini -->
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Tabel Pesanan Ditolak -->
            <div class="card shadow mb-4">
                <div class="card-header py-3">
                    <h6 class="m-0 font-weight-bold text-danger">Pesanan Ditolak</h6>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-bordered" id="pesananDitolakTable" width="100%" cellspacing="0">
                            <thead>
                                <tr>
                                    <th>ID Pesanan</th>
                                    <th>Nama Penyewa</th>
                                    <th>Jenis Kendaraan</th>
                                    <th>Total Harga</th>
                                    <th>Alamat Penyewaan</th>
                                    <th>Status Pembayaran</th>
                                    <th>Tanggal Pemesanan</th>
                                    <th>Detail</th>
                                </tr>
                            </thead>
                            <tbody id="pesananDitolakData">
                                <!-- Data akan dimuat di sini -->
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

<!-- Modal Detail Pesanan -->
<div class="modal fade" id="detailModal" tabindex="-1" role="dialog" aria-labelledby="detailModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg" role="document"> <!-- Menambahkan class modal-lg untuk lebar -->
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="detailModalLabel">Detail Pesanan</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <div class="row">
                    <!-- Kolom Data User -->
                    <div class="col-md-6">
                        <h5>Data Pengguna</h5>
                        <p><strong>Nama:</strong> <span id="userName"></span></p>
                        <p><strong>Email:</strong> <span id="userEmail"></span></p>
                        <p><strong>Alamat:</strong> <span id="userAlamat"></span></p>
                        <p><strong>Nomor HP:</strong> <span id="userPhone"></span></p> 
                        <p><strong>Foto SIM:</strong></p>
                        <img id="userSimPhoto" src="" alt="Foto SIM" class="img-fluid" style="max-width: 200px;"> 
                    </div>

                    <!-- Kolom Data Pesanan -->
                    <div class="col-md-6">
                        <h5>Detail Pesanan</h5>
                        <p><strong>ID Pesanan:</strong> <span id="orderId"></span></p>
                        <p><strong>Status Pembayaran:</strong> <span id="paymentStatus"></span></p>
                        <p><strong>Status Pemesanan:</strong> <span id="orderStatus"></span></p>
                        <p><strong>Total Harga:</strong> Rp <span id="totalPrice"></span></p>
                        <p><strong>Waktu Pemesanan:</strong> Rp <span id="tgl"></span></p>
                        <p><strong>Kendaraan:</strong> <span id="vehicleInfo"></span></p>
                        <p><strong>Fitur Tambahan:</strong></p>
                        <ul id="featureList"></ul>
                    </div>
                </div>
                <div class="text-center mt-4">
                    <img id="vehicleImage" src="" alt="Image Kendaraan" class="img-fluid">
                </div>
            </div>
        </div>
    </div>
</div>


<!-- batas harga diri dan emosi ini   -->

        @include('layouts.partial.footer')
    </div>
</div>

<script src="{{ asset('vendor/jquery/jquery.min.js') }}"></script>
<script src="{{ asset('vendor/bootstrap/js/bootstrap.bundle.min.js') }}"></script>
<script src="{{ asset('vendor/jquery-easing/jquery.easing.min.js') }}"></script>
<script src="{{ asset('js/sb-admin-2.min.js') }}"></script>


<!-- Link ke JavaScript eksternal -->
<script src="{{ asset('js/pesanan.js') }}"></script>

</body>
</html>
