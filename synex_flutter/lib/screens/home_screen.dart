import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/app_theme.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import '../widgets/common_widgets.dart';
import 'wallet_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const HomeScreen({super.key, this.userData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _tournaments = [];
  List<Map<String, dynamic>> _filtered = [];
  String _activeFilter = 'all';
  bool _loading = true;
  Map? _liveStream;

  @override
  void initState() {
    super.initState();
    _listenTournaments();
    _loadLive();
  }

  void _listenTournaments() {
    FirebaseService.tournamentsStream().listen((event) {
      if (!event.snapshot.exists || !mounted) {
        setState(() => _loading = false);
        return;
      }
      final data = event.snapshot.value as Map;
      final list = <Map<String, dynamic>>[];
      data.forEach((k, v) {
        final t = Map<String, dynamic>.from(v as Map);
        t['_tid'] = k;
        list.add(t);
      });
      list.sort((a, b) {
        if ((a['featured'] ?? false) && !(b['featured'] ?? false)) return -1;
        if (!(a['featured'] ?? false) && (b['featured'] ?? false)) return 1;
        return ((b['createdAt'] ?? 0) as num).compareTo((a['createdAt'] ?? 0) as num);
      });
      setState(() {
        _tournaments = list;
        _filterTournaments(_activeFilter);
        _loading = false;
      });
    });
  }

  void _loadLive() async {
    final live = await FirebaseService.getLiveStream();
    if (mounted) setState(() => _liveStream = live);
  }

  void _filterTournaments(String type) {
    setState(() {
      _activeFilter = type;
      if (type == 'all') {
        _filtered = _tournaments;
      } else if (type == 'free') {
        _filtered = _tournaments.where((t) => (t['entryFee'] ?? 0) == 0).toList();
      } else {
        _filtered = _tournaments.where((t) => (t['mode'] ?? 'solo') == type).toList();
      }
    });
  }

  List<String> get _myMatchIds {
    final rm = widget.userData?['registeredMatches'];
    if (rm == null) return [];
    if (rm is Map) return rm.values.map((v) => (v as Map)['id']?.toString() ?? '').toList();
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildHeroBanner()),
          if (_liveStream != null && (_liveStream!['active'] ?? false))
            SliverToBoxAdapter(child: _buildLiveSection()),
          SliverToBoxAdapter(child: _buildComingSoon()),
          SliverToBoxAdapter(child: _buildFilters()),
          _loading
              ? const SliverToBoxAdapter(child: _LoadingCards())
              : _filtered.isEmpty
                  ? SliverToBoxAdapter(child: _buildEmpty())
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => Padding(
                          padding: EdgeInsets.fromLTRB(
                            14, i == 0 ? 0 : 7, 14, i == _filtered.length - 1 ? 20 : 7,
                          ),
                          child: _TournamentCard(
                            tournament: _filtered[i],
                            joined: _myMatchIds.contains(_filtered[i]['_tid']),
                            userData: widget.userData,
                            onJoined: () {},
                          ),
                        ),
                        childCount: _filtered.length,
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.bg2,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D47A1), AppColors.cyan],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text('S', style: GoogleFonts.orbitron(
                fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white,
              )),
            ),
          ),
          const SizedBox(width: 8),
          GradientText('SYNEX',
            colors: const [Color(0xFF42A5F5), AppColors.cyan],
            fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1,
          ),
        ],
      ),
      actions: [
        // Wallet
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => WalletScreen(userData: widget.userData),
          )),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.gold.withOpacity(0.15), AppColors.gold.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.gold.withOpacity(0.35)),
            ),
            child: Row(
              children: [
                const Text('ðŸª™', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  'â‚¹${widget.userData?['wallet'] ?? 0}',
                  style: GoogleFonts.orbitron(
                    fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Notifications
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => const NotificationsScreen(),
          )),
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.card2,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.notifications_rounded,
              color: AppColors.blue3, size: 18),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }

  Widget _buildHeroBanner() {
    final name = widget.userData?['name'] ?? 'Player';
    final matches = widget.userData?['stats']?['matches'] ?? 0;
    final wins = widget.userData?['stats']?['wins'] ?? 0;
    final wallet = widget.userData?['wallet'] ?? 0;
    final tickets = widget.userData?['tickets'] ?? 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF1976D2)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.blue3.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue1.withOpacity(0.3),
            blurRadius: 20, offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome back ðŸ‘‹',
                  style: GoogleFonts.rajdhani(
                    fontSize: 12, color: Colors.white.withOpacity(0.65),
                  )),
                const SizedBox(height: 2),
                Text(name,
                  style: GoogleFonts.orbitron(
                    fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white,
                  )),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _HeroStat(value: '$matches', label: 'Matches'),
                    const SizedBox(width: 16),
                    _HeroStat(value: '$wins', label: 'Wins'),
                    const SizedBox(width: 16),
                    _HeroStat(value: 'â‚¹$wallet', label: 'Balance'),
                    const SizedBox(width: 16),
                    _HeroStat(value: 'ðŸŽ«$tickets', label: 'Tickets'),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => WalletScreen(userData: widget.userData),
            )),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text('Add Money',
                    style: GoogleFonts.rajdhani(
                      fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700,
                    )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.live, width: 2),
        color: const Color(0xFF1A0800),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(color: Colors.black,
                    child: const Center(child: Icon(Icons.play_circle_fill_rounded,
                      color: AppColors.live, size: 48))),
                ),
              ),
              Positioned(
                top: 10, left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.live,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6, height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text('LIVE',
                        style: GoogleFonts.rajdhani(
                          color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11,
                        )),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(_liveStream!['title'] ?? 'Live Stream',
                    style: GoogleFonts.rajdhani(
                      fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.white,
                    )),
                ),
                Row(
                  children: [
                    Icon(Icons.visibility, color: AppColors.danger, size: 14),
                    const SizedBox(width: 4),
                    Text('${_liveStream!['viewers'] ?? 0}',
                      style: GoogleFonts.rajdhani(
                        color: AppColors.muted, fontSize: 12,
                      )),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoon() {
    if (_liveStream != null && (_liveStream!['active'] ?? false)) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cyan.withOpacity(0.3),
          style: BorderStyle.solid,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Text('ðŸš€', style: TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text('COMING SOON',
            style: GoogleFonts.orbitron(
              fontSize: 14, fontWeight: FontWeight.w900,
              color: AppColors.cyan, letterSpacing: 2,
            )),
          const SizedBox(height: 4),
          Text('Live streaming feature â€” stay tuned!',
            style: GoogleFonts.rajdhani(
              fontSize: 13, color: AppColors.muted,
            )),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final filters = [
      {'id': 'all', 'label': 'All'},
      {'id': 'solo', 'label': 'ðŸ‘¤ Solo'},
      {'id': 'duo', 'label': 'ðŸ‘¥ Duo'},
      {'id': 'squad', 'label': 'âš”ï¸ Squad'},
      {'id': 'free', 'label': 'ðŸ†“ Free'},
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = filters[i];
          final active = _activeFilter == f['id'];
          return GestureDetector(
            onTap: () => _filterTournaments(f['id']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: active ? const LinearGradient(
                  colors: [AppColors.blue1, AppColors.blue2],
                ) : null,
                color: active ? null : AppColors.card2,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active ? AppColors.blue2 : AppColors.border,
                ),
              ),
              child: Center(
                child: Text(f['label']!,
                  style: GoogleFonts.rajdhani(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: active ? Colors.white : AppColors.muted,
                  )),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: AppColors.muted.withOpacity(0.5)),
          const SizedBox(height: 12),
          Text('No tournaments found',
            style: GoogleFonts.rajdhani(
              color: AppColors.muted, fontSize: 14,
            )),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String value;
  final String label;
  const _HeroStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
          style: GoogleFonts.orbitron(
            fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.cyan,
          )),
        Text(label,
          style: GoogleFonts.rajdhani(
            fontSize: 10, color: Colors.white.withOpacity(0.55),
          )),
      ],
    );
  }
}

