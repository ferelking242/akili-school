import 'package:flutter/material.dart';

import '../../../../shared/data/mock_data.dart';
import '../../../../shared/widgets/page_scaffold.dart';

class TeacherClassesPage extends StatelessWidget {
  const TeacherClassesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final classes = MockData.classes;
    return PageScaffold(
      title: 'My classes',
      subtitle: '${classes.length} classes — ${classes.fold<int>(0, (a, b) => a + b.students)} students',
      actions: [
        ActionButton(label: 'Filter', icon: Icons.filter_list_rounded, onTap: () {}),
        const SizedBox(width: 8),
        ActionButton(
            label: 'New class',
            icon: Icons.add_rounded,
            primary: true,
            onTap: () {}),
      ],
      child: DataPanel(
        title: 'All classes',
        headerActions: const [SearchInput(hint: 'Search class…')],
        child: DataTablePanel(
          columns: const ['Class', 'Level', 'Lead teacher', 'Students', ''],
          flex: const [2, 3, 3, 2, 2],
          rows: [
            for (final cl in classes)
              [
                Text(cl.name,
                    style: const TextStyle(
                        color: ink, fontSize: 13, fontWeight: FontWeight.w700)),
                Text(cl.level,
                    style: const TextStyle(fontSize: 12, color: muted)),
                Row(children: [
                  Avatar(name: cl.teacher, size: 22),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(cl.teacher,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: ink)),
                  ),
                ]),
                Text('${cl.students}',
                    style: const TextStyle(
                        fontSize: 13, color: ink, fontWeight: FontWeight.w700)),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ActionButton(
                      label: 'Open', icon: Icons.arrow_forward_rounded, onTap: () {}),
                ),
              ],
          ],
        ),
      ),
    );
  }
}
