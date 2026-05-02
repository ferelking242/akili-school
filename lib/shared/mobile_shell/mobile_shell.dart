import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/user_entity.dart';
import '../../presentation/providers/auth_providers.dart';
import '../pages/notifications_page.dart';
import '../pages/search_page.dart';
import '../widgets/responsive_role_shell.dart';

const _pageBg  = Color(0xFFF5EEE6);
const _white   = Colors.white;
const _ink     = Color(0xFF1A0A00);
const _muted   = Color(0xFF7A5C44);
const _border  = Color(0xFFDDCCBB);
const _menuBg  = ScolarisPalette.menuBg;
const _menuAcc = ScolarisPalette.gold;
const _menuTxt = Color(0xFFE8DDD0);
const _terra   = ScolarisPalette.terracotta;

const _kEdgeZone = 28.0;

class MobileShell extends ConsumerStatefulWidget {
  final List<RoleNavEntry> dockEntries;
  final List<RoleNavEntry> drawerEntries;
  final UserRole role;
  final String title;
  const MobileShell({
    super.key,
    required this.dockEntries,
    required this.drawerEntries,
    required this.role,
    required this.title,
  });

  @override
  ConsumerState<MobileShell> createState() => _MobileShellState();
}

class _MobileShellState extends ConsumerState<MobileShell>
    with SingleTickerProviderStateMixin {
  int _pageIndex = 0;

  late final AnimationController _menuCtrl;
  late final Animation<double> _menuAnim;

  bool   _edgeDrag       = false;
  double _dragStartX     = 0;
  double _dragProgressX  = 0;
  bool   _showEdgeBubble = false;

  double _scale  = 1;
  double _xShift = 0;
  double _radius = 0;

  bool get _menuOpen => _menuCtrl.value > 0.01;

  @override
  void initState() {
    super.initState();
    _menuCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320));
    _menuAnim = CurvedAnimation(
        parent: _menuCtrl,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic);
    _menuCtrl.addListener(_onAnim);
  }

  void _onAnim() {
    final t = _menuAnim.value;
    setState(() {
      _scale  = 1 - 0.12 * t;
      _xShift = 0.65 * t;
      _radius = 28 * t;
    });
  }

  @override
  void dispose() {
    _menuCtrl.removeListener(_onAnim);
    _menuCtrl.dispose();
    super.dispose();
  }

  void _openMenu()   => _menuCtrl.animateTo(1);
  void _closeMenu()  => _menuCtrl.animateTo(0);
  void _toggleMenu() => _menuOpen ? _closeMenu() : _openMenu();

  void _navigateTo(String labelKey) {
    final idx = widget.drawerEntries.indexWhere((e) => e.labelKey == labelKey);
    if (idx >= 0) setState(() => _pageIndex = idx);
  }

  void _onDragStart(DragStartDetails d) {
    _dragStartX = d.localPosition.dx;
    _edgeDrag   = !_menuOpen && _dragStartX < _kEdgeZone;
    if (_edgeDrag) setState(() { _showEdgeBubble = true; _dragProgressX = 0; });
  }

  void _onDragUpdate(DragUpdateDetails d) {
    final delta = d.delta.dx;
    if (_edgeDrag) {
      _dragProgressX += delta;
      _menuCtrl.value = (_dragProgressX / 220).clamp(0.0, 1.0);
    } else if (_menuOpen && delta < 0) {
      _menuCtrl.value = (_menuCtrl.value + delta / 260).clamp(0.0, 1.0);
    }
  }

  void _onDragEnd(DragEndDetails d) {
    setState(() => _showEdgeBubble = false);
    final vel = d.primaryVelocity ?? 0;
    if (_edgeDrag) {
      _edgeDrag = false;
      (_menuCtrl.value > 0.42 || vel > 500) ? _openMenu() : _closeMenu();
    } else if (_menuOpen) {
      (_menuCtrl.value < 0.55 || vel < -500) ? _closeMenu() : _openMenu();
    }
  }

  void _openNotifications() {
    if (_menuOpen) _closeMenu();
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const _FullPage(
            title: 'Notifications', child: NotificationsPage())));
  }

  void _openSearch() {
    if (_menuOpen) _closeMenu();
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const _FullPage(
            title: 'Recherche', child: SearchPage())));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final user = ref.watch(authSessionProvider);

    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: _menuBg,
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            // 1 ─ Slide-menu panel
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerLeft,
                child: _SlideMenuPanel(
                  entries: widget.drawerEntries,
                  user: user,
                  onSelect: (key) { _closeMenu(); _navigateTo(key); },
                  onSignOut: () => ref.read(signOutUseCaseProvider)(),
                  opacity: _menuCtrl.value,
                  width: size.width * 0.72,
                ),
              ),
            ),

            // 2 ─ Main content card
            Transform(
              transform: Matrix4.identity()
                ..translate(size.width * _xShift, 0.0)
                ..scale(_scale),
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: _menuOpen ? _closeMenu : null,
                behavior: HitTestBehavior.translucent,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(_radius),
                  child: Scaffold(
                    backgroundColor: _pageBg,
                    body: SafeArea(
                      bottom: true,
                      child: Column(children: [
                        _SmartHeader(
                          title: widget.title,
                          user: user,
                          onMenu: _toggleMenu,
                          onSearch: _openSearch,
                          onNotifications: _openNotifications,
                          pageIndex: _pageIndex,
                          entries: widget.drawerEntries,
                          onTabTap: (i) {
                            if (_menuOpen) _closeMenu();
                            setState(() => _pageIndex = i);
                          },
                        ),
                        Expanded(
                          child: KeyedSubtree(
                            key: ValueKey(_pageIndex),
                            child: widget.drawerEntries[_pageIndex].page,
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
              ),
            ),

            // 3 ─ Edge bubble
            if (_showEdgeBubble || (_menuCtrl.value > 0 && _menuCtrl.value < 0.15))
              Positioned(
                left: 4 + _menuCtrl.value * 12,
                top: size.height * 0.5 - 22,
                child: _EdgeBubble(progress: _menuCtrl.value),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Full Page Wrapper ────────────────────────────────────────────────────
class _FullPage extends StatelessWidget {
  final String title;
  final Widget child;
  const _FullPage({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EEE6),
      body: SafeArea(
        child: Column(children: [
          Container(
            color: _white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5EEE6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_rounded, color: _ink, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(color: _ink, fontSize: 17,
                  fontWeight: FontWeight.w700)),
            ]),
          ),
          Expanded(child: child),
        ]),
      ),
    );
  }
}

// ─── Smart Header with inline tab nav ─────────────────────────────────────
class _SmartHeader extends StatelessWidget {
  final String title;
  final AppUser? user;
  final VoidCallback onMenu;
  final VoidCallback onSearch;
  final VoidCallback onNotifications;
  final int pageIndex;
  final List<RoleNavEntry> entries;
  final ValueChanged<int> onTabTap;

  const _SmartHeader({
    required this.title, required this.user,
    required this.onMenu, required this.onSearch,
    required this.onNotifications,
    required this.pageIndex, required this.entries,
    required this.onTabTap,
  });

  @override
  Widget build(BuildContext context) {
    final initials = (user?.fullName.isNotEmpty ?? false)
        ? user!.fullName.substring(0, math.min(2, user!.fullName.length))
        : '?';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top row
        Container(
          height: 56,
          color: _white,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(children: [
            _HeaderBtn(onTap: onMenu, child: const _HamburgerIcon()),
            ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Image.asset('assets/images/logo.png', width: 26, height: 26,
                  errorBuilder: (_, __, ___) => Container(
                    width: 26, height: 26,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [_terra, ScolarisPalette.orange]),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Center(child: Text('S',
                        style: TextStyle(color: _white, fontSize: 13,
                            fontWeight: FontWeight.w800))),
                  )),
            ),
            const SizedBox(width: 7),
            Text(AppConfig.appName,
                style: const TextStyle(fontSize: 14, color: _ink,
                    fontWeight: FontWeight.w700, letterSpacing: -0.2)),
            const Spacer(),
            _HeaderBtn(onTap: onSearch,
                child: const Icon(Icons.search_rounded, size: 20, color: _muted)),
            _HeaderBtn(
              onTap: onNotifications,
              child: Stack(clipBehavior: Clip.none, children: [
                const Icon(Icons.notifications_outlined, size: 20, color: _muted),
                Positioned(
                  top: -2, right: -2,
                  child: Container(
                    width: 7, height: 7,
                    decoration: const BoxDecoration(color: _terra, shape: BoxShape.circle),
                  ),
                ),
              ]),
            ),
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 30, height: 30,
                margin: const EdgeInsets.only(left: 2, right: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_terra, ScolarisPalette.orange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: [BoxShadow(
                      color: _terra.withOpacity(.25),
                      blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: Center(child: Text(initials.toUpperCase(),
                    style: const TextStyle(color: _white, fontSize: 10.5,
                        fontWeight: FontWeight.w700))),
              ),
            ),
          ]),
        ),

        // Scrollable tab nav bar (replaces dock)
        Container(
          color: _white,
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
            itemCount: entries.length,
            itemBuilder: (ctx, i) {
              final e   = entries[i];
              final sel = i == pageIndex;
              return GestureDetector(
                onTap: () => onTabTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: sel ? _terra : Colors.transparent,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(sel ? (e.activeIcon ?? e.icon) : e.icon,
                        size: 15, color: sel ? _white : _muted),
                    const SizedBox(width: 6),
                    Text(e.labelKey.tr(),
                        style: TextStyle(
                            color: sel ? _white : _muted,
                            fontSize: 12.5,
                            fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
                  ]),
                ),
              );
            },
          ),
        ),

        Container(height: 1, color: const Color(0xFFEEE5D8)),
      ],
    );
  }
}

