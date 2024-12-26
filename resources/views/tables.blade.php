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
        <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css">
        



    </head>
    <body class="font-sans antialiased">


    <div id="wrapper">
    @include('layouts.partial.sidebar')

    
    <div id="content-wrapper" class="d-flex flex-column">
    @include('layouts.partial.navbar')
    <div class="container-fluid">
        <!-- Batasanmu anakmuda -->

        <!-- Page Heading -->

        <div class="d-sm-flex align-items-center justify-content-between mb-4">
    <h1 class="h3 mb-0 text-gray-800">Tables</h1>
    <a href="#" class="d-none d-sm-inline-block btn btn-sm btn-primary shadow-sm"><i
            class="fas fa-download fa-sm text-white-50"></i> Generate Report</a>
</div>
                    <p class="mb-4">Data Semua Table, Silakan Mensortir dan Mencari Sesuai Selera, Table Ini DIbantu oleh <a target="_blank"
                            href="https://datatables.net">official DataTables documentation</a>.</p>    

        <div class="card shadow mb-4">
        <div class="card-header py-3">
            <h6 class="m-0 font-weight-bold text-primary">Daftar Semua Pesanan</h6>
        </div>
        <div class="card-body">
            <div class="table-responsive">
            <table id="dataTable" class="display table table-striped table-bordered">
    <thead>
        <tr>
            <th>ID Pesanan</th>
            <th>Nama Penyewa</th>
            <th>Nama Kendaraan</th>
            <th>Total Harga</th>
            <th>Tanggal Pesanan</th>
            <th>Status Pemesanan</th>
            <th>Detail</th>
        </tr>
    </thead>
    <tbody id="dataTableBody">
        <!-- Data akan dimasukkan secara dinamis -->
    </tbody>
</table>

            </div>
        </div>
    </div>
</div>
</div>
<!-- /.container-fluid -->

<!-- Modal Detail Pesanan -->
<div class="modal fade" id="detailModal" tabindex="-1" role="dialog" aria-labelledby="detailModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="detailModalLabel">Detail Pesanan</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <div id="detailContent">
                    <!-- Detail data akan ditambahkan disini -->
                </div>
            </div>
        </div>
    </div>
</div>
</div>
    <!-- Batasanmu anakmuda -->
    
@include('layouts.partial.footer')        
</div>

<script src="https://code.jquery.com/jquery-3.6.4.min.js"></script>
<!-- Tambahkan JS DataTables -->
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>

<script src="{{ asset('vendor/bootstrap/js/bootstrap.bundle.min.js') }}"></script>
<script src="{{ asset('vendor/jquery-easing/jquery.easing.min.js') }}"></script>
<script src="{{ asset('js/sb-admin-2.min.js') }}"></script>
<script src="{{ asset('js/tables.js') }}"></script>


</body>
</html>


