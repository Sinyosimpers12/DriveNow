// URL API Firebase
const apiUrl = "https://pa-test-da05d-default-rtdb.asia-southeast1.firebasedatabase.app/pesanan.json";

// Fungsi untuk mengambil data dari Firebase dan mengisinya ke dalam tabel
fetch(apiUrl)
    .then(response => response.json())
    .then(data => {
        const tableBody = document.getElementById("dataTableBody");

        // Pastikan data tersedia dan memiliki struktur yang benar
        if (data) {
            // Melakukan iterasi pada setiap pesanan dalam data
            Object.values(data).forEach(pesanan => {
                const row = document.createElement("tr");

                // Menentukan kelas berdasarkan status pemesanan
                let statusClass = '';
                switch (pesanan.statusPemesanan) {
                    case 'Ditolak':
                        statusClass = 'border-left-danger';
                        break;
                    case 'Berlangsung':
                        statusClass = 'border-left-info';
                        break;
                    case 'Selesai':
                        statusClass = 'border-left-success';
                        break;
                    case 'Menunggu Konfirmasi':
                        statusClass = 'border-left-warning';
                        break;
                    default:
                        statusClass = ''; // Tidak ada kelas jika status tidak dikenali
                }

                // Memasukkan data pesanan ke dalam baris tabel dengan kelas status
                row.innerHTML = `
                    <td>${pesanan.idPesanan || 'Data tidak tersedia'}</td>
                    <td>${pesanan.dataUser.name || 'Data tidak tersedia'}</td>
                    <td>${pesanan.vehicle.name || 'Data tidak tersedia'}</td>
                    <td>${pesanan.totalHarga || 'Data tidak tersedia'}</td>
                    <td>${new Date(pesanan.tanggalPesanan).toLocaleString() || 'Data tidak tersedia'}</td>
                    <td class="${statusClass}">${pesanan.statusPemesanan || 'Data tidak tersedia'}</td>
                    <td><button class="btn btn-info btn-sm" onclick="showDetail('${pesanan.idPesanan}')">Detail</button></td>
                `;

                tableBody.appendChild(row);
            });

            // Menginisialisasi DataTables setelah tabel diupdate dengan data
            $('#dataTable').DataTable();
        } else {
            // Jika tidak ada data, tampilkan pesan kosong
            tableBody.innerHTML = "<tr><td colspan='7' class='text-center'>Data tidak ditemukan.</td></tr>";
        }
    })
    .catch(error => {
        console.error("Error fetching data: ", error);
    });

// Fungsi untuk menampilkan detail pesanan dalam modal
function showDetail(idPesanan) {
    // URL API untuk mendapatkan detail pesanan berdasarkan ID
    const detailUrl = `https://pa-test-da05d-default-rtdb.asia-southeast1.firebasedatabase.app/pesanan/${idPesanan}.json`;

    fetch(detailUrl)
        .then(response => response.json())
        .then(pesanan => {
            const detailContent = document.getElementById("detailContent");
            detailContent.innerHTML = `
                <h5>ID Pesanan: ${pesanan.idPesanan}</h5>
                <p><strong>Nama Penyewa:</strong> ${pesanan.dataUser.name}</p>
                <p><strong>Email:</strong> ${pesanan.dataUser.email}</p>
                <p><strong>Alamat:</strong> ${pesanan.pesananAlamat}</p>
                <p><strong>Metode Pembayaran:</strong> ${pesanan.metodePembayaran}</p>
                <p><strong>Status Pembayaran:</strong> ${pesanan.statusPembayaran}</p>
                <p><strong>Status Pemesanan:</strong> ${pesanan.statusPemesanan}</p>
                <p><strong>Total Harga:</strong> Rp ${pesanan.totalHarga}</p>
                <p><strong>Brand Kendaraan:</strong> ${pesanan.vehicle.brand}</p>
                <p><strong>Jenis Kendaraan:</strong> ${pesanan.vehicle.category} - ${pesanan.vehicle.name}</p>
                <p><strong>Model Kendaraan:</strong> ${pesanan.vehicle.model}</p>
                <img src="${pesanan.vehicle.image_url}" alt="Image Kendaraan" class="img-fluid">
            `;

            // Menampilkan modal
            $('#detailModal').modal('show');
        })
        .catch(error => {
            console.error("Error fetching detail: ", error);
        });
}
