import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/locales.dart';
import '../../core/theme/theme_controller.dart';
import '../../presentation/providers/auth_providers.dart';
import '../widgets/page_scaffold.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authSessionProvider);
    final theme = ref.watch(themeControllerProvider).mode;
    return PageScaffold(
      title: 'Settings',
      subtitle: 'Profile, appearance, language and account',
      child: Column(
        children: [
          DataPanel(
            title: 'Profile',
            child: Row(
              children: [
                Avatar(name: user?.fullName ?? '?', size: 56),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.fullName ?? '—',
                          style: const TextStyle(
                              fontSize: 15, color: ink, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(user?.email ?? '—',
                          style: const TextStyle(fontSize: 12, color: muted)),
                      const SizedBox(height: 6),
                      Row(children: [
                        StatusPill.neutral(user?.role.name ?? '—'),
                        const SizedBox(width: 6),
                        StatusPill.success('Verified'),
                      ]),
                    ],
                  ),
                ),
                ActionButton(label: 'Edit', icon: Icons.edit_outlined, onTap: () {}),
              ],
            ),
          ),
          const SizedBox(height: 14),
          DataPanel(
            title: 'Appearance',
            child: Column(
              children: [
                _Row(
                  label: 'Theme',
                  trailing: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode_outlined, size: 14), label: Text('Light')),
                      ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode_outlined, size: 14), label: Text('Dark')),
                      ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.desktop_mac_outlined, size: 14), label: Text('System')),
                    ],
                    selected: {theme},
                    showSelectedIcon: false,
                    onSelectionChanged: (s) =>
                        ref.read(themeControllerProvider.notifier).setMode(s.first),
                  ),
                ),
                const Divider(color: border, height: 16),
                _Row(
                  label: 'Language',
                  trailing: DropdownButton<Locale>(
                    value: context.locale,
                    underline: const SizedBox.shrink(),
                    items: AppLocales.supported.map((l) {
                      return DropdownMenuItem(
                        value: l,
                        child: Text(AppLocales.label(l),
                            style: const TextStyle(fontSize: 12.5, color: ink)),
                      );
                    }).toList(),
                    onChanged: (l) {
                      if (l != null) context.setLocale(l);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          DataPanel(
            title: 'Notifications',
            child: Column(
              children: const [
                _ToggleRow(label: 'Email digest', value: true),
                Divider(color: border, height: 16),
                _ToggleRow(label: 'Push notifications', value: true),
                Divider(color: border, height: 16),
                _ToggleRow(label: 'Weekly report', value: false),
              ],
            ),
          ),
          const SizedBox(height: 14),
          DataPanel(
            title: 'Account',
            child: Column(
              children: [
                _Row(
                  label: 'Sign out',
                  trailing: ActionButton(
                    label: 'Sign out',
                    icon: Icons.logout_rounded,
                    onTap: () => ref.read(signOutUseCaseProvider)(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final Widget trailing;
  const _Row({required this.label, required this.trailing});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 13, color: ink, fontWeight: FontWeight.w600)),
        ),
        trailing,
      ],
    );
  }
}

class _ToggleRow extends StatefulWidget {
  final String label;
  final bool value;
  const _ToggleRow({required this.label, required this.value});
  @override
  State<_ToggleRow> createState() => _ToggleRowState();
}

class _ToggleRowState extends State<_ToggleRow> {
  late bool _v = widget.value;
  @override
  Widget build(BuildContext context) {
    return _Row(
      label: widget.label,
      trailing: Switch(
        value: _v,
        onChanged: (v) => setState(() => _v = v),
      ),
    );
  }
}
