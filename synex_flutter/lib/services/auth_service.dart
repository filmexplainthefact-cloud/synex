import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_service.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseDatabase.instance.ref();
  static final _googleSignIn = GoogleSignIn();

  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStream => _auth.authStateChanges();

  static Future<String?> login(String email, String pass) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: pass);
      return null;
    } on FirebaseAuthException catch (e) {
      return _errMsg(e.code);
    }
  }

  static Future<String?> signup({
    required String name,
    required String email,
    required String pass,
    String? refCode,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: pass,
      );
      final uid = cred.user!.uid;
      final myRef = 'SYN${uid.substring(0, 6).toUpperCase()}';

      // Check referral
      String? referredBy;
      if (refCode != null && refCode.isNotEmpty) {
        final snap = await _db.child('users')
            .orderByChild('referralCode')
            .equalTo(refCode)
            .get();
        if (snap.exists) {
          final data = snap.value as Map;
          referredBy = data.keys.first as String;
        }
      }

      // Create user
      await _db.child('users/$uid').set({
        'name': name,
        'email': email,
        'wallet': 10,
        'uid': '',
        'ign': '',
        'squad': '',
        'isBlocked': false,
        'isAdmin': false,
        'referralCode': myRef,
        'referredBy': referredBy,
        'referralCount': 0,
        'referralEarned': 0,
        'xp': 0,
        'synexPoints': 0,
        'tickets': 0,
        'createdAt': ServerValue.timestamp,
      });

      // Welcome bonus tx
      final txKey = _db.child('users/$uid/transactions').push().key;
      await _db.child('users/$uid/transactions/$txKey').set({
        'type': 'Welcome Bonus',
        'amount': 10,
        'date': ServerValue.timestamp,
        'status': 'completed',
        'desc': 'Welcome bonus on signup',
      });

      // Handle referral
      if (referredBy != null) {
        final refSnap = await _db.child('users/$referredBy').get();
        if (refSnap.exists) {
          final refData = Map<String, dynamic>.from(refSnap.value as Map);
          final rtxKey = _db.child('users/$referredBy/transactions').push().key;
          final rKey = _db.child('users/$referredBy/referrals').push().key;
          final upd = <String, dynamic>{};
          upd['users/$referredBy/wallet'] = (refData['wallet'] ?? 0) + 10;
          upd['users/$referredBy/referralCount'] = (refData['referralCount'] ?? 0) + 1;
          upd['users/$referredBy/referralEarned'] = (refData['referralEarned'] ?? 0) + 10;
          upd['users/$referredBy/transactions/$rtxKey'] = {
            'type': 'Referral Bonus', 'amount': 10,
            'date': ServerValue.timestamp, 'status': 'completed',
            'desc': 'Referral: $name',
          };
          upd['users/$referredBy/referrals/$rKey'] = {
            'name': name, 'email': email,
            'date': ServerValue.timestamp, 'bonus': 10,
          };
          await _db.update(upd);
          // Notify referrer
          final nk = _db.child('notifications/$referredBy').push().key;
          await _db.child('notifications/$referredBy/$nk').set({
            'title': 'ðŸ’° Referral Bonus!',
            'body': '$name joined using your code! â‚¹10 credited.',
            'type': 'deposit', 'date': ServerValue.timestamp, 'read': false,
          });
        }
      }

      await FirebaseService.initNotifications();
      return null;
    } on FirebaseAuthException catch (e) {
      return _errMsg(e.code);
    }
  }

  static Future<String?> googleSignIn() async {
    try {
      final gUser = await _googleSignIn.signIn();
      if (gUser == null) return 'Cancelled';
      final gAuth = await gUser.authentication;
      final cred = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );
      final result = await _auth.signInWithCredential(cred);
      final uid = result.user!.uid;

      // Check if user exists
      final snap = await _db.child('users/$uid').get();
      if (!snap.exists) {
        // New user
        final myRef = 'SYN${uid.substring(0, 6).toUpperCase()}';
        await _db.child('users/$uid').set({
          'name': result.user!.displayName ?? 'Player',
          'email': result.user!.email ?? '',
          'wallet': 10, 'uid': '', 'ign': '', 'squad': '',
          'isBlocked': false, 'isAdmin': false,
          'referralCode': myRef, 'referralCount': 0,
          'referralEarned': 0, 'xp': 0, 'synexPoints': 0,
          'tickets': 0, 'createdAt': ServerValue.timestamp,
        });
      }
      await FirebaseService.initNotifications();
      return null;
    } catch (e) {
      return 'Google sign in failed';
    }
  }

  static Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  static String _errMsg(String code) {
    const msgs = {
      'user-not-found': 'No account found with this email',
      'wrong-password': 'Wrong password',
      'email-already-in-use': 'Email already registered',
      'invalid-email': 'Invalid email address',
      'weak-password': 'Password too weak (min 6 chars)',
      'too-many-requests': 'Too many attempts. Try later',
      'invalid-credential': 'Invalid email or password',
      'network-request-failed': 'No internet connection',
    };
    return msgs[code] ?? 'Something went wrong. Try again.';
  }
}
