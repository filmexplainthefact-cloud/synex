import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../services/auth_service.dart';
import '../widgets/common_widgets.dart';

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// PROFILE SCREEN
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final VoidCallback? onUserUpdate;
  const ProfileScreen({super.key, this.userData, this.onUserUpdate});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _ffuidCtrl = TextEditingController();
  final _ignCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _squadCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ffuidCtrl.text = widget.userData?['uid'] ?? '';
    _ignCtrl.text = widget.userData?['ign'] ?? '';
    _nameCtrl.text = widget.userData?['name'] ?? '';
    _squadCtrl.text = widget.userData?['squad'] ?? '';
  }

  Future<void> _save(String field, String value) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null || value.isEmpty) return;
    await FirebaseDatabase.instance.ref('users/$uid/$field').set(value);
    widget.onUserUpdate?.call();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved! âœ“', style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700)),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.userData;
    final name = u?['name'] ?? 'Player';
    final email = AuthService.currentUser?.email ?? '';
    final xp = (u?['xp'] ?? 0) as int;
    final level = (xp / 500).floor() + 1;
    final wins = u?['stats']?['wins'] ?? 0;
    final kills = u?['stats']?['kills'] ?? 0;
    final matches = u?['stats']?['matches'] ?? 0;
    final kd = matches > 0 ? (kills / matches).toStringAsFixed(1) : '0.0';
    final wr = matches > 0 ? '${((wins / matches) * 100).toStringAsFixed(0)}%' : '0%';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.bg2,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D47A1), AppColors.bg2],
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.cyan, AppColors.blue1],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: AppColors.cyan.withOpacity(0.3), blurRadius: 20),
                        ],
                      ),
                      child: Center(
                        child: Text(name[0].toUpperCase(),
                          style: GoogleFonts.orbitron(
                            fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white,
                          )),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(name, style: GoogleFonts.rajdhani(
                      fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white,
                    )),
                    Text(email, style: GoogleFonts.rajdhani(
                      fontSize: 12, color: Colors.white.withOpacity(0.6),
                    )),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.gold.withOpacity(0.35)),
                      ),
                      child: Text('LV$level Â· $xp XP',
                        style: GoogleFonts.orbitron(
                          fontSize: 11, color: AppColors.gold, fontWeight: FontWeight.w700,
                        )),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
                onPressed: () async {
                  await AuthService.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
                  }
                },
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(14),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats
                const SectionHeader(title: 'PLAYER STATS'),
                SynexCard(
                  child: GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10, mainAxisSpacing: 10,
                    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    children: [
                      StatBox(value: '$wins', label: 'ðŸ† Wins', color: AppColors.gold),
                      StatBox(value: kd, label: 'âš”ï¸ K/D', color: AppColors.cyan),
                      StatBox(value: '$matches', label: 'ðŸŽ® Played', color: AppColors.success),
                      StatBox(value: '$kills', label: 'ðŸ’€ Kills', color: AppColors.danger),
                      StatBox(value: wr, label: 'ðŸ“Š Win%', color: AppColors.purple),
                      StatBox(value: '${u?['synexPoints'] ?? 0}', label: 'S Points', color: AppColors.blue3),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Edit profile
                const SectionHeader(title: 'EDIT PROFILE'),
                SynexCard(
                  child: Column(
                    children: [
                      _EditField(
                        label: 'Free Fire UID',
                        hint: 'Enter FF UID',
                        controller: _ffuidCtrl,
                        onSave: () => _save('uid', _ffuidCtrl.text.trim()),
                      ),
                      const NeonDivider(),
                      _EditField(
                        label: 'In-Game Name (IGN)',
                        hint: 'Enter IGN',
                        controller: _ignCtrl,
                        onSave: () => _save('ign', _ignCtrl.text.trim()),
                      ),
                      const NeonDivider(),
                      _EditField(
                        label: 'Display Name',
                        hint: 'Your name',
                        controller: _nameCtrl,
                        onSave: () => _save('name', _nameCtrl.text.trim()),
                      ),
                      const NeonDivider(),
                      _EditField(
                        label: 'Squad / Team Name',
                        hint: 'e.g. SYNEX WOLVES',
                        controller: _squadCtrl,
                        onSave: () => _save('squad', _squadCtrl.text.trim()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Referral code
                if (u?['referralCode'] != null) ...[
                  const SectionHeader(title: 'REFERRAL'),
                  SynexCard(
                    glow: true,
                    borderColor: AppColors.gold.withOpacity(0.4),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text('ðŸŽ', style: TextStyle(fontSize: 24)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Your Referral Code',
                                    style: GoogleFonts.rajdhani(
                                      color: AppColors.muted, fontSize: 12,
                                    )),
                                  Text(u!['referralCode'],
                                    style: GoogleFonts.orbitron(
                                      fontSize: 18, fontWeight: FontWeight.w900,
                                      color: AppColors.gold,
                                    )),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => copyToClipboard(context, u['referralCode'], 'Referral Code'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.gold.withOpacity(0.35)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.copy_rounded, color: AppColors.gold, size: 14),
                                    const SizedBox(width: 4),
                                    Text('Copy', style: GoogleFonts.rajdhani(
                                      color: AppColors.gold, fontWeight: FontWeight.w700, fontSize: 12,
                                    )),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _ReferStat(
                              value: '${u['referralCount'] ?? 0}',
                              label: 'Referrals',
                            )),
                            Expanded(child: _ReferStat(
                              value: 'â‚¹${u['referralEarned'] ?? 0}',
                              label: 'Earned',
                              color: AppColors.success,
                            )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final VoidCallback onSave;

  const _EditField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(),
                  style: GoogleFonts.rajdhani(
                    fontSize: 10, color: AppColors.muted,
                    fontWeight: FontWeight.w700, letterSpacing: 1,
                  )),
                const SizedBox(height: 6),
                TextField(
                  controller: controller,
                  style: const TextStyle(color: AppColors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: hint,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onSave,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.blue1, AppColors.blue2],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Save', style: GoogleFonts.rajdhani(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13,
              )),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _ReferStat({required this.value, required this.label, this.color = AppColors.cyan});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.orbitron(
          fontSize: 20, fontWeight: FontWeight.w900, color: color,
        )),
        Text(label, style: GoogleFonts.rajdhani(
          fontSize: 12, color: AppColors.muted,
        )),
      ],
    );
  }
}
