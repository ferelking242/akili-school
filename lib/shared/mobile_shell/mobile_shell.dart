import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/user_entity.dart';
import '../../presentation/providers/auth_providers.dart';
import '../widgets/responsive_role_shell.dart';

// ── Design tokens ──────────────────────────────────────────────────────────
const _pageBg   = Color(0xFFF5EEE6);
const _white    = Colors.white;
const _ink      = Color(0xFF1A0A00);
const _muted    = Color(0xFF7A5C44);
const _border   = Color(0xFFDDCCBB);
const _menuBg   = ScolarisPalette.menuBg;
const _menuAcc  = ScolarisPalette.gold;
const _menuTxt  = Color(0xFFE8DDD0);
const _terra    = ScolarisPalette.terracotta;

const _kEdgeZone = 28.0;

/// SmartSlide MobileShell avec menu africain animé.
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

  bool _edgeDrag = false;
  double _dragStartX = 0;
  double _dragProgressX = 0;
  bool _showEdgeBubble = false;

  double _scale = 1;
  double _xShift = 0;
  double _radius = 0;

  bool get _menuOpen => _menuCtrl.value > 0.01;

  int get _dockHighlight {
    final key = widget.drawerEntries[_pageIndex].labelKey;
    return widget.dockEntries.indexWhere((e) => e.labelKey == key);
  }

  @override
  void initState() {
    super.initState();
    _menuCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 320));
    _menuAnim = CurvedAnimation(
      parent: _menuCtrl,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
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
                      bottom: false,
                      child: Column(children: [
                        _SmartHeader(
                          title: widget.title,
                          user: user,
                          onMenu: _toggleMenu,
                          onSearch: () {},
                          menuOpen: _menuOpen,
                        ),
                        Expanded(
                          child: KeyedSubtree(
                            key: ValueKey(_pageIndex),
                            child: widget.drawerEntries[_pageIndex].page,
                          ),
                        ),
                      ]),
                    ),
                    bottomNavigationBar: _FloatingDock(
                      items: widget.dockEntries,
                      currentIndex: _dockHighlight,
                      onTap: (i) {
                        if (_menuOpen) _closeMenu();
                        _navigateTo(widget.dockEntries[i].labelKey);
                      },
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

// ─── Smart Header ─────────────────────────────────────────────────────────
class _SmartHeader extends StatelessWidget {
  final String title;
  final AppUser? user;
  final VoidCallback onMenu;
  final VoidCallback onSearch;
  final bool menuOpen;

  const _SmartHeader({
    required this.title, required this.user,
    required this.onMenu, required this.onSearch,
    required this.menuOpen,
  });

  @override
  Widget build(BuildContext context) {
    final initials = (user?.fullName.isNotEmpty ?? false)
        ? user!.fullName.substring(0, math.min(2, user!.fullName.length))
        : '?';
    return Container(
      height: 56,
      color: _white,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(children: [
        _HeaderBtn(onTap: onMenu, child: const _HamburgerIcon()),
        // Logo
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
          onTap: () {},
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
                blurRadius: 6, offset: const Offset(0, 2),
              )],
            ),
            child: Center(child: Text(initials.toUpperCase(),
                style: const TextStyle(color: _white, fontSize: 10.5,
                    fontWeight: FontWeight.w700))),
          ),
        ),
      ]),
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

// ─── Slide Menu Panel – African dark green ────────────────────────────────
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

class _SlideMenuPanelState extends State<_SlideMenuPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _iconCtrl;
  String _activeKey = '';

  @override
  void initState() {
    super.initState();
    _iconCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    if (widget.entries.isNotEmpty) _activeKey = widget.entries.first.labelKey;
  }

  @override
  void dispose() {
    _iconCtrl.dispose();
    super.dispose();
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
              // ── Header: account icon left, X right ──────────────
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 16, 0),
                  child: Row(children: [
                    // Avatar circle
                    Container(
                      width: 40, height: 40,
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
                              fontWeight: FontWeight.w800, fontSize: 14))),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(user?.fullName ?? 'Utilisateur',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: _white,
                                fontWeight: FontWeight.w700, fontSize: 13)),
                        Text(user?.email ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: _menuTxt.withOpacity(.6), fontSize: 10.5)),
                      ]),
                    ),
                    // X close button
                    GestureDetector(
                      onTap: () => widget.onSelect(_activeKey),
                      child: Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: _white.withOpacity(.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, color: _white, size: 16),
                      ),
                    ),
                  ]),
                ),
              ),

              // Role badge
              if (user != null) Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _menuAcc.withOpacity(.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _menuAcc.withOpacity(.3)),
                  ),
                  child: Text(user.role.name.toUpperCase(),
                      style: const TextStyle(color: _menuAcc,
                          fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                child: Container(height: 1, color: _white.withOpacity(.08)),
              ),

              // ── Nav items ────────────────────────────────────────
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: widget.entries.length,
                  itemBuilder: (ctx, i) {
                    final e = widget.entries[i];
                    final selected = e.labelKey == _activeKey;
                    return _AnimatedMenuItem(
                      entry: e,
                      selected: selected,
                      index: i,
                      opacity: widget.opacity,
                      onTap: () {
                        setState(() => _activeKey = e.labelKey);
                        widget.onSelect(e.labelKey);
                      },
                    );
                  },
                ),
              ),

              // Divider + logout
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
                  border: selected
                      ? Border.all(color: _menuAcc.withOpacity(.25))
                      : null,
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
                          letterSpacing: selected ? 0 : 0.2,
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

// ─── Floating Dock ────────────────────────────────────────────────────────
class _FloatingDock extends StatelessWidget {
  final List<RoleNavEntry> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _FloatingDock({required this.items, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final show = items.take(5).toList();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x1A000000), blurRadius: 16, offset: Offset(0, 4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(show.length, (i) {
              final e = show[i];
              final sel = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: sel ? _terra.withOpacity(.12) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(e.icon, size: 20,
                              color: sel ? _terra : _muted),
                        ),
                        const SizedBox(height: 2),
                        Text(e.labelKey.tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: sel ? _terra : _muted,
                                fontSize: 9.5,
                                fontWeight: sel ? FontWeight.w700 : FontWeight.w400)),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
