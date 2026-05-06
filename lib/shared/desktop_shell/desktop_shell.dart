import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/theme_controller.dart';
import '../../domain/entities/user_entity.dart';
import '../../presentation/providers/auth_providers.dart';

// ── Scolaris African palette ──────────────────────────────────────────────────
const _bg      = Color(0xFFF5EEE6);
const _terra   = Color(0xFF8B1A00);
const _orange  = Color(0xFFD4540A);
const _gold    = Color(0xFFC17F24);
const _green   = Color(0xFF1B5E20);
const _ink     = Color(0xFF1A0A00);
const _muted   = Color(0xFF7A5C44);
const _border  = Color(0xFFDDCCBB);
const _white   = Colors.white;
const _subtle  = Color(0xFFF0E8DC);

// Sidebar — dark African gradient
const _sbBg1   = Color(0xFF1A0A00);
const _sbBg2   = Color(0xFF3E1A00);
const _sbTxt   = Color(0xFFE8DDD0);
const _sbMuted = Color(0xFFB89880);

// ─────────────────────────────────────────────────────────────────────────────
// Data classes (public — used by ResponsiveRoleShell)
// ─────────────────────────────────────────────────────────────────────────────
class DesktopNavGroup {
  final String labelKey;
  final List<DesktopNavItem> items;
  const DesktopNavGroup({required this.labelKey, required this.items});
}

class DesktopNavItem {
  final IconData icon;
  final String labelKey;
  final Widget page;
  const DesktopNavItem({
    required this.icon,
    required this.labelKey,
    required this.page,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Shell
// ─────────────────────────────────────────────────────────────────────────────
class DesktopShell extends ConsumerStatefulWidget {
  final List<DesktopNavGroup> groups;
  final UserRole role;
  final String title;

  const DesktopShell({
    super.key,
    required this.groups,
    required this.role,
    required this.title,
  });

  @override
  ConsumerState<DesktopShell> createState() => _DesktopShellState();
}

class _DesktopShellState extends ConsumerState<DesktopShell> {
  late int _flatIndex;
  bool _collapsed = false;

  @override
  void initState() {
    super.initState();
    _flatIndex = 0;
  }

  List<DesktopNavItem> get _flatItems =>
      [for (final g in widget.groups) ...g.items];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authSessionProvider);
    final sideW = _collapsed ? 64.0 : 220.0;
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Dark African Sidebar ──────────────────────────────────────
            SizedBox(
              width: sideW,
              child: Stack(children: [
                // Gradient background
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_sbBg1, _sbBg2],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                // Subtle African pattern
                Positioned.fill(
                  child: CustomPaint(
                    painter: _SidebarPatternPainter(),
                  ),
                ),
                // Content
                _Sidebar(
                  groups: widget.groups,
                  user: user,
                  role: widget.role,
                  collapsed: _collapsed,
                  currentIndex: _flatIndex,
                  onSelect: (i) => setState(() => _flatIndex = i),
                  onToggle: () => setState(() => _collapsed = !_collapsed),
                ),
              ]),
            ),
            // ── Main area ─────────────────────────────────────────────────
            Expanded(
              child: Column(
                children: [
                  _Header(title: widget.title),
                  Expanded(
                    child: Container(
                      color: _bg,
                      child: _flatItems[_flatIndex].page,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sidebar
// ─────────────────────────────────────────────────────────────────────────────
class _Sidebar extends ConsumerWidget {
  final List<DesktopNavGroup> groups;
  final AppUser? user;
  final UserRole role;
  final bool collapsed;
  final int currentIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onToggle;

  const _Sidebar({
    required this.groups,
    required this.user,
    required this.role,
    required this.collapsed,
    required this.currentIndex,
    required this.onSelect,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _BrandRow(collapsed: collapsed, onToggle: onToggle),
        if (!collapsed)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
            child: _SchoolChip(),
          ),
        const SizedBox(height: 6),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              for (var g = 0; g < groups.length; g++) ...[
                if (!collapsed)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 14, 10, 6),
                    child: Text(
                      groups[g].labelKey.tr().toUpperCase(),
                      style: TextStyle(
                        fontSize: 9.5,
                        letterSpacing: 1.0,
                        color: _gold.withOpacity(.65),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 12),
                ...List.generate(groups[g].items.length, (i) {
                  final flatIdx = _flatIndexFor(g, i);
                  final selected = flatIdx == currentIndex;
                  final it = groups[g].items[i];
                  return _SideItem(
                    icon: it.icon,
                    labelKey: it.labelKey,
                    selected: selected,
                    collapsed: collapsed,
                    onTap: () => onSelect(flatIdx),
                  );
                }),
              ],
            ],
          ),
        ),
        // Divider
        Container(height: 1, color: _white.withOpacity(.08)),
        // Footer
        _FooterBlock(collapsed: collapsed, user: user),
      ],
    );
  }

  int _flatIndexFor(int gIdx, int iIdx) {
    int flat = 0;
    for (var i = 0; i < gIdx; i++) flat += groups[i].items.length;
    return flat + iIdx;
  }
}

// ── Brand row ─────────────────────────────────────────────────────────────────
class _BrandRow extends StatelessWidget {
  final bool collapsed;
  final VoidCallback onToggle;
  const _BrandRow({required this.collapsed, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: collapsed ? 0 : 14),
        child: Row(
          mainAxisAlignment:
              collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            // Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/logo.png',
                width: 32, height: 32,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: _terra,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('S', style: TextStyle(
                        color: _white, fontWeight: FontWeight.w800, fontSize: 15)),
                  ),
                ),
              ),
            ),
            if (!collapsed) ...[
              const SizedBox(width: 10),
              Text(
                AppConfig.appName,
                style: const TextStyle(
                  color: _white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              _SbIconBtn(
                icon: Icons.menu_open_rounded,
                onTap: onToggle,
                size: 18,
              ),
            ] else ...[
              // collapsed toggle accessible via tap on logo area
            ],
          ],
        ),
      ),
    );
  }
}

