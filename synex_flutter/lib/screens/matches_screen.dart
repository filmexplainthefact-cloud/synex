import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../services/auth_service.dart';
import '../widgets/common_widgets.dart';

class MatchesScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const MatchesScreen({super.key, this.userData});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  List<Map<String, dynamic>> _matches = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  void _loadMatches() async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) { setState(() => _loading = false); return; }

    FirebaseDatabase.instance.ref('users/$uid/registeredMatches').onValue.listen((event) async {
      if (!event.snapshot.exists || !mounted) {
        setState(() => _loading = false);
        return;
      }
      final data = event.snapshot.value as Map;
      final list = <Map<String, dynamic>>[];

      for (final entry in data.entries) {
        if (entry.value == null) continue;
        final m = Map<String, dynamic>.from(entry.value as Map);
        m['_key'] = entry.key;

        // Get tournament data for room credentials
        if (m['id'] != null) {
          try {
            final tSnap = await FirebaseDatabase.instance
                .ref('tournaments/${m['id']}').get();
            if (tSnap.exists) {
              final td = Map<String, dynamic>.from(tSnap.value as Map);
              m['_roomId'] = td['roomId'] ?? '';
              m['_roomPass'] = td['roomPassword'] ?? '';
              m['_startTime'] = td['startTime'];
            }
          } catch (_) {}
        }
        list.add(m);
      }

      list.sort((a, b) => ((b['joinedAt'] ?? 0) as num).compareTo((a['joinedAt'] ?? 0) as num));
      if (mounted) setState(() { _matches = list; _loading = false; });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg2,
        title: Text('My Matches', style: GoogleFonts.orbitron(
          fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.white,
        )),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.cyan))
          : _matches.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.emoji_events_rounded,
                        size: 64, color: AppColors.muted.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text('No matches joined yet',
                        style: GoogleFonts.rajdhani(
                          color: AppColors.muted, fontSize: 16,
                        )),
                      const SizedBox(height: 8),
                      Text('Join a tournament to get started!',
                        style: GoogleFonts.rajdhani(
                          color: AppColors.muted.withOpacity(0.6), fontSize: 13,
                        )),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(14),
                  itemCount: _matches.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) => _MatchCard(match: _matches[i]),
                ),
    );
  }
}

class _MatchCard extends StatefulWidget {
  final Map<String, dynamic> match;
  const _MatchCard({required this.match});

  @override
  State<_MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<_MatchCard> {
  bool _passRevealed = false;

  Map get m => widget.match;
  bool get _hasRoomId => (m['_roomId'] ?? '').toString().isNotEmpty;
  bool get _hasPass => (m['_roomPass'] ?? '').toString().isNotEmpty;
  bool get _isCompleted => m['status'] == 'completed';

  String get _modeEmoji => {'solo': 'ðŸ‘¤', 'duo': 'ðŸ‘¥', 'squad': 'âš”ï¸'}[m['mode'] ?? 'solo'] ?? 'ðŸ‘¤';

  String _timeAgo(dynamic ts) {
    if (ts == null) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch((ts as num).toInt());
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }

  void _showAd() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AdDialog(
        onComplete: () {
          Navigator.pop(context);
          setState(() => _passRevealed = true);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SynexCard(
      glow: _hasRoomId,
      borderColor: _hasRoomId ? AppColors.cyan.withOpacity(0.4) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(m['name'] ?? 'Tournament',
                  style: GoogleFonts.orbitron(
                    fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.white,
                  )),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _isCompleted
                      ? AppColors.muted.withOpacity(0.1)
                      : AppColors.warn.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _isCompleted ? AppColors.muted : AppColors.warn,
                  ),
                ),
                child: Text(
                  _isCompleted ? 'âœ“ Done' : 'â° Upcoming',
                  style: GoogleFonts.rajdhani(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: _isCompleted ? AppColors.muted : AppColors.warn,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Meta info
          Wrap(
            spacing: 10, runSpacing: 6,
            children: [
              if (m['prizePool'] != null)
                Text('ðŸ† ${m['prizePool']}',
                  style: GoogleFonts.rajdhani(color: AppColors.muted, fontSize: 13)),
              if (m['entryFee'] != null)
                Text('ðŸ’° ${m['entryFee'] == 0 ? 'FREE' : 'â‚¹${m['entryFee']}'}',
                  style: GoogleFonts.rajdhani(color: AppColors.muted, fontSize: 13)),
              if (m['map'] != null)
                Text('ðŸ—ºï¸ ${m['map']}',
                  style: GoogleFonts.rajdhani(color: AppColors.muted, fontSize: 13)),
              Text('$_modeEmoji ${(m['mode'] ?? 'solo').toString().capitalize()}',
                style: GoogleFonts.rajdhani(color: AppColors.muted, fontSize: 13)),
              Text('ðŸ“… ${_timeAgo(m['joinedAt'])}',
                style: GoogleFonts.rajdhani(color: AppColors.muted, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),

          // Room credentials
          if (!_isCompleted) ...[
            if (_hasRoomId) ...[
              // Room ID
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.card2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Text('ðŸ”', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ROOM ID',
                          style: GoogleFonts.rajdhani(
                            fontSize: 10, color: AppColors.muted,
                            letterSpacing: 1, fontWeight: FontWeight.w700,
                          )),
                        Text(m['_roomId'].toString(),
                          style: GoogleFonts.orbitron(
                            fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.cyan,
                          )),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => copyToClipboard(context, m['_roomId'].toString(), 'Room ID'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.blue1.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.blue1),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.copy_rounded, size: 12, color: AppColors.blue3),
                            const SizedBox(width: 4),
                            Text('Copy', style: GoogleFonts.rajdhani(
                              color: AppColors.blue3, fontWeight: FontWeight.w700, fontSize: 12,
                            )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Password section
              if (_hasPass) ...[
                if (_passRevealed)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.success.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        const Text('ðŸ”‘', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('PASSWORD',
                              style: GoogleFonts.rajdhani(
                                fontSize: 10, color: AppColors.muted,
                                letterSpacing: 1, fontWeight: FontWeight.w700,
                              )),
                            Text(m['_roomPass'].toString(),
                              style: GoogleFonts.orbitron(
                                fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.success,
                              )),
                          ],
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => copyToClipboard(context, m['_roomPass'].toString(), 'Password'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.success.withOpacity(0.5)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.copy_rounded, size: 12, color: AppColors.success),
                                const SizedBox(width: 4),
                                Text('Copy', style: GoogleFonts.rajdhani(
                                  color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 12,
                                )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  GestureDetector(
                    onTap: _showAd,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE65100), AppColors.warn],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.warn.withOpacity(0.3),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.visibility_rounded, color: Colors.black, size: 18),
                          const SizedBox(width: 8),
                          Text('View Room Password',
                            style: GoogleFonts.rajdhani(
                              color: Colors.black, fontWeight: FontWeight.w700, fontSize: 15,
                            )),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('Watch Ad',
                              style: GoogleFonts.rajdhani(
                                color: Colors.black.withOpacity(0.7),
                                fontSize: 11, fontWeight: FontWeight.w700,
                              )),
                          ),
                        ],
                      ),
                    ),
                  ),
              ] else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warn.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.warn.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_rounded, color: AppColors.warn, size: 14),
                      const SizedBox(width: 8),
                      Text('Password set nahi hua abhi.',
                        style: GoogleFonts.rajdhani(
                          color: AppColors.warn, fontSize: 13,
                        )),
                    ],
                  ),
                ),
            ] else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warn.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.warn.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_rounded, color: AppColors.warn, size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Room credentials will appear here before match starts.',
                        style: GoogleFonts.rajdhani(
                          color: AppColors.warn, fontSize: 13,
                        )),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// â”€â”€ AD DIALOG â”€â”€
