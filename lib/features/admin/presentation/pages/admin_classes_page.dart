import 'package:flutter/material.dart';

import '../../../../shared/data/mock_data.dart';
import '../../../../shared/widgets/page_scaffold.dart';

class AdminClassesPage extends StatelessWidget {
  const AdminClassesPage({super.key});
  @override
  Widget build(BuildContext context) {
    final classes = MockData.classes;
    return PageScaffold(
      title: 'Classes & sections',
      subtitle: '${classes.length} classes across the school',
      actions: [
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
          columns: const ['Class', 'Level', 'Lead teacher', 'Students', 'Capacity', ''],
          flex: const [2, 3, 3, 1, 2, 2],
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
                _CapacityBar(used: cl.students, max: 32),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    ActionButton(label: 'Edit', icon: Icons.edit_outlined, onTap: () {}),
                    const SizedBox(width: 6),
                    ActionButton(label: 'Assign', onTap: () {}, primary: true),
                  ]),
                ),
              ],
          ],
        ),
      ),
    );
  }
}

class _CapacityBar extends StatelessWidget {
  final int used, max;
  const _CapacityBar({required this.used, required this.max});
  @override
  Widget build(BuildContext context) {
    final ratio = (used / max).clamp(0.0, 1.0);
    final color = ratio > .9
        ? const Color(0xFFDC2626)
        : ratio > .7
            ? const Color(0xFFEA580C)
            : const Color(0xFF16A34A);
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Stack(
                children: [
                  Container(color: subtleBg),
                  FractionallySizedBox(
                    widthFactor: ratio,
                    child: Container(color: color),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('$used/$max',
            style: const TextStyle(fontSize: 11, color: muted)),
      ],
    );
  }
}
