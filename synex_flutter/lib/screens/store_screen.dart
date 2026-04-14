import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../services/auth_service.dart';
import '../widgets/common_widgets.dart';

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// STORE SCREEN
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class StoreScreen extends StatelessWidget {
  final Map<String, dynamic>? userData;
  const StoreScreen({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg2,
        title: Text('Synex Store', style: GoogleFonts.orbitron(
          fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.white,
        )),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('ðŸ›ï¸', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text('Store Coming Soon',
              style: GoogleFonts.orbitron(
                fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.cyan,
              )),
            const SizedBox(height: 8),
            Text('Coupons, Tickets & more!',
              style: GoogleFonts.rajdhani(color: AppColors.muted, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
