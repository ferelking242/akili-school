import 'package:flutter/material.dart';

import '../../../../shared/data/mock_data.dart';
import '../../../../shared/widgets/page_scaffold.dart';

class StudentsListPage extends StatelessWidget {
  const StudentsListPage({super.key});
  @override
  Widget build(BuildContext context) {
    final students = MockData.students;
    return PageScaffold(
      title: 'Students directory',
      subtitle: '${students.length} students enrolled this year',
      actions: [
        ActionButton(label: 'Filter', icon: Icons.filter_list_rounded, onTap: () {}),
        const SizedBox(width: 8),
        ActionButton(
            label: 'Export',
            icon: Icons.file_download_outlined,
            primary: true,
            onTap: () {}),
      ],
      child: DataPanel(
        title: 'All students',
        headerActions: const [SearchInput(hint: 'Search student…')],
        child: DataTablePanel(
          columns: const ['Name', 'ID', 'Class', 'Average', 'Attendance', 'Guardian'],
          flex: const [3, 2, 2, 2, 2, 3],
          rows: [
            for (final s in students)
              [
                Row(children: [
                  Avatar(name: s.name, size: 24),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(s.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: ink,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600)),
                  ),
                ]),
                Text(s.id,
                    style: const TextStyle(fontSize: 12, color: muted)),
                Text(s.classGroup,
                    style: const TextStyle(fontSize: 12, color: ink)),
                Text(s.avg.toStringAsFixed(1),
                    style: const TextStyle(
                        fontSize: 12.5, color: ink, fontWeight: FontWeight.w700)),
                Text('${(s.attendance * 100).round()}%',
                    style: const TextStyle(fontSize: 12, color: ink)),
                Text(s.guardian,
                    style: const TextStyle(fontSize: 12, color: muted)),
              ],
          ],
        ),
      ),
    );
  }
}
