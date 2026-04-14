import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseService {
  static final db = FirebaseDatabase.instance.ref();
  static final auth = FirebaseAuth.instance;
  static final messaging = FirebaseMessaging.instance;
  static final _localNotif = FlutterLocalNotificationsPlugin();

  // â”€â”€ INIT NOTIFICATIONS â”€â”€
  static Future<void> initNotifications() async {
    // Request permission
    await messaging.requestPermission(
      alert: true, badge: true, sound: true,
    );

    // Local notification setup
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _localNotif.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    // FCM foreground
    FirebaseMessaging.onMessage.listen((msg) {
      final n = msg.notification;
      if (n != null) _showLocalNotif(n.title ?? 'Synex', n.body ?? '');
    });

    // Save FCM token to database
    final token = await messaging.getToken();
    final user = auth.currentUser;
    if (token != null && user != null) {
      await db.child('users/${user.uid}/fcmToken').set(token);
    }

    // Token refresh
    messaging.onTokenRefresh.listen((token) {
      final user = auth.currentUser;
      if (user != null) db.child('users/${user.uid}/fcmToken').set(token);
    });
  }

  static Future<void> _showLocalNotif(String title, String body) async {
    const android = AndroidNotificationDetails(
      'synex_channel', 'Synex Notifications',
      channelDescription: 'Tournament & wallet notifications',
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFF00E5FF),
    );
    const ios = DarwinNotificationDetails();
    await _localNotif.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title, body,
      const NotificationDetails(android: android, iOS: ios),
    );
  }

  // â”€â”€ USER â”€â”€
  static Future<Map?> getUser(String uid) async {
    final snap = await db.child('users/$uid').get();
    if (!snap.exists) return null;
    return Map<String, dynamic>.from(snap.value as Map);
  }

  static Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await db.child('users/$uid').update(data);
  }

  // â”€â”€ TOURNAMENTS â”€â”€
  static Stream<DatabaseEvent> tournamentsStream() {
    return db.child('tournaments').orderByChild('createdAt').onValue;
  }

  static Future<Map?> getTournament(String tid) async {
    final snap = await db.child('tournaments/$tid').get();
    if (!snap.exists) return null;
    return Map<String, dynamic>.from(snap.value as Map);
  }

  // â”€â”€ NOTIFICATIONS â”€â”€
  static Stream<DatabaseEvent> notifStream(String uid) {
    return db.child('notifications/$uid').limitToLast(25).onValue;
  }

  static Future<void> markNotifRead(String uid, String nid) async {
    await db.child('notifications/$uid/$nid/read').set(true);
  }

  // â”€â”€ WALLET â”€â”€
  static Stream<DatabaseEvent> transactionsStream(String uid) {
    return db.child('users/$uid/transactions').onValue;
  }

  // â”€â”€ SPIN HISTORY â”€â”€
  static Stream<DatabaseEvent> spinHistoryStream(String uid) {
    return db.child('spinHistory/$uid').limitToLast(20).onValue;
  }

  // â”€â”€ SETTINGS â”€â”€
  static Future<Map?> getWheelSettings() async {
    final snap = await db.child('settings/wheel').get();
    if (!snap.exists) return null;
    return Map<String, dynamic>.from(snap.value as Map);
  }

  static Future<Map?> getLiveStream() async {
    final snap = await db.child('liveStream').get();
    if (!snap.exists) return null;
    return Map<String, dynamic>.from(snap.value as Map);
  }

  // â”€â”€ LEADERBOARD â”€â”€
  static Future<List<Map>> getLeaderboard({String sortBy = 'wallet'}) async {
    final snap = await db.child('users').limitToLast(50).get();
    if (!snap.exists) return [];
    final list = <Map>[];
    final data = snap.value as Map;
    data.forEach((k, v) {
      final u = Map<String, dynamic>.from(v as Map);
      u['_uid'] = k;
      list.add(u);
    });
    if (sortBy == 'wins') {
      list.sort((a, b) => ((b['stats']?['wins'] ?? 0) as int).compareTo((a['stats']?['wins'] ?? 0) as int));
    } else {
      list.sort((a, b) => ((b['wallet'] ?? 0) as num).compareTo((a['wallet'] ?? 0) as num));
    }
    return list;
  }
}

// ignore: unused_element
const Color _cyan = Color(0xFF00E5FF);
