import 'package:flutter/material.dart';
import 'package:i/service/user_provider.dart';
import 'package:i/view/task_details.dart';
import 'package:i/view_model/tasks/task_view_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskListPage extends StatelessWidget {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final taskViewModel = Provider.of<TaskViewModel>(context);
    final user = Provider.of<UserProvider>(context, listen: false);
    final String userId = user.userId;
    DateFormat dateFormat = DateFormat('dd/MM/yyyy: HH:mm');

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (taskViewModel.isLoading && taskViewModel.tasks.isEmpty) {
            return Center(
                child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ));
          }
          if (!taskViewModel.isLoading && taskViewModel.tasks.isEmpty) {
            return Center(
              child: Text(
                'Nenhuma tarefa encontrada.',
                style: GoogleFonts.inter(
                  textStyle: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: taskViewModel.tasks.length,
                  itemBuilder: (context, index) {
                    final task = taskViewModel.tasks[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          color: task.state == 1
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          Text(
                            task.description,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                          if (task.donedate != null)
                            Text(
                              '${dateFormat.format(DateTime.parse(task.donedate!))}',
                              style: TextStyle(
                                color: task.state == 1
                                    ? Colors.green[700]
                                    : Colors.red,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                      trailing: Checkbox(
                        value: task.state == 2,
                        onChanged: (value) {
                          taskViewModel.updateTaskState(
                              userId, task.id, value!);
                        },
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskDetailPage(task: task),
                        ),
                      ).then((_) {
                        taskViewModel.loadTasks(userId);
                      }),
                      leading: Icon(
                        task.state == 2
                            ? Icons.check_circle_outline
                            : Icons.radio_button_unchecked,
                        color: task.state == 2
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const Divider(height: 0),
                ),
              ),
              if (!taskViewModel.isLoading &&
                  taskViewModel.tasks.isNotEmpty &&
                  taskViewModel.totalPages > 1)
                _buildPaginationControls(context, taskViewModel),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateTaskModal(context, taskViewModel, userId);
        },
        shape: CircleBorder(
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPaginationControls(
      BuildContext context, TaskViewModel taskViewModel) {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            color: Theme.of(context).colorScheme.primary,
            onPressed: taskViewModel.currentPage > 0
                ? () => taskViewModel.previousPage(userId)
                : null,
          ),
          Text(
            'Página ${taskViewModel.currentPage + 1} de ${taskViewModel.totalPages}',
            style: GoogleFonts.inter(
              textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 18),
            color: Theme.of(context).colorScheme.primary,
            onPressed: taskViewModel.currentPage < taskViewModel.totalPages - 1
                ? () => taskViewModel.nextPage(userId)
                : null,
          ),
        ],
      ),
    );
  }

  void _showCreateTaskModal(
      BuildContext context, TaskViewModel taskViewModel, String userId) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
          title: const Text('Criar Nova Tarefa',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty) return;
                final newTask = {
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'state': 1,
                };
                await taskViewModel.createTask(newTask, userId);
                Navigator.pop(context);
              },
              child: const Text('Criar'),
            ),
          ],
        );
      },
    );
  }
}
