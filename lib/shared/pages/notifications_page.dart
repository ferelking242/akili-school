import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

const _terra  = ScolarisPalette.terracotta;
const _orange = ScolarisPalette.orange;
const _gold   = ScolarisPalette.gold;
const _green  = ScolarisPalette.forestGreen;
const _ink    = Color(0xFF1A0A00);
const _muted  = Color(0xFF7A5C44);
const _white  = Colors.white;
const _bg     = Color(0xFFF5EEE6);

enum _NotiType { info, success, warning, grade, schedule, payment }

class _Notification {
  final String title;
  final String body;
  final String time;
  final _NotiType type;
  final bool read;
  const _Notification({
    required this.title, required this.body,
    required this.time, required this.type, this.read = false,
  });
}

const _mockNotifications = [
  _Notification(
    title: 'Nouvelle note disponible',
    body: 'Votre note en Mathématiques vient d\'être publiée : 17.5/20. Félicitations !',
    time: 'Il y a 5 min',
    type: _NotiType.grade,
  ),
  _Notification(
    title: 'Cours annulé',
    body: 'Le cours de Physique de 14h00 est annulé. M. Ouédraogo est absent.',
    time: 'Il y a 30 min',
    type: _NotiType.warning,
  ),
  _Notification(
    title: 'Paiement confirmé',
    body: 'Votre frais de scolarité du mois d\'avril a bien été reçu. Merci.',
    time: 'Il y a 2h',
    type: _NotiType.payment,
    read: true,
  ),
  _Notification(
    title: 'Rappel : Devoir à rendre',
    body: 'Vous avez un devoir de Français à rendre demain avant 23h59.',
    time: 'Il y a 3h',
    type: _NotiType.info,
    read: true,
  ),
  _Notification(
    title: 'Emploi du temps mis à jour',
    body: 'Votre planning de la semaine prochaine a été modifié. Consultez les nouveaux horaires.',
    time: 'Hier',
    type: _NotiType.schedule,
    read: true,
  ),
  _Notification(
    title: 'Résultats du trimestre',
    body: 'Les résultats du 2ème trimestre sont disponibles. Votre moyenne générale : 15.4/20.',
    time: 'Hier',
    type: _NotiType.success,
    read: true,
  ),
  _Notification(
    title: 'Réunion parents-professeurs',
    body: 'Une réunion est prévue le 15 Mai à 18h00. La présence des parents est obligatoire.',
    time: 'Il y a 2 jours',
    type: _NotiType.info,
    read: true,
  ),
  _Notification(
    title: 'Nouvelle note en Physique',
    body: 'Votre note en Physique-Chimie : 13.0/20. Des progrès sont possibles !',
    time: 'Il y a 3 jours',
    type: _NotiType.grade,
    read: true,
  ),
];

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final List<bool> _read = List.generate(
      _mockNotifications.length, (i) => _mockNotifications[i].read);

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  List<int> get _unreadIndices => [
    for (int i = 0; i < _mockNotifications.length; i++)
      if (!_read[i]) i
  ];

  List<int> _indicesForTab(int t) {
    if (t == 1) return _unreadIndices;
    if (t == 2) {
      return [for (int i = 0; i < _mockNotifications.length; i++)
        if (_read[i]) i];
    }
    return List.generate(_mockNotifications.length, (i) => i);
  }

  void _markAllRead() => setState(() {
    for (int i = 0; i < _read.length; i++) _read[i] = true;
  });

  void _markRead(int i) => setState(() => _read[i] = true);

  @override
  Widget build(BuildContext context) {
    final unread = _unreadIndices.length;

    return Container(
      color: _bg,
      child: Column(
        children: [
          _NotifHeader(unreadCount: unread, onMarkAll: unread > 0 ? _markAllRead : null),
          _NotifTabs(controller: _tab, unreadCount: unread),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [0, 1, 2].map((t) {
                final indices = _indicesForTab(t);
                if (indices.isEmpty) return _EmptyState(tab: t);
                return _NotifList(
                  notifications: _mockNotifications,
                  indices: indices,
                  readFlags: _read,
                  onTap: _markRead,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifHeader extends StatelessWidget {
  final int unreadCount;
  final VoidCallback? onMarkAll;
  const _NotifHeader({required this.unreadCount, required this.onMarkAll});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Notifications',
              style: TextStyle(color: _ink, fontSize: 20, fontWeight: FontWeight.w800)),
          if (unreadCount > 0)
            Text('$unreadCount non lue${unreadCount > 1 ? 's' : ''}',
                style: const TextStyle(color: _terra, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
        const Spacer(),
        if (unreadCount > 0)
          GestureDetector(
            onTap: onMarkAll,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: _terra.withOpacity(.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _terra.withOpacity(.2)),
              ),
              child: const Text('Tout lire',
                  style: TextStyle(color: _terra, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ),
      ]),
    );
  }
}

class _NotifTabs extends StatelessWidget {
  final TabController controller;
  final int unreadCount;
  const _NotifTabs({required this.controller, required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _white,
      child: TabBar(
        controller: controller,
        labelColor: _terra,
        unselectedLabelColor: _muted,
        indicatorColor: _terra,
        indicatorWeight: 2.5,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        tabs: [
          const Tab(text: 'Toutes'),
          Tab(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Text('Non lues'),
              if (unreadCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: _terra,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$unreadCount',
                      style: const TextStyle(color: _white, fontSize: 10,
                          fontWeight: FontWeight.w800)),
                ),
              ],
            ]),
          ),
          const Tab(text: 'Lues'),
        ],
      ),
    );
  }
}

class _NotifList extends StatelessWidget {
  final List<_Notification> notifications;
  final List<int> indices;
  final List<bool> readFlags;
  final ValueChanged<int> onTap;
  const _NotifList({
    required this.notifications, required this.indices,
    required this.readFlags, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      itemCount: indices.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFEEE5D8)),
      itemBuilder: (_, i) {
        final idx = indices[i];
        final n   = notifications[idx];
        final isRead = readFlags[idx];
        return _NotifTile(notif: n, isRead: isRead, onTap: () => onTap(idx));
      },
    );
  }
}

