import 'package:flutter/material.dart';

import '../../../domain/entities/user_entity.dart';
import '../../../shared/pages/settings_page.dart';
import '../../../shared/widgets/dashboard_scaffold.dart';
import '../../../shared/widgets/responsive_role_shell.dart';
import 'pages/billing_page.dart';
import 'pages/payments_page.dart';
import 'pages/reports_page.dart';

class FinanceHome extends StatelessWidget {
  const FinanceHome({super.key});
  @override
  Widget build(BuildContext context) {
    return ResponsiveRoleShell(
      role: UserRole.finance,
      title: 'scolaris',
      groups: const [
        RoleNavGroup(labelKey: 'sections.setup', entries: [
          RoleNavEntry(
              icon: Icons.dashboard_outlined,
              labelKey: 'nav.dashboard',
              page: _FinanceDashboard()),
          RoleNavEntry(
              icon: Icons.payments_outlined,
              labelKey: 'nav.payments',
              page: FinancePaymentsPage()),
        ]),
        RoleNavGroup(labelKey: 'sections.activity', entries: [
          RoleNavEntry(
              icon: Icons.receipt_long_outlined,
              labelKey: 'nav.billing',
              page: BillingPage()),
          RoleNavEntry(
              icon: Icons.summarize_outlined,
              labelKey: 'nav.reports',
              page: FinanceReportsPage()),
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

class _FinanceDashboard extends StatelessWidget {
  const _FinanceDashboard();
  @override
  Widget build(BuildContext context) {
    return const DashboardScaffold(
      stats: [
        DashStat(icon: Icons.account_balance_wallet_outlined, label: 'Revenue (MTD)', value: '\$24,580'),
        DashStat(icon: Icons.receipt_long_outlined, label: 'Invoices', value: '187'),
        DashStat(icon: Icons.timelapse_rounded, label: 'Pending', value: '\$3,420'),
        DashStat(icon: Icons.summarize_rounded, label: 'Reports', value: '6'),
      ],
      sections: [
        DashSection(
          title: 'Recent payments',
          count: '12',
          emptyText: 'No payment activity for this range.',
          footerLabel: 'PAYMENTS',
          actionLabel: 'View Payments',
        ),
        DashSection(
          title: 'Outstanding invoices',
          count: '3',
          emptyText: 'No outstanding invoices for this range.',
          footerLabel: 'INVOICES',
          actionLabel: 'Open Invoices',
          dotColor: Color(0xFFF59E0B),
        ),
      ],
    );
  }
}
