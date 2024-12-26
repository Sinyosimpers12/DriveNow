document.addEventListener('DOMContentLoaded', () => {
  const apiUrl = "https://pa-test-da05d-default-rtdb.asia-southeast1.firebasedatabase.app/pesanan.json";

  // Ambil data dari Firebase
  fetch(apiUrl)
      .then(response => response.json())
      .then(data => {
          // Inisialisasi penghitung status
          const statusCounts = {
              MenungguKonfirmasi: 0,
              Berlangsung: 0,
              Ditolak: 0
          };

          // Hitung jumlah pesanan berdasarkan status
          if (data) {
              Object.values(data).forEach(pesanan => {
                  if (pesanan.statusPemesanan === "Menunggu Konfirmasi") {
                      statusCounts.MenungguKonfirmasi++;
                  } else if (pesanan.statusPemesanan === "Berlangsung") {
                      statusCounts.Berlangsung++;
                  } else if (pesanan.statusPemesanan === "Ditolak") {
                      statusCounts.Ditolak++;
                  }
              });
          }

          // Gambar grafik pie
          const ctx = document.getElementById('statusPesananChart').getContext('2d');
          new Chart(ctx, {
              type: 'pie',
              data: {
                  labels: ['Menunggu Konfirmasi', 'Berlangsung', 'Ditolak'],
                  datasets: [{
                      data: [
                          statusCounts.MenungguKonfirmasi,
                          statusCounts.Berlangsung,
                          statusCounts.Ditolak
                      ],
                      backgroundColor: ['#4e73df', '#1cc88a', '#e74a3b'],
                      hoverBackgroundColor: ['#2e59d9', '#17a673', '#e02d1b'],
                      borderWidth: 1
                  }]
              },
              options: {
                  responsive: true,
                  maintainAspectRatio: false,
                  plugins: {
                      legend: {
                          position: 'top'
                      }
                  }
              }
          });
      })
      .catch(error => {
          console.error("Error fetching data:", error);
      });
});
