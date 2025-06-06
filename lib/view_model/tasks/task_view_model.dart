import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:i/model/task.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskViewModel extends ChangeNotifier {
  final String baseUrl = 'https://aiproject-todolist-huq1.onrender.com/api';

  List<Task> tasks = [];
  bool _isLoading = false;
  int currentPage = 0;
  final int pageSize = 10;
  bool hasMore = true;
  String state = "OPEN";
  int totalPages = 0;
  bool get isLoading => _isLoading;
  List<Task> filteredTasks = [];
  List<Task> _originalTasksForSearch = [];

  Future<void> loadTasks(String userId) async {
    if (userId.isEmpty) {
      tasks = [];
      _originalTasksForSearch = [];
      totalPages = 0;
      _isLoading = false;
      notifyListeners();
      return;
    }
    _isLoading = true;

    try {
      await goToPage(currentPage, userId);
    } catch (e) {
      print('Erro ao carregar tarefas (em loadTasks): $e');
      tasks = [];
      for (var task in tasks) {
        print('Task: ${task.title}, State: ${task.state}');
      }
      _originalTasksForSearch = [];
      totalPages = 0;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTasksByState(String userId, String state) async {
    this.state = state;
    currentPage = 0;
    tasks = [];
    _originalTasksForSearch = []; // Resetar aqui também
    hasMore = true;
    await loadTasks(userId);
  }

  Future<void> searchTask(String query) async {
    if (query.isEmpty) {
      if (_originalTasksForSearch.isEmpty) {
        _originalTasksForSearch = List.from(tasks);
      } else {
        tasks = List.from(_originalTasksForSearch);
      }
    } else {
      tasks = _originalTasksForSearch
          .where((task) =>
              task.title.toLowerCase().contains(query.toLowerCase()) ||
              task.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  Future<void> updateTaskState(
      String userId, int taskId, bool isCompleted) async {
    try {
      Map<String, dynamic> updatedTask = {
        'state': isCompleted ? 2 : 1,
      };
      final response = await http.put(
        Uri.parse('$baseUrl/$userId/task/$taskId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedTask),
      );

      if (response.statusCode == 200) {
        await loadTasks(userId);
      } else {
        print('Erro ao atualizar tarefa: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao atualizar tarefa: $e');
    }
  }

  Future<void> createTask(Map<String, dynamic> newTask, String userId) async {
    try {
      tasks.add(Task.fromJson(newTask));
      _originalTasksForSearch.add(Task.fromJson(newTask));
      notifyListeners();
      final response = await http.post(
        Uri.parse('$baseUrl/$userId/task'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newTask),
      );
      if (response.statusCode == 200) {
      } else {
        print('Erro ao criar tarefa: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao criar tarefa: $e');
    }
  }

  Future<Map<String, dynamic>> goToPage(int pageToLoad, String userId) async {
    final url = Uri.parse(
        '$baseUrl/$userId/task/criteria/$state?page=$pageToLoad&size=$pageSize');

    Map<String, dynamic> result = {
      'tasks': <Task>[],
      'totalElements': 0,
      'totalPagesApi': 0,
      'currentPageApi': pageToLoad
    };

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonBody = jsonDecode(response.body);
        final List<dynamic> tasksJson = jsonBody['tasks'] ?? [];
        final int totalElementsApi = jsonBody['totalTasks'] as int? ?? 0;
        tasks = tasksJson.map((taskJson) => Task.fromJson(taskJson)).toList();
        _originalTasksForSearch = List.from(tasks);
        totalPages = (totalElementsApi > 0 && pageSize > 0)
            ? (totalElementsApi / pageSize).ceil()
            : 0;
        currentPage = pageToLoad;
        hasMore = (pageToLoad < totalPages - 1);

        result = {
          'tasks': tasks,
          'totalElements': totalElementsApi,
          'totalPagesApi': totalPages,
          'currentPageApi': currentPage
        };
      } else {
        print('Erro ao carregar tarefas (em goToPage): ${response.statusCode}');
        tasks = [];
        _originalTasksForSearch = [];
        totalPages = 0;
        hasMore = false;
      }
    } catch (e) {
      print('Erro ao carregar tarefas (em goToPage catch): $e');
      tasks = [];
      _originalTasksForSearch = [];
      totalPages = 0;
      hasMore = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return result;
  }

  void nextPage(String userId) {
    if (!_isLoading && currentPage < totalPages - 1) {
      currentPage++;
      loadTasks(userId);
    }
  }

  void previousPage(String userId) {
    if (!_isLoading && currentPage > 0) {
      currentPage--;
      loadTasks(userId);
    }
  }

  void setStateFilter(String newState, String userId) {
    if (state != newState) {
      state = newState;
      currentPage = 0;
      tasks = [];
      _originalTasksForSearch = [];
      hasMore = true;
      loadTasks(userId);
    }
  }

  Future<void> updateTask(
      String userId, int taskId, Map<String, dynamic> updatedTask) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$userId/task/$taskId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedTask),
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao atualizar a tarefa');
    }
  }

  Future<bool> deleteTask(int taskId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userData = prefs.getString('user');

      if (userData != null) {
        Map<String, dynamic> user = jsonDecode(userData);

        final response = await http.delete(
          Uri.parse('$baseUrl/${user['id']}/task/$taskId'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 204) {
          return true;
        } else {
          throw Exception('Erro ao excluir tarefa: ${response.statusCode}');
        }
      } else {
        throw Exception('Usuário não logado');
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<int?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('user');

    if (userData != null) {
      Map<String, dynamic> user = jsonDecode(userData);
      return user['id'];
    }
    return null;
  }

  Future<bool> completeTask(int taskId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userData = prefs.getString('user');

      if (userData != null) {
        Map<String, dynamic> user = jsonDecode(userData);

        final response = await http.put(
          Uri.parse('$baseUrl/${user['id']}/task/done/$taskId'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          return true;
        } else {
          throw Exception('Erro ao concluir tarefa: ${response.statusCode}');
        }
      } else {
        throw Exception('Usuário não logado');
      }
    } catch (e) {
      print(e);
      return false;
    }
  }
}
