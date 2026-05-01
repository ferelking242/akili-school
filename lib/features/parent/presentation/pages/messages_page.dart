import 'package:flutter/material.dart';

import '../../../../shared/data/mock_data.dart';
import '../../../../shared/widgets/page_scaffold.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final msgs = MockData.messages;
    return PageScaffold(
      title: 'Messages',
      subtitle: '${msgs.where((m) => m.unread).length} unread',
      actions: [
        ActionButton(
            label: 'Compose',
            icon: Icons.edit_outlined,
            primary: true,
            onTap: () {}),
      ],
      child: DataPanel(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < msgs.length; i++) ...[
              if (i > 0) const Divider(height: 1, color: border),
              _MessageRow(msg: msgs[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _MessageRow extends StatelessWidget {
  final MockMessage msg;
  const _MessageRow({required this.msg});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Avatar(name: msg.from, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(msg.from,
                          style: TextStyle(
                              fontSize: 13,
                              color: ink,
                              fontWeight:
                                  msg.unread ? FontWeight.w700 : FontWeight.w600)),
                      if (msg.unread) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2563EB),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(msg.time,
                          style: const TextStyle(fontSize: 11, color: muted)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(msg.preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12,
                          color: msg.unread ? ink : muted,
                          fontWeight:
                              msg.unread ? FontWeight.w500 : FontWeight.w400)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
