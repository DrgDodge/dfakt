import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../providers/app_provider.dart';
import '../database/database.dart'; // For WeightLog type
import 'settings_screen.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  // Metric Selection: 0 = Weight, 1 = Body Fat, 2 = Muscle Mass
  final Set<int> selectedMetrics = {0}; 
  
  // Time Range: 0=1W, 1=1M, 2=3M, 3=6M, 4=1Y, 5=All
  int selectedTimeRange = 1; // Default 1M for General
  int selectedWorkoutTimeRange = 1; // Default 1M for Workout

  // For Workout Progress
  String? selectedExercise;

  @override
  Widget build(BuildContext context) {
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
      body: PageView(
        children: [
          _buildGeneralStats(context),
          _buildWorkoutStats(context),
        ],
      ),
    );
  }

  Widget _buildGeneralStats(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    
    // --- Filter Data based on Time Range ---
    final now = DateTime.now();
    DateTime? startDate;
    switch (selectedTimeRange) {
      case 0: startDate = now.subtract(const Duration(days: 7)); break;
      case 1: startDate = now.subtract(const Duration(days: 30)); break;
      case 2: startDate = now.subtract(const Duration(days: 90)); break;
      case 3: startDate = now.subtract(const Duration(days: 180)); break;
      case 4: startDate = now.subtract(const Duration(days: 365)); break;
      case 5: startDate = null; break;
    }

    // Weight Logs
    List<WeightLog> filteredWeightLogs = provider.weightLogs;
    if (startDate != null) {
      filteredWeightLogs = filteredWeightLogs.where((l) => l.date.isAfter(startDate!)).toList();
    }
    // Ensure sorted by date
    filteredWeightLogs.sort((a, b) => a.date.compareTo(b.date));

    // Nutrition Logs
    List<NutritionLog> filteredNutritionLogs = provider.nutritionLogs;
    if (startDate != null) {
      filteredNutritionLogs = filteredNutritionLogs.where((l) => l.date.isAfter(startDate!)).toList();
    }

    // --- Calculate Averages ---
    double avgWeight = 0;
    double avgFat = 0;
    double avgMuscle = 0;
    
    if (filteredWeightLogs.isNotEmpty) {
      avgWeight = filteredWeightLogs.map((e) => e.weight).average;
      final fatLogs = filteredWeightLogs.where((e) => e.bodyFat != null).toList();
      if (fatLogs.isNotEmpty) avgFat = fatLogs.map((e) => e.bodyFat!).average;
      final muscleLogs = filteredWeightLogs.where((e) => e.muscleMass != null).toList();
      if (muscleLogs.isNotEmpty) avgMuscle = muscleLogs.map((e) => e.muscleMass!).average;
    }

    double avgCals = 0;
    double avgProtein = 0;
    double avgCarbs = 0;
    if (filteredNutritionLogs.isNotEmpty) {
      // Group by day to get daily totals
      final logsByDay = groupBy(filteredNutritionLogs, (log) => DateFormat('yyyy-MM-dd').format(log.date));
      final dailyTotals = logsByDay.values.map((dayLogs) => {
        'calories': dayLogs.map((e) => e.calories).sum,
        'protein': dayLogs.map((e) => e.protein).sum,
        'carbs': dayLogs.map((e) => e.carbs).sum,
      }).toList();

      avgCals = dailyTotals.map((e) => e['calories']!).average;
      avgProtein = dailyTotals.map((e) => e['protein']!).average;
      avgCarbs = dailyTotals.map((e) => e['carbs']!).average;
    }

    // --- Normalization Logic ---
    double minW = 0, maxW = 100;
    double minF = 0, maxF = 100;
    double minM = 0, maxM = 100;
    bool useNormalization = selectedMetrics.length > 1;

    if (useNormalization && filteredWeightLogs.isNotEmpty) {
       final weights = filteredWeightLogs.map((e) => e.weight).toList();
       if (weights.isNotEmpty) {
         minW = weights.reduce((a, b) => a < b ? a : b);
         maxW = weights.reduce((a, b) => a > b ? a : b);
         if (minW == maxW) { minW -= 5; maxW += 5; }
       }

       final fats = filteredWeightLogs.where((e) => e.bodyFat != null).map((e) => e.bodyFat!).toList();
       if (fats.isNotEmpty) {
         minF = fats.reduce((a, b) => a < b ? a : b);
         maxF = fats.reduce((a, b) => a > b ? a : b);
         if (minF == maxF) { minF -= 2; maxF += 2; }
       }
       
       final muscles = filteredWeightLogs.where((e) => e.muscleMass != null).map((e) => e.muscleMass!).toList();
       if (muscles.isNotEmpty) {
         minM = muscles.reduce((a, b) => a < b ? a : b);
         maxM = muscles.reduce((a, b) => a > b ? a : b);
         if (minM == maxM) { minM -= 2; maxM += 2; }
       }
    }

    double? normalize(double? val, double min, double max) {
      if (val == null) return null;
      return ((val - min) / (max - min)) * 100;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time Range Toggle
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTimeToggle(0, "1W", false),
                _buildTimeToggle(1, "1M", false),
                _buildTimeToggle(2, "3M", false),
                _buildTimeToggle(3, "6M", false),
                _buildTimeToggle(4, "1Y", false),
                _buildTimeToggle(5, "All", false),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Body Composition Chart with Averages inside
          _buildChartCard(
            title: "Body Composition Trends",
            child: Column(
              children: [
                if (filteredWeightLogs.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMiniStat("Avg Weight", "${avgWeight.toStringAsFixed(1)} kg", Colors.blueAccent),
                        _buildMiniStat("Avg Fat", "${avgFat.toStringAsFixed(1)} %", Colors.redAccent),
                        _buildMiniStat("Avg Muscle", "${avgMuscle.toStringAsFixed(1)} %", Colors.green),
                      ],
                    ),
                  ),
                filteredWeightLogs.isEmpty 
                ? const Center(child: Text("No data for selected period"))
                : SizedBox(
                  height: 250,
                  child: LineChart(
                    LineChartData(
                       lineTouchData: LineTouchData(
                         touchTooltipData: LineTouchTooltipData(
                           getTooltipItems: (touchedSpots) {
                             return touchedSpots.map((LineBarSpot touchedSpot) {
                               final index = touchedSpot.spotIndex;
                               if (index >= 0 && index < filteredWeightLogs.length) {
                                  final log = filteredWeightLogs[index];
                                  String text = "";
                                  // Map barIndex back to metric type based on selectedMetrics order
                                  List<int> orderedMetrics = [];
                                  if (selectedMetrics.contains(0)) orderedMetrics.add(0);
                                  if (selectedMetrics.contains(1)) orderedMetrics.add(1);
                                  if (selectedMetrics.contains(2)) orderedMetrics.add(2);
                                  
                                  if (touchedSpot.barIndex < orderedMetrics.length) {
                                     int metric = orderedMetrics[touchedSpot.barIndex];
                                     if (metric == 0) text = "${log.weight} kg";
                                     if (metric == 1) text = "${log.bodyFat} %";
                                     if (metric == 2) text = "${log.muscleMass} %";
                                  }
                                  return LineTooltipItem(text, const TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
                               }
                               return null;
                             }).toList();
                           },
                         ),
                       ),
                       lineBarsData: [
                         if (selectedMetrics.contains(0))
                           _buildLine(filteredWeightLogs, (e) => useNormalization ? normalize(e.weight, minW, maxW) : e.weight, Colors.blueAccent),
                         if (selectedMetrics.contains(1))
                           _buildLine(filteredWeightLogs, (e) => useNormalization ? normalize(e.bodyFat, minF, maxF) : (e.bodyFat), Colors.redAccent),
                         if (selectedMetrics.contains(2))
                           _buildLine(filteredWeightLogs, (e) => useNormalization ? normalize(e.muscleMass, minM, maxM) : (e.muscleMass), Colors.green),
                       ],
                       titlesData: FlTitlesData(
                        show: true,
                         bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (double value, TitleMeta meta) {
                               int index = value.toInt();
                               if (index >= 0 && index < filteredWeightLogs.length) {
                                 int interval = filteredWeightLogs.length > 7 ? (filteredWeightLogs.length / 5).ceil() : 1;
                                 if (index % interval == 0 || index == filteredWeightLogs.length - 1) { 
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(DateFormat('MM/dd').format(filteredWeightLogs[index].date), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                    );
                                 }
                               }
                               return const Text('');
                            },
                          ),
                        ),
                        // Hide left titles if normalized (mixed units)
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: !useNormalization, reservedSize: 35)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                       ),
                       borderData: FlBorderData(show: false),
                       gridData: FlGridData(
                         show: true, 
                         drawVerticalLine: false,
                         getDrawingHorizontalLine: (value) => FlLine(color: Colors.white10, strokeWidth: 1),
                       ),
                    ),
                  ),
                ),
              ],
            ),
            headerAction: PopupMenuButton<int>(
               icon: const Icon(Icons.layers, color: Color(0xFF80CBC4)),
               itemBuilder: (context) => [
                 CheckedPopupMenuItem(checked: selectedMetrics.contains(0), value: 0, child: const Text("Weight")),
                 CheckedPopupMenuItem(checked: selectedMetrics.contains(1), value: 1, child: const Text("Body Fat %")),
                 CheckedPopupMenuItem(checked: selectedMetrics.contains(2), value: 2, child: const Text("Muscle %")),
               ],
               onSelected: (val) {
                 setState(() {
                    if (selectedMetrics.contains(val)) {
                      if (selectedMetrics.length > 1) selectedMetrics.remove(val);
                    } else {
                      selectedMetrics.add(val);
                    }
                 });
               },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Calories & Macros Section
          _buildChartCard(
            title: "Average Daily Intake",
            child: Column(
              children: [
                // Protein Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         const Text("Protein", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                         Text("${avgProtein.toStringAsFixed(0)}g", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ]
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                       value: 1.0, 
                       valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                       backgroundColor: Colors.blueAccent.withOpacity(0.2),
                       minHeight: 8,
                       borderRadius: BorderRadius.circular(4),
                    )
                  ]
                ),
                const SizedBox(height: 12),
                // Carbs Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         const Text("Carbs", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
                         Text("${avgCarbs.toStringAsFixed(0)}g", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ]
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                       value: 1.0,
                       valueColor: const AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                       backgroundColor: Colors.orangeAccent.withOpacity(0.2),
                       minHeight: 8,
                       borderRadius: BorderRadius.circular(4),
                    )
                  ]
                ),
                const SizedBox(height: 20),
                // Calories Bar
                 Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         const Text("Calories", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                         Text("${avgCals.toInt()} / ${provider.dailyCalorieGoal} kcal", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                       ],
                     ),
                     const SizedBox(height: 8),
                     SizedBox(
                       height: 12,
                       child: LinearProgressIndicator(
                         value: (avgCals / (provider.dailyCalorieGoal == 0 ? 2000 : provider.dailyCalorieGoal)).clamp(0.0, 1.0),
                         backgroundColor: Colors.grey[800],
                         color: avgCals > provider.dailyCalorieGoal ? Colors.redAccent : const Color(0xFF80CBC4),
                         borderRadius: BorderRadius.circular(6),
                       ),
                     ),
                   ],
                 )
              ],
            )
          ),
          
          // Swipe Hint
          const Center(
             child: Padding(
               padding: EdgeInsets.all(16.0),
               child: Icon(Icons.more_horiz, color: Colors.grey),
             ),
          )
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  LineChartBarData _buildLine(List<WeightLog> logs, double? Function(WeightLog) mapper, Color color) {
    return LineChartBarData(
      spots: logs.asMap().entries.map((e) {
        final val = mapper(e.value);
        return val != null ? FlSpot(e.key.toDouble(), val) : null;
      }).nonNulls.cast<FlSpot>().toList(),
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: true),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [color.withOpacity(0.3), color.withOpacity(0.0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildTimeToggle(int index, String label, bool isWorkout) {
    final selected = isWorkout ? selectedWorkoutTimeRange : selectedTimeRange;
    final isSelected = selected == index;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {
          setState(() {
            if (isWorkout) {
              selectedWorkoutTimeRange = index;
            } else {
              selectedTimeRange = index;
            }
          });
        },
        selectedColor: const Color(0xFF80CBC4),
        labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white),
        backgroundColor: const Color(0xFF2C2C2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
      ),
    );
  }

  Widget _buildWorkoutStats(BuildContext context) {
     final provider = Provider.of<AppProvider>(context);
     final exercises = provider.exercises.where((e) => e.name != 'Pushups').map((e) => e.name).toList();
     final List<String> dropdownOptions = ["Daily Summary", ...exercises];

     if (selectedExercise == null || !dropdownOptions.contains(selectedExercise)) {
       selectedExercise = "Daily Summary";
     }

     List<Map<String, dynamic>> progressData = provider.getWorkoutProgress(exerciseName: selectedExercise);

     // Filter by Time Range
     final now = DateTime.now();
     DateTime? startDate;
     switch (selectedWorkoutTimeRange) {
       case 0: startDate = now.subtract(const Duration(days: 7)); break;
       case 1: startDate = now.subtract(const Duration(days: 30)); break;
       case 2: startDate = now.subtract(const Duration(days: 90)); break;
       case 3: startDate = now.subtract(const Duration(days: 180)); break;
       case 4: startDate = now.subtract(const Duration(days: 365)); break;
       case 5: startDate = null; break;
     }
     
     if (startDate != null) {
       progressData = progressData.where((l) => (l['date'] as DateTime).isAfter(startDate!)).toList();
     }

     // Calculate Avg Score Increase
     double avgIncrease = 0;
     if (progressData.length > 1) {
       final first = progressData.first['value'] as double;
       final last = progressData.last['value'] as double;
       avgIncrease = (last - first) / (progressData.length - 1);
     }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               const Text("Select: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
               const SizedBox(width: 8),
               DropdownButton<String>(
                 value: selectedExercise,
                 dropdownColor: const Color(0xFF2C2C2C),
                 items: dropdownOptions.map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
                 onChanged: (val) {
                   setState(() => selectedExercise = val);
                 },
                 hint: const Text("Select"),
               ),
            ],
          ),
          const SizedBox(height: 16),
          // Time Toggle
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTimeToggle(0, "1W", true),
                _buildTimeToggle(1, "1M", true),
                _buildTimeToggle(2, "3M", true),
                _buildTimeToggle(3, "6M", true),
                _buildTimeToggle(4, "1Y", true),
                _buildTimeToggle(5, "All", true),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          _buildChartCard(
            title: selectedExercise == "Daily Summary" ? "Daily Strength Score" : "$selectedExercise Progress",
            headerAction: progressData.isEmpty ? null : Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text("Avg Increase", style: TextStyle(fontSize: 12, color: Colors.grey)),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: avgIncrease > 0 ? "+${avgIncrease.toStringAsFixed(1)}" : avgIncrease.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const TextSpan(
                        text: " pts",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF80CBC4)),
                      ),
                    ]
                  ),
                ),
              ],
            ),
            child: Column(
              children: [
                progressData.isEmpty
                  ? const SizedBox(height: 250, child: Center(child: Text("No history for this period")))
                  : SizedBox(
                    height: 250,
                    child: LineChart(
                      LineChartData(
                        lineTouchData: LineTouchData(
                           touchTooltipData: LineTouchTooltipData(
                             getTooltipItems: (touchedSpots) {
                               return touchedSpots.map((LineBarSpot touchedSpot) {
                                 return LineTooltipItem(
                                   "${touchedSpot.y.toStringAsFixed(1)} kg eq",
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
                            spots: progressData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['value'])).toList(),
                            isCurved: true,
                            color: const Color(0xFF80CBC4),
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
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
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                 int index = value.toInt();
                                 if (index >= 0 && index < progressData.length) {
                                   int totalPoints = progressData.length;
                                   int interval = 1;
                                   if (totalPoints > 5) interval = (totalPoints / 5).ceil();

                                   if (index % interval == 0 || index == totalPoints - 1) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(DateFormat('MM/dd').format(progressData[index]['date']), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                      );
                                   }
                                 }
                                 return const Text('');
                              },
                            )
                          ),
                           leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 35)),
                           topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                           rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => FlLine(color: Colors.white10, strokeWidth: 1),
                        ),
                        borderData: FlBorderData(show: false),
                      )
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Score = (Volume / Sets) / 10 reps eq",
                    style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
              ],
            )
          ),
        ],
      ),
    );
  }



  Widget _buildChartCard({required String title, required Widget child, Widget? headerAction}) {
    return Card(
      elevation: 0,
      color: const Color(0xFF252525),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.white.withOpacity(0.05))),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF80CBC4)))),
                if (headerAction != null) headerAction,
              ],
            ),
            const SizedBox(height: 20),
            child, 
          ],
        ),
      ),
    );
  }
}
