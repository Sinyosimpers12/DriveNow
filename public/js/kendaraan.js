document.getElementById('uploadButton').addEventListener('click', function(event) {
    event.preventDefault();
    
    // Menampilkan pesan sementara
    document.getElementById('message').innerText = "Mengupload gambar...";

    // Ambil file gambar yang dipilih
    const imageInput = document.getElementById('image');
    const imageFile = imageInput.files[0];
    
    if (!imageFile) {
        document.getElementById('message').innerText = "Harap pilih gambar terlebih dahulu!";
        return;
    }

    // FormData untuk upload gambar
    let formData = new FormData();
    formData.append('image', imageFile);

    // Kirim gambar ke server (misalnya ke Cloudinary atau endpoint server untuk upload gambar)
    fetch('/upload-image', { // Ganti '/upload-image' dengan URL endpoint Anda
        method: 'POST',
        body: formData,
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            // Menyimpan URL gambar yang berhasil di-upload
            const imageUrl = data.imageUrl;

            // Menampilkan pesan sukses upload gambar
            document.getElementById('message').innerText = "Gambar berhasil diupload!";

            // Menampilkan tombol simpan data kendaraan
            document.getElementById('saveButton').style.display = 'inline-block';

            // Menyimpan URL gambar dalam form untuk data kendaraan
            const hiddenImageUrlInput = document.createElement('input');
            hiddenImageUrlInput.type = 'hidden';
            hiddenImageUrlInput.name = 'image_url';
            hiddenImageUrlInput.value = imageUrl;
            document.getElementById('kendaraanForm').appendChild(hiddenImageUrlInput);
        } else {
            document.getElementById('message').innerText = "Gagal upload gambar!";
        }
    })
    .catch(error => {
        document.getElementById('message').innerText = "Terjadi kesalahan: " + error.message;
    });
});

// Menangani submit form untuk menyimpan data kendaraan
document.getElementById('kendaraanForm').addEventListener('submit', function(event) {
    event.preventDefault();

    // Ambil data dari form
    const formData = new FormData(this);

    // Kirim data kendaraan ke server
    fetch('/saveKendaraan', { // Ganti '/save-kendaraan' dengan URL endpoint Anda
        method: 'POST',
        body: formData,
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            document.getElementById('message').innerText = "Data kendaraan berhasil disimpan!";
        } else {
            document.getElementById('message').innerText = "Gagal menyimpan data kendaraan!";
        }
    })
    .catch(error => {
        document.getElementById('message').innerText = "Terjadi kesalahan: " + error.message;
    });
});
