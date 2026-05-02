import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/locales.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_controller.dart';
import '../../presentation/providers/auth_providers.dart';
import 'account_page.dart';

const _terra  = ScolarisPalette.terracotta;
const _orange = ScolarisPalette.orange;
const _gold   = ScolarisPalette.gold;
const _green  = ScolarisPalette.forestGreen;
const _ink    = Color(0xFF1A0A00);
const _muted  = Color(0xFF7A5C44);
const _border = Color(0xFFDDCCBB);
const _white  = Colors.white;
const _bg     = Color(0xFFF5EEE6);

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authSessionProvider);
    final themeMode = ref.watch(themeControllerProvider).mode;
    final locale = context.locale;

    final name     = user?.fullName ?? 'Utilisateur';
    final email    = user?.email ?? '';
    final role     = user?.role.name ?? 'user';
    final initials = name.isNotEmpty
        ? name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
        : '?';

    final themeName = themeMode == ThemeMode.dark
        ? 'Sombre'
        : themeMode == ThemeMode.light ? 'Clair' : 'Système';
    final langName = AppLocales.label(locale);

    return Container(
      color: _bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Mini profile header ────────────────────────────────────
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AccountPage())),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _border),
                  boxShadow: const [BoxShadow(
                      color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
                ),
                child: Row(children: [
                  // Avatar
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [_terra, _orange],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                      shape: BoxShape.circle,
                      border: Border.all(color: _terra.withOpacity(.2), width: 2),
                    ),
                    child: Center(child: Text(initials, style: const TextStyle(
                        color: _white, fontSize: 18, fontWeight: FontWeight.w900))),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(
                          color: _ink, fontSize: 15, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(email, style: const TextStyle(
                          color: _muted, fontSize: 12)),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _terra.withOpacity(.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _terra.withOpacity(.25)),
                        ),
                        child: Text(role.toUpperCase(), style: const TextStyle(
                            color: _terra, fontSize: 9,
                            fontWeight: FontWeight.w800, letterSpacing: 0.8)),
                      ),
                    ],
                  )),
                  const Icon(Icons.chevron_right_rounded, color: _muted, size: 20),
                ]),
              ),
            ),

            const SizedBox(height: 24),

            // ── Section: Compte ────────────────────────────────────────
            _SectionLabel('COMPTE'),
            const SizedBox(height: 8),
            _SettingsCard(items: [
              _SettingsItem(
                icon: Icons.person_outline_rounded,
                color: _terra,
                label: 'Gérer le profil',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AccountPage())),
              ),
              _SettingsItem(
                icon: Icons.lock_outline_rounded,
                color: _orange,
                label: 'Mot de passe & Sécurité',
                onTap: () {},
              ),
              _SettingsItemToggle(
                icon: Icons.notifications_outlined,
                color: _gold,
                label: 'Notifications push',
                value: true,
              ),
              _SettingsItem(
                icon: Icons.language_outlined,
                color: _green,
                label: 'Langue',
                trailing: langName,
                onTap: () => _showLanguagePicker(context, ref),
              ),
            ]),

            const SizedBox(height: 20),

            // ── Section: Apparence ─────────────────────────────────────
            _SectionLabel('APPARENCE'),
            const SizedBox(height: 8),
            _SettingsCard(items: [
              _SettingsItemTheme(
                icon: Icons.palette_outlined,
                color: _terra,
                label: 'Thème',
                currentValue: themeName,
                themeMode: themeMode,
                onChanged: (m) => ref.read(themeControllerProvider.notifier).setMode(m),
              ),
            ]),

            const SizedBox(height: 20),

            // ── Section: Support ───────────────────────────────────────
            _SectionLabel('SUPPORT'),
            const SizedBox(height: 8),
            _SettingsCard(items: [
              _SettingsItem(
                icon: Icons.help_outline_rounded,
                color: _gold,
                label: 'Aide & Centre de support',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.privacy_tip_outlined,
                color: _green,
                label: 'Confidentialité',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.info_outline_rounded,
                color: _muted,
                label: 'À propos de Scolaris',
                trailing: 'v0.1.0',
                onTap: () {},
              ),
            ]),

            const SizedBox(height: 32),

            // ── Sign out ───────────────────────────────────────────────
            GestureDetector(
              onTap: () => ref.read(signOutUseCaseProvider)(),
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _terra.withOpacity(.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _terra.withOpacity(.3)),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.logout_rounded, size: 18, color: _terra),
                  const SizedBox(width: 8),
                  const Text('Se déconnecter', style: TextStyle(
                      color: _terra, fontSize: 15, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _LanguagePicker(),
    );
  }
}

