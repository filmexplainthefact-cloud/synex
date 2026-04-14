import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../services/auth_service.dart';
import 'auth_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _ringController;
  late AnimationController _loadController;
  double _loadProgress = 0;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this, duration: const Duration(seconds: 3),
    )..repeat();

    _loadController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2000),
    );

    _startLoad();
  }

  void _startLoad() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _loadController.forward();

    // Animate progress
    for (int i = 0; i <= 100; i += 2) {
      await Future.delayed(const Duration(milliseconds: 30));
      if (mounted) setState(() => _loadProgress = i / 100);
    }

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    // Check auth
    final user = AuthService.currentUser;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            user != null ? const MainScreen() : const AuthScreen(),
        transitionDuration: const Duration(milliseconds: 800),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _ringController.dispose();
    _loadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Background radial
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.2),
                radius: 1.2,
                colors: [Color(0xFF071A36), Color(0xFF020D1E), Colors.black],
              ),
            ),
          ),

          // Animated rings
          Center(
            child: AnimatedBuilder(
              animation: _ringController,
              builder: (_, __) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    _Ring(size: 280, progress: _ringController.value, delay: 0),
                    _Ring(size: 340, progress: _ringController.value, delay: 0.3),
                    _Ring(size: 400, progress: _ringController.value, delay: 0.6),
                  ],
                );
              },
            ),
          ),

          // Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Big S
                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                    colors: [Colors.white, Color(0xFF90CAF9), AppColors.cyan, Color(0xFF42A5F5), AppColors.purple],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ).createShader(b),
                  child: Text('S',
                    style: GoogleFonts.orbitron(
                      fontSize: 100, fontWeight: FontWeight.w900, color: Colors.white,
                    ),
                  ),
                ).animate()
                  .scale(begin: const Offset(0.3, 0.3), duration: 700.ms, curve: Curves.elasticOut)
                  .fadeIn(duration: 400.ms),

                // SYNEX text
                Text('SYNEX',
                  style: GoogleFonts.orbitron(
                    fontSize: 24, fontWeight: FontWeight.w900,
                    letterSpacing: 6, color: AppColors.cyan,
                  ),
                ).animate(delay: 400.ms)
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 4),
                Text('THE ARENA FOR CHAMPIONS',
                  style: GoogleFonts.rajdhani(
                    fontSize: 11, color: AppColors.cyan.withOpacity(0.5),
                    letterSpacing: 4,
                  ),
                ).animate(delay: 600.ms).fadeIn(),

                const SizedBox(height: 40),

                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: _loadProgress,
                          backgroundColor: AppColors.card2,
                          valueColor: const AlwaysStoppedAnimation(AppColors.cyan),
                          minHeight: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(_loadProgress * 100).toInt()}%',
                        style: GoogleFonts.orbitron(
                          fontSize: 10, color: AppColors.cyan.withOpacity(0.4),
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 800.ms).fadeIn(),
              ],
            ),
          ),

          // Scanline effect
          _ScanLine(),
        ],
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  final double size;
  final double progress;
  final double delay;

  const _Ring({required this.size, required this.progress, required this.delay});

  @override
  Widget build(BuildContext context) {
    final p = ((progress + delay) % 1.0);
    final opacity = (1 - p).clamp(0.0, 0.4);
    final scale = 0.4 + p * 2.2;

    return Transform.scale(
      scale: scale,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.cyan.withOpacity(opacity),
            width: 1,
          ),
        ),
      ),
    );
  }
}

class _ScanLine extends StatefulWidget {
  @override
  State<_ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<_ScanLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final h = MediaQuery.of(context).size.height;
        return Positioned(
          top: _ctrl.value * h - 2,
          left: 0, right: 0,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.cyan.withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
