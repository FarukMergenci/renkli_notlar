import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/note_model.dart';
import '../../providers/category_provider.dart';
import '../core/app_colors.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;
  final VoidCallback onPinTap;
  final VoidCallback onDeleteTap;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onPinTap,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorOption = AppColors.getColorById(note.colorId);
    final cardBgColor = isDark ? colorOption.darkColor : colorOption.color;

    final categoryProvider = Provider.of<CategoryProvider>(context);
    final category = categoryProvider.getCategoryById(note.categoryId);

    final String formattedDate =
        DateFormat('dd MMM, HH:mm', 'tr_TR').format(note.updatedAt);

    final bool hasActiveReminder = note.hasReminder;

    return Card(
      color: cardBgColor,
      elevation: note.isPinned ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: note.isPinned
              ? colorOption.accentColor
              : (isDark
                  ? Colors.white10
                  : Colors.black.withValues(alpha: 0.05)),
          width: note.isPinned ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header: Pin icon & Action Menu
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      note.title.isEmpty ? 'Başlıksız Not' : note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      note.isPinned
                          ? Icons.push_pin_rounded
                          : Icons.push_pin_outlined,
                      size: 20,
                      color: note.isPinned
                          ? colorOption.accentColor
                          : (isDark ? Colors.white38 : Colors.black38),
                    ),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    onPressed: onPinTap,
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Content snippet
              Text(
                note.content.isEmpty ? 'İçerik yok' : note.content,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.black87,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),

              // Footer: Category badge, Reminder badge, Date
              Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: category.color.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: category.color.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(category.icon,
                              size: 12, color: category.color),
                          const SizedBox(width: 4),
                          Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.9)
                                  : category.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (hasActiveReminder)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber.shade700,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.notifications_active_rounded,
                              size: 12, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('dd MMM HH:mm', 'tr_TR')
                                .format(note.reminderDateTime!),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.amber.shade200
                                  : Colors.amber.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Date bottom text
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.white38 : Colors.black45,
                    ),
                  ),
                  InkWell(
                    onTap: onDeleteTap,
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        size: 16,
                        color: isDark ? Colors.white38 : Colors.black45,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
