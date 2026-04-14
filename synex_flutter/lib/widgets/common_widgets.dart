import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

// â”€â”€ SYNEX CARD â”€â”€
class SynexCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool glow;

  const SynexCard({
    super.key, required this.child,
    this.padding, this.borderColor,
    this.onTap, this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor ?? AppColors.border, width: 1,
          ),
          boxShadow: glow ? [
            BoxShadow(
              color: (borderColor ?? AppColors.cyan).withOpacity(0.2),
              blurRadius: 16, spreadRadius: 0,
            ),
          ] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8, offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

// â”€â”€ SYNEX BUTTON â”€â”€
class SynexButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool loading;
  final List<Color>? gradient;
  final double? width;
  final bool outlined;

  const SynexButton({
    super.key, required this.label,
    this.onTap, this.icon, this.loading = false,
    this.gradient, this.width, this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          gradient: outlined ? null : LinearGradient(
            colors: gradient ?? [AppColors.blue1, AppColors.blue2],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          border: outlined ? Border.all(color: AppColors.border) : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: outlined ? null : [
            BoxShadow(
              color: (gradient?.first ?? AppColors.blue1).withOpacity(0.35),
              blurRadius: 12, offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading) ...[
              const SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
            ] else if (icon != null) ...[
              Icon(icon, size: 16, color: outlined ? AppColors.blue3 : Colors.white),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: GoogleFonts.rajdhani(
                fontSize: 15, fontWeight: FontWeight.w700,
                color: outlined ? AppColors.blue3 : Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// â”€â”€ SYNEX TEXT FIELD â”€â”€
class SynexTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const SynexTextField({
    super.key, required this.label,
    this.hint, this.controller, this.obscure = false,
    this.keyboardType, this.suffix, this.validator, this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.rajdhani(
            fontSize: 11, color: AppColors.muted,
            fontWeight: FontWeight.w700, letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          style: const TextStyle(color: AppColors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffix,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14,
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

// â”€â”€ BADGE â”€â”€
class SynexBadge extends StatelessWidget {
  final String label;
  final Color color;

  const SynexBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: GoogleFonts.rajdhani(
          fontSize: 11, color: color,
          fontWeight: FontWeight.w700, letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// â”€â”€ GRADIENT TEXT â”€â”€
class GradientText extends StatelessWidget {
  final String text;
  final List<Color> colors;
  final double? fontSize;
  final FontWeight? fontWeight;
  final String? fontFamily;
  final double letterSpacing;

  const GradientText(
    this.text, {
    super.key,
    this.colors = const [AppColors.blue3, AppColors.cyan],
    this.fontSize, this.fontWeight,
    this.fontFamily, this.letterSpacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontFamily: fontFamily ?? 'Orbitron',
          letterSpacing: letterSpacing,
        ),
      ),
    );
  }
}

// â”€â”€ SHIMMER LOADING â”€â”€
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width, height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          colors: [
            AppColors.card2,
            AppColors.border.withOpacity(0.5),
            AppColors.card2,
          ],
        ),
      ),
    );
  }
}

// â”€â”€ COPY TEXT UTIL â”€â”€
void copyToClipboard(BuildContext context, String text, String label) {
  Clipboard.setData(ClipboardData(text: text));
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$label copied! ðŸ“‹',
        style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700)),
      backgroundColor: AppColors.card,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.success),
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}

// â”€â”€ SECTION HEADER â”€â”€
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const SectionHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
            style: GoogleFonts.orbitron(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: AppColors.blue3, letterSpacing: 0.6,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!,
              style: GoogleFonts.rajdhani(
                fontSize: 12, color: AppColors.muted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// â”€â”€ NEON DIVIDER â”€â”€
class NeonDivider extends StatelessWidget {
  const NeonDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.border,
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// â”€â”€ STAT BOX â”€â”€
class StatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const StatBox({
    super.key,
    required this.value,
    required this.label,
    this.color = AppColors.cyan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(value,
            style: GoogleFonts.orbitron(
              fontSize: 16, fontWeight: FontWeight.w900, color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(label,
            style: GoogleFonts.rajdhani(
              fontSize: 10, color: AppColors.muted,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