// ── School chip ───────────────────────────────────────────────────────────────
class _SchoolChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: _white.withOpacity(.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _white.withOpacity(.12)),
        ),
        child: Row(children: [
          Icon(Icons.school_outlined, size: 14, color: _gold.withOpacity(.8)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppConfig.appName,
              style: TextStyle(
                  color: _sbTxt, fontWeight: FontWeight.w600, fontSize: 12.5),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(Icons.unfold_more_rounded, size: 14, color: _sbMuted),
        ]),
      ),
    );
  }
}

// ── Side item ─────────────────────────────────────────────────────────────────
class _SideItem extends StatefulWidget {
  final IconData icon;
  final String labelKey;
  final bool selected;
  final bool collapsed;
  final VoidCallback onTap;
  const _SideItem({
    required this.icon,
    required this.labelKey,
    required this.selected,
    required this.collapsed,
    required this.onTap,
  });

  @override
  State<_SideItem> createState() => _SideItemState();
}

class _SideItemState extends State<_SideItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.selected;
    final bgColor = isActive
        ? _terra
        : _hover
            ? _white.withOpacity(.08)
            : Colors.transparent;
    final iconColor = isActive ? _white : _sbMuted;
    final textColor = isActive ? _white : _sbTxt;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 34,
            padding: EdgeInsets.symmetric(
                horizontal: widget.collapsed ? 0 : 10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              mainAxisAlignment: widget.collapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(widget.icon, size: 16, color: iconColor),
                if (!widget.collapsed) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.labelKey.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: textColor,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isActive)
                    Container(
                      width: 5, height: 5,
                      decoration: BoxDecoration(
                        color: _gold,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Footer block ─────────────────────────────────────────────────────────────
class _FooterBlock extends StatelessWidget {
  final bool collapsed;
  final AppUser? user;
  const _FooterBlock({required this.collapsed, required this.user});

  @override
  Widget build(BuildContext context) {
    if (collapsed) return const SizedBox(height: 60);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 7, height: 7,
              decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50), shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              'Année 2025–26',
              style: TextStyle(
                  fontSize: 11, color: _sbTxt.withOpacity(.8),
                  fontWeight: FontWeight.w600),
            ),
          ]),
          const SizedBox(height: 7),
          _FRow(label: 'Trimestre', value: 'Semestre 2'),
          const SizedBox(height: 3),
          _FRow(label: 'Classes', value: '24 actives'),
          const SizedBox(height: 3),
          _FRow(label: 'Élèves', value: '487'),
        ],
      ),
    );
  }
}

