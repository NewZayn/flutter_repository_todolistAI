import 'package:flutter/material.dart';
import 'package:i/model/statistics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StatisticsViewModel extends ChangeNotifier {
  final String baseUrl = 'https://aiproject-todolist-huq1.onrender.com/api';
  Statistics _statistics = Statistics(
    closedTasks: 0,
    totalTasks: 0,
    lateTasks: 0,
    openTasks: 0,
  );
  bool _isLoading = true;
  Statistics get statistics => _statistics;
  int get closedTasks => _statistics.closedTasks;
  int get lateTasks => _statistics.lateTasks;
  int get openTasks => _statistics.openTasks;
  int get totalTasks => _statistics.totalTasks;
  bool get isLoading => _isLoading;

  void _updateStatisticsData(Statistics newStats) {
    _statistics = newStats;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchStatistics() async {
    _isLoading = true;
    notifyListeners();
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userData = prefs.getString('userId');
      print('User ID: $userData');

      if (userData != null) {
        final response = await http.get(
          Uri.parse('$baseUrl+statistics/$userData'),
          headers: {'Content-Type': 'application/json'},
        );
        if (response.statusCode == 200) {
          Map<String, dynamic> jsonBody = jsonDecode(response.body);
          _updateStatisticsData(Statistics.fromJson(jsonBody));
        } else {
          print('Erro ao buscar estatísticas: ${response.statusCode}');
          _statistics = Statistics(
              closedTasks: 0, totalTasks: 0, lateTasks: 0, openTasks: 0);
          _isLoading = false;
          notifyListeners();
        }
      } else {
        print('Usuário não logado');
        _statistics = Statistics(
            closedTasks: 0, totalTasks: 0, lateTasks: 0, openTasks: 0);
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      print('Exceção ao buscar estatísticas: $e');
      _statistics =
          Statistics(closedTasks: 0, totalTasks: 0, lateTasks: 0, openTasks: 0);
      _isLoading = false;
      notifyListeners();
    }
  }
}
