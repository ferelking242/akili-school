import 'package:flutter/material.dart';

import '../../../../shared/data/mock_data.dart';
import '../../../../shared/widgets/page_scaffold.dart';

class AttendanceLogPage extends StatelessWidget {
  const AttendanceLogPage({super.key});
  @override
  Widget build(BuildContext context) {
    final entries = MockData.attendance;
    return PageScaffold(
      title: 'Attendance log',
      subtitle: 'Real-time gate scans for ${DateTime.now().day}/${DateTime.now().month}',
      actions: [
        ActionButton(
            label: 'Open scanner',
            icon: Icons.qr_code_scanner_rounded,
            primary: true,
            onTap: () {}),
      ],
      child: DataPanel(
        title: 'Today\'s scans',
        headerActions: const [SearchInput(hint: 'Search…')],
        child: DataTablePanel(
          columns: const ['Time', 'Student', 'Class', 'Status', 'Action'],
          flex: const [1, 3, 1, 2, 2],
          rows: [
            for (final e in entries)
              [
                Text(e.time,
                    style: const TextStyle(
                        color: ink, fontSize: 12, fontFeatures: [FontFeature.tabularFigures()])),
                Row(children: [
                  Avatar(name: e.student, size: 22),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(e.student,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: ink, fontSize: 12.5, fontWeight: FontWeight.w600)),
                  ),
                ]),
                Text(e.classGroup,
                    style: const TextStyle(fontSize: 12, color: muted)),
                Align(alignment: Alignment.centerLeft, child: _statusPill(e.status)),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ActionButton(
                      label: 'Notify guardian',
                      icon: Icons.send_outlined,
                      onTap: () {}),
                ),
              ],
          ],
        ),
      ),
    );
  }

  static Widget _statusPill(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.present:
        return StatusPill.success('Present');
      case AttendanceStatus.late:
        return StatusPill.warning('Late');
      case AttendanceStatus.absent:
        return StatusPill.danger('Absent');
    }
  }
}
