import 'package:flutter/material.dart';

import '../../../../shared/data/mock_data.dart';
import '../../../../shared/widgets/page_scaffold.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final schedule = MockData.schedule;
    final byDay = <String, List<MockScheduleSlot>>{};
    for (final s in schedule) {
      byDay.putIfAbsent(s.day, () => []).add(s);
    }
    const order = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    final days = order.where(byDay.containsKey).toList();
    return PageScaffold(
      title: 'Weekly schedule',
      subtitle: '${schedule.length} sessions this week',
      actions: [
        ActionButton(label: 'Print', icon: Icons.print_rounded, onTap: () {}),
        const SizedBox(width: 8),
        ActionButton(
            label: 'Subscribe (.ics)',
            icon: Icons.calendar_today_rounded,
            primary: true,
            onTap: () {}),
      ],
      child: LayoutBuilder(builder: (ctx, c) {
        final cols = c.maxWidth > 980 ? 5 : c.maxWidth > 620 ? 3 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: days.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 280,
          ),
          itemBuilder: (_, i) =>
              _DayCard(day: days[i], slots: byDay[days[i]]!),
        );
      }),
    );
  }
}

class _DayCard extends StatelessWidget {
  final String day;
  final List<MockScheduleSlot> slots;
  const _DayCard({required this.day, required this.slots});
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
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(day.toUpperCase(),
              style: const TextStyle(
                  fontSize: 11.5,
                  color: muted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7)),
          const SizedBox(height: 8),
          for (final s in slots)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: subtleBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.subject,
                      style: const TextStyle(
                          fontSize: 12.5,
                          color: ink,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text('${s.time}  ·  ${s.room}',
                      style: const TextStyle(fontSize: 11, color: muted)),
                  const SizedBox(height: 1),
                  Text(s.teacher,
                      style: const TextStyle(fontSize: 11, color: muted)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
