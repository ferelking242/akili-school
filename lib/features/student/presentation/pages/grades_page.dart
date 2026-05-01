import 'package:flutter/material.dart';

import '../../../../shared/data/mock_data.dart';
import '../../../../shared/widgets/page_scaffold.dart';

class GradesPage extends StatelessWidget {
  const GradesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final grades = MockData.grades;
    final avg = grades.fold<double>(0, (s, g) => s + g.value) / grades.length;
    return PageScaffold(
      title: 'My grades',
      subtitle: 'Trimester 2 — ${grades.length} grades recorded',
      actions: [
        ActionButton(
            label: 'Export PDF',
            icon: Icons.download_rounded,
            onTap: () {}),
      ],
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'Term average',
                  value: avg.toStringAsFixed(1),
                  unit: '/ 20',
                  color: const Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  label: 'Best subject',
                  value: 'Biology',
                  unit: '18.0',
                  color: const Color(0xFF0891B2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  label: 'Class rank',
                  value: '4',
                  unit: '/ 28',
                  color: const Color(0xFF6D28D9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DataPanel(
            title: 'Recent grades',
            child: DataTablePanel(
              columns: const ['Subject', 'Term', 'Grade', 'Teacher', 'Date'],
              flex: const [3, 1, 1, 2, 2],
              rows: [
                for (final g in grades)
                  [
                    Text(g.subject,
                        style: const TextStyle(
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
    Color color;
    if (value >= 16) {
      color = const Color(0xFF16A34A);
    } else if (value >= 12) {
      color = const Color(0xFF0891B2);
    } else if (value >= 10) {
      color = const Color(0xFFEA580C);
    } else {
      color = const Color(0xFFDC2626);
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text('${value.toStringAsFixed(1)} / 20',
            style: TextStyle(
                color: color,
                fontSize: 11.5,
                fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  const _MetricCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });
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
      height: 86,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: muted, fontWeight: FontWeight.w600)),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 22,
                      color: color,
                      fontWeight: FontWeight.w700)),
              const SizedBox(width: 6),
              Text(unit,
                  style: const TextStyle(
                      fontSize: 12, color: muted, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