class _FRow extends StatelessWidget {
  final String label;
  final String value;
  const _FRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(label, style: TextStyle(fontSize: 10.5, color: _sbMuted)),
      const Spacer(),
      Text(value, style: const TextStyle(
          fontSize: 10.5, color: _gold, fontWeight: FontWeight.w600)),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────
class _Header extends ConsumerWidget {
  final String title;
  const _Header({required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authSessionProvider);
    final initials = (user?.fullName.isNotEmpty ?? false)
        ? user!.fullName
            .split(' ')
            .map((w) => w.isNotEmpty ? w[0] : '')
            .take(2)
            .join()
            .toUpperCase()
        : '?';

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: _white,
        border: Border(bottom: BorderSide(color: _border.withOpacity(.6))),
        boxShadow: const [
          BoxShadow(
              color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Breadcrumb
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _terra.withOpacity(.06),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              title,
              style: const TextStyle(
                  fontSize: 13, color: _terra, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 14),
          Container(width: 1, height: 16, color: _border),
          const SizedBox(width: 14),
          // Search bar
          Container(
            width: 240,
            height: 34,
            decoration: BoxDecoration(
              color: _subtle,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                const SizedBox(width: 10),
                Icon(Icons.search_rounded, size: 14, color: _muted),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Rechercher élèves, classes…',
                    style: TextStyle(fontSize: 12, color: _muted.withOpacity(.8)),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: _border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('⌘K',
                      style: TextStyle(fontSize: 10, color: _muted)),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Bell
          _IconBtn(
              icon: Icons.notifications_outlined, onTap: () {}, badge: true),
          const SizedBox(width: 2),
          _IconBtn(icon: Icons.help_outline_rounded, onTap: () {}),
          const SizedBox(width: 12),
          Container(width: 1, height: 20, color: _border),
          const SizedBox(width: 12),
          // Avatar popup
          PopupMenuButton<String>(
            tooltip: '',
            position: PopupMenuPosition.under,
            offset: const Offset(0, 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: _border),
            ),
            elevation: 4,
            color: _white,
            itemBuilder: (_) => [
              PopupMenuItem<String>(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullName ?? '—',
                      style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: _ink),
                    ),
                    Text(user?.email ?? '',
                        style: TextStyle(fontSize: 11, color: _muted)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'settings',
                child: Row(children: const [
                  Icon(Icons.settings_outlined, size: 14),
                  SizedBox(width: 8),
                  Text('Paramètres', style: TextStyle(fontSize: 12.5)),
                ]),
              ),
              PopupMenuItem<String>(
                value: 'theme',
                child: Row(children: const [
                  Icon(Icons.brightness_6_outlined, size: 14),
                  SizedBox(width: 8),
                  Text('Changer le thème', style: TextStyle(fontSize: 12.5)),
                ]),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(children: const [
                  Icon(Icons.logout_rounded, size: 14, color: _terra),
                  SizedBox(width: 8),
                  Text('Se déconnecter',
                      style: TextStyle(fontSize: 12.5, color: _terra)),
                ]),
              ),
            ],
            onSelected: (v) {
              if (v == 'logout') ref.read(signOutUseCaseProvider)();
              if (v == 'theme') {
                ref.read(themeControllerProvider.notifier).toggleBrightness();
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_terra, _orange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: [
                      BoxShadow(
                          color: _terra.withOpacity(.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                          color: _white,
                          fontWeight: FontWeight.w800,
                          fontSize: 11),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: _muted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// African hexagonal pattern painter (sidebar background texture)
// ─────────────────────────────────────────────────────────────────────────────
class _SidebarPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x0DFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    const r = 18.0;
    final dx = r * math.sqrt(3);
    final dy = r * 1.5;

    for (double y = -r; y < size.height + r * 2; y += dy) {
      for (double x = -dx; x < size.width + dx; x += dx) {
        final offset = ((y / dy).floor() % 2 == 0) ? 0.0 : dx / 2;
        _drawHex(canvas, paint, Offset(x + offset, y), r);
      }
    }
  }

  void _drawHex(Canvas canvas, Paint paint, Offset center, double r) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = math.pi / 180 * (60 * i - 30);
      final p = Offset(center.dx + r * math.cos(angle),
          center.dy + r * math.sin(angle));
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────
class _SbIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  const _SbIconBtn(
      {required this.icon, required this.onTap, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Icon(icon, size: size, color: _sbMuted),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final bool badge;
  const _IconBtn({
    required this.icon,
    required this.onTap,
    this.size = 18,
    this.badge = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, size: size, color: _muted),
            if (badge)
              Positioned(
                top: -2, right: -2,
                child: Container(
                  width: 7, height: 7,
                  decoration: const BoxDecoration(
                      color: _terra, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
