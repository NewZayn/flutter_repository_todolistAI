import 'package:flutter/material.dart';
import 'package:i/view_model/statistics/statistics_view_model.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class StaticsPage extends StatelessWidget {
  const StaticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StatisticsViewModel()..fetchStatistics(),
      child: Consumer<StatisticsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            );
          }

          return Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOverallStatisticsCard(context, viewModel),
                  const SizedBox(height: 24),
                  _buildTasksOverTimeChartCard(context, viewModel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverallStatisticsCard(
      BuildContext context, StatisticsViewModel viewModel) {
    final stats = viewModel.statistics;
    final textStyle = GoogleFonts.inter(
      textStyle: TextStyle(
        fontSize: 16,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
    final valueStyle = GoogleFonts.inter(
      textStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );

    return Card(
      // CardTheme será aplicado
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Visão Geral das Tarefas',
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Total de Tarefas:', '${stats.totalTasks}',
                valueStyle, textStyle, context),
            _buildStatRow('Tarefas Abertas:', '${stats.openTasks}', valueStyle,
                textStyle, context),
            _buildStatRow(
                'Tarefas Concluídas:',
                '${stats.closedTasks}',
                valueStyle.copyWith(
                    color: Theme.of(context).colorScheme.secondary),
                textStyle,
                context),
            _buildStatRow(
                'Tarefas Atrasadas:',
                '${stats.lateTasks}',
                valueStyle.copyWith(color: Theme.of(context).colorScheme.error),
                textStyle,
                context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, TextStyle valueStyle,
      TextStyle labelStyle, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: labelStyle),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }

  Widget _buildTasksOverTimeChartCard(
      BuildContext context, StatisticsViewModel viewModel) {
    // MOCANDO DADOS PARA O GRÁFICO
    final List<Map<String, dynamic>> mockChartData = [
      {'day': 'Seg', 'closed': 5, 'value': 0.0},
      {'day': 'Ter', 'closed': 8, 'value': 1.0},
      {'day': 'Qua', 'closed': 3, 'value': 2.0},
      {'day': 'Qui', 'closed': 7, 'value': 3.0},
      {'day': 'Sex', 'closed': 6, 'value': 4.0},
      {'day': 'Sáb', 'closed': 9, 'value': 5.0},
      {'day': 'Dom', 'closed': 4, 'value': 6.0},
    ];

    final List<FlSpot> spots = mockChartData.map((data) {
      return FlSpot(data['value'] as double, data['closed'] as double);
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12), // Ajuste no padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tarefas Concluídas (Últimos 7 Dias)', // Título simplificado
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 24), // Mais espaço antes do gráfico
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        strokeWidth: 0.8,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        strokeWidth: 0.8,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < mockChartData.length) {
                            return SideTitleWidget(
                              space: 8.0,
                              meta: meta,
                              child: Text(mockChartData[index]['day'] as String,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            );
                          }
                          return Container();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 2, // Ajuste o intervalo conforme seus dados
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(value.toInt().toString(),
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.left);
                        },
                        reservedSize: 28, // Espaço para os números
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        width: 1),
                  ),
                  minX: 0,
                  maxX: (mockChartData.length - 1)
                      .toDouble(), // Ajusta o maxX para o número de dias
                  minY: 0,
                  maxY: spots
                          .map((spot) => spot.y)
                          .reduce((a, b) => a > b ? a : b) +
                      2,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3),
                            Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.3),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          final flSpot = barSpot;
                          return LineTooltipItem(
                            '${mockChartData[flSpot.x.toInt()]['day']}\n',
                            TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: flSpot.y.toInt().toString(),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              TextSpan(
                                text: ' tarefas',
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant),
                              ),
                            ],
                          );
                        }).toList();
                      },
                    ),
                    handleBuiltInTouches: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
