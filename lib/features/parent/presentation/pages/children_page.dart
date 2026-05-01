import 'package:flutter/material.dart';

import '../../../../shared/data/mock_data.dart';
import '../../../../shared/widgets/page_scaffold.dart';

class ChildrenPage extends StatelessWidget {
  const ChildrenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final kids = MockData.students.take(2).toList();
    return PageScaffold(
      title: 'My children',
      subtitle: '${kids.length} children enrolled',
      child: LayoutBuilder(builder: (ctx, c) {
        final cols = c.maxWidth > 720 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: kids.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 200,
          ),
          itemBuilder: (_, i) => _ChildCard(student: kids[i]),
        );
      }),
    );
  }
}

class _ChildCard extends StatelessWidget {
  final MockStudent student;
  const _ChildCard({required this.student});
  @override
  Widget build(BuildContext context) {
    final attPct = (student.attendance * 100).round();
    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Avatar(name: student.name, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.name,
                        style: const TextStyle(
                            fontSize: 14,
                            color: ink,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text('${student.classGroup}  ·  ${student.id}',
                        style: const TextStyle(fontSize: 12, color: muted)),
                  ],
                ),
              ),
              StatusPill.success('Active'),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                  child: _Mini(
                      label: 'Average',
                      value: '${student.avg.toStringAsFixed(1)} / 20')),
              Container(
                width: 1,
                height: 30,
                color: border,
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Expanded(
                  child: _Mini(label: 'Attendance', value: '$attPct%')),
              Container(
                width: 1,
                height: 30,
                color: border,
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Expanded(child: _Mini(label: 'Behavior', value: 'A')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ActionButton(
                  label: 'Open profile',
                  icon: Icons.arrow_forward_rounded,
                  onTap: () {}),
              const SizedBox(width: 8),
              ActionButton(
                  label: 'Message teacher',
                  icon: Icons.message_outlined,
                  onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  final String label;
  final String value;
  const _Mini({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: muted)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontSize: 13, color: ink, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
