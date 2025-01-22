import 'dart:convert';
import 'task.dart';

class Storage {
  Future<List<Task>> readTasks() async {
    // Пример чтения задач из файла
    final jsonData = [
      {'id': '1', 'title': 'Task 1', 'completed': false},
      {'id': '2', 'title': 'Task 2', 'completed': true},
    ];

    // Преобразуем JSON в список задач
    return jsonData.map((item) => Task.fromJson(item)).toList();
  }

  Future<void> writeTasks(List<Task> tasks) async {
    // Преобразуем список задач в JSON
    final jsonData = tasks.map((task) => task.toJson()).toList();
    final jsonString = jsonEncode(jsonData);

    // Пример записи JSON в файл
    print(jsonString);
  }
}