class _HamburgerIcon extends StatelessWidget {
  const _HamburgerIcon();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 20, height: 2, color: _ink),
        const SizedBox(height: 4),
        Container(width: 14, height: 2, color: _ink),
        const SizedBox(height: 4),
        Container(width: 17, height: 2, color: _ink),
      ],
    );
  }
}

class _HeaderBtn extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _HeaderBtn({required this.child, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: child,
      ),
    );
  }
}

class _EdgeBubble extends StatelessWidget {
  final double progress;
  const _EdgeBubble({required this.progress});
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: (1 - progress * 6).clamp(0.0, 1.0),
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: _terra.withOpacity(.85),
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 12,
              offset: Offset(2, 2))],
        ),
        child: const Center(child: Icon(Icons.chevron_right_rounded,
            size: 26, color: _white)),
      ),
    );
  }
}

// ─── Slide Menu Panel ─────────────────────────────────────────────────────
class _SlideMenuPanel extends StatefulWidget {
  final List<RoleNavEntry> entries;
  final AppUser? user;
  final ValueChanged<String> onSelect;
  final VoidCallback onSignOut;
  final double opacity;
  final double width;

  const _SlideMenuPanel({
    required this.entries, required this.user,
    required this.onSelect, required this.onSignOut,
    required this.opacity, required this.width,
  });

