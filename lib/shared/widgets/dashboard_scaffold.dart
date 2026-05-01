import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

const _ink = Color(0xFF111827);
const _muted = Color(0xFF6B7280);
const _border = Color(0xFFE5E7EB);
const _white = Colors.white;
const _bg = Color(0xFFF0F0F0);

/// Mem0-inspired dashboard layout used by every role's home page.
class DashboardScaffold extends StatelessWidget {
  final List<DashStat> stats;
  final List<DashSection> sections;
  final List<ExploreCard>? explore;

  const DashboardScaffold({
    super.key,
    required this.stats,
    required this.sections,
    this.explore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _DateRangeBar(),
            const SizedBox(height: 14),
            _StatsGrid(stats: stats),
            const SizedBox(height: 14),
            for (final s in sections) ...[
              _SectionCard(section: s),
              const SizedBox(height: 14),
            ],
            if (explore != null && explore!.isNotEmpty) ...[
              const SizedBox(height: 6),
              const Text(
                'Explore the Platform',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: _ink),
              ),
              const SizedBox(height: 10),
              _ExploreGrid(cards: explore!),
            ],
          ],
        ),
      ),
    );
  }
}

class _DateRangeBar extends StatelessWidget {
  const _DateRangeBar();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RangePill(label: 'Pick a date range', icon: Icons.calendar_today_outlined),
        const SizedBox(width: 8),
        _RangeChip(label: 'All Time', selected: true),
        const SizedBox(width: 6),
        _RangeChip(label: '1d'),
        const SizedBox(width: 6),
        _RangeChip(label: '7d'),
        const SizedBox(width: 6),
        _RangeChip(label: '30d'),
      ],
    );
  }
}

class _RangePill extends StatelessWidget {
  final String label;
  final IconData icon;
  const _RangePill({required this.label, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: _muted),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(fontSize: 12, color: _ink, fontWeight: FontWeight.w500)),
          const SizedBox(width: 6),
          const Icon(Icons.expand_more_rounded, size: 14, color: _muted),
        ],
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  final String label;
  final bool selected;
  const _RangeChip({required this.label, this.selected = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? _white : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12,
              color: selected ? _ink : _muted,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500)),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final List<DashStat> stats;
  const _StatsGrid({required this.stats});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, c) {
      final cols = c.maxWidth > 980 ? 4 : c.maxWidth > 620 ? 2 : 1;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: 86,
        ),
        itemCount: stats.length,
        itemBuilder: (_, i) => _StatCard(stat: stats[i]),
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  final DashStat stat;
  const _StatCard({required this.stat});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(stat.icon, size: 13, color: _muted),
              const SizedBox(width: 6),
              Text(stat.label,
                  style: const TextStyle(
                      fontSize: 12.5, color: _ink, fontWeight: FontWeight.w500)),
              const SizedBox(width: 4),
              const Icon(Icons.info_outline_rounded, size: 12, color: _muted),
            ],
          ),
          const Spacer(),
          Text(stat.value,
              style: const TextStyle(
                  fontSize: 24, color: _ink, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final DashSection section;
  const _SectionCard({required this.section});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(section.title,
                        style: const TextStyle(
                            fontSize: 14,
                            color: _ink,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(section.count,
                        style: const TextStyle(
                            fontSize: 22,
                            color: _ink,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              if (section.actionLabel != null)
                _PrimaryButton(
                  label: section.actionLabel!,
                  onTap: section.onAction ?? () {},
                ),
            ],
          ),
          const SizedBox(height: 28),
          Center(
            child: Text(section.emptyText,
                style: const TextStyle(fontSize: 12.5, color: _muted)),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: section.dotColor ?? const Color(0xFF22C55E),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(section.footerLabel,
                  style: const TextStyle(
                      fontSize: 11.5,
                      color: _muted,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4)),
              const Spacer(),
              const Text('View Breakdown',
                  style: TextStyle(fontSize: 11.5, color: _muted)),
              const SizedBox(width: 6),
              const _MiniSwitch(),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _ink,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

class _MiniSwitch extends StatelessWidget {
  const _MiniSwitch();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 16,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExploreGrid extends StatelessWidget {
  final List<ExploreCard> cards;
  const _ExploreGrid({required this.cards});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, c) {
      final cols = c.maxWidth > 720 ? 2 : 1;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: 92,
        ),
        itemCount: cards.length,
        itemBuilder: (_, i) => _ExploreItem(card: cards[i]),
      );
    });
  }
}

class _ExploreItem extends StatelessWidget {
  final ExploreCard card;
  const _ExploreItem({required this.card});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(card.icon, size: 15, color: const Color(0xFFB45309)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(card.title,
                        style: const TextStyle(
                            fontSize: 13,
                            color: _ink,
                            fontWeight: FontWeight.w700)),
                    if (card.suggested) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: const Text('Suggested',
                            style: TextStyle(
                                fontSize: 9.5,
                                color: Color(0xFFB45309),
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(card.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11.5, color: _muted, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────── data classes ─────────────────────────────

class DashStat {
  final IconData icon;
  final String label;
  final String value;
  const DashStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  // Backward-compat factory used by old call-sites (labelKey + tr).
  factory DashStat.tr({
    required IconData icon,
    required String labelKey,
    required String value,
  }) =>
      DashStat(icon: icon, label: labelKey.tr(), value: value);
}

class DashSection {
  final String title;
  final String count;
  final String emptyText;
  final String footerLabel;
  final Color? dotColor;
  final String? actionLabel;
  final VoidCallback? onAction;
  const DashSection({
    required this.title,
    required this.count,
    required this.emptyText,
    required this.footerLabel,
    this.dotColor,
    this.actionLabel,
    this.onAction,
  });
}

class ExploreCard {
  final IconData icon;
  final String title;
  final String description;
  final bool suggested;
  const ExploreCard({
    required this.icon,
    required this.title,
    required this.description,
    this.suggested = false,
  });
}
