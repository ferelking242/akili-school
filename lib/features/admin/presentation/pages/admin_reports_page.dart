import 'package:flutter/material.dart';

import '../../../../shared/widgets/page_scaffold.dart';

class AdminReportsPage extends StatelessWidget {
  const AdminReportsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Reports',
      subtitle: 'School-wide insights and exports',
      actions: [
        ActionButton(
            label: 'Build report',
            icon: Icons.add_rounded,
            primary: true,
            onTap: () {}),
      ],
      child: Column(
        children: [
          DataPanel(
            title: 'Quick metrics',
            child: LayoutBuilder(builder: (ctx, c) {
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: const [
                  _Tile(label: 'Total users',   value: '1,284', icon: Icons.group_rounded),
                  _Tile(label: 'Active classes', value: '42',    icon: Icons.class_rounded),
                  _Tile(label: 'Avg attendance', value: '94%',   icon: Icons.health_and_safety_rounded),
                  _Tile(label: 'Avg grade',      value: '14.6',  icon: Icons.grading_rounded),
                ],
              );
            }),
          ),
          const SizedBox(height: 14),
          DataPanel(
            title: 'Saved reports',
            child: Column(
              children: const [
                _ReportRow(title: 'School-wide attendance', subtitle: 'Daily aggregate by class', icon: Icons.fact_check_rounded),
                Divider(color: border, height: 1),
                _ReportRow(title: 'Grade distribution',     subtitle: 'Histogram per subject',   icon: Icons.bar_chart_rounded),
                Divider(color: border, height: 1),
                _ReportRow(title: 'Behavior incidents',     subtitle: 'Aggregated by month',     icon: Icons.policy_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _Tile({required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: subtleBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: border),
            ),
            child: Icon(icon, size: 16, color: muted),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: muted, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 18, color: ink, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  const _ReportRow({required this.title, required this.subtitle, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: subtleBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: muted),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, color: ink, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11.5, color: muted)),
              ],
            ),
          ),
          ActionButton(label: 'Open', onTap: () {}),
        ],
      ),
    );
  }
}
