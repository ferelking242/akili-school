import 'package:flutter/material.dart';

import '../../../../shared/data/mock_data.dart';
import '../../../../shared/widgets/page_scaffold.dart';

class ParentPaymentsPage extends StatelessWidget {
  const ParentPaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final invoices = MockData.invoices.take(4).toList();
    final due = invoices
        .where((i) => i.status != InvoiceStatus.paid)
        .fold<double>(0, (a, b) => a + b.amount);
    return PageScaffold(
      title: 'Payments',
      subtitle: 'Tuition, cantine and bus invoices',
      actions: [
        ActionButton(
            label: 'Pay all (\$${due.toStringAsFixed(0)})',
            icon: Icons.credit_card_rounded,
            primary: true,
            onTap: () {}),
      ],
      child: DataPanel(
        title: 'Recent invoices',
        headerActions: const [SearchInput()],
        child: DataTablePanel(
          columns: const ['Invoice', 'Description', 'Due', 'Amount', 'Status', ''],
          flex: const [2, 3, 2, 2, 2, 2],
          rows: [
            for (final inv in invoices)
              [
                Text(inv.number,
                    style: const TextStyle(
                        color: ink, fontSize: 12.5, fontWeight: FontWeight.w600)),
                Text(inv.description,
                    style: const TextStyle(fontSize: 12.5, color: ink)),
                Text(_fmtDate(inv.due),
                    style: const TextStyle(fontSize: 12, color: muted)),
                Text('\$${inv.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 12.5, color: ink, fontWeight: FontWeight.w700)),
                Align(alignment: Alignment.centerLeft, child: _statusPill(inv.status)),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ActionButton(
                    label: inv.status == InvoiceStatus.paid ? 'Receipt' : 'Pay now',
                    onTap: () {},
                    primary: inv.status != InvoiceStatus.paid,
                  ),
                ),
              ],
          ],
        ),
      ),
    );
  }

  static String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  static Widget _statusPill(InvoiceStatus s) {
    switch (s) {
      case InvoiceStatus.paid:
        return StatusPill.success('Paid');
      case InvoiceStatus.pending:
        return StatusPill.warning('Pending');
      case InvoiceStatus.overdue:
        return StatusPill.danger('Overdue');
    }
  }
}