class _LoadingCards extends StatelessWidget {
  const _LoadingCards();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: List.generate(3, (i) => Container(
          margin: const EdgeInsets.only(bottom: 14),
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
        )),
      ),
    );
  }
}

// â”€â”€ TOURNAMENT CARD â”€â”€
class _TournamentCard extends StatelessWidget {
  final Map<String, dynamic> tournament;
  final bool joined;
  final Map<String, dynamic>? userData;
  final VoidCallback onJoined;

  const _TournamentCard({
    required this.tournament,
    required this.joined,
    required this.userData,
    required this.onJoined,
  });

  @override
  Widget build(BuildContext context) {
    final t = tournament;
    final tid = t['_tid'] as String;
    final isFeatured = t['featured'] ?? false;
    final registered = (t['registered'] ?? 0) as int;
    final maxPlayers = (t['maxPlayers'] ?? 32) as int;
    final isFull = registered >= maxPlayers;
    final entryFee = (t['entryFee'] ?? 0) as int;
    final mode = t['mode'] ?? 'solo';
    final modeLabel = {'solo': 'ðŸ‘¤ Solo', 'duo': 'ðŸ‘¥ Duo', 'squad': 'âš”ï¸ Squad'}[mode] ?? 'ðŸ‘¤ Solo';
    final pct = maxPlayers > 0 ? registered / maxPlayers : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFeatured ? AppColors.gold.withOpacity(0.5) : AppColors.border,
        ),
        boxShadow: isFeatured ? [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.1),
            blurRadius: 16, spreadRadius: 0,
          ),
        ] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: t['thumbnail'] != null
                      ? CachedNetworkImage(
                          imageUrl: t['thumbnail'],
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: AppColors.card2,
                            child: const Center(child: Icon(Icons.gamepad_rounded,
                              color: AppColors.border, size: 40))),
                          errorWidget: (_, __, ___) => Container(color: AppColors.card2,
                            child: const Center(child: Icon(Icons.gamepad_rounded,
                              color: AppColors.border, size: 40))),
                        )
                      : Container(color: AppColors.card2,
                          child: const Center(child: Icon(Icons.gamepad_rounded,
                            color: AppColors.border, size: 40))),
                ),
              ),
              if (isFeatured)
                Positioned(
                  top: 10, right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('â­ FEATURED',
                      style: GoogleFonts.rajdhani(
                        color: Colors.black, fontWeight: FontWeight.w700, fontSize: 10,
                      )),
                  ),
                ),
              if (joined)
                Positioned(
                  bottom: 8, left: 8,
                  child: SynexBadge(label: 'âœ“ Joined', color: AppColors.success),
                ),
            ],
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name row
                Row(
                  children: [
                    Expanded(
                      child: Text(t['name'] ?? 'Tournament',
                        style: GoogleFonts.orbitron(
                          fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.white,
                        )),
                    ),
                    Icon(Icons.info_outline_rounded, color: AppColors.muted, size: 16),
                  ],
                ),
                const SizedBox(height: 8),

                // Tags
                Wrap(
                  spacing: 6, runSpacing: 6,
                  children: [
                    _Tag('ðŸ“ ${t['map'] ?? 'Bermuda'}'),
                    _Tag('$registered/$maxPlayers'),
                    _Tag(modeLabel),
                  ],
                ),
                const SizedBox(height: 10),

                // Progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Players', style: GoogleFonts.rajdhani(
                          fontSize: 11, color: AppColors.muted)),
                        Text('$registered/$maxPlayers', style: GoogleFonts.rajdhani(
                          fontSize: 11, color: AppColors.muted)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: pct.clamp(0.0, 1.0),
                        backgroundColor: AppColors.card2,
                        valueColor: AlwaysStoppedAnimation(
                          isFull ? AppColors.danger : AppColors.cyan,
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Footer
                Row(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.emoji_events_rounded,
                          color: AppColors.gold, size: 16),
                        const SizedBox(width: 4),
                        Text(t['prizePool']?.toString() ?? 'â€”',
                          style: GoogleFonts.orbitron(
                            fontSize: 13, color: AppColors.gold, fontWeight: FontWeight.w700,
                          )),
                      ],
                    ),
                    const Spacer(),
                    // Fee badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: entryFee == 0
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.blue1.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: entryFee == 0 ? AppColors.success : AppColors.blue1,
                        ),
                      ),
                      child: Text(
                        entryFee == 0 ? 'ðŸŽ FREE' : 'â‚¹$entryFee',
                        style: GoogleFonts.rajdhani(
                          fontSize: 12, fontWeight: FontWeight.w700,
                          color: entryFee == 0 ? AppColors.success : AppColors.blue3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Join button
                    if (joined)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.success),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_rounded, color: AppColors.success, size: 14),
                            const SizedBox(width: 4),
                            Text('Joined', style: GoogleFonts.rajdhani(
                              color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 13,
                            )),
                          ],
                        ),
                      )
                    else if (isFull)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.card2,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.muted),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lock_rounded, color: AppColors.muted, size: 14),
                            const SizedBox(width: 4),
                            Text('Full', style: GoogleFonts.rajdhani(
                              color: AppColors.muted, fontWeight: FontWeight.w700, fontSize: 13,
                            )),
                          ],
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () => _showJoinDialog(context, tid),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.blue1, AppColors.blue2],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.blue1.withOpacity(0.35),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.gamepad_rounded, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text('Join Now', style: GoogleFonts.rajdhani(
                                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13,
                              )),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showJoinDialog(BuildContext context, String tid) {
    final fee = (tournament['entryFee'] ?? 0) as int;
    final bal = (userData?['wallet'] ?? 0) as int;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _JoinSheet(
        tournament: tournament,
        userData: userData,
        onConfirm: () => _doJoin(context, tid),
      ),
    );
  }

  Future<void> _doJoin(BuildContext context, String tid) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;
    try {
      final fee = (tournament['entryFee'] ?? 0) as int;
      final curBal = (userData?['wallet'] ?? 0) as int;
      if (curBal < fee) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Insufficient balance!',
            style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700))),
        );
        return;
      }
      final db = FirebaseDatabase.instance.ref();
      final mKey = db.child('users/$uid/registeredMatches').push().key;
      final txKey = db.child('users/$uid/transactions').push().key;
      final nk = db.child('notifications/$uid').push().key;
      final upd = <String, dynamic>{
        'users/$uid/wallet': curBal - fee,
        'users/$uid/registeredMatches/$mKey': {
          'id': tid, 'name': tournament['name'],
          'status': 'upcoming', 'prizePool': tournament['prizePool'],
          'entryFee': fee, 'map': tournament['map'],
          'mode': tournament['mode'] ?? 'solo',
          'joinedAt': ServerValue.timestamp,
        },
        'users/$uid/transactions/$txKey': {
          'type': 'Tournament Join', 'amount': -fee,
          'date': ServerValue.timestamp, 'status': 'completed',
          'desc': tournament['name'],
        },
        'tournaments/$tid/registered': (tournament['registered'] ?? 0) + 1,
        'notifications/$uid/$nk': {
          'title': 'ðŸŽ® Tournament Joined!',
          'body': 'You joined: ${tournament['name']}. Get ready!',
          'type': 'tournament', 'date': ServerValue.timestamp, 'read': false,
        },
      };
      await db.update(upd);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Joined! ðŸŽ®',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700)),
            backgroundColor: AppColors.success,
          ),
        );
        onJoined();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error joining. Try again.',
            style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700))),
        );
      }
    }
  }
}

