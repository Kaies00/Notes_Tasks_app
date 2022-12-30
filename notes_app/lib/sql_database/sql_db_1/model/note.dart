final String tableNotes = 'notes';

class NoteFields {
  static final List<String> values = [
    /// Add all fields
    id, isImportant, isTask, isCompleted, number, title, description, notebook,
    time
  ];

  static final String id = '_id';
  static final String isImportant = 'isImportant';
  static final String isTask = 'isTask';
  static final String isCompleted = 'isCompleted';
  static final String number = 'number';
  static final String title = 'title';
  static final String description = 'description';
  static final String notebook = 'notebook';
  static final String time = 'time';
}

class Note {
  final int? id;
  final bool isImportant;
  final bool isTask;
  final bool isCompleted;
  final int number;
  final String title;
  final String description;
  final String notebook;
  final DateTime createdTime;

  const Note({
    this.id,
    required this.isImportant,
    required this.isTask,
    required this.isCompleted,
    required this.number,
    required this.title,
    required this.description,
    required this.notebook,
    required this.createdTime,
  });

  Note copy({
    int? id,
    bool? isImportant,
    bool? isTask,
    bool? isCompleted,
    int? number,
    String? title,
    String? description,
    String? notebook,
    DateTime? createdTime,
  }) =>
      Note(
        id: id ?? this.id,
        isImportant: isImportant ?? this.isImportant,
        isTask: isTask ?? this.isTask,
        isCompleted: isCompleted ?? this.isCompleted,
        number: number ?? this.number,
        title: title ?? this.title,
        description: description ?? this.description,
        notebook: notebook ?? this.notebook,
        createdTime: createdTime ?? this.createdTime,
      );

  static Note fromJson(Map<String, Object?> json) => Note(
        id: json[NoteFields.id] as int?,
        isImportant: json[NoteFields.isImportant] == 1,
        isTask: json[NoteFields.isTask] == 1,
        isCompleted: json[NoteFields.isCompleted] == 1,
        number: json[NoteFields.number] as int,
        title: json[NoteFields.title] as String,
        description: json[NoteFields.description] as String,
        notebook: json[NoteFields.notebook] as String,
        createdTime: DateTime.parse(json[NoteFields.time] as String),
      );

  Map<String, Object?> toJson() => {
        NoteFields.id: id,
        NoteFields.title: title,
        NoteFields.isCompleted: isCompleted ? 1 : 0,
        NoteFields.isTask: isTask ? 1 : 0,
        NoteFields.isImportant: isImportant ? 1 : 0,
        NoteFields.number: number,
        NoteFields.description: description,
        NoteFields.notebook: notebook,
        NoteFields.time: createdTime.toIso8601String(),
      };
}