// ── Section label ──────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(text, style: TextStyle(
          color: _muted.withOpacity(.7), fontSize: 11,
          fontWeight: FontWeight.w800, letterSpacing: 1.2)),
    );
  }
}

// ── Settings Card ──────────────────────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  final List<Widget> items;
  const _SettingsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: const [BoxShadow(
            color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        children: List.generate(items.length, (i) => Column(children: [
          items[i],
          if (i < items.length - 1)
            Divider(height: 1, indent: 62, endIndent: 0, color: _border.withOpacity(.5)),
        ])),
      ),
    );
  }
}

// ── Settings Item ──────────────────────────────────────────────────────────
class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String? trailing;
  final VoidCallback? onTap;
  const _SettingsItem({
    required this.icon, required this.color,
    required this.label, this.trailing, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: const TextStyle(
                color: _ink, fontSize: 14, fontWeight: FontWeight.w500))),
            if (trailing != null) ...[
              Text(trailing!, style: TextStyle(
                  color: _muted.withOpacity(.8), fontSize: 12,
                  fontWeight: FontWeight.w500)),
              const SizedBox(width: 4),
            ],
            const Icon(Icons.chevron_right_rounded, color: _muted, size: 18),
          ]),
        ),
      ),
    );
  }
}

// ── Settings Item Toggle ───────────────────────────────────────────────────
class _SettingsItemToggle extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String label;
  final bool value;
  const _SettingsItemToggle({
    required this.icon, required this.color,
    required this.label, required this.value,
  });
  @override
  State<_SettingsItemToggle> createState() => _SettingsItemToggleState();
}

class _SettingsItemToggleState extends State<_SettingsItemToggle> {
  late bool _v;
  @override
  void initState() { super.initState(); _v = widget.value; }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(widget.icon, size: 18, color: widget.color),
        ),
        const SizedBox(width: 14),
        Expanded(child: Text(widget.label, style: const TextStyle(
            color: _ink, fontSize: 14, fontWeight: FontWeight.w500))),
        Switch(
          value: _v,
          activeColor: _terra,
          onChanged: (v) => setState(() => _v = v),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ]),
    );
  }
}

// ── Settings Item Theme ────────────────────────────────────────────────────
class _SettingsItemTheme extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String currentValue;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onChanged;
  const _SettingsItemTheme({
    required this.icon, required this.color, required this.label,
    required this.currentValue, required this.themeMode, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 14),
            Text(label, style: const TextStyle(
                color: _ink, fontSize: 14, fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(currentValue, style: TextStyle(
                color: _muted.withOpacity(.8), fontSize: 12)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            const SizedBox(width: 50),
            Expanded(
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode_outlined, size: 14),
                      label: Text('Clair')),
                  ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode_outlined, size: 14),
                      label: Text('Sombre')),
                  ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.phone_android_outlined, size: 14),
                      label: Text('Auto')),
                ],
                selected: {themeMode},
                showSelectedIcon: false,
                style: ButtonStyle(
                  textStyle: WidgetStateProperty.all(
                      const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                ),
                onSelectionChanged: (s) => onChanged(s.first),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

// ── Language Picker ────────────────────────────────────────────────────────
class _LanguagePicker extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Choisir la langue', style: TextStyle(
              color: _ink, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          ...AppLocales.supported.map((l) {
            final selected = context.locale == l;
            return GestureDetector(
              onTap: () { context.setLocale(l); Navigator.pop(context); },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: selected ? _terra.withOpacity(.08) : _white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: selected ? _terra.withOpacity(.4) : _border),
                ),
                child: Row(children: [
                  Text(AppLocales.label(l), style: TextStyle(
                      color: selected ? _terra : _ink,
                      fontSize: 14, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  if (selected)
                    const Icon(Icons.check_circle_rounded, color: _terra, size: 20),
                ]),
              ),
            );
          }),
        ],
      ),
    );
  }
}
