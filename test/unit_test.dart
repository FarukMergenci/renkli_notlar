import 'package:flutter_test/flutter_test.dart';
import 'package:renkli_notlar/data/models/category_model.dart';
import 'package:renkli_notlar/data/models/note_model.dart';

void main() {
  group('CategoryModel Tests', () {
    test('toMap and fromMap work correctly', () {
      final category = CategoryModel(
        id: 1,
        name: 'Test Kategori',
        colorValue: 0xFF0D6EFD,
        iconCode: 12345,
      );

      final map = category.toMap();
      expect(map['id'], 1);
      expect(map['name'], 'Test Kategori');
      expect(map['colorValue'], 0xFF0D6EFD);

      final restored = CategoryModel.fromMap(map);
      expect(restored.id, 1);
      expect(restored.name, 'Test Kategori');
      expect(restored.colorValue, 0xFF0D6EFD);
    });
  });

  group('NoteModel Tests', () {
    test('toMap and fromMap work correctly', () {
      final now = DateTime.now();
      final reminder = now.add(const Duration(days: 1));

      final note = NoteModel(
        id: 10,
        title: 'Harika Fikir',
        content: 'Not içeriği burada',
        categoryId: 1,
        colorId: 'purple',
        isPinned: true,
        reminderDateTime: reminder,
      );

      final map = note.toMap();
      expect(map['id'], 10);
      expect(map['title'], 'Harika Fikir');
      expect(map['colorId'], 'purple');
      expect(map['isPinned'], 1);

      final restored = NoteModel.fromMap(map);
      expect(restored.id, 10);
      expect(restored.title, 'Harika Fikir');
      expect(restored.isPinned, isTrue);
      expect(restored.hasReminder, isTrue);
    });
  });
}
