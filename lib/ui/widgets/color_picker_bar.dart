import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class ColorPickerBar extends StatelessWidget {
  final String selectedColorId;
  final ValueChanged<String> onColorSelected;

  const ColorPickerBar({
    super.key,
    required this.selectedColorId,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: AppColors.noteColors.length,
        itemBuilder: (context, index) {
          final colorOption = AppColors.noteColors[index];
          final isSelected = colorOption.id == selectedColorId;
          final displayColor =
              isDark ? colorOption.darkColor : colorOption.color;

          return GestureDetector(
            onTap: () => onColorSelected(colorOption.id),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              width: 44,
              decoration: BoxDecoration(
                color: displayColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? colorOption.accentColor
                      : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                  width: isSelected ? 3 : 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: colorOption.accentColor.withValues(alpha: 0.4),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: colorOption.accentColor,
                      size: 22,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
