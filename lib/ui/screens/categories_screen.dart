import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/category_model.dart';
import '../../providers/category_provider.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  static const List<IconData> availableIcons = [
    Icons.work_outline,
    Icons.person_outline,
    Icons.shopping_bag_outlined,
    Icons.lightbulb_outline,
    Icons.school_outlined,
    Icons.favorite_border,
    Icons.home_outlined,
    Icons.fitness_center,
    Icons.flight_takeoff,
    Icons.restaurant,
    Icons.music_note_outlined,
    Icons.palette_outlined,
    Icons.sports_esports_outlined,
    Icons.attach_money,
    Icons.star_border,
  ];

  static const List<Color> availableColors = [
    Color(0xFF0D6EFD), // Blue
    Color(0xFF6F42C1), // Purple
    Color(0xFF198754), // Green
    Color(0xFFE6A100), // Yellow
    Color(0xFFDC3545), // Red
    Color(0xFFFD7E14), // Orange
    Color(0xFF20C997), // Teal
    Color(0xFF6C757D), // Gray
  ];

  void _showAddCategoryDialog(BuildContext context, [CategoryModel? existing]) {
    final nameController =
        TextEditingController(text: existing != null ? existing.name : '');
    int selectedIconCode = existing != null
        ? existing.iconCode
        : availableIcons.first.codePoint;
    int selectedColorValue = existing != null
        ? existing.colorValue
        : availableColors.first.toARGB32();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(existing == null ? 'Yeni Kategori' : 'Kategoriyi Düzenle'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Kategori Adı',
                        hintText: 'Örn: Spor, Projeler...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('İkon Seçin:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableIcons.map((iconData) {
                        final isSelected =
                            iconData.codePoint == selectedIconCode;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedIconCode = iconData.codePoint;
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Color(selectedColorValue).withValues(alpha: 0.2)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? Color(selectedColorValue)
                                    : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              iconData,
                              color: isSelected
                                  ? Color(selectedColorValue)
                                  : Colors.grey[700],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('Renk Seçin:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableColors.map((color) {
                        final isSelected = color.toARGB32() == selectedColorValue;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedColorValue = color.toARGB32();
                            });
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.black
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 20)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('İptal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;

                    final categoryProvider =
                        Provider.of<CategoryProvider>(context, listen: false);

                    if (existing == null) {
                      categoryProvider.addCategory(
                        CategoryModel(
                          name: name,
                          colorValue: selectedColorValue,
                          iconCode: selectedIconCode,
                        ),
                      );
                    } else {
                      categoryProvider.updateCategory(
                        existing.copyWith(
                          name: name,
                          colorValue: selectedColorValue,
                          iconCode: selectedIconCode,
                        ),
                      );
                    }
                    Navigator.pop(context);
                  },
                  child: Text(existing == null ? 'Ekle' : 'Kaydet'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori Yönetimi'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCategoryDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Kategori Ekle'),
      ),
      body: categoryProvider.categories.isEmpty
          ? const Center(child: Text('Henüz kategori eklenmedi'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categoryProvider.categories.length,
              itemBuilder: (context, index) {
                final category = categoryProvider.categories[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: category.color.withValues(alpha: 0.2),
                      child: Icon(category.icon, color: category.color),
                    ),
                    title: Text(
                      category.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () =>
                              _showAddCategoryDialog(context, category),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              size: 20, color: Colors.redAccent),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Kategoriyi Sil'),
                                content: Text(
                                    '${category.name} kategorisini silmek istediğinizden emin misiniz? Bu kategoriye ait notların kategorisi sıfırlanacaktır.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Vazgeç'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent),
                                    onPressed: () {
                                      categoryProvider
                                          .deleteCategory(category.id!);
                                      Navigator.pop(ctx);
                                    },
                                    child: const Text('Sil',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
