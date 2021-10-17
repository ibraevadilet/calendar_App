final String tableTasks = 'tasks';

class TaskFields {
  static final List<String> values = [
    id,
    isImportant,
    date,
    title,
    description,
    time,
    year,
    month,
    day,
  ];

  static final String id = '_id';
  static final String isImportant = 'isImportant';
  static final String date = 'date';
  static final String title = 'title';
  static final String description = 'description';
  static final String time = 'time';
  static final String year = 'year';
  static final String month = 'month';
  static final String day = 'day';
}

class Task {
  final int? id;
  final bool isImportant;
  final String? date;
  final String title;
  final String description;
  final String createdTime;
  final int? year;
  final int? month;
  final int? day;

  const Task({
    this.id,
    required this.isImportant,
    required this.date,
    required this.title,
    required this.description,
    required this.createdTime,
    this.year,
    this.month,
    this.day,
  });

  Task copy({
    int? id,
    bool? isImportant,
    String? date,
    String? title,
    String? description,
    String? createdTime,
    int? year,
    int? month,
    int? day,
  }) =>
      Task(
        id: id ?? this.id,
        isImportant: isImportant ?? this.isImportant,
        date: date ?? this.date,
        title: title ?? this.title,
        description: description ?? this.description,
        createdTime: createdTime ?? this.createdTime,
        year: year ?? this.year,
        month: month ?? this.month,
        day: day ?? this.day,
      );

  static Task fromJson(Map<String, Object?> json) => Task(
        id: json[TaskFields.id] as int?,
        isImportant: json[TaskFields.isImportant] == 1,
        date: json[TaskFields.date] as String?,
        title: json[TaskFields.title] as String,
        description: json[TaskFields.description] as String,
        createdTime: json[TaskFields.time] as String,
        year: json[TaskFields.year] as int?,
        month: json[TaskFields.month] as int?,
        day: json[TaskFields.day] as int?,
      );

  Map<String, Object?> toJson() => {
        TaskFields.id: id,
        TaskFields.title: title,
        TaskFields.isImportant: isImportant ? 1 : 0,
        TaskFields.date: date,
        TaskFields.description: description,
        TaskFields.time: createdTime,
        TaskFields.year: year,
        TaskFields.month: month,
        TaskFields.day: day,
      };
}
