import 'package:flutter/material.dart';

/// Paleta de cores oficial da marca be EASY Print conforme DESIGN.md e protótipo Stitch
class AppColors {
  AppColors._();

  // Cores Principais da Marca
  static const Color primary = Color(0xFF709A28); // Accent Green (Botões de ação, Sucesso, Valor em destaque)
  static const Color primaryDark = Color(0xFF446600);
  static const Color secondary = Color(0xFF912A18); // Brand Brick (Títulos, Cabeçalhos, Ícones de destaque)
  static const Color tertiary = Color(0xFFBD8561); // Primary Tan (Bordas de cartões, Área do pendrive)

  // Superfícies e Fundos
  static const Color background = Color(0xFFFAFAFA); // Off-white para conforto visual
  static const Color surface = Color(0xFFFFFFFF); // Branco puro para cards
  static const Color surfaceContainer = Color(0xFFF0EDED);
  static const Color surfaceContainerLow = Color(0xFFF6F3F2);
  static const Color surfaceContainerHigh = Color(0xFFEAE7E7);
  static const Color dropzoneTint = Color(0xFFF9F3EF); // 10% tan suave
  static const Color borderTanLight = Color(0xFFE9DACF);

  // Tipografia e Contrastes
  static const Color textPrimary = Color(0xFF2C2C2C); // Cinza muito escuro
  static const Color textSecondary = Color(0xFF666666); // Cinza médio
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFBA1A1A); // Cor para erros e alertas
  static const Color onError = Color(0xFFFFFFFF);
}
