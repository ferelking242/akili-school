import 'package:flutter/material.dart';

import '../../../domain/entities/user_entity.dart';
import '../../../shared/pages/settings_page.dart';
import '../../../shared/widgets/dashboard_scaffold.dart';
import '../../../shared/widgets/qr_panel.dart';
import '../../../shared/widgets/responsive_role_shell.dart';
import 'pages/attendance_log_page.dart';
import 'pages/students_list_page.dart';

class SurveillanceHome extends StatelessWidget {
  const SurveillanceHome({super.key});
  @override
  Widget build(BuildContext context) {
    return ResponsiveRoleShell(
      role: UserRole.surveillance,
      title: 'scolaris',
      groups: const [
        RoleNavGroup(labelKey: 'sections.setup', entries: [
          RoleNavEntry(
              icon: Icons.dashboard_outlined,
              labelKey: 'nav.dashboard',
              page: _SurvDashboard()),
          RoleNavEntry(
              icon: Icons.qr_code_2_outlined,
              labelKey: 'nav.qr',
              page: QrPanel()),
        ]),
        RoleNavGroup(labelKey: 'sections.activity', entries: [
          RoleNavEntry(
              icon: Icons.fact_check_outlined,
              labelKey: 'nav.attendance',
              page: AttendanceLogPage()),
          RoleNavEntry(
              icon: Icons.people_outline,
              labelKey: 'nav.students',
              page: StudentsListPage()),
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

class _SurvDashboard extends StatelessWidget {
  const _SurvDashboard();
  @override
  Widget build(BuildContext context) {
    return const DashboardScaffold(
      stats: [
        DashStat(icon: Icons.check_circle_outline, label: 'Attendance Rate', value: '94%'),
        DashStat(icon: Icons.cancel_outlined, label: 'Absences', value: '12'),
        DashStat(icon: Icons.qr_code_scanner, label: 'QR Scans', value: '341'),
        DashStat(icon: Icons.warning_amber_outlined, label: 'Active alerts', value: '2'),
      ],
      sections: [
        DashSection(
          title: 'Late arrivals',
          count: '2',
          emptyText: 'No late arrivals for this range.',
          footerLabel: 'GATE SCANS',
          actionLabel: 'View Log',
        ),
        DashSection(
          title: 'Unexcused absences',
          count: '1',
          emptyText: 'No flagged absences for this range.',
          footerLabel: 'ABSENCES',
          actionLabel: 'Flag Absences',
          dotColor: Color(0xFFEF4444),
        ),
      ],
    );
  }
}
