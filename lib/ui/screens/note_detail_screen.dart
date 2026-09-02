import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/note_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/note_provider.dart';
import '../core/app_colors.dart';
import '../widgets/color_picker_bar.dart';

class NoteDetailScreen extends StatefulWidget {
  final NoteModel? note;

  const NoteDetailScreen({super.key, this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late String _selectedColorId;
  int? _selectedCategoryId;
  late bool _isPinned;
  DateTime? _reminderDateTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController =
        TextEditingController(text: widget.note?.content ?? '');
    _selectedColorId = widget.note?.colorId ?? 'yellow';
    _selectedCategoryId = widget.note?.categoryId;
    _isPinned = widget.note?.isPinned ?? false;
    _reminderDateTime = widget.note?.reminderDateTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickReminderDateTime() async {
    final now = DateTime.now();
    final initialDate = _reminderDateTime ?? now.add(const Duration(hours: 1));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now) ? now : initialDate,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      locale: const Locale('tr', 'TR'),
    );

    if (pickedDate == null) return;

    if (!mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (pickedTime == null) return;

    setState(() {
      _reminderDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final noteProvider = Provider.of<NoteProvider>(context, listen: false);

    if (widget.note == null) {
      // Create New
      final newNote = NoteModel(
        title: title,
        content: content,
        categoryId: _selectedCategoryId,
        colorId: _selectedColorId,
        isPinned: _isPinned,
        reminderDateTime: _reminderDateTime,
      );
      noteProvider.addNote(newNote);
    } else {
      // Update Existing
      final updatedNote = widget.note!.copyWith(
        title: title,
        content: content,
        categoryId: _selectedCategoryId,
        clearCategory: _selectedCategoryId == null,
        colorId: _selectedColorId,
        isPinned: _isPinned,
        reminderDateTime: _reminderDateTime,
        clearReminder: _reminderDateTime == null,
      );
      noteProvider.updateNote(updatedNote);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorOption = AppColors.getColorById(_selectedColorId);
    final bgColor = isDark ? colorOption.darkColor : colorOption.color;
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: _saveNote,
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
              color: _isPinned
                  ? colorOption.accentColor
                  : (isDark ? Colors.white70 : Colors.black87),
            ),
            tooltip: _isPinned ? 'Sabitlemeyi Kaldır' : 'Başa Sabitle',
            onPressed: () {
              setState(() {
                _isPinned = !_isPinned;
              });
            },
          ),
          if (widget.note != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Colors.redAccent),
              tooltip: 'Notu Sil',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Notu Sil'),
                    content:
                        const Text('Bu notu silmek istediğinize emin misiniz?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Vazgeç'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent),
                        onPressed: () {
                          Provider.of<NoteProvider>(context, listen: false)
                              .deleteNote(widget.note!.id!);
                          Navigator.pop(ctx); // close dialog
                          Navigator.pop(context); // exit detail screen
                        },
                        child: const Text('Sil',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.check_rounded),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category selector dropdown
                    Row(
                      children: [
                        const Icon(Icons.label_outline_rounded, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int?>(
                              value: _selectedCategoryId,
                              hint: const Text('Kategori Seçin'),
                              isExpanded: true,
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text('Kategorisiz'),
                                ),
                                ...categoryProvider.categories.map((c) {
                                  return DropdownMenuItem<int?>(
                                    value: c.id,
                                    child: Row(
                                      children: [
                                        Icon(c.icon, size: 18, color: c.color),
                                        const SizedBox(width: 8),
                                        Text(c.name),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                              onChanged: (val) {
                                setState(() {
                                  _selectedCategoryId = val;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Reminder status chip / picker button
                    InkWell(
                      onTap: _pickReminderDateTime,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _reminderDateTime != null
                              ? Colors.amber.withValues(alpha: 0.2)
                              : (isDark
                                  ? Colors.white10
                                  : Colors.black.withValues(alpha: 0.04)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _reminderDateTime != null
                                ? Colors.amber.shade700
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _reminderDateTime != null
                                  ? Icons.notifications_active_rounded
                                  : Icons.add_alarm_rounded,
                              size: 18,
                              color: _reminderDateTime != null
                                  ? Colors.amber.shade800
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _reminderDateTime != null
                                  ? DateFormat('dd MMMM yyyy HH:mm', 'tr_TR')
                                      .format(_reminderDateTime!)
                                  : 'Hatırlatıcı Ekle',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: _reminderDateTime != null
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _reminderDateTime != null
                                    ? (isDark
                                        ? Colors.amber.shade200
                                        : Colors.amber.shade900)
                                    : (isDark
                                        ? Colors.white70
                                        : Colors.black87),
                              ),
                            ),
                            if (_reminderDateTime != null) ...[
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _reminderDateTime = null;
                                  });
                                },
                                child: const Icon(Icons.close_rounded,
                                    size: 16, color: Colors.amber),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title input field
                    TextField(
                      controller: _titleController,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Başlık',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const Divider(),

                    // Content input field
                    TextField(
                      controller: _contentController,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.4,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.9)
                            : Colors.black87,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Notunuzu yazın...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Color palette at bottom
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.6),
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.white10 : Colors.black12,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Not Rengi',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  ColorPickerBar(
                    selectedColorId: _selectedColorId,
                    onColorSelected: (id) {
                      setState(() {
                        _selectedColorId = id;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
