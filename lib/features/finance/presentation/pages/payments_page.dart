import 'package:flutter/material.dart';

import '../../../../shared/data/mock_data.dart';
import '../../../../shared/widgets/page_scaffold.dart';

class FinancePaymentsPage extends StatelessWidget {
  const FinancePaymentsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final invoices = MockData.invoices;
    return PageScaffold(
      title: 'Payments',
      subtitle: '${invoices.length} invoices this month',
      actions: [
        ActionButton(label: 'Export CSV', icon: Icons.file_download_outlined, onTap: () {}),
        const SizedBox(width: 8),
        ActionButton(
            label: 'Record payment',
            icon: Icons.add_rounded,
            primary: true,
            onTap: () {}),
      ],
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _Kpi(
                    label: 'Collected',
                    value: '\$${MockData.totalCollected().toStringAsFixed(0)}',
                    color: const Color(0xFF16A34A)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Kpi(
                    label: 'Pending',
                    value: '\$${MockData.totalPending().toStringAsFixed(0)}',
                    color: const Color(0xFFEA580C)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Kpi(
                    label: 'Overdue',
                    value: '\$${MockData.totalOverdue().toStringAsFixed(0)}',
                    color: const Color(0xFFDC2626)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DataPanel(
            title: 'All invoices',
            headerActions: const [SearchInput(hint: 'Search invoice…')],
            child: DataTablePanel(
              columns: const ['Invoice', 'Student', 'Description', 'Due', 'Amount', 'Status'],
              flex: const [2, 3, 3, 2, 2, 2],
              rows: [
                for (final inv in invoices)
                  [
                    Text(inv.number,
                        style: const TextStyle(
                            color: ink, fontSize: 12.5, fontWeight: FontWeight.w600)),
                    Row(children: [
                      Avatar(name: inv.student, size: 22),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(inv.student,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: ink)),
                      ),
                    ]),
                    Text(inv.description,
                        style: const TextStyle(fontSize: 12, color: muted)),
                    Text(_fmtDate(inv.due),
                        style: const TextStyle(fontSize: 12, color: muted)),
                    Text('\$${inv.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 12.5, color: ink, fontWeight: FontWeight.w700)),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: _statusPill(inv.status)),
                  ],
              ],
            ),
          ),
        ],
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

class _Kpi extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Kpi({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: muted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 22, color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
