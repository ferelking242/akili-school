import 'package:flutter/material.dart';

import '../../../../shared/data/mock_data.dart';
import '../../../../shared/widgets/page_scaffold.dart';

class AttendanceTodayPage extends StatefulWidget {
  const AttendanceTodayPage({super.key});
  @override
  State<AttendanceTodayPage> createState() => _AttendanceTodayPageState();
}

class _AttendanceTodayPageState extends State<AttendanceTodayPage> {
  late Map<String, AttendanceStatus> _state;

  @override
  void initState() {
    super.initState();
    _state = {for (final a in MockData.attendance) a.student: a.status};
  }

  @override
  Widget build(BuildContext context) {
    final entries = MockData.attendance;
    final present = _state.values.where((s) => s == AttendanceStatus.present).length;
    final late = _state.values.where((s) => s == AttendanceStatus.late).length;
    final absent = _state.values.where((s) => s == AttendanceStatus.absent).length;
    return PageScaffold(
      title: 'Attendance — today',
      subtitle: 'Mark students as present, late or absent',
      actions: [
        ActionButton(
            label: 'Open scanner',
            icon: Icons.qr_code_scanner_rounded,
            onTap: () {}),
        const SizedBox(width: 8),
        ActionButton(
            label: 'Save',
            icon: Icons.check_rounded,
            primary: true,
            onTap: () {}),
      ],
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _SummaryCard(label: 'Present', value: present, color: const Color(0xFF16A34A))),
              const SizedBox(width: 12),
              Expanded(child: _SummaryCard(label: 'Late', value: late, color: const Color(0xFFEA580C))),
              const SizedBox(width: 12),
              Expanded(child: _SummaryCard(label: 'Absent', value: absent, color: const Color(0xFFDC2626))),
            ],
          ),
          const SizedBox(height: 12),
          DataPanel(
            title: 'Class roll',
            headerActions: const [SearchInput(hint: 'Search student…')],
            child: DataTablePanel(
              columns: const ['Student', 'Class', 'Time', 'Status'],
              flex: const [3, 1, 1, 3],
              rows: [
                for (final e in entries)
                  [
                    Row(children: [
                      Avatar(name: e.student, size: 24),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(e.student,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: ink,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600)),
                      ),
                    ]),
                    Text(e.classGroup,
                        style: const TextStyle(fontSize: 12, color: muted)),
                    Text(e.time,
                        style: const TextStyle(fontSize: 12, color: ink)),
                    _StatusToggle(
                      current: _state[e.student] ?? AttendanceStatus.present,
                      onChanged: (v) => setState(() => _state[e.student] = v),
                    ),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _SummaryCard({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text('$value',
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w700, fontSize: 14)),
          ),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: ink, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _StatusToggle extends StatelessWidget {
  final AttendanceStatus current;
  final ValueChanged<AttendanceStatus> onChanged;
  const _StatusToggle({required this.current, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    Widget btn(AttendanceStatus s, String label, Color color) {
      final selected = s == current;
      return GestureDetector(
        onTap: () => onChanged(s),
        child: Container(
          height: 26,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          margin: const EdgeInsets.only(right: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: .15) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border:
                Border.all(color: selected ? color : border, width: 1),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 11.5,
                  color: selected ? color : muted,
                  fontWeight: FontWeight.w700)),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        btn(AttendanceStatus.present, 'Present', const Color(0xFF16A34A)),
        btn(AttendanceStatus.late, 'Late', const Color(0xFFEA580C)),
        btn(AttendanceStatus.absent, 'Absent', const Color(0xFFDC2626)),
      ],
    );
  }
}
