const apiUrl = "https://pa-test-da05d-default-rtdb.asia-southeast1.firebasedatabase.app/pesanan.json";

// Fungsi untuk memuat data dari API ke dalam tabel
function loadPesanan() {
    $.ajax({
        url: apiUrl,
        method: "GET",
        success: function (data) {
            const tableMasuk = $("#pesananData");
            const tableBerlangsung = $("#pesananBerlangsungData");
            const tableDitolak = $("#pesananDitolakData");

            tableMasuk.empty();
            tableBerlangsung.empty();
            tableDitolak.empty();

            if (data) {
                // Proses setiap pesanan dari data
                Object.values(data).forEach(pesanan => {
                    const fiturList = pesanan.fitur.map(fitur => `${fitur.name} (Rp ${fitur.price})`).join(", ");
                    
                    // Membuat row untuk pesanan "Menunggu Konfirmasi"
                    if (pesanan.statusPemesanan === "Menunggu Konfirmasi") {
                        const row = `
                            <tr>
                                <td>${pesanan.idPesanan}</td>
                                <td>${pesanan.dataUser.name}</td>
                                <td>${pesanan.vehicle.name} (${pesanan.vehicle.category}, ${pesanan.vehicle.cc}cc)</td>
                                <td>${pesanan.totalHarga}</td>
                                <td>${pesanan.pesananAlamat}</td>
                                <td>${pesanan.metodePembayaran}</td>
                                <td>${pesanan.booking}</td>
                                <td>
                                    <button class="btn btn-info btn-sm" onclick="showDetail('${pesanan.idPesanan}')">Detail</button>
                                </td>
                                <td>
                                    <button class="btn btn-success btn-sm" onclick="updateStatus('${pesanan.idPesanan}', 'Berlangsung')">Terima</button>
                                </td>
                                <td>
                                    <button class="btn btn-danger btn-sm" onclick="updateStatus('${pesanan.idPesanan}', 'Ditolak')">Tolak</button>
                                </td>
                            </tr>
                        `;
                        // Menambahkan baris ke tabel pesanan yang masuk
                        tableMasuk.append(row);
                    }

                    // Membuat row untuk pesanan "Berlangsung"
                    if (pesanan.statusPemesanan === "Berlangsung") {
                        const now = new Date(); // Waktu sekarang
                        const returnDate = new Date(pesanan.return); // Waktu return dari pesanan
                        const isLate = now > returnDate; // Cek apakah waktu sekarang melewati waktu return
                    
                        const rowBerlangsung = `
                            <tr class="${isLate ? 'border-bottom-danger' : ''}">
                                <td>${pesanan.idPesanan}</td>
                                <td>${pesanan.dataUser.name}</td>
                                <td>${pesanan.vehicle.name} (${pesanan.vehicle.category}, ${pesanan.vehicle.cc}cc)</td>
                                <td>${pesanan.totalHarga}</td>
                                <td>${pesanan.pesananAlamat}</td>
                                <td>${pesanan.statusPembayaran}</td>
                                <td>${pesanan.return}</td>
                                <td>
                                    <button class="btn btn-info btn-sm" onclick="showDetail('${pesanan.idPesanan}')">Detail</button>
                                </td>
                                <td>
                                    <button class="btn btn-success btn-sm" onclick="updateStatus('${pesanan.idPesanan}', 'Selesai')">Selesai</button>
                                </td>
                            </tr>
                        `;
                        tableBerlangsung.append(rowBerlangsung);
                    }
                    

                    // Membuat row untuk pesanan "Ditolak"
                    if (pesanan.statusPemesanan === "Ditolak") {
                        const rowDitolak = `
                            <tr>
                                <td>${pesanan.idPesanan}</td>
                                <td>${pesanan.dataUser.name}</td>
                                <td>${pesanan.vehicle.name} (${pesanan.vehicle.category}, ${pesanan.vehicle.cc}cc)</td>
                                <td>${pesanan.totalHarga}</td>
                                <td>${pesanan.pesananAlamat}</td>
                                <td>${pesanan.statusPembayaran}</td>
                                <td>${pesanan.return}</td>
                                <td>
                                    <button class="btn btn-info btn-sm" onclick="showDetail('${pesanan.idPesanan}')">Detail</button>
                                </td>
                            </tr>
                        `;
                        tableDitolak.append(rowDitolak);
                    }
                });
            } else {
                const emptyRow = "<tr><td colspan='9' class='text-center'>Data tidak ditemukan.</td></tr>";
                tableMasuk.append(emptyRow);
                tableBerlangsung.append(emptyRow);
                tableDitolak.append(emptyRow);
            }
        },
        error: function (error) {
            console.error("Error fetching data: ", error);
        }
    });
}

// Panggil fungsi untuk memuat data saat halaman dimuat
$(document).ready(function () {
    loadPesanan();
});


