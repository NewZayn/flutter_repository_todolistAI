import 'package:flutter/material.dart';
import 'package:i/view/calender_page.dart';
import 'package:i/view/speak_page.dart';
import 'package:i/view/statatics.page.dart';
import 'package:i/view/task_list_page.dart';

class HomeViewModel extends ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  // Lista de páginas
  List<Widget> get pages => [
        const TaskListPage(),
        const CalenderPage(),
        const StaticsPage(),
        const SpeakPage(),
      ];

  // Títulos das páginas
  List<String> get titles => [
        'Tasks',
        'Calendar',
        'Statistics',
        'Speak',
      ];
}
