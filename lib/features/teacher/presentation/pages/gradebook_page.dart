import 'package:flutter/material.dart';

import '../../../../shared/data/mock_data.dart';
import '../../../../shared/widgets/page_scaffold.dart';

class GradebookPage extends StatefulWidget {
  const GradebookPage({super.key});
  @override
  State<GradebookPage> createState() => _GradebookPageState();
}

class _GradebookPageState extends State<GradebookPage> {
  String _classFilter = '5e A';

  @override
  Widget build(BuildContext context) {
    final students = MockData.students
        .where((s) => s.classGroup == _classFilter)
        .toList();
    return PageScaffold(
      title: 'Gradebook',
      subtitle: 'Enter and review grades for your classes',
      actions: [
        ActionButton(
            label: 'Import CSV',
            icon: Icons.upload_rounded,
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
          _ClassPicker(
            classes: const ['5e A', '5e B', '4e A', '4e B', '3e A'],
            selected: _classFilter,
            onChanged: (v) => setState(() => _classFilter = v),
          ),
          const SizedBox(height: 12),
          DataPanel(
            title: 'Term 2 — Mathematics',
            headerActions: const [SearchInput(hint: 'Search student…')],
            child: DataTablePanel(
              columns: const ['Student', 'ID', 'Quiz 1', 'Quiz 2', 'Mid-term', 'Final', 'Avg'],
              flex: const [3, 2, 1, 1, 1, 1, 1],
              rows: [
                for (final s in students)
                  [
                    Row(children: [
                      Avatar(name: s.name, size: 22),
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
                    _GradeInput(initial: 14),
                    _GradeInput(initial: 16),
                    _GradeInput(initial: 13),
                    _GradeInput(initial: 17),
                    Text(s.avg.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 13, color: ink, fontWeight: FontWeight.w700)),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassPicker extends StatelessWidget {
  final List<String> classes;
  final String selected;
  final ValueChanged<String> onChanged;
  const _ClassPicker({
    required this.classes,
    required this.selected,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      children: [
        for (final c in classes)
          GestureDetector(
            onTap: () => onChanged(c),
            child: Container(
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c == selected ? ink : cardBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: c == selected ? ink : border),
              ),
              child: Text(c,
                  style: TextStyle(
                      fontSize: 12,
                      color: c == selected ? Colors.white : ink,
                      fontWeight: FontWeight.w600)),
            ),
          ),
      ],
    );
  }
}

class _GradeInput extends StatelessWidget {
  final double initial;
  const _GradeInput({required this.initial});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 28,
      child: TextFormField(
        initialValue: initial.toStringAsFixed(0),
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontSize: 12.5, color: ink, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: ink, width: 1.4),
          ),
        ),
      ),
    );
  }
}
