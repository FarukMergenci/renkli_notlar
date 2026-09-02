import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';

class CategoryChip extends StatelessWidget {
  final CategoryModel? category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = category?.color ?? Theme.of(context).primaryColor;

    final String label = category == null ? 'Tümü' : category!.name;
    final IconData icon = category == null ? Icons.grid_view_rounded : category!.icon;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        selected: isSelected,
        showCheckmark: false,
        avatar: Icon(
          icon,
          size: 16,
          color: isSelected
              ? Colors.white
              : (category != null
                  ? categoryColor
                  : (isDark ? Colors.white70 : Colors.black87)),
        ),
        label: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
        selectedColor: categoryColor,
        backgroundColor: isDark
            ? Colors.grey[850]
            : (category != null
                ? categoryColor.withValues(alpha: 0.12)
                : Colors.grey[200]),
        side: BorderSide(
          color: isSelected
              ? categoryColor
              : (category != null
                  ? categoryColor.withValues(alpha: 0.3)
                  : Colors.transparent),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }
}
