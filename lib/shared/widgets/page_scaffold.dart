import 'package:flutter/material.dart';

const ink = Color(0xFF111827);
const muted = Color(0xFF6B7280);
const border = Color(0xFFE5E7EB);
const cardBg = Colors.white;
const pageBg = Color(0xFFF0F0F0);
const subtleBg = Color(0xFFF1F2F4);

/// Common scaffold for every internal page — keeps the mem0 light look.
class PageScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget child;
  const PageScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    required this.child,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      color: pageBg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 18,
                              color: ink,
                              fontWeight: FontWeight.w700)),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(subtitle!,
                            style: const TextStyle(
                                fontSize: 12.5, color: muted)),
                      ],
                    ],
                  ),
                ),
                ...actions,
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class DataPanel extends StatelessWidget {
  final String? title;
  final List<Widget> headerActions;
  final Widget child;
  final EdgeInsetsGeometry padding;
  const DataPanel({
    super.key,
    this.title,
    this.headerActions = const [],
    required this.child,
    this.padding = const EdgeInsets.all(16),
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
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Text(title!,
                        style: const TextStyle(
                            fontSize: 14,
                            color: ink,
                            fontWeight: FontWeight.w700)),
                    const Spacer(),
                    ...headerActions,
                  ],
                ),
              ),
            child,
          ],
        ),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color? bg;
  const StatusPill({
    super.key,
    required this.label,
    required this.color,
    this.bg,
  });

  factory StatusPill.success(String label) =>
      StatusPill(label: label, color: const Color(0xFF166534), bg: const Color(0xFFDCFCE7));
  factory StatusPill.warning(String label) =>
      StatusPill(label: label, color: const Color(0xFF92400E), bg: const Color(0xFFFEF3C7));
  factory StatusPill.danger(String label) =>
      StatusPill(label: label, color: const Color(0xFF991B1B), bg: const Color(0xFFFEE2E2));
  factory StatusPill.info(String label) =>
      StatusPill(label: label, color: const Color(0xFF1E40AF), bg: const Color(0xFFDBEAFE));
  factory StatusPill.neutral(String label) =>
      StatusPill(label: label, color: muted, bg: subtleBg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg ?? subtleBg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10.5, color: color, fontWeight: FontWeight.w700)),
    );
  }
}

class SearchInput extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  const SearchInput({super.key, this.hint = 'Search…', this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 14, color: muted),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: const TextStyle(fontSize: 12.5, color: ink),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(fontSize: 12.5, color: muted),
                isCollapsed: true,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool primary;
  const ActionButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.primary = false,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: primary ? ink : cardBg,
            borderRadius: BorderRadius.circular(8),
            border: primary ? null : Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon,
                    size: 13, color: primary ? Colors.white : ink),
                const SizedBox(width: 6),
              ],
              Text(label,
                  style: TextStyle(
                      color: primary ? Colors.white : ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: subtleBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: muted, size: 22),
          ),
          const SizedBox(height: 10),
          Text(title,
              style: const TextStyle(
                  fontSize: 13, color: ink, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: muted)),
        ],
      ),
    );
  }
}

/// Lightweight, framework-agnostic table.
class DataTablePanel extends StatelessWidget {
  final List<String> columns;
  final List<List<Widget>> rows;
  final List<int>? flex;
  const DataTablePanel({
    super.key,
    required this.columns,
    required this.rows,
    this.flex,
  });

  int _flex(int i) => flex == null || i >= flex!.length ? 1 : flex![i];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: subtleBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Row(
            children: [
              for (var i = 0; i < columns.length; i++)
                Expanded(
                  flex: _flex(i),
                  child: Text(columns[i].toUpperCase(),
                      style: const TextStyle(
                          fontSize: 10.5,
                          color: muted,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6)),
                ),
            ],
          ),
        ),
        for (var r = 0; r < rows.length; r++)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: border)),
              color: r.isEven ? cardBg : const Color(0xFFFAFAFA),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (var c = 0; c < rows[r].length; c++)
                  Expanded(flex: _flex(c), child: rows[r][c]),
              ],
            ),
          ),
      ],
    );
  }
}

class Avatar extends StatelessWidget {
  final String name;
  final Color? color;
  final double size;
  const Avatar({super.key, required this.name, this.color, this.size = 28});
  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';
    final c = color ?? _palette[name.codeUnits.fold<int>(0, (a, b) => a + b) % _palette.length];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: c.withValues(alpha: .2),
        borderRadius: BorderRadius.circular(size / 4),
      ),
      alignment: Alignment.center,
      child: Text(initial,
          style: TextStyle(
              color: c, fontWeight: FontWeight.w700, fontSize: size * .42)),
    );
  }

  static const _palette = [
    Color(0xFF6D28D9),
    Color(0xFF0EA5E9),
    Color(0xFF16A34A),
    Color(0xFFEA580C),
    Color(0xFFDB2777),
    Color(0xFF0891B2),
  ];
}
