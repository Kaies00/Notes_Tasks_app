final String tableNotesBooks = 'notebooks';

class NoteBookFields {
  static final List<String> values = [
    /// Add all fields
    id, title, image, time
  ];

  static final String id = '_id';
  static final String title = 'title';
  static final String image = 'image';
  static final String time = 'time';
}

class NoteBook {
  final int? id;
  final String title;
  final String image;
  final DateTime createdTime;

  const NoteBook({
    this.id,
    required this.title,
    required this.image,
    required this.createdTime,
  });

  NoteBook copy({
    int? id,
    String? title,
    String? image,
    DateTime? createdTime,
  }) =>
      NoteBook(
        id: id ?? this.id,
        title: title ?? this.title,
        image: image ?? this.image,
        createdTime: createdTime ?? this.createdTime,
      );

  static NoteBook fromJson(Map<String, Object?> json) => NoteBook(
        id: json[NoteBookFields.id] as int?,
        title: json[NoteBookFields.title] as String,
        image: json[NoteBookFields.image] as String,
        createdTime: DateTime.parse(json[NoteBookFields.time] as String),
      );

  Map<String, Object?> toJson() => {
        NoteBookFields.id: id,
        NoteBookFields.title: title,
        NoteBookFields.image: image,
        NoteBookFields.time: createdTime.toIso8601String(),
      };
}
