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

    <div class="container-fluid">
    <!-- Page Heading -->
    <h1 class="h3 mb-2 text-gray-800">Kendaraan</h1>

    <!-- Display success message if exists -->
    @if(session('success'))
        <div class="alert alert-success">
            {{ session('success') }}
        </div>
    @endif

    <div class="d-flex justify-content-between align-items-center mb-4">
        <p class="mb-0">Berikut adalah data kendaraan yang tersedia:</p>
        <button class="btn btn-primary" data-toggle="modal" data-target="#addVehicleModal">Tambah Kendaraan</button>
    </div>
    <!-- DataTales Example -->
    <div class="card shadow mb-4">
        <div class="card-header py-3">
            <h6 class="m-0 font-weight-bold text-primary">Data Kendaraan</h6>
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-bordered" id="dataTable" width="100%" cellspacing="0">
                    <thead>
                        <tr>
                            <th>Name</th>
                            <th>Brand</th>
                            <th>Category</th>
                            <th>CC</th>
                            <th>Model</th>
                            <th>Price</th>
                            <th>Price2</th>
                            <!-- <th>Status</th> -->
                            <th>Image URL</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($kendaraan as $key => $item)
                            <tr>
                                <td>{{ $item['name'] }}</td>
                                <td>{{ $item['brand'] }}</td>
                                <td>{{ $item['category'] }}</td>
                                <td>{{ $item['cc'] }}</td>
                                <td>{{ $item['model'] }}</td>
                                <td>{{ $item['price'] }}</td>
                                <td>{{ $item['price2'] }}</td>
                               
                                <td><img src="{{ $item['image_url'] }}" alt="{{ $item['name'] }}" width="100"></td>
                                <td>
                                    <div class="d-flex justify-content-around">
                                        <!-- Tombol Edit -->
        <button class="btn btn-warning btn-sm" data-toggle="modal" data-target="#editVehicleModal{{ $key }}">Edit</button>

<!-- Modal Edit -->
<div class="modal fade" id="editVehicleModal{{ $key }}" tabindex="-1" role="dialog" aria-labelledby="editVehicleModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="editVehicleModalLabel">Edit Kendaraan</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <form action="{{ route('kendaraan.update', $key) }}" method="POST">
                @csrf
                @method('PUT')
                <div class="modal-body">
                    <!-- Field Name -->
                    <div class="form-group">
                        <label for="name">Name</label>
                        <input type="text" class="form-control" id="name" name="name" value="{{ $item['name'] }}" required>
                    </div>
                    <!-- Field Brand -->
                    <div class="form-group">
                        <label for="brand">Brand</label>
                        <input type="text" class="form-control" id="brand" name="brand" value="{{ $item['brand'] }}" required>
                    </div>
                    <!-- Field Category -->
                    <div class="form-group">
                        <label for="category">Category</label>
                        <input type="text" class="form-control" id="category" name="category" value="{{ $item['category'] }}" required>
                    </div>
                    <!-- Field CC -->
                    <div class="form-group">
                        <label for="cc">CC</label>
                        <input type="text" class="form-control" id="cc" name="cc" value="{{ $item['cc'] }}" required>
                    </div>
                    <!-- Field Model -->
                    <div class="form-group">
                        <label for="model">Model</label>
                        <input type="text" class="form-control" id="model" name="model" value="{{ $item['model'] }}" required>
                    </div>
                    <!-- Field Price -->
                    <div class="form-group">
                        <label for="price">Price</label>
                        <input type="text" class="form-control" id="price" name="price" value="{{ $item['price'] }}" required>
                    </div>
                    <!-- Field Price2 -->
                    <div class="form-group">
                        <label for="price2">Price2</label>
                        <input type="text" class="form-control" id="price2" name="price2" value="{{ $item['price2'] }}" required>
                    </div>
                    <!-- Field Image URL -->
                    <div class="form-group">
                        <label for="image_url">Image URL</label>
                        <input type="text" class="form-control" id="image_url" name="image_url" value="{{ $item['image_url'] }}" required>
                    </div>
                    <!-- Radio Button Status -->
                    <div class="form-group">
                        <label for="status">Status</label><br>
                        <input type="radio" id="tersedia" name="status" value="Tersedia" 
                            {{ isset($item['status']) && $item['status'] == 'Tersedia' ? 'checked' : '' }}>
                        <label for="tersedia">Tersedia</label><br>
                        <input type="radio" id="tidak_tersedia" name="status" value="Tidak Tersedia" 
                            {{ isset($item['status']) && $item['status'] == 'Tidak Tersedia' ? 'checked' : '' }}>
                        <label for="tidak_tersedia">Tidak Tersedia</label><br>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Tutup</button>
                    <button type="submit" class="btn btn-primary">Perbarui Kendaraan</button>
                </div>
            </form>
        </div>
    </div>