// Fungsi untuk memperbarui status pemesanan dan status kendaraan
function updateStatus(idPesanan, status) {
    const updatePesananUrl = `https://pa-test-da05d-default-rtdb.asia-southeast1.firebasedatabase.app/pesanan/${idPesanan}.json`;

    // Pertama, ambil data pesanan untuk mengetahui image_url kendaraan
    $.ajax({
        url: updatePesananUrl,
        method: "GET",
        success: function (pesanan) {
            const kendaraanImageUrl = pesanan.vehicle.image_url;  // Ambil image_url kendaraan dari pesanan

            if (status === 'Selesai') {
                // Jika status adalah "Selesai", ubah status kendaraan menjadi "Tersedia" dan update status pembayaran menjadi "Lunas"
                $.ajax({
                    url: updatePesananUrl,
                    method: "PATCH",
                    contentType: "application/json",
                    data: JSON.stringify({ 
                        statusPemesanan: status,
                        statusPembayaran: "Lunas" // Update status pembayaran menjadi "Lunas"
                    }),
                    success: function () {
                        // Setelah status pesanan dan status pembayaran diperbarui, update status kendaraan
                        updateKendaraanStatus(kendaraanImageUrl, "Tersedia");
                        loadPesanan();
                        
                    },
                    error: function (error) {
                        console.error("Error updating pesanan status: ", error);
                    }
                });
            } else if (status === 'Berlangsung') {
                // Fungsi untuk mengubah status menjadi "Berlangsung" pada kendaraan, seperti yang sebelumnya
                $.ajax({
                    url: updatePesananUrl,
                    method: "PATCH",
                    contentType: "application/json",
                    data: JSON.stringify({ statusPemesanan: status }),
                    success: function () {
                        // Setelah status pesanan diperbarui, update status kendaraan menjadi "Tidak Tersedia"
                        updateKendaraanStatus(kendaraanImageUrl, "Tidak Tersedia");
                        loadPesanan();
                    },
                    error: function (error) {
                        console.error("Error updating pesanan status: ", error);
                    }
                });
            } else if (status === 'Ditolak') {
                // Fungsi untuk mengubah status menjadi "Ditolak", seperti yang sebelumnya
                $.ajax({
                    url: updatePesananUrl,
                    method: "PATCH",
                    contentType: "application/json",
                    data: JSON.stringify({ statusPemesanan: status }),
                    success: function () {
                        loadPesanan();
                        // Tidak perlu update kendaraan karena pesanan ditolak
                    },
                    error: function (error) {
                        console.error("Error updating pesanan status: ", error);
                    }
                });
            }
        },
        error: function (error) {
            console.error("Error fetching pesanan data: ", error);
        }
    });
}

// Fungsi untuk memperbarui status kendaraan menjadi "Tersedia" atau "Tidak Tersedia"
function updateKendaraanStatus(kendaraanImageUrl, status) {
    const kendaraanUrl = "https://pa-test-da05d-default-rtdb.asia-southeast1.firebasedatabase.app/Kendaraan.json";

    $.ajax({
        url: kendaraanUrl,
        method: "GET",
        success: function (data) {
            // Cari kendaraan yang memiliki image_url yang sama dengan pesanan
            for (let key in data) {
                if (data[key].image_url === kendaraanImageUrl) {
                    const updateKendaraanUrl = `https://pa-test-da05d-default-rtdb.asia-southeast1.firebasedatabase.app/Kendaraan/${key}.json`;

                    // Update status kendaraan
                    $.ajax({
                        url: updateKendaraanUrl,
                        method: "PATCH",
                        contentType: "application/json",
                        data: JSON.stringify({ status: status }),
                        success: function () {
                            console.log(`Status kendaraan berhasil diperbarui menjadi ${status}.`);
                        },
                        error: function (error) {
                            console.error("Error updating kendaraan status: ", error);
                        }
                    });
                    break; 
                }
            }
        },
        error: function (error) {
            console.error("Error fetching kendaraan data: ", error);
        }
    });
}

// Fungsi untuk menampilkan detail pesanan
function showDetail(idPesanan) {
    const detailUrl = `https://pa-test-da05d-default-rtdb.asia-southeast1.firebasedatabase.app/pesanan/${idPesanan}.json`;

    $.ajax({
        url: detailUrl,
        method: "GET",
        success: function (pesanan) {
            // Data Pengguna
            $("#userName").text(pesanan.dataUser.name);
            $("#userEmail").text(pesanan.dataUser.email);
            $("#userAlamat").text(pesanan.pesananAlamat);
            $("#userPhone").text(pesanan.dataUser.noHp); 
            $("#userSimPhoto").attr("src", pesanan.dataUser.sim);  

            // Data Pesanan
            $("#orderId").text(pesanan.idPesanan);
            $("#paymentStatus").text(pesanan.statusPembayaran);
            $("#orderStatus").text(pesanan.statusPemesanan);
            $("#totalPrice").text(pesanan.totalHarga);
            $("#tgl").text(pesanan.booking);

            // Kendaraan
            const vehicleInfo = `${pesanan.vehicle.brand} ${pesanan.vehicle.name} (${pesanan.vehicle.category}, ${pesanan.vehicle.cc}cc)`;
            $("#vehicleInfo").text(vehicleInfo);

            // Fitur Tambahan
            const fiturList = pesanan.fitur.map(fitur => `<li>${fitur.name} (Rp ${fitur.price})</li>`).join("");
            $("#featureList").html(fiturList);

            // Gambar Kendaraan
            $("#vehicleImage").attr("src", pesanan.vehicle.image_url);

            // Tampilkan Modal
            $("#detailModal").modal("show");
        },
        error: function (error) {
            console.error("Error fetching detail: ", error);
        }
    });
}

// Panggil fungsi untuk memuat data
$(document).ready(function () {
    loadPesanan();
});