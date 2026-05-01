import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme_controller.dart';
import '../../domain/entities/user_entity.dart';
import '../../presentation/providers/auth_providers.dart';

/// mem0.ai-style dashboard shell.
///
/// Layout:
///   ┌──────────┬──────────────────────────────────┐
///   │          │ Header (white, content-only)     │
///   │ Sidebar  ├──────────────────────────────────┤
///   │ (white)  │ Content (gray)                   │
///   │          │                                  │
///   └──────────┴──────────────────────────────────┘
/// The visual "concave" corner where sidebar / header / gray meet is
/// produced naturally by the color contrast — no clipper.
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

const _bgColor = Color(0xFFF0F0F0);
const _whiteColor = Colors.white;
const _border = Color(0xFFE5E7EB);
const _activeBg = Color(0xFFF1F2F4);
const _muted = Color(0xFF6B7280);
const _ink = Color(0xFF111827);

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
    final width = _collapsed ? 68.0 : 220.0;
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: width,
              color: _whiteColor,
              child: _Sidebar(
                groups: widget.groups,
                user: user,
                role: widget.role,
                collapsed: _collapsed,
                currentIndex: _flatIndex,
                onSelect: (i) => setState(() => _flatIndex = i),
                onToggle: () => setState(() => _collapsed = !_collapsed),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  _Header(
                    title: widget.title,
                  ),
                  Expanded(
                    child: Container(
                      color: _bgColor,
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: _ProjectRow(collapsed: collapsed),
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
                      style: const TextStyle(
                        fontSize: 10.5,
                        letterSpacing: 0.7,
                        color: _muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 14),
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
        const Divider(height: 1, color: _border),
        _UsageBlock(collapsed: collapsed, user: user),
      ],
    );
  }

  int _flatIndexFor(int gIdx, int iIdx) {
    int flat = 0;
    for (var i = 0; i < gIdx; i++) {
      flat += groups[i].items.length;
    }
    return flat + iIdx;
  }
}

