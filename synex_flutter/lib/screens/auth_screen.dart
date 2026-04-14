import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../services/auth_service.dart';
import '../widgets/common_widgets.dart';
import 'main_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  bool _loading = false;
  String? _error;

  // Login controllers
  final _liEmail = TextEditingController();
  final _liPass = TextEditingController();
  bool _liShowPass = false;

  // Signup controllers
  final _suName = TextEditingController();
  final _suEmail = TextEditingController();
  final _suPass = TextEditingController();
  final _suRef = TextEditingController();
  bool _suShowPass = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() => setState(() => _error = null));
  }

  @override
  void dispose() {
    _tab.dispose();
    _liEmail.dispose(); _liPass.dispose();
    _suName.dispose(); _suEmail.dispose();
    _suPass.dispose(); _suRef.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    if (_liEmail.text.isEmpty || _liPass.text.isEmpty) {
      setState(() => _error = 'Please fill all fields');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final err = await AuthService.login(_liEmail.text.trim(), _liPass.text);
    if (!mounted) return;
    if (err != null) {
      setState(() { _error = err; _loading = false; });
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  Future<void> _doSignup() async {
    if (_suName.text.isEmpty || _suEmail.text.isEmpty || _suPass.text.isEmpty) {
      setState(() => _error = 'Please fill all fields');
      return;
    }
    if (_suPass.text.length < 6) {
      setState(() => _error = 'Password min 6 characters');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final err = await AuthService.signup(
      name: _suName.text.trim(),
      email: _suEmail.text.trim(),
      pass: _suPass.text,
      refCode: _suRef.text.trim().toUpperCase(),
    );
    if (!mounted) return;
    if (err != null) {
      setState(() { _error = err; _loading = false; });
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  Future<void> _doGoogle() async {
    setState(() { _loading = true; _error = null; });
    final err = await AuthService.googleSignIn();
    if (!mounted) return;
    if (err != null) {
      setState(() { _error = err; _loading = false; });
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.5),
                radius: 1.0,
                colors: [Color(0xFF071C3A), AppColors.bg],
              ),
            ),
          ),
          // Particles
          ..._buildParticles(),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Logo
                  _buildLogo(),

                  const SizedBox(height: 32),

                  // Tabs
                  _buildTabs(),

                  const SizedBox(height: 16),

                  // Form card
                  _buildFormCard(),

                  const SizedBox(height: 24),

                  // Bottom text
                  Text(
                    'ðŸ”’ Secure Â· Trusted by Gamers Â· Free Fire MAX India',
                    style: GoogleFonts.rajdhani(
                      fontSize: 11, color: AppColors.muted.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildParticles() {
    return List.generate(12, (i) {
      final positions = [
        [0.1, 0.1], [0.9, 0.15], [0.05, 0.4], [0.95, 0.35],
        [0.2, 0.7], [0.8, 0.65], [0.5, 0.05], [0.3, 0.9],
        [0.7, 0.85], [0.15, 0.55], [0.85, 0.5], [0.5, 0.5],
      ];
      final colors = [AppColors.cyan, AppColors.purple, AppColors.blue3];
      return Positioned(
        left: MediaQuery.of(context).size.width * positions[i][0],
        top: MediaQuery.of(context).size.height * positions[i][1],
        child: Container(
          width: i % 3 == 0 ? 3 : 2,
          height: i % 3 == 0 ? 3 : 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors[i % 3].withOpacity(0.3),
          ),
        ).animate(
          onPlay: (c) => c.repeat(reverse: true),
        ).fadeIn(duration: Duration(milliseconds: 1000 + i * 200))
         .fadeOut(duration: Duration(milliseconds: 1000 + i * 200)),
      );
    });
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D47A1), AppColors.cyan],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.cyan.withOpacity(0.3),
                blurRadius: 24, spreadRadius: 0,
              ),
            ],
            border: Border.all(
              color: AppColors.cyan.withOpacity(0.4), width: 2,
            ),
          ),
          child: Center(
            child: Text('S',
              style: GoogleFonts.orbitron(
                fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white,
              ),
            ),
          ),
        ).animate().scale(
          begin: const Offset(0.5, 0.5),
          duration: 600.ms, curve: Curves.elasticOut,
        ),

        const SizedBox(height: 14),

        GradientText(
          'SYNEX',
          colors: const [Colors.white, Color(0xFF90CAF9), AppColors.cyan],
          fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2,
        ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3, end: 0),

        const SizedBox(height: 4),
        Text('THE ARENA FOR CHAMPIONS',
          style: GoogleFonts.rajdhani(
            fontSize: 10, color: AppColors.cyan.withOpacity(0.6),
            letterSpacing: 4,
          ),
        ).animate(delay: 350.ms).fadeIn(),

        const SizedBox(height: 14),

        // Badges row
        Wrap(
          spacing: 8, runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            SynexBadge(label: 'ðŸ† Daily Tournaments', color: AppColors.cyan),
            SynexBadge(label: 'ðŸ’° Real Cash', color: AppColors.gold),
            SynexBadge(label: 'ðŸŽ® FF MAX', color: AppColors.success),
          ],
        ).animate(delay: 450.ms).fadeIn(),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        controller: _tab,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.blue1, AppColors.blue2],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: GoogleFonts.orbitron(
          fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5,
        ),
        unselectedLabelStyle: GoogleFonts.rajdhani(
          fontSize: 13, fontWeight: FontWeight.w700,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.muted,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'ðŸ”‘ LOGIN'),
          Tab(text: 'âš¡ SIGN UP'),
        ],
      ),
    ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFA0B1F3D), Color(0xFA081528)],
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 30, offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top accent
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.transparent, AppColors.cyan, Colors.transparent],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: TabBarView(
              controller: _tab,
              children: [_buildLoginForm(), _buildSignupForm()],
            ),
          ),
        ],
      ),
    ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.15, end: 0);
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        SynexTextField(
          label: 'Email',
          hint: 'your@email.com',
          controller: _liEmail,
          keyboardType: TextInputType.emailAddress,
        ),
        SynexTextField(
          label: 'Password',
          hint: 'â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢',
          controller: _liPass,
          obscure: !_liShowPass,
          suffix: IconButton(
            icon: Icon(
              _liShowPass ? Icons.visibility_off : Icons.visibility,
              color: AppColors.muted, size: 18,
            ),
            onPressed: () => setState(() => _liShowPass = !_liShowPass),
          ),
        ),
        if (_error != null) _buildError(),
        SynexButton(
          label: 'LOGIN',
          icon: Icons.login_rounded,
          loading: _loading,
          width: double.infinity,
          onTap: _doLogin,
        ),
        const SizedBox(height: 14),
        _buildDivider(),
        const SizedBox(height: 14),
        _buildGoogleBtn(),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Don't have an account? ",
              style: GoogleFonts.rajdhani(color: AppColors.muted, fontSize: 13)),
            GestureDetector(
              onTap: () => _tab.animateTo(1),
              child: Text('Sign Up Free',
                style: GoogleFonts.rajdhani(
                  color: AppColors.cyan, fontSize: 13, fontWeight: FontWeight.w700,
                )),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSignupForm() {
    return Column(
      children: [
        SynexTextField(label: 'Gamer Name', hint: 'Your Name', controller: _suName),
        SynexTextField(
          label: 'Email', hint: 'your@email.com',
          controller: _suEmail, keyboardType: TextInputType.emailAddress,
        ),
        SynexTextField(
          label: 'Password', hint: 'Min 6 characters',
          controller: _suPass, obscure: !_suShowPass,
          suffix: IconButton(
            icon: Icon(
              _suShowPass ? Icons.visibility_off : Icons.visibility,
              color: AppColors.muted, size: 18,
            ),
            onPressed: () => setState(() => _suShowPass = !_suShowPass),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('REFERRAL CODE '.toUpperCase(),
                  style: GoogleFonts.rajdhani(
                    fontSize: 11, color: AppColors.muted,
                    fontWeight: FontWeight.w700, letterSpacing: 1,
                  )),
                Text('(+â‚¹10 bonus!)',
                  style: GoogleFonts.rajdhani(
                    fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w700,
                  )),
              ],
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _suRef,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(color: AppColors.white, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Optional referral code',
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 14),
          ],
        ),
        if (_error != null) _buildError(),
        SynexButton(
          label: 'CREATE ACCOUNT',
          icon: Icons.bolt_rounded,
          loading: _loading,
          width: double.infinity,
          gradient: const [Color(0xFF1B5E20), AppColors.success],
          onTap: _doSignup,
        ),
        const SizedBox(height: 14),
        _buildDivider(),
        const SizedBox(height: 14),
        _buildGoogleBtn(),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Already have an account? ',
              style: GoogleFonts.rajdhani(color: AppColors.muted, fontSize: 13)),
            GestureDetector(
              onTap: () => _tab.animateTo(0),
              child: Text('Login',
                style: GoogleFonts.rajdhani(
                  color: AppColors.cyan, fontSize: 13, fontWeight: FontWeight.w700,
                )),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildError() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.danger.withOpacity(0.3)),
      ),
      child: Text(_error!,
        style: GoogleFonts.rajdhani(color: AppColors.danger, fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('OR', style: GoogleFonts.rajdhani(
            color: AppColors.muted, fontSize: 11, letterSpacing: 1,
          )),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }

  Widget _buildGoogleBtn() {
    return GestureDetector(
      onTap: _loading ? null : _doGoogle,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.card2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
              width: 18, height: 18,
            ),
            const SizedBox(width: 10),
            Text('Continue with Google',
              style: GoogleFonts.rajdhani(
                fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.white,
              )),
          ],
        ),
      ),
    );
  }
}
