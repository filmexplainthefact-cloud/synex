import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../services/auth_service.dart';
import '../widgets/common_widgets.dart';

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// NOTIFICATIONS SCREEN
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.currentUser?.uid;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg2,
        title: Text('Notifications', style: GoogleFonts.orbitron(
          fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.white,
        )),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: uid == null
          ? const SizedBox.shrink()
          : StreamBuilder<DatabaseEvent>(
              stream: FirebaseDatabase.instance
                  .ref('notifications/$uid')
                  .limitToLast(30)
                  .onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.snapshot.exists) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.notifications_none_rounded,
                          size: 48, color: AppColors.muted.withOpacity(0.3)),
                        const SizedBox(height: 12),
                        Text('No notifications yet',
                          style: GoogleFonts.rajdhani(color: AppColors.muted, fontSize: 14)),
                      ],
                    ),
                  );
                }
                final data = snapshot.data!.snapshot.value as Map;
                final notifs = <Map>[];
                data.forEach((k, v) {
                  final n = Map<String, dynamic>.from(v as Map);
                  n['_key'] = k;
                  notifs.add(n);
                });
                notifs.sort((a, b) =>
                    ((b['date'] ?? 0) as num).compareTo((a['date'] ?? 0) as num));

                return ListView.separated(
                  padding: const EdgeInsets.all(14),
                  itemCount: notifs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final n = notifs[i];
                    final unread = n['read'] == false || n['read'] == null;
                    final type = n['type'] ?? 'default';
                    final col = type == 'tournament' ? AppColors.cyan :
                        type == 'deposit' ? AppColors.success :
                        type == 'room' ? AppColors.gold : AppColors.purple;

                    return GestureDetector(
                      onTap: () {
                        FirebaseDatabase.instance
                            .ref('notifications/$uid/${n['_key']}/read')
                            .set(true);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: unread ? col.withOpacity(0.05) : AppColors.card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: unread ? col.withOpacity(0.3) : AppColors.border,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: col.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  type == 'tournament' ? 'ðŸŽ®' :
                                  type == 'deposit' ? 'ðŸ’°' :
                                  type == 'room' ? 'ðŸ”' : 'ðŸ“¢',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(n['title'] ?? '',
                                    style: GoogleFonts.rajdhani(
                                      fontSize: 14, fontWeight: FontWeight.w700,
                                      color: unread ? AppColors.white : AppColors.muted,
                                    )),
                                  const SizedBox(height: 3),
                                  Text(n['body'] ?? '',
                                    style: GoogleFonts.rajdhani(
                                      fontSize: 12, color: AppColors.muted,
                                    )),
                                ],
                              ),
                            ),
                            if (unread)
                              Container(
                                width: 8, height: 8,
                                decoration: BoxDecoration(
                                  color: col,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(color: col.withOpacity(0.5), blurRadius: 4),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
