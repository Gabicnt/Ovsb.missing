import 'package:flutter/material.dart';

/// Paleta de cores monocromática estilo Kindle - MODO CLARO
class KindleColors {
  KindleColors._();

  /// Preto puro - textos principais, ícones ativos, bordas de destaque
  static const Color black = Color(0xFF000000);

  /// Cinza escuro - textos secundários, legendas
  static const Color dark = Color(0xFF333333);

  /// Cinza médio - ícones inativos, divisores, placeholder
  static const Color medium = Color(0xFF999999);

  /// Cinza claro - fundo de cards, separadores discretos
  static const Color light = Color(0xFFE0E0E0);

  /// Off-white - fundo de tela "papel"
  static const Color offWhite = Color(0xFFF5F5F0);

  /// Branco - fundo de cards, diálogos
  static const Color white = Color(0xFFFFFFFF);
}

/// Paleta de cores monocromática estilo Kindle - MODO ESCURO
class KindleColorsDark {
  KindleColorsDark._();

  /// Branco - textos principais no modo escuro
  static const Color black = Color(0xFFFFFFFF);

  /// Cinza claro - textos secundários no modo escuro
  static const Color dark = Color(0xFFE0E0E0);

  /// Cinza médio - ícones inativos, divisores
  static const Color medium = Color(0xFF888888);

  /// Cinza escuro - bordas, separadores
  static const Color light = Color(0xFF3D3D3D);

  /// Preto suave - fundo de tela
  static const Color offWhite = Color(0xFF1A1A1A);

  /// Preto - fundo de cards
  static const Color white = Color(0xFF252525);
}

/// Classe para obter cores baseado no tema atual
class AppColors {
  final bool isDark;

  AppColors({required this.isDark});

  Color get primary => isDark ? KindleColorsDark.black : KindleColors.black;
  Color get secondary => isDark ? KindleColorsDark.dark : KindleColors.dark;
  Color get tertiary => isDark ? KindleColorsDark.medium : KindleColors.medium;
  Color get border => isDark ? KindleColorsDark.light : KindleColors.light;
  Color get background => isDark ? KindleColorsDark.offWhite : KindleColors.offWhite;
  Color get surface => isDark ? KindleColorsDark.white : KindleColors.white;
  
  // Cores invertidas para botões
  Color get buttonBg => isDark ? KindleColors.white : KindleColors.black;
  Color get buttonText => isDark ? KindleColors.black : KindleColors.white;
}

/// Extensão para facilitar uso das cores em contexto de Material
extension KindleColorsExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  AppColors get colors => AppColors(isDark: isDarkMode);
  
  // Atalhos para modo claro (compatibilidade)
  Color get kindleBlack => colors.primary;
  Color get kindleDark => colors.secondary;
  Color get kindleMedium => colors.tertiary;
  Color get kindleLight => colors.border;
  Color get kindleOffWhite => colors.background;
  Color get kindleWhite => colors.surface;
}
