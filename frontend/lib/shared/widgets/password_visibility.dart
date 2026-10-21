import 'package:flutter/material.dart';

/// Tombol mata untuk field password: menampilkan atau menyembunyikan isi.
///
/// [visible] = true berarti password sedang tampil, jadi ikonnya "mata
/// tertutup" (sembunyikan lagi). Ikon dan tooltip hanya didefinisikan di
/// sini supaya auth dan dashboard konsisten.
class PasswordVisibilityButton extends StatelessWidget {
  final bool visible;
  final VoidCallback onPressed;

  const PasswordVisibilityButton({
    super.key,
    required this.visible,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 19,
      tooltip: visible ? 'Sembunyikan password' : 'Tampilkan password',
      onPressed: onPressed,
      icon: Icon(
        visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
      ),
    );
  }
}
