import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/user_entity.dart';
import '../../presentation/providers/auth_providers.dart';

const _terra  = ScolarisPalette.terracotta;
const _orange = ScolarisPalette.orange;
const _gold   = ScolarisPalette.gold;
const _green  = ScolarisPalette.forestGreen;
const _ink    = Color(0xFF1A0A00);
const _muted  = Color(0xFF7A5C44);
const _border = Color(0xFFDDCCBB);
const _white  = Colors.white;
const _bg     = Color(0xFFF5EEE6);
const _dark   = Color(0xFF1A0A00);

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authSessionProvider);
    final name = user?.fullName ?? 'Utilisateur';
    final email = user?.email ?? '';
    final role = user?.role.name ?? 'student';
    final initials = name.isNotEmpty
        ? name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
          // ── Cover + Avatar ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _ProfileHeader(
                name: name, email: email, role: role, initials: initials),
          ),

          // ── Stats row ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: _StatsRow(),
            ),
          ),

          // ── Info card ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _InfoCard(user: user),
            ),
          ),

          // ── Quick actions ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: _QuickActions(),
            ),
          ),

          // ── Settings sections ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: _SettingsSection(),
            ),
          ),

          // ── Sign out ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
              child: GestureDetector(
                onTap: () => ref.read(signOutUseCaseProvider)(),
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _terra.withOpacity(.3)),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.logout_rounded, size: 18, color: _terra),
                    const SizedBox(width: 8),
                    const Text('Se déconnecter',
                        style: TextStyle(color: _terra, fontSize: 15,
                            fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Profile Header ─────────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final String initials;
  const _ProfileHeader({
    required this.name, required this.email,
    required this.role, required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Cover
        Container(
          height: 200,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A0A00), _terra],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(children: [
            CustomPaint(painter: _AfricanCoverPainter(), child: const SizedBox.expand()),
            // Back button
            Positioned(
              top: 0, left: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: _white.withOpacity(.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: _white, size: 20),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0, right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: _white.withOpacity(.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit_rounded, color: _white, size: 18),
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ),

        // Avatar
        Positioned(
          bottom: -44, left: 20,
          child: Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_terra, _orange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: _white, width: 4),
              boxShadow: [BoxShadow(
                color: _terra.withOpacity(.3), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: Center(
              child: Text(initials, style: const TextStyle(
                  color: _white, fontSize: 28, fontWeight: FontWeight.w900)),
            ),
          ),
        ),

        // Name + role (right side of cover)
        Positioned(
          bottom: -40, right: 20,
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(name,
                style: const TextStyle(color: _ink, fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _terra.withOpacity(.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _terra.withOpacity(.3)),
              ),
              child: Text(role.toUpperCase(),
                  style: const TextStyle(color: _terra, fontSize: 10,
                      fontWeight: FontWeight.w800, letterSpacing: 1)),
            ),
          ]),
        ),

        // Height placeholder
        const SizedBox(height: 256),
      ],
    );
  }
}

// ── Stats Row ──────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 60),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: const [BoxShadow(
            color: Color(0x0C000000), blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: IntrinsicHeight(
        child: Row(children: [
          _Stat(value: '15.4', label: 'Moyenne', color: _terra),
          _StatDivider(),
          _Stat(value: '96%', label: 'Présence', color: _green),
          _StatDivider(),
          _Stat(value: '4', label: 'Cours actifs', color: _gold),
          _StatDivider(),
          _Stat(value: '47', label: 'Jours restants', color: _orange),
        ]),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _Stat({required this.value, required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Text(value, style: TextStyle(color: color, fontSize: 18,
            fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        Text(label, textAlign: TextAlign.center,
            style: const TextStyle(color: _muted, fontSize: 10, height: 1.2)),
      ]),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, color: _border, margin: const EdgeInsets.symmetric(vertical: 8));
  }
}

// ── Info Card ──────────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final AppUser? user;
  const _InfoCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: const [BoxShadow(
            color: Color(0x0C000000), blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.person_outline_rounded, size: 16, color: _terra),
          const SizedBox(width: 8),
          const Text('Informations personnelles',
              style: TextStyle(color: _ink, fontSize: 14, fontWeight: FontWeight.w700)),
          const Spacer(),
          GestureDetector(
            onTap: () {},
            child: const Text('Modifier',
                style: TextStyle(color: _terra, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 14),
        _InfoRow(icon: Icons.mail_outline_rounded, label: 'Email',
            value: user?.email ?? '—'),
        const SizedBox(height: 10),
        _InfoRow(icon: Icons.badge_outlined, label: 'ID étudiant',
            value: 'SCO-2024-${user?.role.name.toUpperCase() ?? '001'}'),
        const SizedBox(height: 10),
        _InfoRow(icon: Icons.school_outlined, label: 'Établissement',
            value: 'Lycée Scolaris — Dakar'),
        const SizedBox(height: 10),
        _InfoRow(icon: Icons.calendar_today_outlined, label: 'Inscrit depuis',
            value: 'Septembre 2024'),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: _terra.withOpacity(.08),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, size: 16, color: _terra),
      ),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: _muted, fontSize: 11)),
        Text(value, style: const TextStyle(color: _ink, fontSize: 13,
            fontWeight: FontWeight.w600)),
      ]),
    ]);
  }
}

// ── Quick Actions ──────────────────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.share_rounded,         'Partager',   _terra),
      (Icons.qr_code_rounded,       'Mon QR',     _gold),
      (Icons.download_rounded,      'Bulletins',  _green),
      (Icons.notifications_rounded, 'Alertes',    _orange),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions.map((a) => GestureDetector(
          onTap: () {},
          child: Column(children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: a.$3.withOpacity(.1),
                shape: BoxShape.circle,
              ),
              child: Icon(a.$1, color: a.$3, size: 22),
            ),
            const SizedBox(height: 6),
            Text(a.$2, style: const TextStyle(color: _ink, fontSize: 11,
                fontWeight: FontWeight.w600)),
          ]),
        )).toList(),
      ),
    );
  }
}

// ── Settings Section ───────────────────────────────────────────────────────
class _SettingsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.palette_outlined,        'Apparence & Thème',     _terra),
      (Icons.language_outlined,        'Langue',                _gold),
      (Icons.notifications_outlined,   'Notifications',         _orange),
      (Icons.privacy_tip_outlined,     'Confidentialité',       _green),
      (Icons.help_outline_rounded,     'Aide & Support',        _muted),
      (Icons.info_outline_rounded,     'À propos de Scolaris',  _muted),
    ];
    return Container(
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Column(
            children: [
              GestureDetector(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: (item.$3 as Color).withOpacity(.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.$1, size: 18, color: item.$3 as Color),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Text(item.$2,
                        style: const TextStyle(color: _ink, fontSize: 14,
                            fontWeight: FontWeight.w500))),
                    const Icon(Icons.chevron_right_rounded, color: _muted, size: 18),
                  ]),
                ),
              ),
              if (i < items.length - 1)
                const Divider(height: 1, indent: 66, color: Color(0xFFEEE5D8)),
            ],
          );
        }),
      ),
    );
  }
}

// ── African Cover Painter ──────────────────────────────────────────────────
class _AfricanCoverPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (int i = 0; i < 8; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.5),
        30.0 + i * 22,
        p,
      );
    }
    final p2 = Paint()
      ..color = ScolarisPalette.gold.withOpacity(.08)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.1 + i * 40, size.height * 0.2),
        8,
        p2,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
