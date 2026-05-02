import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/data/mock_data.dart';
import '../../../../shared/widgets/page_scaffold.dart';

const _terra  = ScolarisPalette.terracotta;
const _orange = ScolarisPalette.orange;
const _gold   = ScolarisPalette.gold;
const _green  = ScolarisPalette.forestGreen;

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});
  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  String _filter = 'Tous';
  final _filters = ['Tous', 'Obligatoire', 'Optionnel'];

  @override
  Widget build(BuildContext context) {
    final courses = MockData.courses;

    return PageScaffold(
      title: 'Mes cours',
      subtitle: '${courses.length} cours actifs ce trimestre',
      actions: [
        ActionButton(label: 'Actualiser', icon: Icons.refresh_rounded, onTap: () {}),
        const SizedBox(width: 8),
        ActionButton(
          label: 'Catalogue',
          icon: Icons.add_rounded,
          primary: true,
          onTap: () {},
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Filter chips ───────────────────────────────────────────
          Row(children: _filters.map((f) {
            final sel = f == _filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _filter = f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel ? _terra : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? _terra : border),
                  ),
                  child: Text(f, style: TextStyle(
                      color: sel ? Colors.white : muted,
                      fontSize: 12, fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
                ),
              ),
            );
          }).toList()),
          const SizedBox(height: 14),

          // ── Course grid ────────────────────────────────────────────
          LayoutBuilder(builder: (ctx, c) {
            final cols = c.maxWidth > 1100 ? 3 : c.maxWidth > 720 ? 2 : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: courses.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 170,
              ),
              itemBuilder: (_, i) => _CourseCard(course: courses[i]),
            );
          }),
        ],
      ),
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
        boxShadow: const [BoxShadow(
            color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: course.color.withOpacity(.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: course.color.withOpacity(.25)),
              ),
              child: Icon(course.icon, color: course.color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(course.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13.5, color: ink, fontWeight: FontWeight.w700)),
              Text(course.teacher, style: const TextStyle(
                  fontSize: 11.5, color: muted)),
            ])),
            StatusPill.neutral(course.code),
          ]),
          const SizedBox(height: 12),

          // Progress bar (mock)
          Row(children: [
            const Text('Progression', style: TextStyle(color: muted, fontSize: 11)),
            const Spacer(),
            Text('${(65 + course.name.length % 30)}%',
                style: TextStyle(color: course.color, fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (65 + course.name.length % 30) / 100,
              minHeight: 6,
              backgroundColor: course.color.withOpacity(.1),
              valueColor: AlwaysStoppedAnimation<Color>(course.color),
            ),
          ),
          const Spacer(),

          // Footer
          Row(children: [
            Icon(Icons.schedule_rounded, size: 12, color: muted),
            const SizedBox(width: 5),
            Text('${course.hoursPerWeek}h / semaine',
                style: const TextStyle(fontSize: 11.5, color: muted)),
            const Spacer(),
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: course.color.withOpacity(.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: course.color.withOpacity(.25)),
                ),
                child: Row(children: [
                  Text('Ouvrir', style: TextStyle(
                      color: course.color, fontSize: 11, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 12, color: course.color),
                ]),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
