import 'package:flutter/material.dart';
import '../data/database/database_helper.dart';
import '../data/models/note_model.dart';
import '../data/services/notification_service.dart';

enum SortOption { dateDesc, dateAsc, titleAsc }

class NoteProvider extends ChangeNotifier {
  List<NoteModel> _notes = [];
  bool _isLoading = false;
  int? _selectedCategoryId;
  String _searchQuery = '';
  SortOption _sortOption = SortOption.dateDesc;
  bool _isGridView = true;

  List<NoteModel> get notes => _notes;
  bool get isLoading => _isLoading;
  int? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  SortOption get sortOption => _sortOption;
  bool get isGridView => _isGridView;

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    _notes = await DatabaseHelper.instance.getAllNotes();
    _isLoading = false;
    notifyListeners();
  }

  void setSelectedCategory(int? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortOption(SortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  void toggleViewLayout() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  // Filtered and Sorted Notes
  List<NoteModel> get filteredNotes {
    return _notes.where((note) {
      // Category filter
      if (_selectedCategoryId != null &&
          note.categoryId != _selectedCategoryId) {
        return false;
      }
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = note.title.toLowerCase().contains(query);
        final matchesContent = note.content.toLowerCase().contains(query);
        if (!matchesTitle && !matchesContent) return false;
      }
      return true;
    }).toList()
      ..sort((a, b) {
        // Pinned notes always come first
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;

        switch (_sortOption) {
          case SortOption.dateDesc:
            return b.updatedAt.compareTo(a.updatedAt);
          case SortOption.dateAsc:
            return a.updatedAt.compareTo(b.updatedAt);
          case SortOption.titleAsc:
            return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        }
      });
  }

  List<NoteModel> get upcomingReminders {
    final now = DateTime.now();
    return _notes
        .where((n) =>
            n.reminderDateTime != null && n.reminderDateTime!.isAfter(now))
        .toList()
      ..sort((a, b) => a.reminderDateTime!.compareTo(b.reminderDateTime!));
  }

  Future<void> addNote(NoteModel note) async {
    final createdNote = await DatabaseHelper.instance.createNote(note);
    _notes.insert(0, createdNote);

    if (createdNote.reminderDateTime != null && createdNote.id != null) {
      await NotificationService.instance.scheduleNotification(
        id: createdNote.id!,
        title: createdNote.title,
        body: createdNote.content,
        scheduledDate: createdNote.reminderDateTime!,
      );
    }

    notifyListeners();
  }

  Future<void> updateNote(NoteModel note) async {
    await DatabaseHelper.instance.updateNote(note);
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
    }

    if (note.id != null) {
      if (note.reminderDateTime != null) {
        await NotificationService.instance.scheduleNotification(
          id: note.id!,
          title: note.title,
          body: note.content,
          scheduledDate: note.reminderDateTime!,
        );
      } else {
        await NotificationService.instance.cancelNotification(note.id!);
      }
    }

    notifyListeners();
  }

  Future<void> togglePin(NoteModel note) async {
    final updated = note.copyWith(isPinned: !note.isPinned);
    await updateNote(updated);
  }

  Future<void> deleteNote(int id) async {
    await DatabaseHelper.instance.deleteNote(id);
    _notes.removeWhere((n) => n.id == id);
    await NotificationService.instance.cancelNotification(id);
    notifyListeners();
  }

  Future<void> removeReminder(NoteModel note) async {
    final updated = note.copyWith(clearReminder: true);
    await updateNote(updated);
  }
}
