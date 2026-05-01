import 'package:flutter/material.dart';

import '../../../../shared/data/mock_data.dart';
import '../../../../shared/widgets/page_scaffold.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final courses = MockData.courses;
    return PageScaffold(
      title: 'My courses',
      subtitle: '${courses.length} active courses this term',
      actions: [
        ActionButton(label: 'Sync', icon: Icons.refresh_rounded, onTap: () {}),
        const SizedBox(width: 8),
        ActionButton(
          label: 'Browse catalog',
          icon: Icons.add_rounded,
          primary: true,
          onTap: () {},
        ),
      ],
      child: LayoutBuilder(builder: (ctx, c) {
        final cols = c.maxWidth > 1100 ? 3 : c.maxWidth > 720 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: courses.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 158,
          ),
          itemBuilder: (_, i) => _CourseCard(course: courses[i]),
        );
      }),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final MockCourse course;
  const _CourseCard({required this.course});
  @override
  Widget build(BuildContext context) {
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
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: course.color.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(course.icon, color: course.color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course.name,
                        style: const TextStyle(
                            fontSize: 13.5,
                            color: ink,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(course.teacher,
                        style: const TextStyle(fontSize: 11.5, color: muted)),
                  ],
                ),
              ),
              StatusPill.neutral(course.code),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 13, color: muted),
              const SizedBox(width: 6),
              Text('${course.hoursPerWeek}h / week',
                  style: const TextStyle(fontSize: 12, color: muted)),
              const Spacer(),
              ActionButton(
                label: 'Open',
                icon: Icons.arrow_forward_rounded,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