class _JoinSheet extends StatelessWidget {
  final Map<String, dynamic> tournament;
  final Map<String, dynamic>? userData;
  final VoidCallback onConfirm;

  const _JoinSheet({
    required this.tournament,
    required this.userData,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final fee = (tournament['entryFee'] ?? 0) as int;
    final bal = (userData?['wallet'] ?? 0) as int;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text('Confirm Join',
            style: GoogleFonts.orbitron(
              fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.white,
            )),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Entry Fee',
                      style: GoogleFonts.rajdhani(color: AppColors.muted, fontSize: 12)),
                    Text(fee == 0 ? 'FREE' : 'â‚¹$fee',
                      style: GoogleFonts.orbitron(
                        fontSize: 20, fontWeight: FontWeight.w900,
                        color: fee == 0 ? AppColors.success : AppColors.white,
                      )),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Your Balance',
                      style: GoogleFonts.rajdhani(color: AppColors.muted, fontSize: 12)),
                    Text('â‚¹$bal',
                      style: GoogleFonts.orbitron(
                        fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.gold,
                      )),
                    Text('After: â‚¹${bal - fee}',
                      style: GoogleFonts.rajdhani(
                        fontSize: 12,
                        color: bal - fee < 0 ? AppColors.danger : AppColors.muted,
                      )),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.blue1.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.blue1.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_rounded, color: AppColors.blue3, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Room ID & Password will appear in My Matches before match starts.',
                    style: GoogleFonts.rajdhani(
                      fontSize: 12, color: AppColors.blue3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SynexButton(
                  label: 'Confirm & Join',
                  icon: Icons.check_rounded,
                  gradient: const [Color(0xFF1B5E20), AppColors.success],
                  width: double.infinity,
                  onTap: onConfirm,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SynexButton(
                  label: 'Cancel',
                  outlined: true,
                  width: double.infinity,
                  onTap: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.card2,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(label,
        style: GoogleFonts.rajdhani(
          fontSize: 11, color: AppColors.muted,
        )),
    );
  }
}
