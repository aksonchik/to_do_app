import 'package:flutter/material.dart';
import 'package:todoapp/task.dart';
import 'package:todoapp/readandwrite.dart';
import 'about_us.dart';

void main() {
  runApp(const MaterialApp(
    home: ToDoApp(),
  ));
}

class ToDoApp extends StatefulWidget {
  const ToDoApp({super.key});

  @override
  _ToDoAppState createState() => _ToDoAppState();
}

class _ToDoAppState extends State<ToDoApp> {
  final List<Task> _tasks = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final Storage storage = Storage();

  @override
  void initState() {
    super.initState();
    storage.readTasks().then((taskList) {
      setState(() {
        _tasks.addAll(taskList);
      });
    });
  }

  void _addNewTask(String title) {
    final newTask = Task(
      id: DateTime.now().toString(),
      title: title,
    );

    setState(() {
      _tasks.add(newTask); // Добавляем задачу в список
    });
    _listKey.currentState?.insertItem(_tasks.length - 1); // Обновляем AnimatedList
    storage.writeTasks(_tasks); // Сохраняем задачи
  }

  void _startAddNewTask(BuildContext context) {
    String taskTitle = '';

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white, // Белый фон для диалога
          title: const Text('Add New Task'),
          content: TextField(
            onChanged: (value) {
              taskTitle = value; // Обновляем значение при вводе текста
            },
            decoration: const InputDecoration(
              labelText: 'Task Title',
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                if (taskTitle.isNotEmpty) {
                  _addNewTask(taskTitle); // Добавляем задачу
                  Navigator.of(ctx).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteTask(int index) {
    if (index < 0 || index >= _tasks.length) {
      return; // Проверяем, что индекс допустим
    }

    Task removedTask = _tasks[index];

    setState(() {
      _tasks.removeAt(index);
    });

    _listKey.currentState?.removeItem(
      index,
          (BuildContext context, Animation<double> animation) {
        return SizeTransition(
          sizeFactor: animation,
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(removedTask.title,
                  style: const TextStyle(decoration: TextDecoration.lineThrough)),
              leading: const Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
            ),
          ),
        );
      },
      duration: const Duration(milliseconds: 250),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white, // Белый фон для SnackBar
        content: Text(
          '${removedTask.title} deleted',
          style: const TextStyle(color: Colors.black), // Чёрный текст
        ),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.blue, // Цвет текста кнопки
          onPressed: () {
            setState(() {
              _tasks.insert(index, removedTask);
            });
            _listKey.currentState?.insertItem(index);
          },
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    storage.writeTasks(_tasks); // Сохраняем изменения
  }

  Widget _buildTaskItem(BuildContext context, int index, List<Task> tasks) {
    if (index < 0 || index >= tasks.length) {
      return Container(); // Возвращаем пустой контейнер, если индекс недопустим
    }

    return Card(
      color: Colors.white, // Белый фон для карточки
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        title: Text(
          tasks[index].title,
          style: TextStyle(
              decoration: tasks[index].completed ? TextDecoration.lineThrough : null),
        ),
        leading: Icon(
          tasks[index].completed ? Icons.check_circle : Icons.radio_button_unchecked,
          color: tasks[index].completed ? Colors.green : null,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _deleteTask(index),
        ),
        onTap: () {
          setState(() {
            tasks[index].toggleCompleted();
          });
          storage.writeTasks(_tasks); // Сохраняем изменения
        },
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Устанавливаем белый фон
      appBar: AppBar(
        title: const Text('Flutter ToDo App'),
        backgroundColor: Colors.blue, // Цвет AppBar (опционально)
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutUsPage()),
              );
            },
          ),
        ],
      ),
      body: _tasks.isEmpty
          ? const Center(
          child: Text('No tasks available')) // Сообщение, если список пуст
          : Container(
        color: Colors.white, // Белый фон для списка задач
        child: AnimatedList(
          key: _listKey,
          initialItemCount: _tasks.length,
          itemBuilder: (context, index, animation) {
            return _buildTaskItem(context, index, _tasks);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startAddNewTask(context),
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}