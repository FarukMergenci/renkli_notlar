import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/note_provider.dart';
import '../../providers/theme_provider.dart';
import '../widgets/category_chip.dart';
import '../widgets/note_card.dart';
import '../widgets/search_bar_widget.dart';
import 'categories_screen.dart';
import 'note_detail_screen.dart';
import 'reminders_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NoteProvider>(context, listen: false).loadNotes();
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final filteredNotes = noteProvider.filteredNotes;
    final pinnedNotes = filteredNotes.where((n) => n.isPinned).toList();
    final otherNotes = filteredNotes.where((n) => !n.isPinned).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Renkli Notlar'),
        actions: [
          // View Layout Toggle
          IconButton(
            icon: Icon(
              noteProvider.isGridView
                  ? Icons.view_list_rounded
                  : Icons.grid_view_rounded,
            ),
            tooltip: noteProvider.isGridView ? 'Liste Görünümü' : 'Izgara Görünümü',
            onPressed: () => noteProvider.toggleViewLayout(),
          ),

          // Sort Menu
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Sırala',
            onSelected: (option) => noteProvider.setSortOption(option),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: SortOption.dateDesc,
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Yeniden Eskiye'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: SortOption.dateAsc,
                child: Row(
                  children: [
                    Icon(Icons.history_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Eskiden Yeniye'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: SortOption.titleAsc,
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('A - Z Başlığa Göre'),
                  ],
                ),
              ),
            ],
          ),

          // Theme Mode Switch
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            tooltip: isDark ? 'Aydınlık Mod' : 'Karanlık Mod',
            onPressed: () => themeProvider.toggleTheme(!isDark),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.edit_note_rounded,
                      size: 44, color: Color(0xFF6750A4)),
                  const SizedBox(height: 8),
                  Text(
                    'Renkli Not Defteri',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    'Organize edin, renklendirin',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimaryContainer
                          .withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.notes_rounded),
              title: const Text('Tüm Notlar'),
              onTap: () {
                noteProvider.setSelectedCategory(null);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.alarm_rounded, color: Colors.amber),
              title: const Text('Hatırlatıcılar'),
              trailing: noteProvider.upcomingReminders.isNotEmpty
                  ? Badge(
                      label: Text('${noteProvider.upcomingReminders.length}'),
                    )
                  : null,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RemindersScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.category_rounded, color: Colors.purple),
              title: const Text('Kategori Yönetimi'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CategoriesScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            SwitchListTile(
              secondary: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              ),
              title: const Text('Karanlık Mod'),
              value: isDark,
              onChanged: (val) => themeProvider.toggleTheme(val),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NoteDetailScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded, size: 28),
        label: const Text('Yeni Not', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Search Bar Widget
          SearchBarWidget(
            query: noteProvider.searchQuery,
            onChanged: (q) => noteProvider.setSearchQuery(q),
            onClear: () {
              _searchController.clear();
              noteProvider.setSearchQuery('');
            },
          ),

          // Categories Horizontal Chips
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categoryProvider.categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return CategoryChip(
                    category: null,
                    isSelected: noteProvider.selectedCategoryId == null,
                    onTap: () => noteProvider.setSelectedCategory(null),
                  );
                }
                final category = categoryProvider.categories[index - 1];
                return CategoryChip(
                  category: category,
                  isSelected: noteProvider.selectedCategoryId == category.id,
                  onTap: () => noteProvider.setSelectedCategory(category.id),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Notes View Body
          Expanded(
            child: noteProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredNotes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.note_alt_outlined,
                              size: 72,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              noteProvider.searchQuery.isNotEmpty
                                  ? 'Aramanıza uygun not bulunamadı'
                                  : 'Henüz not eklenmemiş',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Yeni bir not eklemek için "+" butonuna dokunun.',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await noteProvider.loadNotes();
                        },
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Pinned Notes Section
                              if (pinnedNotes.isNotEmpty) ...[
                                Row(
                                  children: [
                                    const Icon(Icons.push_pin_rounded,
                                        size: 16, color: Colors.amber),
                                    const SizedBox(width: 6),
                                    Text(
                                      'SABİTLENENLER',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.1,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _buildNotesGridOrList(
                                  context,
                                  pinnedNotes,
                                  noteProvider.isGridView,
                                ),
                                const SizedBox(height: 20),
                              ],

                              // Other Notes Section
                              if (otherNotes.isNotEmpty) ...[
                                if (pinnedNotes.isNotEmpty)
                                  Text(
                                    'DİĞER NOTLAR',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.1,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                if (pinnedNotes.isNotEmpty)
                                  const SizedBox(height: 8),
                                _buildNotesGridOrList(
                                  context,
                                  otherNotes,
                                  noteProvider.isGridView,
                                ),
                              ],
                              const SizedBox(height: 80), // FAB space
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesGridOrList(
      BuildContext context, List notes, bool isGrid) {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);

    if (isGrid) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.82,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return NoteCard(
            note: note,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteDetailScreen(note: note),
                ),
              );
            },
            onPinTap: () => noteProvider.togglePin(note),
            onDeleteTap: () => noteProvider.deleteNote(note.id!),
          );
        },
      );
    } else {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: NoteCard(
              note: note,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteDetailScreen(note: note),
                  ),
                );
              },
              onPinTap: () => noteProvider.togglePin(note),
              onDeleteTap: () => noteProvider.deleteNote(note.id!),
            ),
          );
        },
      );
    }
  }
}
