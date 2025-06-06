import 'package:flutter/material.dart';
import 'package:i/model/task.dart'; // Certifique-se que Task.fromJson está implementado
import 'package:i/view_model/tasks/task_view_model.dart';
import 'package:intl/intl.dart'; // Para formatação de data
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:i/view/task_details.dart'; // Para navegação

class CalenderPage extends StatefulWidget {
  const CalenderPage({super.key});

  @override
  _CalenderPageState createState() => _CalenderPageState();
}

class _CalenderPageState extends State<CalenderPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<Task>> _tasksByDate = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasks();
    });
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _tasksByDate = {};
    });

    try {
      final viewModel = Provider.of<TaskViewModel>(context, listen: false);
      if (viewModel.tasks.isEmpty) {}

      print("Total de tarefas: ${viewModel.tasks.length}");

      final List<Task> allTasks = viewModel.tasks;
      Map<DateTime, List<Task>> localTasksMap = {};

      for (Task taskItem in allTasks) {
        print(
            "Processando tarefa: ${taskItem.title}, donedate: ${taskItem.donedate}");

        DateTime? taskDate;

        // Tente primeiro donedate
        if (taskItem.donedate != null && taskItem.donedate!.isNotEmpty) {
          try {
            taskDate = DateTime.parse(taskItem.donedate!).toLocal();
            print("Data parseada de donedate: $taskDate");
          } catch (e) {
            print(
                "Erro ao parsear donedate '${taskItem.donedate}' para a tarefa ID ${taskItem.id}: $e");
          }
        }

        // Se donedate falhar, tente createddate
        if (taskDate == null &&
            taskItem.createddate != null &&
            taskItem.createddate!.isNotEmpty) {
          try {
            taskDate = DateTime.parse(taskItem.createddate!).toLocal();
            print("Data parseada de createddate: $taskDate");
          } catch (e) {
            print(
                "Erro ao parsear createddate '${taskItem.createddate}' para a tarefa ID ${taskItem.id}: $e");
          }
        }

        if (taskDate != null) {
          final dateOnly =
              DateTime.utc(taskDate.year, taskDate.month, taskDate.day);
          print("Data normalizada: $dateOnly");

          if (localTasksMap.containsKey(dateOnly)) {
            localTasksMap[dateOnly]!.add(taskItem);
          } else {
            localTasksMap[dateOnly] = [taskItem];
          }
        } else {
          print("Tarefa '${taskItem.title}' não possui data válida");
        }
      }

      print("Mapa de tarefas por data: ${localTasksMap.keys.toList()}");
      print("Total de datas com tarefas: ${localTasksMap.length}");

      if (mounted) {
        setState(() {
          _tasksByDate = localTasksMap;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Falha ao carregar tarefas: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar tarefas: $e')),
        );
      }
    }
  }

  List<Task> _getTasksForDay(DateTime day) {
    final dateOnly = DateTime.utc(day.year, day.month, day.day);
    return _tasksByDate[dateOnly] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar<Task>(
                  firstDay: DateTime.utc(2010, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    if (!isSameDay(_selectedDay, selectedDay)) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    }
                  },
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  eventLoader: _getTasksForDay,
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, tasks) {
                      if (tasks.isNotEmpty) {
                        return _buildEventsMarker(date, tasks.cast<Task>());
                      }
                      return null;
                    },
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                  ),
                  calendarStyle: const CalendarStyle(
                    outsideDaysVisible: false,
                    weekendTextStyle: TextStyle(color: Colors.red),
                    selectedDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                Expanded(
                  child: _buildTaskListForSelectedDay(),
                ),
              ],
            ),
    );
  }

  Widget _buildEventsMarker(DateTime date, List<Task> tasks) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red[400],
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${tasks.length}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskListForSelectedDay() {
    final tasksForDay = _getTasksForDay(_selectedDay);
    if (tasksForDay.isEmpty) {
      return const Center(
        child: Text(
          "Nenhuma tarefa para este dia.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: tasksForDay.length,
      itemBuilder: (context, index) {
        final task = tasksForDay[index];
        String displayTime = 'Horário não definido';

        if (task.donedate != null && task.donedate!.isNotEmpty) {
          try {
            final taskDateTime = DateTime.parse(task.donedate!);
            displayTime = DateFormat('HH:mm').format(taskDateTime);
          } catch (e) {
            displayTime = 'Horário inválido';
          }
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getPriorityColor(task.priority),
              child: Text(
                '${task.priority}',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              task.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.description),
                Text(
                  displayTime,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            trailing: Icon(
              task.state == 1
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: task.state == 1 ? Colors.green : Colors.grey,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskDetailPage(task: task),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