</div>
                                        <form action="{{ route('kendaraan.delete', $key) }}" method="POST" onsubmit="return confirm('Apakah kamu yakin menghapus data ini?');">
                                            @csrf
                                            @method('DELETE')
                                            <!-- <button type="submit" class="btn btn-danger btn-icon-split"><i class="fas fa-trash"></i>Hapus</button> -->

                                            <button type="submit" class="btn btn-danger btn-icon-split">
                                                <span class="icon text-white-50">
                                                    <i class="fas fa-trash"></i>
                                                </span>
                                            <span class="text">Hapus
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        </div>
    </div>


    <!-- Modal for adding new vehicle -->
    <div class="modal fade" id="addVehicleModal" tabindex="-1" role="dialog" aria-labelledby="addVehicleModalLabel" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="addVehicleModalLabel">Tambah Kendaran</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <form method="POST" action="{{ route('kendaraan.save') }}" enctype="multipart/form-data">
    @csrf
    <div class="modal-body">
        <div class="form-group">
            <label for="name">Name</label>
            <input type="text" class="form-control" id="name" name="name" required>
        </div>
        <div class="form-group">
            <label for="brand">Brand</label>
            <input type="text" class="form-control" id="brand" name="brand" required>
        </div>
        <div class="form-group">
            <label for="category">Category</label>
            <input type="text" class="form-control" id="category" name="category" required>
        </div>
        <div class="form-group">
            <label for="cc">CC</label>
            <input type="number" class="form-control" id="cc" name="cc" required>
        </div>
        <div class="form-group">
            <label for="model">Model</label>
            <input type="text" class="form-control" id="model" name="model" required>
        </div>
        <div class="form-group">
            <label for="price">Price</label>
            <input type="number" step="0.01" class="form-control" id="price" name="price" required>
        </div>
        <div class="form-group">
            <label for="price2">Price2</label>
            <input type="number" step="0.01" class="form-control" id="price2" name="price2" required>
        </div>

        <!-- Cloudinary Image Upload -->
        <div class="form-group">
            <label for="image">Image</label>
            
            <button type="button" id="uploadButton" class="btn btn-primary">Upload to Cloudinary</button>
            <input type="hidden" step="0.01" id="image" name="image" required>
        </div>

        <br>
        <button type="submit" class="btn btn-success">Save</button>
    </div>
</form>

<!-- Cloudinary Script -->
<script src="https://widget.cloudinary.com/v2.0/global/all.js" type="text/javascript"></script>
<script>
    var myWidget = cloudinary.createUploadWidget({
        cloudName: 'dtkgxh4zh', 
        uploadPreset: 'default',
        multiple: false
    }, (error, result) => { 
        if (!error && result && result.event === "success") { 
            // Set the URL of the uploaded image in the hidden input field
            document.getElementById("image").value = result.info.secure_url;
        }
    });

    document.getElementById("uploadButton").addEventListener("click", function(e) {
        e.preventDefault();
        myWidget.open();
    }, false);
</script>


            </div>
        </div>
    </div>
</div>
@include('layouts.partial.footer')        
</div>

<script src="{{ asset('vendor/jquery/jquery.min.js') }}"></script>
<script src="{{ asset('vendor/bootstrap/js/bootstrap.bundle.min.js') }}"></script>
<script src="{{ asset('vendor/jquery-easing/jquery.easing.min.js') }}"></script>
<script src="{{ asset('js/sb-admin-2.min.js') }}"></script>
<script src="{{ asset('vendor/chart.js/Chart.min.js') }}"></script>
<script src="{{ asset('js/demo/chart-area-demo.js') }}"></script>
<script src="{{ asset('js/demo/chart-pie-demo.js') }}"></script>
</body>
</html>