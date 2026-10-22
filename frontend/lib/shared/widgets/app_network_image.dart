import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/network/api_config.dart';
import 'package:frontend/core/theme/app_colors.dart';

/// Pengganti tunggal untuk semua gambar jaringan: resolve path relatif
/// backend, cache lintas navigasi, dan placeholder kaca.
class AppNetworkImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double radius;
  final BoxShape shape;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius = 0,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = ApiConfig.resolveFileUrl(url);

    Widget content;
    if (resolved.isEmpty) {
      content = _fallback();
    } else {
      content = CachedNetworkImage(
        imageUrl: resolved,
        width: width,
        height: height,
        fit: fit,
        // Jangan render lewat elemen <img> bawaan browser (HtmlImage):
        // pada Flutter 3.47.x engine web mendisposisi sumber <img> saat
        // ImageCache melakukan eviction, sehingga Picture yang masih
        // mereferensikan bitmap itu ter-rasterisasi HITAM setelah kembali
        // dari halaman lain yang memuat banyak gambar (gejala: avatar di
        // dashboard jadi hitam polos setelah dari galeri; F5 memulihkan).
        // Ref: flutter/flutter#191800 (regresi 3.47.0, diperbaiki di
        // master), dikonfirmasi juga Baseflow/flutter_cached_network_image#1034.
        // HttpGet mem-fetch byte lewat http Dart lalu decode via pixels,
        // sehingga bebas dari regresi engine ini.
        imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
        fadeInDuration: const Duration(milliseconds: 180),
        placeholder: (_, __) => _fallback(),
        errorWidget: (_, __, ___) => _fallback(),
      );
    }

    if (shape == BoxShape.circle) {
      return ClipOval(child: content);
    }
    if (radius <= 0) return content;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: content,
    );
  }

  Widget _fallback() {
    final side = width ?? height ?? 48;
    return Container(
      width: width,
      height: height,
      color: Colors.white.withValues(alpha: 0.06),
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: (side * 0.28).clamp(10, 44),
        color: AppColors.muted,
      ),
    );
  }
}
