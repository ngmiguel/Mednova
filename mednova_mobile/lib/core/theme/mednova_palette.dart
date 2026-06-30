import 'package:flutter/material.dart';

/// Theme-aware colors for 3D surfaces, glass cards and parallax backgrounds.
class MedNovaPalette {
  const MedNovaPalette({
    required this.isDark,
    required this.scaffoldGradient,
    required this.cardGradient,
    required this.glassFill,
    required this.glassBorder,
    required this.textPrimary,
    required this.textMuted,
    required this.parallaxOrbColors,
    required this.cardShadow,
    required this.messageBubble,
    required this.messageBubbleBorder,
    required this.messageText,
    required this.inputBarFill,
  });

  final bool isDark;
  final List<Color> scaffoldGradient;
  final Gradient cardGradient;
  final Color glassFill;
  final Color glassBorder;
  final Color textPrimary;
  final Color textMuted;
  final List<Color> parallaxOrbColors;
  final Color cardShadow;
  final Color messageBubble;
  final Color messageBubbleBorder;
  final Color messageText;
  final Color inputBarFill;

  static MedNovaPalette of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }

  static const dark = MedNovaPalette(
    isDark: true,
    scaffoldGradient: [Color(0xFF050810), Color(0xFF0A0F1E), Color(0xFF121A32)],
    cardGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1A2238), Color(0xFF0F1524)],
    ),
    glassFill: Color(0x1AFFFFFF),
    glassBorder: Color(0x33FFFFFF),
    textPrimary: Color(0xFFF8FAFC),
    textMuted: Color(0xFF94A3B8),
    parallaxOrbColors: [
      Color(0xFF14B8A6),
      Color(0xFF8B5CF6),
      Color(0xFFEC4899),
      Color(0xFF22D3EE),
    ],
    cardShadow: Color(0xFF14B8A6),
    messageBubble: Color(0x3314B8A6),
    messageBubbleBorder: Color(0x6614B8A6),
    messageText: Color(0xFFF8FAFC),
    inputBarFill: Color(0x1AFFFFFF),
  );

  static const light = MedNovaPalette(
    isDark: false,
    scaffoldGradient: [Color(0xFFEFF6FF), Color(0xFFE0E7FF), Color(0xFFFDF2F8)],
    cardGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFFFFF), Color(0xFFF0F9FF), Color(0xFFEDE9FE)],
    ),
    glassFill: Color(0xCCFFFFFF),
    glassBorder: Color(0x4D14B8A6),
    textPrimary: Color(0xFF0F172A),
    textMuted: Color(0xFF64748B),
    parallaxOrbColors: [
      Color(0xFF2DD4BF),
      Color(0xFFA78BFA),
      Color(0xFFF472B6),
      Color(0xFF38BDF8),
    ],
    cardShadow: Color(0xFF6366F1),
    messageBubble: Color(0x2614B8A6),
    messageBubbleBorder: Color(0x4D14B8A6),
    messageText: Color(0xFF0F172A),
    inputBarFill: Color(0xF2FFFFFF),
  );
}
