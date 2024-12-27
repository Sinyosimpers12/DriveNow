import 'package:get/get.dart';

import '../auth/auth.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/konfirmasi_pesanan/bindings/konfirmasi_pesanan_binding.dart';
import '../modules/konfirmasi_pesanan/views/konfirmasi_pesanan_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/nav_bar/bindings/nav_bar_binding.dart';
import '../modules/nav_bar/views/nav_bar_view.dart';
import '../modules/pembayaran/bindings/pembayaran_binding.dart';
import '../modules/pembayaran/views/pembayaran_view.dart';
import '../modules/pencarian/bindings/pencarian_binding.dart';
import '../modules/pencarian/views/pencarian_view.dart';
import '../modules/pesanan/bindings/pesanan_binding.dart';
import '../modules/pesanan/views/pesanan_view.dart';
import '../modules/profil/bindings/profil_binding.dart';
import '../modules/profil/views/profil_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/riwayat/bindings/riwayat_binding.dart';
import '../modules/riwayat/views/riwayat_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.NAV_BAR,
      page: () => NavBarView(),
      binding: NavBarBinding(),
    ),
    GetPage(
      name: _Paths.RIWAYAT,
      page: () => const RiwayatView(),
      binding: RiwayatBinding(),
    ),
    GetPage(
      name: _Paths.PROFIL,
      page: () => ProfilView(),
      binding: ProfilBinding(),
    ),
    GetPage(
      name: _Paths.PESANAN,
      page: () => PesananView(vehicle: Get.arguments),
      binding: PesananBinding(),
    ),
    GetPage(
      name: _Paths.PENCARIAN,
      page: () => const PencarianView(),
      binding: PencarianBinding(),
    ),
    GetPage(
      name: _Paths.KONFIRMASI_PESANAN,
      page: () => KonfirmasiPesananView(),
      binding: KonfirmasiPesananBinding(),
    ),
    GetPage(
      name: _Paths.PEMBAYARAN,
      page: () => PembayaranView(),
      binding: PembayaranBinding(),
    ),
  ];
}
