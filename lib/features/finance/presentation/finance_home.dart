import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
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
      title: 'Scolaris',
      groups: const [
        RoleNavGroup(labelKey: 'sections.setup', entries: [
          RoleNavEntry(
              icon: Icons.dashboard_outlined,
              activeIcon: Icons.dashboard_rounded,
              labelKey: 'nav.dashboard',
              page: _FinanceDashboard()),
          RoleNavEntry(
              icon: Icons.payments_outlined,
              activeIcon: Icons.payments_rounded,
              labelKey: 'nav.payments',
              page: FinancePaymentsPage()),
        ]),
        RoleNavGroup(labelKey: 'sections.activity', entries: [
          RoleNavEntry(
              icon: Icons.receipt_long_outlined,
              activeIcon: Icons.receipt_long_rounded,
              labelKey: 'nav.billing',
              page: BillingPage()),
          RoleNavEntry(
              icon: Icons.summarize_outlined,
              activeIcon: Icons.summarize_rounded,
              labelKey: 'nav.reports',
              page: FinanceReportsPage()),
        ]),
        RoleNavGroup(labelKey: 'sections.account', entries: [
          RoleNavEntry(
              icon: Icons.settings_outlined,
              activeIcon: Icons.settings_rounded,
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
        DashStat(icon: Icons.account_balance_wallet_outlined, label: 'Revenus (mois)',  value: '24 580 F'),
        DashStat(icon: Icons.receipt_long_outlined,            label: 'Factures',        value: '187'),
        DashStat(icon: Icons.timelapse_rounded,                label: 'En attente',      value: '3 420 F'),
        DashStat(icon: Icons.summarize_rounded,                label: 'Rapports',        value: '6'),
      ],
      sections: [
        DashSection(
          title: 'Paiements récents',
          count: '12',
          emptyText: 'Aucune activité de paiement pour cette période.',
          footerLabel: 'PAIEMENTS',
          actionLabel: 'Voir paiements',
        ),
        DashSection(
          title: 'Factures impayées',
          count: '3',
          emptyText: 'Aucune facture en souffrance pour cette période.',
          footerLabel: 'FACTURES',
          actionLabel: 'Gérer factures',
          dotColor: Color(0xFFD4540A),
        ),
      ],
      explore: [
        ExploreCard(
          icon: Icons.pie_chart_outline_rounded,
          title: 'Rapport financier',
          description: 'Générez un rapport complet des recettes et dépenses.',
          suggested: true,
        ),
        ExploreCard(
          icon: Icons.send_rounded,
          title: 'Relance automatique',
          description: 'Envoyez des rappels aux familles avec des impayés.',
        ),
      ],
    );
  }
}
