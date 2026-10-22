import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_theme.dart';

/// Satu opsi di dalam [FolioDropdown] — pengganti `DropdownMenuItem`
/// supaya pemanggil tidak perlu tahu detail package dropdown_button2.
class FolioDropdownOption<T> {
  const FolioDropdownOption({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;

  /// Ikon kecil di depan label (opsional, bikin menu lebih mudah dipindai).
  final IconData? icon;
}

/// Dropdown FolioSpace di atas package `dropdown_button2`:
/// - Dekorasi mengikuti [InputDecorationTheme] global (radius 14, fill
///   lembut) sehingga seragam dengan semua field Folio, termasuk mode gelap.
/// - Menu melayang bergaya glass (permukaan `0xFF101830`, border halus,
///   sudut 14) dengan scrollbar tipis dan tinggi maksimum terbatas.
/// - Ikon chevron berputar saat menu terbuka, opsi terpilih ditandai centang.
/// - Opsi `searchable` menambahkan kolom pencarian di atas menu (mis. filter
///   kreator yang bisa berisi banyak user).
///
/// Value'nya dikendalikan induk: [value] masuk sebagai prop dan
/// [onChanged] mengembalikan pilihan baru — pola `setState` biasa.
class FolioDropdown<T> extends StatefulWidget {
  const FolioDropdown({
    super.key,
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
    this.hint,
    this.searchable = false,
    this.menuMaxHeight = 280,
  });

  /// Nilai terpilih saat ini (boleh null bila memang ada opsi null).
  final T? value;
  final String label;
  final List<FolioDropdownOption<T>> items;
  final ValueChanged<T?> onChanged;

  /// Placeholder saat belum ada pilihan yang masuk ke [value].
  final String? hint;
  final bool searchable;

  /// Tinggi maksimum menu melayang sebelum menggulir.
  final double menuMaxHeight;

  @override
  State<FolioDropdown<T>> createState() => _FolioDropdownState<T>();
}

class _FolioDropdownState<T> extends State<FolioDropdown<T>> {
  /// dropdown_button2 v3 mengelola nilai lewat [ValueNotifier], bukan
  /// `setState` — notifier ini dijaga tetap sinkron dengan [FolioDropdown.value].
  late final ValueNotifier<T?> _value = ValueNotifier<T?>(widget.value);
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Bila induk tidak me-rebuild saat nilai berubah, label tombol tetap
    // harus ikut berganti — makanya dropdown ini ikut menyegarkan dirinya.
    _value.addListener(_onValueChanged);
  }

  void _onValueChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant FolioDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _value.value) _value.value = widget.value;
  }

  @override
  void dispose() {
    _value.removeListener(_onValueChanged);
    _value.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentValue = _value.value;

    return DropdownButtonFormField2<T>(
      isExpanded: true,
      valueListenable: _value,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
      ),
      items: [
        for (final option in widget.items)
          DropdownItem<T>(
            value: option.value,
            height: 44,
            child: Row(
              children: [
                if (option.icon != null) ...[
                  Icon(option.icon, size: 16, color: AppColors.muted),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(option.label, overflow: TextOverflow.ellipsis),
                ),
                if (option.value == currentValue) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.check_rounded, size: 16, color: AppColors.cyan),
                ],
              ],
            ),
          ),
      ],
      iconStyleData: const IconStyleData(
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.muted),
        openMenuIcon: Icon(Icons.keyboard_arrow_up_rounded, color: AppColors.cyan),
        iconSize: 22,
      ),
      dropdownStyleData: DropdownStyleData(
        maxHeight: widget.menuMaxHeight,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF101830),
          borderRadius: BorderRadius.circular(AppTheme.radiusField),
          border: Border.all(color: AppColors.glassBorderStrong),
        ),
        elevation: 16,
        scrollbarTheme: const ScrollbarThemeData(
          radius: Radius.circular(10),
          thickness: WidgetStatePropertyAll(4),
          thumbVisibility: WidgetStatePropertyAll(true),
        ),
      ),
      menuItemStyleData: MenuItemStyleData(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        borderRadius: BorderRadius.circular(10),
        // Warna overlay hover/press item menu — resolusi per state karena
        // MenuItemStyleData v3 memakai WidgetStateProperty, bukan
        // hoverColor/splashColor terpisah.
        overlayColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.pressed)
              ? AppColors.indigoSoft
              : AppColors.glassFill,
        ),
      ),
      dropdownSearchData: widget.searchable
          ? DropdownSearchData<T>(
              searchController: _searchController,
              searchBarWidgetHeight: 56,
              searchBarWidget: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Cari ${widget.label.toLowerCase()}...',
                    prefixIcon: const Icon(Icons.search, size: 18),
                    prefixIconColor: AppColors.muted,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              searchMatchFn: (item, query) {
                final queryLower = query.toLowerCase();
                return widget.items.any(
                  (option) =>
                      option.value == item.value &&
                      option.label.toLowerCase().contains(queryLower),
                );
              },
              noResultsWidget: const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Tidak ada hasil'),
              ),
            )
          : null,
      onMenuStateChange: (isOpen) {
        if (!isOpen) _searchController.clear();
      },
    );
  }
}
