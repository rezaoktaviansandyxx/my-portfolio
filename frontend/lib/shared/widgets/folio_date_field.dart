import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

const _monthNames = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

/// Format tanggal untuk payload API (`YYYY-MM-DD`).
String folioIsoDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year.toString().padLeft(4, '0')}-$month-$day';
}

/// Format tanggal yang ramah dibaca, mis. `15 Jan 2023`.
String folioDisplayDate(DateTime date) =>
    '${date.day} ${_monthNames[date.month - 1]} ${date.year}';

/// Field tanggal dengan date picker Syncfusion.
///
/// Tampilannya sama dengan [folioField] (dekorasi dari `InputDecorationTheme`
/// global), tetapi tanggal dipilih lewat kalender — bukan diketik — supaya
/// formatnya selalu valid. Ketuk field untuk membuka dialog pemilihan.
///
/// [onChanged] dipanggil dengan `null` saat tombol hapus ditekan, jadi field
/// opsional bisa dikosongkan kembali.
Widget folioDateField({
  required String label,
  required DateTime? value,
  required ValueChanged<DateTime?> onChanged,
  bool enabled = true,
  bool clearable = true,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  return FolioDateField(
    label: label,
    value: value,
    onChanged: onChanged,
    enabled: enabled,
    clearable: clearable,
    firstDate: firstDate,
    lastDate: lastDate,
  );
}

class FolioDateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final bool enabled;
  final bool clearable;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const FolioDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.clearable = true,
    this.firstDate,
    this.lastDate,
  });

  Future<void> _pick(BuildContext context) async {
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (_) => _FolioDatePickerDialog(
        title: label,
        initialDate: value,
        firstDate: firstDate,
        lastDate: lastDate,
      ),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: enabled ? () => _pick(context) : null,
          child: InputDecorator(
            isEmpty: !hasValue,
            decoration: InputDecoration(
              labelText: label,
              isDense: true,
              enabled: enabled,
              prefixIcon: const Icon(Icons.event_outlined, size: 18),
              suffixIcon: hasValue && clearable && enabled
                  ? IconButton(
                      tooltip: 'Hapus tanggal',
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => onChanged(null),
                    )
                  : const Icon(Icons.expand_more, size: 18),
            ),
            child: Text(
              hasValue ? folioDisplayDate(value!) : '',
              style: const TextStyle(color: AppColors.ink, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }
}

class _FolioDatePickerDialog extends StatefulWidget {
  final String title;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const _FolioDatePickerDialog({
    required this.title,
    this.initialDate,
    this.firstDate,
    this.lastDate,
  });

  @override
  State<_FolioDatePickerDialog> createState() => _FolioDatePickerDialogState();
}

class _FolioDatePickerDialogState extends State<_FolioDatePickerDialog> {
  late DateTime? _selected = widget.initialDate;

  @override
  Widget build(BuildContext context) {
    // Tanggal lama yang sudah tersimpan harus tetap bisa dibuka walau batas
    // minimum bergeser (mis. tanggal mulai diganti ke setelah tanggal selesai).
    final min = widget.firstDate ?? DateTime(1900);
    final effectiveMin =
        widget.initialDate != null && widget.initialDate!.isBefore(min)
        ? widget.initialDate!
        : min;

    return AlertDialog(
      title: Text(widget.title),
      contentPadding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
      content: SizedBox(
        width: 340,
        height: 360,
        child: SfDateRangePicker(
          selectionMode: DateRangePickerSelectionMode.single,
          initialSelectedDate: _selected,
          initialDisplayDate: _selected ?? DateTime.now(),
          minDate: effectiveMin,
          maxDate: widget.lastDate ?? DateTime(2100, 12, 31),
          showNavigationArrow: true,
          showTodayButton: true,
          todayHighlightColor: AppColors.cyan,
          backgroundColor: Colors.transparent,
          selectionColor: AppColors.indigo,
          selectionTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          headerStyle: const DateRangePickerHeaderStyle(
            backgroundColor: Colors.transparent,
            textStyle: TextStyle(
              color: AppColors.ink,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          monthViewSettings: const DateRangePickerMonthViewSettings(
            firstDayOfWeek: 1,
            viewHeaderStyle: DateRangePickerViewHeaderStyle(
              textStyle: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ),
          monthCellStyle: const DateRangePickerMonthCellStyle(
            textStyle: TextStyle(color: AppColors.body, fontSize: 13),
            todayTextStyle: TextStyle(
              color: AppColors.cyan,
              fontWeight: FontWeight.w700,
            ),
            weekendTextStyle: TextStyle(color: AppColors.body),
            disabledDatesTextStyle: TextStyle(color: AppColors.muted),
            leadingDatesTextStyle: TextStyle(color: AppColors.muted),
            trailingDatesTextStyle: TextStyle(color: AppColors.muted),
          ),
          onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
            final value = args.value;
            if (value is DateTime) {
              setState(() => _selected = value);
            }
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _selected == null
              ? null
              : () => Navigator.pop(context, _selected),
          child: const Text('Pilih'),
        ),
      ],
    );
  }
}
