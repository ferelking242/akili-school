import 'package:flutter/material.dart';

import '../../../../shared/data/mock_data.dart';
import '../../../../shared/widgets/page_scaffold.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});
  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final users = MockData.users
        .where((u) => _filter == 'All' || u.role == _filter.toLowerCase())
        .toList();
    return PageScaffold(
      title: 'Users',
      subtitle: '${MockData.users.length} accounts across all roles',
      actions: [
        ActionButton(label: 'Invite', icon: Icons.send_outlined, onTap: () {}),
        const SizedBox(width: 8),
        ActionButton(
            label: 'New user',
            icon: Icons.person_add_alt_1_rounded,
            primary: true,
            onTap: () {}),
      ],
      child: Column(
        children: [
          _FilterRow(
            current: _filter,
            options: const ['All', 'Admin', 'Teacher', 'Finance', 'Surveillance', 'Parent', 'Student'],
            onChange: (v) => setState(() => _filter = v),
          ),
          const SizedBox(height: 12),
          DataPanel(
            title: 'Accounts',
            headerActions: const [SearchInput(hint: 'Search user…')],
            child: DataTablePanel(
              columns: const ['Name', 'Email', 'Role', 'Status', 'Last seen', ''],
              flex: const [3, 3, 2, 2, 2, 2],
              rows: [
                for (final u in users)
                  [
                    Row(children: [
                      Avatar(name: u.name, size: 24),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(u.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: ink, fontSize: 12.5, fontWeight: FontWeight.w600)),
                      ),
                    ]),
                    Text(u.email,
                        style: const TextStyle(fontSize: 12, color: muted)),
                    Align(alignment: Alignment.centerLeft, child: StatusPill.neutral(u.role)),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: u.active
                            ? StatusPill.success('Active')
                            : StatusPill.danger('Inactive')),
                    Text(u.lastSeen,
                        style: const TextStyle(fontSize: 12, color: muted)),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ActionButton(label: 'Manage', onTap: () {}),
                    ),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final String current;
  final List<String> options;
  final ValueChanged<String> onChange;
  const _FilterRow({
    required this.current,
    required this.options,
    required this.onChange,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final o in options) ...[
              GestureDetector(
                onTap: () => onChange(o),
                child: Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: o == current ? ink : cardBg,
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: o == current ? ink : border),
                  ),
                  child: Text(o,
                      style: TextStyle(
                          fontSize: 12,
                          color: o == current ? Colors.white : ink,
                          fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 6),
            ],
          ],
        ),
      ),
    );
  }
}
