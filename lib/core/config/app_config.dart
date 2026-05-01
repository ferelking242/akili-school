class AppConfig {
  AppConfig._();

  static const String appName    = 'Scolaris';
  static const String appTagline = 'Savoir, Héritage, Avenir';
  static const String appVersion = '0.1.0';

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  // ── Palette africaine inspirée du logo ───────────────────────────────────
  /// Terracotta profond — couleur principale de la marque
  static const int defaultAccentArgb = 0xFF8B1A00;
  /// Or chaud / ambre
  static const int accentGoldArgb    = 0xFFC17F24;
  /// Vert forêt
  static const int accentGreenArgb   = 0xFF1B5E20;
  /// Orange vif
  static const int accentOrangeArgb  = 0xFFD4540A;
}
