import 'package:flutter/material.dart';

class AppColors {
  // Predefined vibrant & pastel colors for notes
  static const List<ColorOption> noteColors = [
    ColorOption(
      id: 'yellow',
      name: 'Sarı',
      color: Color(0xFFFFF3CD),
      darkColor: Color(0xFF3E3618),
      accentColor: Color(0xFFE6A100),
    ),
    ColorOption(
      id: 'green',
      name: 'Yeşil',
      color: Color(0xFFD1E7DD),
      darkColor: Color(0xFF14382B),
      accentColor: Color(0xFF198754),
    ),
    ColorOption(
      id: 'blue',
      name: 'Mavi',
      color: Color(0xFFCFE2FF),
      darkColor: Color(0xFF16325C),
      accentColor: Color(0xFF0D6EFD),
    ),
    ColorOption(
      id: 'purple',
      name: 'Mor',
      color: Color(0xFFE2D9F3),
      darkColor: Color(0xFF2C194D),
      accentColor: Color(0xFF6F42C1),
    ),
    ColorOption(
      id: 'orange',
      name: 'Turuncu',
      color: Color(0xFFFFE5D0),
      darkColor: Color(0xFF4A2800),
      accentColor: Color(0xFFFD7E14),
    ),
    ColorOption(
      id: 'pink',
      name: 'Pembe',
      color: Color(0xFFF8D7DA),
      darkColor: Color(0xFF421217),
      accentColor: Color(0xFFDC3545),
    ),
    ColorOption(
      id: 'teal',
      name: 'Turkuaz',
      color: Color(0xFFCFF4FC),
      darkColor: Color(0xFF0F3E47),
      accentColor: Color(0xFF20C997),
    ),
    ColorOption(
      id: 'gray',
      name: 'Gri',
      color: Color(0xFFE9ECEF),
      darkColor: Color(0xFF212529),
      accentColor: Color(0xFF6C757D),
    ),
  ];

  static ColorOption getColorById(String id) {
    return noteColors.firstWhere(
      (c) => c.id == id,
      orElse: () => noteColors.first,
    );
  }
}

class ColorOption {
  final String id;
  final String name;
  final Color color;
  final Color darkColor;
  final Color accentColor;

  const ColorOption({
    required this.id,
    required this.name,
    required this.color,
    required this.darkColor,
    required this.accentColor,
  });
}
