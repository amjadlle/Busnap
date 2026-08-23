import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:busnap/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const BusnapApp());
}

class BusnapApp extends StatelessWidget {
  const BusnapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Busnap',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const HomePage(),
    );
  }
}

class AppTheme {
  AppTheme._();

  // ── Core palette — black & white ──────────────────────────────────────────
  static const Color bg           = Color(0xFFF4FBF6);
  static const Color bgInner      = Color(0xFFFFFFFF);
  static const Color ink          = Color(0xFF17251C);
  static const Color inkSecondary = Color(0xFF526458);
  static const Color inkMuted     = Color(0xFF8A9C90);

  // ── Accent ────────────────────────────────────────────────────────────────
  static const Color accent       = Color(0xFF1DB56A);
  static const Color accentLight  = Color(0xFFDCF8E7);

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color danger       = Color(0xFFE45868);
  static const Color dangerLight  = Color(0xFFFFE7E9);
  static const Color warning      = Color(0xFFE9A334);
  static const Color warningLight = Color(0xFFFFF2D8);

  // ── Glass ────────────────────────────────────────────────────────────────
  // White bg glass: more opaque fill + coloured border = floating card look
  static const Color glassFill    = Color(0xEFFFFFFF);
  static const Color glassBorder  = Color(0x00FFFFFF);
  static const Color glassShadow  = Color(0x1A247446);

  // Background radial gradient — very subtle warm vignette
  static const Color gradEdge     = Color(0xFFE9F6ED);
  static const Color gradCentre   = Color(0xFFFFFFFF);

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.light(
      primary: accent,
      secondary: accent,
      surface: bgInner,
      error: danger,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: bg,
      foregroundColor: ink,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF7FCF8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2EFE6)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2EFE6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: accent, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      hintStyle: const TextStyle(color: inkMuted, fontSize: 15),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 8,
        shadowColor: accent.withValues(alpha: 0.35),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ink,
        side: const BorderSide(color: glassBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
  );
}
