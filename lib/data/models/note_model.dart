class NoteModel {
  final int? id;
  final String title;
  final String content;
  final int? categoryId;
  final String colorId;
  final bool isPinned;
  final DateTime? reminderDateTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  NoteModel({
    this.id,
    required this.title,
    required this.content,
    this.categoryId,
    this.colorId = 'yellow',
    this.isPinned = false,
    this.reminderDateTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get hasReminder =>
      reminderDateTime != null && reminderDateTime!.isAfter(DateTime.now());

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'content': content,
      'categoryId': categoryId,
      'colorId': colorId,
      'isPinned': isPinned ? 1 : 0,
      'reminderDateTime': reminderDateTime?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      categoryId: map['categoryId'] as int?,
      colorId: map['colorId'] as String? ?? 'yellow',
      isPinned: (map['isPinned'] as int?) == 1,
      reminderDateTime: map['reminderDateTime'] != null
          ? DateTime.tryParse(map['reminderDateTime'] as String)
          : null,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  NoteModel copyWith({
    int? id,
    String? title,
    String? content,
    int? categoryId,
    bool clearCategory = false,
    String? colorId,
    bool? isPinned,
    DateTime? reminderDateTime,
    bool clearReminder = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      colorId: colorId ?? this.colorId,
      isPinned: isPinned ?? this.isPinned,
      reminderDateTime: clearReminder
          ? null
          : (reminderDateTime ?? this.reminderDateTime),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