class _BrandRow extends StatelessWidget {
  final bool collapsed;
  final VoidCallback onToggle;
  const _BrandRow({required this.collapsed, required this.onToggle});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: EdgeInsets.symmetric(horizontal: collapsed ? 0 : 14),
      child: Row(
        mainAxisAlignment:
            collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: const Color(0xFF8B1A00),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Center(
              child: Text(
                'S',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          if (!collapsed) ...[
            const SizedBox(width: 10),
            const Text(
              'Scolaris',
              style: TextStyle(
                color: const Color(0xFF8B1A00),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            _IconBtn(icon: Icons.menu_open_rounded, onTap: onToggle, size: 18),
          ],
        ],
      ),
    );
  }
}

class _ProjectRow extends StatelessWidget {
  final bool collapsed;
  const _ProjectRow({required this.collapsed});
  @override
  Widget build(BuildContext context) {
    if (collapsed) {
      return const SizedBox(
        height: 32,
        child: Center(
          child: Icon(Icons.folder_open_rounded, size: 16, color: _muted),
        ),
      );
    }
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: _activeBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: const [
          Icon(Icons.folder_open_rounded, size: 14, color: _muted),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Scolaris',
              style: TextStyle(
                color: const Color(0xFF8B1A00),
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(Icons.unfold_more_rounded, size: 14, color: _muted),
        ],
      ),
    );
  }
}

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
    final bg = widget.selected
        ? _activeBg
        : _hover
            ? const Color(0xFFF7F8FA)
            : Colors.transparent;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            height: 32,
            padding: EdgeInsets.symmetric(
              horizontal: widget.collapsed ? 0 : 10,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: widget.collapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(
                  widget.icon,
                  size: 16,
                  color: widget.selected ? _ink : _muted,
                ),
                if (!widget.collapsed) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.labelKey.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: widget.selected ? _ink : const Color(0xFF374151),
                        fontWeight: widget.selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
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

class _UsageBlock extends StatelessWidget {
  final bool collapsed;
  final AppUser? user;
  const _UsageBlock({required this.collapsed, required this.user});
  @override
  Widget build(BuildContext context) {
    if (collapsed) {
      return const SizedBox(height: 56);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF22C55E),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'School Year 2025–26',
                style: TextStyle(
                  fontSize: 11.5,
                  color: _muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _InfoRow(label: 'Term', value: 'Semester 2'),
          const SizedBox(height: 4),
          _InfoRow(label: 'Classes', value: '24 active'),
          const SizedBox(height: 4),
          _InfoRow(label: 'Students', value: '487'),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: _muted)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
              fontSize: 11,
              color: const Color(0xFF8B1A00),
              fontWeight: FontWeight.w600,
            )),
      ],
    );
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
        ? user!.fullName.substring(0, user.fullName.length >= 2 ? 2 : 1)
        : '?';
    return Container(
      height: 56,
      color: _whiteColor,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // ── Breadcrumb ────────────────────────────────────────────
          Text(
            title,
            style: const TextStyle(
              fontSize: 13.5,
              color: const Color(0xFF8B1A00),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 16),
          Container(width: 1, height: 16, color: _border),
          const SizedBox(width: 16),
          // ── Search bar ────────────────────────────────────────────
          Container(
            width: 240,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                const SizedBox(width: 10),
                const Icon(Icons.search_rounded, size: 14, color: _muted),
                const SizedBox(width: 7),
                const Expanded(
                  child: Text(
                    'Search students, classes…',
                    style: TextStyle(
                      fontSize: 12,
                      color: _muted,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: _border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('⌘K',
                      style: TextStyle(fontSize: 10, color: _muted)),
                ),
              ],
            ),
          ),
          const Spacer(),
          // ── Notification bell ─────────────────────────────────────
          _IconBtn(
            icon: Icons.notifications_outlined,
            onTap: () {},
            badge: true,
          ),
          const SizedBox(width: 4),
          // ── Help ─────────────────────────────────────────────────
          _IconBtn(icon: Icons.help_outline_rounded, onTap: () {}),
          const SizedBox(width: 12),
          Container(width: 1, height: 20, color: _border),
          const SizedBox(width: 12),
          // ── Avatar + popup ────────────────────────────────────────
          PopupMenuButton<String>(
            tooltip: '',
            position: PopupMenuPosition.under,
            offset: const Offset(0, 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: _border),
            ),
            elevation: 4,
            color: Colors.white,
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
                        style: const TextStyle(fontSize: 11, color: _muted)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, size: 14),
                    SizedBox(width: 8),
                    Text('Settings', style: TextStyle(fontSize: 12.5)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'theme',
                child: Row(
                  children: const [
                    Icon(Icons.brightness_6_outlined, size: 14),
                    SizedBox(width: 8),
                    Text('Toggle theme', style: TextStyle(fontSize: 12.5)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, size: 14),
                    SizedBox(width: 8),
                    Text('Sign out', style: TextStyle(fontSize: 12.5)),
                  ],
                ),
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
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x337C3AED),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initials.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: 14, color: _muted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DropdownChip({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: _whiteColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: _muted),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: const Color(0xFF8B1A00), fontWeight: FontWeight.w500)),
          const SizedBox(width: 6),
          const Icon(Icons.unfold_more_rounded, size: 13, color: _muted),
        ],
      ),
    );
  }
}

class _BannerPill extends StatelessWidget {
  final String text;
  final String actionText;
  final VoidCallback onAction;
  const _BannerPill({
    required this.text,
    required this.actionText,
    required this.onAction,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.celebration_outlined, size: 14, color: _muted),
        const SizedBox(width: 6),
        Text(text,
            style: const TextStyle(fontSize: 12, color: _muted)),
      ],
    );
  }
}

class _TextLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final bool underline;
  const _TextLink({
    required this.label,
    required this.onTap,
    this.color,
    this.underline = false,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color ?? _ink,
            fontWeight: FontWeight.w500,
            decoration: underline ? TextDecoration.underline : null,
          ),
        ),
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
        padding: const EdgeInsets.all(5.0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, size: size, color: _muted),
            if (badge)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
