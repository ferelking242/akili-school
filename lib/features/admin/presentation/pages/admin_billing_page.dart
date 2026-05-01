import 'package:flutter/material.dart';

import '../../../../shared/data/mock_data.dart';
import '../../../../shared/widgets/page_scaffold.dart';

class AdminBillingPage extends StatelessWidget {
  const AdminBillingPage({super.key});
  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Billing overview',
      subtitle: 'Health of the school finances',
      actions: [
        ActionButton(label: 'Export', icon: Icons.file_download_outlined, onTap: () {}),
      ],
      child: Column(
        children: [
          DataPanel(
            title: 'This month',
            child: LayoutBuilder(builder: (ctx, c) {
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatBox(label: 'Collected', value: '\$${MockData.totalCollected().toStringAsFixed(0)}', color: const Color(0xFF16A34A)),
                  _StatBox(label: 'Pending',   value: '\$${MockData.totalPending().toStringAsFixed(0)}',   color: const Color(0xFFEA580C)),
                  _StatBox(label: 'Overdue',   value: '\$${MockData.totalOverdue().toStringAsFixed(0)}',   color: const Color(0xFFDC2626)),
                  _StatBox(label: 'Invoices',  value: '${MockData.invoices.length}',                       color: const Color(0xFF6D28D9)),
                ],
              );
            }),
          ),
          const SizedBox(height: 14),
          DataPanel(
            title: 'Recent invoices',
            child: DataTablePanel(
              columns: const ['Invoice', 'Student', 'Amount', 'Status'],
              flex: const [2, 3, 2, 2],
              rows: [
                for (final inv in MockData.invoices.take(5))
                  [
                    Text(inv.number,
                        style: const TextStyle(
                            color: ink, fontSize: 12.5, fontWeight: FontWeight.w600)),
                    Text(inv.student,
                        style: const TextStyle(fontSize: 12.5, color: ink)),
                    Text('\$${inv.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 12.5, color: ink, fontWeight: FontWeight.w700)),
                    Align(alignment: Alignment.centerLeft, child: _statusPill(inv.status)),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }

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

class _StatBox extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatBox({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: subtleBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: muted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 22, color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
