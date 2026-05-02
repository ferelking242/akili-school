import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/data/mock_data.dart';
import '../../../../shared/widgets/page_scaffold.dart';

const _terra  = ScolarisPalette.terracotta;
const _orange = ScolarisPalette.orange;
const _gold   = ScolarisPalette.gold;
const _green  = ScolarisPalette.forestGreen;

class GradesPage extends StatelessWidget {
  const GradesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final grades = MockData.grades;
    final avg = grades.isEmpty
        ? 0.0
        : grades.fold<double>(0, (s, g) => s + g.value) / grades.length;

    final best = grades.isEmpty
        ? null
        : grades.reduce((a, b) => a.value >= b.value ? a : b);

    return PageScaffold(
      title: 'Mes notes',
      subtitle: 'Trimestre 2 · ${grades.length} notes enregistrées',
      actions: [
        ActionButton(
            label: 'Export PDF',
            icon: Icons.download_rounded,
            onTap: () {}),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top metrics ─────────────────────────────────────────────
          Row(children: [
            Expanded(child: _MetricCard(
              label: 'Moyenne générale',
              value: avg.toStringAsFixed(1),
              unit: '/ 20',
              color: avg >= 14 ? _green : avg >= 10 ? _gold : _terra,
              icon: Icons.grading_rounded,
            )),
            const SizedBox(width: 10),
            Expanded(child: _MetricCard(
              label: 'Meilleure matière',
              value: best?.subject.split(' ').first ?? '—',
              unit: best != null ? '${best.value.toStringAsFixed(1)}/20' : '',
              color: _green,
              icon: Icons.emoji_events_outlined,
            )),
            const SizedBox(width: 10),
            Expanded(child: _MetricCard(
              label: 'Rang de classe',
              value: '4',
              unit: '/ 32',
              color: _terra,
              icon: Icons.leaderboard_outlined,
            )),
          ]),
          const SizedBox(height: 16),

          // ── Progress bar ─────────────────────────────────────────────
          DataPanel(
            title: 'Progression vers la mention',
            child: Column(children: [
              Row(children: [
                Expanded(child: Text('Moyenne : ${avg.toStringAsFixed(1)}/20',
                    style: const TextStyle(color: ink, fontSize: 13,
                        fontWeight: FontWeight.w600))),
                _MentionBadge(avg: avg),
              ]),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (avg / 20).clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: const Color(0xFFEEE5D8),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      avg >= 14 ? _green : avg >= 10 ? _gold : _terra),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _BarLabel('0', ''),
                  _BarLabel('10', 'Passable'),
                  _BarLabel('12', 'AB'),
                  _BarLabel('14', 'Bien'),
                  _BarLabel('16', 'TB'),
                  _BarLabel('20', ''),
                ],
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // ── Grade table ──────────────────────────────────────────────
          DataPanel(
            title: 'Toutes les notes',
            child: DataTablePanel(
              columns: const ['Matière', 'Trim.', 'Note', 'Enseignant', 'Date'],
              flex: const [3, 1, 2, 2, 2],
              rows: [
                for (final g in grades)
                  [
                    Text(g.subject, style: const TextStyle(
                        color: ink, fontSize: 12.5, fontWeight: FontWeight.w600)),
                    Text(g.term, style: const TextStyle(fontSize: 12, color: muted)),
                    _GradeChip(value: g.value),
                    Text(g.teacher, style: const TextStyle(fontSize: 12, color: ink)),
                    Text(_fmtDate(g.date),
                        style: const TextStyle(fontSize: 12, color: muted)),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _GradeChip extends StatelessWidget {
  final double value;
  const _GradeChip({required this.value});
  @override
  Widget build(BuildContext context) {
    final color = value >= 16 ? _green
        : value >= 14 ? const Color(0xFF1B5E20)
        : value >= 12 ? _gold
        : value >= 10 ? _orange
        : _terra;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(.3)),
        ),
        child: Text('${value.toStringAsFixed(1)} / 20',
            style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label, value, unit;
  final Color color;
  final IconData icon;
  const _MetricCard({
    required this.label, required this.value,
    required this.unit, required this.color, required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
        boxShadow: const [BoxShadow(
            color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Expanded(child: Text(label, style: const TextStyle(
              fontSize: 10.5, color: muted), overflow: TextOverflow.ellipsis)),
        ]),
        const Spacer(),
        Row(crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: TextStyle(
                  fontSize: 20, color: color, fontWeight: FontWeight.w900)),
              const SizedBox(width: 4),
              Text(unit, style: const TextStyle(
                  fontSize: 11, color: muted, fontWeight: FontWeight.w600)),
            ]),
      ]),
    );
  }
}

class _MentionBadge extends StatelessWidget {
  final double avg;
  const _MentionBadge({required this.avg});
  @override
  Widget build(BuildContext context) {
    final (label, color) = avg >= 16
        ? ('Très Bien', _green)
        : avg >= 14
            ? ('Bien', const Color(0xFF1B5E20))
            : avg >= 12
                ? ('Assez Bien', _gold)
                : avg >= 10
                    ? ('Passable', _orange)
                    : ('Insuffisant', _terra);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(.3)),
      ),
      child: Text(label, style: TextStyle(
          color: color, fontSize: 11, fontWeight: FontWeight.w800)),
    );
  }
}

class _BarLabel extends StatelessWidget {
  final String value;
  final String label;
  const _BarLabel(this.value, this.label);
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: const TextStyle(fontSize: 9, color: muted)),
    if (label.isNotEmpty)
      Text(label, style: const TextStyle(fontSize: 8, color: muted)),
  ]);
}
