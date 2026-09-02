import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/category_model.dart';
import '../models/note_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('renkli_notlar.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        colorValue INTEGER NOT NULL,
        iconCode INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        categoryId INTEGER,
        colorId TEXT NOT NULL,
        isPinned INTEGER NOT NULL DEFAULT 0,
        reminderDateTime TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE SET NULL
      )
    ''');

    // Seed default categories
    final defaultCategories = [
      CategoryModel(
        name: 'İş',
        colorValue: const Color(0xFF0D6EFD).toARGB32(),
        iconCode: Icons.work_outline.codePoint,
      ),
      CategoryModel(
        name: 'Kişisel',
        colorValue: const Color(0xFF6F42C1).toARGB32(),
        iconCode: Icons.person_outline.codePoint,
      ),
      CategoryModel(
        name: 'Alışveriş',
        colorValue: const Color(0xFF198754).toARGB32(),
        iconCode: Icons.shopping_bag_outlined.codePoint,
      ),
      CategoryModel(
        name: 'Fikirler',
        colorValue: const Color(0xFFE6A100).toARGB32(),
        iconCode: Icons.lightbulb_outline.codePoint,
      ),
      CategoryModel(
        name: 'Ders',
        colorValue: const Color(0xFFDC3545).toARGB32(),
        iconCode: Icons.school_outlined.codePoint,
      ),
    ];

    for (var cat in defaultCategories) {
      await db.insert('categories', cat.toMap());
    }
  }

  // --- CATEGORIES CRUD ---

  Future<CategoryModel> createCategory(CategoryModel category) async {
    final db = await instance.database;
    final id = await db.insert('categories', category.toMap());
    return category.copyWith(id: id);
  }

  Future<List<CategoryModel>> getAllCategories() async {
    final db = await instance.database;
    final result = await db.query('categories', orderBy: 'name ASC');
    return result.map((map) => CategoryModel.fromMap(map)).toList();
  }

  Future<int> updateCategory(CategoryModel category) async {
    final db = await instance.database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await instance.database;
    // Set notes' categoryId to null when category deleted
    await db.update(
      'notes',
      {'categoryId': null},
      where: 'categoryId = ?',
      whereArgs: [id],
    );
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // --- NOTES CRUD ---

  Future<NoteModel> createNote(NoteModel note) async {
    final db = await instance.database;
    final id = await db.insert('notes', note.toMap());
    return note.copyWith(id: id);
  }

  Future<List<NoteModel>> getAllNotes() async {
    final db = await instance.database;
    final result = await db.query(
      'notes',
      orderBy: 'isPinned DESC, updatedAt DESC',
    );
    return result.map((map) => NoteModel.fromMap(map)).toList();
  }

  Future<NoteModel?> getNoteById(int id) async {
    final db = await instance.database;
    final maps = await db.query('notes', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return NoteModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateNote(NoteModel note) async {
    final db = await instance.database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await instance.database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<NoteModel>> getNotesWithReminders() async {
    final db = await instance.database;
    final result = await db.query(
      'notes',
      where: 'reminderDateTime IS NOT NULL',
      orderBy: 'reminderDateTime ASC',
    );
    return result.map((map) => NoteModel.fromMap(map)).toList();
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