  @override
  State<_SlideMenuPanel> createState() => _SlideMenuPanelState();
}

class _SlideMenuPanelState extends State<_SlideMenuPanel> {
  String _activeKey = '';

  @override
  void initState() {
    super.initState();
    if (widget.entries.isNotEmpty) _activeKey = widget.entries.first.labelKey;
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final initials = (user?.fullName.isNotEmpty ?? false)
        ? user!.fullName.substring(0, math.min(2, user.fullName.length)).toUpperCase()
        : '?';

    return SizedBox(
      width: widget.width,
      child: Opacity(
        opacity: widget.opacity.clamp(0.0, 1.0),
        child: Container(
          color: _menuBg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 16, 0),
                  child: Row(children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_menuAcc, _terra],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: _menuAcc.withOpacity(.5), width: 2),
                      ),
                      child: Center(child: Text(initials,
                          style: const TextStyle(color: _white,
                              fontWeight: FontWeight.w800, fontSize: 16))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(user?.fullName ?? 'Utilisateur',
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: _white,
                                fontWeight: FontWeight.w700, fontSize: 14)),
                        Text(user?.email ?? '',
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: _menuTxt.withOpacity(.6), fontSize: 11)),
                      ]),
                    ),
                    GestureDetector(
                      onTap: () => widget.onSelect(_activeKey),
                      child: Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                            color: _white.withOpacity(.08), shape: BoxShape.circle),
                        child: const Icon(Icons.close_rounded, color: _white, size: 16),
                      ),
                    ),
                  ]),
                ),
              ),
              if (user != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: _menuAcc.withOpacity(.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _menuAcc.withOpacity(.3)),
                    ),
                    child: Text(user.role.name.toUpperCase(),
                        style: const TextStyle(color: _menuAcc,
                            fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                child: Container(height: 1, color: _white.withOpacity(.08)),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: widget.entries.length,
                  itemBuilder: (ctx, i) {
                    final e        = widget.entries[i];
                    final selected = e.labelKey == _activeKey;
                    return _AnimatedMenuItem(
                      entry: e, selected: selected,
                      index: i, opacity: widget.opacity,
                      onTap: () {
                        setState(() => _activeKey = e.labelKey);
                        widget.onSelect(e.labelKey);
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Container(height: 1, color: _white.withOpacity(.08)),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: _LogoutTile(onTap: widget.onSignOut),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedMenuItem extends StatelessWidget {
  final RoleNavEntry entry;
  final bool selected;
  final int index;
  final double opacity;
  final VoidCallback onTap;
  const _AnimatedMenuItem({
    required this.entry, required this.selected,
    required this.index, required this.opacity, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: Offset(-(1 - opacity) * 0.4, 0),
      duration: Duration(milliseconds: 200 + index * 40),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: opacity.clamp(0.0, 1.0),
        duration: Duration(milliseconds: 200 + index * 40),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              splashColor: _menuAcc.withOpacity(.15),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                decoration: BoxDecoration(
                  color: selected ? _white.withOpacity(.10) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: selected ? Border.all(color: _menuAcc.withOpacity(.25)) : null,
                ),
                child: Row(children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: selected ? _menuAcc.withOpacity(.2) : _white.withOpacity(.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(entry.icon, size: 18,
                        color: selected ? _menuAcc : _menuTxt.withOpacity(.7)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(entry.labelKey.tr(),
                        style: TextStyle(
                          color: selected ? _white : _menuTxt.withOpacity(.8),
                          fontSize: 14,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                        )),
                  ),
                  if (selected)
                    Container(
                      width: 5, height: 5,
                      decoration: const BoxDecoration(
                          color: _menuAcc, shape: BoxShape.circle),
                    ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoutTile extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _terra.withOpacity(.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.logout_rounded, size: 18, color: _terra),
            ),
            const SizedBox(width: 14),
            Text('common.logout'.tr(),
                style: TextStyle(color: _terra.withOpacity(.9), fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}
