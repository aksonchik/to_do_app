class Task {
  final String id;
  final String title;
  bool completed;

  Task({
    required this.id,
    required this.title,
    this.completed = false,
  });

  void toggleCompleted() {
    completed = !completed;
  }

  // Метод для преобразования объекта Task в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
    };
  }

  // Метод для создания объекта Task из JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      completed: json['completed'],
    );
  }
}