class _NotifTile extends StatelessWidget {
  final _Notification notif;
  final bool isRead;
  final VoidCallback onTap;
  const _NotifTile({required this.notif, required this.isRead, required this.onTap});

  Color get _typeColor {
    switch (notif.type) {
      case _NotiType.grade:    return _terra;
      case _NotiType.success:  return _green;
      case _NotiType.warning:  return Colors.orange;
      case _NotiType.payment:  return const Color(0xFF7C3AED);
      case _NotiType.schedule: return _gold;
      case _NotiType.info:     return const Color(0xFF0284C7);
    }
  }

  IconData get _typeIcon {
    switch (notif.type) {
      case _NotiType.grade:    return Icons.grading_rounded;
      case _NotiType.success:  return Icons.emoji_events_rounded;
      case _NotiType.warning:  return Icons.warning_amber_rounded;
      case _NotiType.payment:  return Icons.payments_rounded;
      case _NotiType.schedule: return Icons.calendar_today_rounded;
      case _NotiType.info:     return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: isRead ? _white : _terra.withOpacity(.04),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: _typeColor.withOpacity(.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_typeIcon, color: _typeColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text(notif.title,
                      style: TextStyle(
                          color: _ink, fontSize: 14,
                          fontWeight: isRead ? FontWeight.w500 : FontWeight.w700)),
                ),
                if (!isRead)
                  Container(
                    width: 8, height: 8,
                    margin: const EdgeInsets.only(left: 8, top: 4),
                    decoration: const BoxDecoration(color: _terra, shape: BoxShape.circle),
                  ),
              ]),
              const SizedBox(height: 4),
              Text(notif.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: _muted, fontSize: 12.5, height: 1.4,
                      fontWeight: isRead ? FontWeight.w400 : FontWeight.w500)),
              const SizedBox(height: 6),
              Text(notif.time,
                  style: TextStyle(color: _muted.withOpacity(.6), fontSize: 11)),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final int tab;
  const _EmptyState({required this.tab});

  @override
  Widget build(BuildContext context) {
    final msg = tab == 1
        ? 'Aucune notification non lue'
        : tab == 2 ? 'Aucune notification lue' : 'Aucune notification';
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: _terra.withOpacity(.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.notifications_off_outlined, color: _terra, size: 36),
        ),
        const SizedBox(height: 16),
        Text(msg, style: const TextStyle(color: _ink, fontSize: 16,
            fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('Vous êtes à jour !',
            style: TextStyle(color: _muted, fontSize: 13)),
      ]),
    );
  }
}
