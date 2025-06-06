class Statistics {
  int totalTasks;
  int closedTasks;
  int lateTasks;
  int openTasks;
  Statistics({
    required this.totalTasks,
    required this.closedTasks,
    required this.lateTasks,
    required this.openTasks,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      totalTasks: json['totalTasks'],
      closedTasks: json['closedTasks'],
      lateTasks: json['lateTasks'],
      openTasks: json['openTasks'],
    );
  }
}
