import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/user_entity.dart';
import '../widgets/responsive_role_shell.dart';

/// Curved Android-style drawer.
///
/// A slim white panel pinned to the left edge with rounded outer corners that
/// "carve" into the dark scrim — giving the curved-cutout look you see in
/// premium Android UIs.
class CurvedDrawer extends StatelessWidget {
  final List<RoleNavEntry> entries;
  final String currentLabelKey;
  final AppUser? user;
  final ValueChanged<RoleNavEntry> onSelect;
  const CurvedDrawer({
    super.key,
    required this.entries,
    required this.currentLabelKey,
    required this.user,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: PhysicalShape(
          color: Colors.white,
          elevation: 8,
          shadowColor: Colors.black26,
          clipper: _CurvedShapeClipper(),
          child: SizedBox(
            width: 220,
            child: _DrawerBody(
              entries: entries,
              currentLabelKey: currentLabelKey,
              user: user,
              onSelect: onSelect,
            ),
          ),
        ),
      ),
    );
  }
}

class _CurvedShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const radius = 28.0;
    final p = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width - radius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, radius)
      ..lineTo(size.width, size.height - radius)
      ..quadraticBezierTo(
          size.width, size.height, size.width - radius, size.height)
      ..lineTo(0, size.height)
      ..close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _DrawerBody extends StatelessWidget {
  final List<RoleNavEntry> entries;
  final String currentLabelKey;
  final AppUser? user;
  final ValueChanged<RoleNavEntry> onSelect;
  const _DrawerBody({
    required this.entries,
    required this.currentLabelKey,
    required this.user,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('S',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                ),
              ),
              const SizedBox(width: 10),
              const Text('Scolaris',
                  style: TextStyle(
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
            ],
          ),
        ),
        if (user != null) ...[
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F2F4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: const Color(0xFFE9D5FF),
                    child: Text(
                      (user!.fullName.isNotEmpty ? user!.fullName.substring(0,1) : "?").toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF6D28D9),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user!.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827))),
                        Text(user!.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 10.5, color: Color(0xFF6B7280))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 14),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              for (final e in entries)
                _DrawerItem(
                  entry: e,
                  selected: e.labelKey == currentLabelKey,
                  onTap: () => onSelect(e),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final RoleNavEntry entry;
  final bool selected;
  final VoidCallback onTap;
  const _DrawerItem({
    required this.entry,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final color =
        selected ? const Color(0xFF111827) : const Color(0xFF374151);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: selected ? const Color(0xFFF1F2F4) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Icon(entry.icon,
                    size: 16,
                    color: selected
                        ? const Color(0xFF111827)
                        : const Color(0xFF6B7280)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    entry.labelKey.tr(),
                    style: TextStyle(
                      color: color,
                      fontSize: 12.5,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
