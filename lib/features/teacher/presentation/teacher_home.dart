import 'package:flutter/material.dart';

import '../../../domain/entities/user_entity.dart';
import '../../../shared/pages/settings_page.dart';
import '../../../shared/widgets/dashboard_scaffold.dart';
import '../../../shared/widgets/qr_panel.dart';
import '../../../shared/widgets/responsive_role_shell.dart';
import 'pages/attendance_today_page.dart';
import 'pages/classes_page.dart';
import 'pages/gradebook_page.dart';

class TeacherHome extends StatelessWidget {
  const TeacherHome({super.key});
  @override
  Widget build(BuildContext context) {
    return ResponsiveRoleShell(
      role: UserRole.teacher,
      title: 'scolaris',
      groups: const [
        RoleNavGroup(labelKey: 'sections.setup', entries: [
          RoleNavEntry(
              icon: Icons.dashboard_outlined,
              labelKey: 'nav.dashboard',
              page: _TeacherDashboard()),
          RoleNavEntry(
              icon: Icons.class_outlined,
              labelKey: 'nav.classes',
              page: TeacherClassesPage()),
        ]),
        RoleNavGroup(labelKey: 'sections.activity', entries: [
          RoleNavEntry(
              icon: Icons.grading_outlined,
              labelKey: 'nav.grades',
              page: GradebookPage()),
          RoleNavEntry(
              icon: Icons.fact_check_outlined,
              labelKey: 'nav.attendance',
              page: AttendanceTodayPage()),
          RoleNavEntry(
              icon: Icons.qr_code_2_outlined,
              labelKey: 'nav.qr',
              page: QrPanel()),
        ]),
        RoleNavGroup(labelKey: 'sections.account', entries: [
          RoleNavEntry(
              icon: Icons.settings_outlined,
              labelKey: 'common.settings',
              page: SettingsPage()),
        ]),
      ],
    );
  }
}

class _TeacherDashboard extends StatelessWidget {
  const _TeacherDashboard();
  @override
  Widget build(BuildContext context) {
    return const DashboardScaffold(
      stats: [
        DashStat(icon: Icons.class_rounded, label: 'Classes', value: '6'),
        DashStat(icon: Icons.people_outline, label: 'Students', value: '178'),
        DashStat(icon: Icons.grading_rounded, label: 'Class average', value: '13.8'),
        DashStat(icon: Icons.assignment_outlined, label: 'Pending tasks', value: '4'),
      ],
      sections: [
        DashSection(
          title: 'My classes today',
          count: '3',
          emptyText: 'No additional classes for this range.',
          footerLabel: 'CLASSES',
          actionLabel: 'View Classes',
        ),
        DashSection(
          title: 'Grading queue',
          count: '4',
          emptyText: 'No assignments waiting to be graded.',
          footerLabel: 'GRADING',
          actionLabel: 'Open Gradebook',
          dotColor: Color(0xFFF59E0B),
        ),
      ],
    );
  }
}
