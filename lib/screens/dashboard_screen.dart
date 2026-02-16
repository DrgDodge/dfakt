import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../database/database.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final weightLogs = provider.weightLogs; // Sorted ASC

    return Scaffold(
      appBar: AppBar(
        title: const Text('DFakt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              provider.userName != null ? "Welcome Back, ${provider.userName}" : "Welcome Back", 
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF80CBC4)),
            ),
            Text(
              DateFormat.yMMMMEEEEd().format(DateTime.now()),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Row for Consistency and Trend Headers and Cards
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Consistency Side
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader("Consistency"),
                      AspectRatio(
                        aspectRatio: 1.2,
                        child: _buildConsistencyCard(weightLogs),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Trend Side
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader("Trend"),
                      AspectRatio(
                        aspectRatio: 1.2,
                        child: _buildMiniTrendCard(weightLogs),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Priority Tasks
            _buildSectionHeader("Priority Tasks"),
            if (provider.urgentTasks.isEmpty)
              Card(
                color: const Color(0xFF252525),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.white.withOpacity(0.05))),
                child: const Padding(padding: EdgeInsets.all(20), child: Center(child: Text("All caught up!", style: TextStyle(color: Colors.grey)))),
              )
            else
              Column(
                children: provider.urgentTasks.take(5).map((task) => _buildUrgentTaskCard(context, task, provider)).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrgentTaskCard(BuildContext context, Reminder task, AppProvider provider) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
    
    Color accentColor;
    String urgencyLabel;
    
    if (dueDate.isBefore(today)) {
      accentColor = Colors.redAccent;
      urgencyLabel = "Overdue";
    } else if (dueDate.isAtSameMomentAs(today)) {
      accentColor = Colors.orangeAccent;
      urgencyLabel = "Today";
    } else if (dueDate.isAtSameMomentAs(today.add(const Duration(days: 1)))) {
      accentColor = const Color(0xFF80CBC4);
      urgencyLabel = "Tomorrow";
    } else {
      accentColor = Colors.blueAccent;
      urgencyLabel = DateFormat.MMMd().format(dueDate);
    }

    return GestureDetector(
      onTap: () => provider.requestJumpToReminder(task.categoryId, task.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF252525),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(task.isEvent ? Icons.event : Icons.task_alt, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        task.isEvent ? "Event" : "Task",
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accentColor.withOpacity(0.2)),
              ),
              child: Text(
                urgencyLabel,
                style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget _buildConsistencyCard(List<dynamic> logs) {
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final loggedDays = logs
        .where((l) => l.date.year == now.year && l.date.month == now.month)
        .map((l) => l.date.day)
        .toSet();

    return Card(
      color: const Color(0xFF252525),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.white.withOpacity(0.05))),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double itemWidth = (constraints.maxWidth - 48) / 7;
            
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(daysInMonth, (index) {
                final day = index + 1;
                final isLogged = loggedDays.contains(day);
                final isToday = day == now.day;
                
                return Container(
                  width: itemWidth,
                  height: itemWidth,
                  decoration: BoxDecoration(
                    color: isLogged ? const Color(0xFF80CBC4) : (isToday ? const Color(0xFF80CBC4).withOpacity(0.2) : Colors.transparent),
                    shape: BoxShape.circle,
                    border: isLogged ? null : Border.all(color: Colors.grey.shade800),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMiniTrendCard(List<dynamic> logs) {
    if (logs.isEmpty) return const Card(child: Padding(padding: EdgeInsets.all(16), child: Text("No data")));
    final recent = logs.length > 10 ? logs.sublist(logs.length - 10) : logs;

    return Card(
      color: const Color(0xFF252525),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.white.withOpacity(0.05))),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((LineBarSpot touchedSpot) {
                    return LineTooltipItem(
                      touchedSpot.y.toString(),
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    );
                  }).toList();
                },
                tooltipMargin: 50,
                tooltipRoundedRadius: 8,
                tooltipPadding: const EdgeInsets.all(8),
              ),
              handleBuiltInTouches: true,
            ),
            lineBarsData: [
              LineChartBarData(
                spots: recent.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.weight)).toList(),
                isCurved: true,
                color: const Color(0xFF80CBC4),
                barWidth: 3,
                dotData: FlDotData(show: true, checkToShowDot: (spot, barData) => true),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [const Color(0xFF80CBC4).withOpacity(0.3), const Color(0xFF80CBC4).withOpacity(0.0)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              )
            ],
            titlesData: FlTitlesData(show: false),
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }
}