class _AdDialog extends StatefulWidget {
  final VoidCallback onComplete;
  const _AdDialog({required this.onComplete});

  @override
  State<_AdDialog> createState() => _AdDialogState();
}

class _AdDialogState extends State<_AdDialog> {
  int _sec = 5;
  bool _canSkip = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() async {
    for (int i = 5; i >= 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() {
        _sec = i;
        if (i == 0) _canSkip = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.card, AppColors.card2],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gold.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withOpacity(0.1),
              blurRadius: 30,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ad label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.card2,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Text('ADVERTISEMENT',
                style: GoogleFonts.rajdhani(
                  fontSize: 10, color: AppColors.muted, letterSpacing: 3,
                )),
            ),
            const SizedBox(height: 20),

            // Ad content
            const Text('ðŸŽ®', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 10),
            GradientText('SYNEX TOURNAMENT',
              colors: const [Colors.white, AppColors.cyan],
              fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1,
            ),
            const SizedBox(height: 4),
            Text('India\'s #1 Free Fire Tournament Platform',
              style: GoogleFonts.rajdhani(
                color: AppColors.muted, fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text('ðŸ† Daily Tournaments â€¢ ðŸ’° Real Cash Prizes',
              style: GoogleFonts.rajdhani(
                color: AppColors.gold, fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),

            // Timer
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 60, height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _canSkip ? AppColors.success : AppColors.gold,
                  width: 2,
                ),
                color: _canSkip
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.gold.withOpacity(0.1),
              ),
              child: Center(
                child: Text(
                  _canSkip ? 'âœ“' : '$_sec',
                  style: GoogleFonts.orbitron(
                    fontSize: 20, fontWeight: FontWeight.w900,
                    color: _canSkip ? AppColors.success : AppColors.gold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Skip button
            GestureDetector(
              onTap: _canSkip ? widget.onComplete : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: _canSkip
                      ? const LinearGradient(
                          colors: [Color(0xFF1B5E20), AppColors.success])
                      : null,
                  color: _canSkip ? null : AppColors.card2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _canSkip ? AppColors.success : AppColors.border,
                  ),
                ),
                child: Text(
                  _canSkip ? 'âœ“ Reveal Password Now' : 'Skip in ${_sec}s',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.rajdhani(
                    fontSize: 15, fontWeight: FontWeight.w700,
                    color: _canSkip ? Colors.white : AppColors.muted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
