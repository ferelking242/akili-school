import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/data/mock_data.dart';
import '../../../../shared/widgets/page_scaffold.dart';

const _terra  = ScolarisPalette.terracotta;
const _orange = ScolarisPalette.orange;
const _gold   = ScolarisPalette.gold;
const _green  = ScolarisPalette.forestGreen;
const _ink2   = Color(0xFF1A0A00);
const _muted2 = Color(0xFF7A5C44);

const _dayNames = {
  'Mon': 'Lundi',
  'Tue': 'Mardi',
  'Wed': 'Mercredi',
  'Thu': 'Jeudi',
  'Fri': 'Vendredi',
};

const _dayColors = [_terra, _gold, _green, _orange, Color(0xFF5D4037)];

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});
  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  int _selectedDay = 0;

  @override
  Widget build(BuildContext context) {
    final schedule = MockData.schedule;
    const order = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    final byDay = <String, List<MockScheduleSlot>>{};
    for (final s in schedule) {
      byDay.putIfAbsent(s.day, () => []).add(s);
    }
    final days = order.where(byDay.containsKey).toList();
    final today = days.isNotEmpty ? days[_selectedDay.clamp(0, days.length - 1)] : null;
    final todaySlots = today != null ? byDay[today] ?? [] : <MockScheduleSlot>[];

    return PageScaffold(
      title: 'Emploi du temps',
      subtitle: '${schedule.length} sessions cette semaine',
      actions: [
        ActionButton(label: 'Imprimer', icon: Icons.print_rounded, onTap: () {}),
        const SizedBox(width: 8),
        ActionButton(label: 'Exporter (.ics)',
            icon: Icons.calendar_today_rounded, primary: true, onTap: () {}),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Day tabs ─────────────────────────────────────────────
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final sel = i == _selectedDay;
                final color = _dayColors[i % _dayColors.length];
                return GestureDetector(
                  onTap: () => setState(() => _selectedDay = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: sel ? color : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: sel ? color : border),
                      boxShadow: sel ? [BoxShadow(
                          color: color.withOpacity(.2), blurRadius: 8,
                          offset: const Offset(0, 2))] : [],
                    ),
                    child: Text(
                      _dayNames[days[i]] ?? days[i],
                      style: TextStyle(
                          color: sel ? Colors.white : _muted2,
                          fontSize: 13,
                          fontWeight: sel ? FontWeight.w800 : FontWeight.w500),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // ── Today's timeline ─────────────────────────────────────
          if (todaySlots.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border),
              ),
              child: const Text('Aucun cours ce jour-là.',
                  style: TextStyle(color: muted, fontSize: 14)),
            )
          else
            for (int i = 0; i < todaySlots.length; i++) ...[
              _TimelineSlot(
                slot: todaySlots[i],
                color: _dayColors[i % _dayColors.length],
                isLast: i == todaySlots.length - 1,
              ),
              if (i < todaySlots.length - 1) const SizedBox(height: 0),
            ],

          const SizedBox(height: 16),

          // ── Week overview (compact) ───────────────────────────────
          DataPanel(
            title: 'Vue semaine',
            child: LayoutBuilder(builder: (ctx, c) {
              final cols = c.maxWidth > 700 ? 5 : c.maxWidth > 500 ? 3 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: days.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  mainAxisExtent: 110,
                ),
                itemBuilder: (_, i) => _MiniDayCard(
                  day: days[i],
                  slots: byDay[days[i]] ?? [],
                  color: _dayColors[i % _dayColors.length],
                  selected: i == _selectedDay,
                  onTap: () => setState(() => _selectedDay = i),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _TimelineSlot extends StatelessWidget {
  final MockScheduleSlot slot;
  final Color color;
  final bool isLast;
  const _TimelineSlot({required this.slot, required this.color, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Timeline line
        Column(children: [
          Container(width: 12, height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          if (!isLast)
            Expanded(child: Container(width: 2, color: color.withOpacity(.2))),
        ]),
        const SizedBox(width: 12),
        // Card
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
              boxShadow: const [BoxShadow(
                  color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 1))],
            ),
            child: Row(children: [
              Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(slot.subject, style: const TextStyle(
                    color: ink, fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Row(children: [
                  Icon(Icons.schedule_outlined, size: 12, color: color),
                  const SizedBox(width: 4),
                  Text(slot.time, style: TextStyle(
                      color: color, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 10),
                  Icon(Icons.room_outlined, size: 12, color: _muted2),
                  const SizedBox(width: 4),
                  Text(slot.room, style: const TextStyle(
                      color: muted, fontSize: 12)),
                ]),
                const SizedBox(height: 2),
                Row(children: [
                  const Icon(Icons.person_outline_rounded, size: 12, color: muted),
                  const SizedBox(width: 4),
                  Text(slot.teacher, style: const TextStyle(
                      color: muted, fontSize: 11)),
                ]),
              ])),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _MiniDayCard extends StatelessWidget {
  final String day;
  final List<MockScheduleSlot> slots;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _MiniDayCard({
    required this.day, required this.slots,
    required this.color, required this.selected, required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? color : border,
              width: selected ? 1.5 : 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text((_dayNames[day] ?? day).substring(0, 3).toUpperCase(),
              style: TextStyle(
                  fontSize: 10, color: selected ? color : muted,
                  fontWeight: FontWeight.w800, letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Text('${slots.length}', style: TextStyle(
              fontSize: 20, color: selected ? color : ink,
              fontWeight: FontWeight.w900)),
          Text('cours', style: const TextStyle(fontSize: 10, color: muted)),
          const Spacer(),
          Wrap(spacing: 3, runSpacing: 2, children: [
            for (final s in slots.take(3))
              Container(
                width: 6, height: 6,
                decoration: BoxDecoration(color: color.withOpacity(.5), shape: BoxShape.circle),
              ),
          ]),
        ]),
      ),
    );
  }
}
