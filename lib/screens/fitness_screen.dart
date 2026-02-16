import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:drift/drift.dart' as drift;
import '../providers/app_provider.dart';
import '../database/database.dart'; 
import 'settings_screen.dart';
import '../widgets/ui_helpers.dart';

class FitnessScreen extends StatelessWidget {
  const FitnessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Workout'),
              Tab(text: 'Weight'),
              Tab(text: 'Nutrition'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            WorkoutTab(),
            WeightTab(),
            NutritionTab(),
          ],
        ),
      ),
    );
  }
}

class WorkoutTab extends StatelessWidget {
  const WorkoutTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    // Group logs by Date, then by Exercise
    final groupedLogs = groupBy(provider.gymLogs, (log) => DateFormat('yyyy-MM-dd').format(log.log.date));

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddWorkoutDialog(context, provider),
        child: const Icon(Icons.add),
      ),
      body: groupedLogs.isEmpty ? 
      const Center(child: Text("Start your journey by logging a workout!")) :
      ListView.builder(
        itemCount: groupedLogs.length,
        itemBuilder: (context, index) {
          final dateKey = groupedLogs.keys.toList()[index];
          final logsForDay = groupedLogs[dateKey]!;
          
          // Group by Exercise within the day
          final logsByExercise = groupBy(logsForDay, (l) => l.exercise.name);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2C),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat.yMMMd().format(DateTime.parse(dateKey)),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF80CBC4)),
                      ),
                      Text(
                        "Score: ${(logsForDay.map((l) => l.log.weight * l.log.reps).sum / logsForDay.length / 10).toStringAsFixed(1)}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                ...logsByExercise.entries.map((entry) {
                  final exerciseName = entry.key;
                  final sets = entry.value;
                  final exercise = sets.first.exercise;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(exerciseName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                            PopupMenuButton<String>(
                               onSelected: (value) {
                                 if (value == 'delete_all') {
                                   _confirmDeleteExerciseLogs(context, provider, exercise.id, DateTime.parse(dateKey));
                                 } else if (value == 'edit_name') {
                                   _showEditExerciseNameDialog(context, provider, exercise);
                                 }
                               },
                               itemBuilder: (context) => [
                                 const PopupMenuItem(value: 'edit_name', child: Text("Rename Exercise")),
                                 const PopupMenuItem(value: 'delete_all', child: Text("Delete All Sets")),
                               ],
                               child: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                            )
                          ],
                        ),
                        const Divider(height: 12),
                        ...sets.mapIndexed((i, setLog) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: [
                               Text('Set ${i+1}: ${setLog.log.weight}kg x ${setLog.log.reps} reps', style: const TextStyle(fontSize: 15)),
                               PopupMenuButton<String>(
                                 onSelected: (value) {
                                   if (value == 'edit') {
                                     _showEditSetDialog(context, provider, setLog.log);
                                   } else if (value == 'delete') {
                                     provider.deleteGymLog(setLog.log.id);
                                   }
                                 },
                                 itemBuilder: (context) => [
                                   const PopupMenuItem(value: 'edit', child: Text("Edit")),
                                   const PopupMenuItem(value: 'delete', child: Text("Delete")),
                                 ],
                                 child: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                               )
                             ],
                          ),
                        )),
                        const SizedBox(height: 8),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmDeleteExerciseLogs(BuildContext context, AppProvider provider, int exerciseId, DateTime date) {
    showDialog(
      context: context,
      builder: (ctx) => StyledDialog(
        title: "Delete Logs?",
        content: const Text("This will delete all sets for this exercise on this date."),
        onCancel: () => Navigator.pop(ctx),
        onSave: () {
          provider.deleteGymLogsForExerciseDate(exerciseId, date);
          Navigator.pop(ctx);
        },
        saveText: "Delete",
      )
    );
  }

  void _showEditExerciseNameDialog(BuildContext context, AppProvider provider, Exercise exercise) {
    final controller = TextEditingController(text: exercise.name);
    showDialog(
      context: context,
      builder: (ctx) => StyledDialog(
        title: "Rename Exercise",
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: "New Name")),
        onCancel: () => Navigator.pop(ctx),
        onSave: () {
          if (controller.text.isNotEmpty) {
            provider.updateExercise(exercise.copyWith(name: controller.text));
            Navigator.pop(ctx);
          }
        },
      )
    );
  }

  void _showEditSetDialog(BuildContext context, AppProvider provider, GymLog log) {
     final weightController = TextEditingController(text: log.weight.toString());
     final repsController = TextEditingController(text: log.reps.toString());
     DateTime selectedDate = log.date;

     showDialog(
       context: context,
       builder: (context) => StatefulBuilder(
         builder: (context, setState) => StyledDialog(
           title: "Edit Set",
           content: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               TextButton.icon(
                 onPressed: () async {
                   final picked = await showDatePicker(
                     context: context,
                     initialDate: selectedDate,
                     firstDate: DateTime(2000),
                     lastDate: DateTime.now().add(const Duration(days: 365)),
                   );
                   if (picked != null) setState(() => selectedDate = picked);
                 },
                 icon: const Icon(Icons.calendar_today, size: 18),
                 label: Text(DateFormat.yMMMd().format(selectedDate)),
               ),
               const SizedBox(height: 8),
               TextField(controller: weightController, decoration: const InputDecoration(labelText: "Weight (kg)"), keyboardType: TextInputType.number),
               const SizedBox(height: 12),
               TextField(controller: repsController, decoration: const InputDecoration(labelText: "Reps"), keyboardType: TextInputType.number),
             ],
           ),
           onCancel: () => Navigator.pop(context),
           onSave: () {
             provider.updateGymLog(log.copyWith(
               date: selectedDate,
               weight: double.tryParse(weightController.text) ?? 0,
               reps: int.tryParse(repsController.text) ?? 0,
             ));
             Navigator.pop(context);
           },
         ),
       )
     );
  }

  void _showAddWorkoutDialog(BuildContext context, AppProvider provider) {
     final nameController = TextEditingController();
     DateTime selectedDate = DateTime.now();
     List<Map<String, dynamic>> sets = [
       {'weight': 0.0, 'reps': 0}
     ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return StyledDialog(
            title: 'Log Workout',
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: TextButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) setState(() => selectedDate = picked);
                      },
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(DateFormat.yMMMd().format(selectedDate)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') {
                        return const Iterable<String>.empty();
                      }
                      return provider.exercises
                          .where((e) => e.name.toLowerCase().contains(textEditingValue.text.toLowerCase()))
                          .map((e) => e.name);
                    },
                    onSelected: (String selection) {
                      nameController.text = selection;
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                       controller.addListener(() {
                         nameController.text = controller.text;
                       });
                       return TextField(
                         controller: controller,
                         focusNode: focusNode,
                         decoration: const InputDecoration(labelText: 'Exercise Name'),
                       );
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text("Sets", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ...sets.mapIndexed((index, set) => Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(labelText: 'Weight (kg)', isDense: true),
                            keyboardType: TextInputType.number,
                            onChanged: (val) => set['weight'] = double.tryParse(val) ?? 0.0,
                          ),
                        ),
                        const SizedBox(width: 10),
                         Expanded(
                          child: TextField(
                            decoration: const InputDecoration(labelText: 'Reps', isDense: true),
                            keyboardType: TextInputType.number,
                             onChanged: (val) => set['reps'] = int.tryParse(val) ?? 0,
                          ),
                        ),
                        if (sets.length > 1)
                          IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () {
                             setState(() {
                               sets.removeAt(index);
                             });
                          })
                      ],
                    ),
                  )),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        final last = sets.last;
                        sets.add({'weight': last['weight'], 'reps': last['reps']});
                      });
                    },
                    icon: const Icon(Icons.add, color: Color(0xFF80CBC4)),
                    label: const Text("Add Set", style: TextStyle(color: Color(0xFF80CBC4))),
                  )
                ],
              ),
            ),
            onCancel: () => Navigator.pop(context),
            onSave: () {
              if (nameController.text.isNotEmpty && sets.isNotEmpty) {
                 provider.addGymLog(nameController.text, sets, date: selectedDate);
                 Navigator.pop(context);
              }
            },
          );
        }
      ),
    );
  }
}

class WeightTab extends StatelessWidget {
  const WeightTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final logs = provider.weightLogs.reversed.toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddWeightDialog(context, provider),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF2C2C2C), 
                radius: 25,
                child: Text(log.weight.toStringAsFixed(1), style: const TextStyle(color: Color(0xFF80CBC4), fontWeight: FontWeight.bold)),
              ),
              title: Text(DateFormat.yMMMd().format(log.date), style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                'Fat: ${log.bodyFat?.toStringAsFixed(1) ?? '-'}% | Muscle: ${log.muscleMass?.toStringAsFixed(1) ?? '-'}%'),
              trailing: PopupMenuButton<String>(
                 onSelected: (value) {
                   if (value == 'edit') {
                     _showEditWeightDialog(context, provider, log);
                   } else if (value == 'delete') {
                     provider.deleteWeightLog(log.id);
                   }
                 },
                 itemBuilder: (BuildContext context) {
                   return [
                     const PopupMenuItem(value: 'edit', child: Text('Edit')),
                     const PopupMenuItem(value: 'delete', child: Text('Delete')),
                   ];
                 },
              ),
            ),
          );
        },
      ),
    );
  }

   void _showAddWeightDialog(BuildContext context, AppProvider provider) {
     final weightController = TextEditingController();
     final fatController = TextEditingController();
     final muscleController = TextEditingController();
     DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => StyledDialog(
          title: 'Log Weight',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => selectedDate = picked);
                },
                icon: const Icon(Icons.calendar_today, size: 18),
                label: Text(DateFormat.yMMMd().format(selectedDate)),
              ),
              const SizedBox(height: 8),
              TextField(controller: weightController, decoration: const InputDecoration(labelText: 'Weight (kg)'), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              TextField(controller: fatController, decoration: const InputDecoration(labelText: 'Body Fat %'), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              TextField(controller: muscleController, decoration: const InputDecoration(labelText: 'Muscle Mass %'), keyboardType: TextInputType.number),
            ],
          ),
          onCancel: () => Navigator.pop(context),
          onSave: () {
            if (weightController.text.isNotEmpty) {
               provider.addWeightLog(
                 double.tryParse(weightController.text) ?? 0,
                 double.tryParse(fatController.text),
                 double.tryParse(muscleController.text),
                 date: selectedDate,
               );
               Navigator.pop(context);
            }
          },
          saveText: "Add",
        ),
      ),
    );
  }

  void _showEditWeightDialog(BuildContext context, AppProvider provider, WeightLog log) {
     final weightController = TextEditingController(text: log.weight.toString());
     final fatController = TextEditingController(text: log.bodyFat?.toString() ?? '');
     final muscleController = TextEditingController(text: log.muscleMass?.toString() ?? '');
     DateTime selectedDate = log.date;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => StyledDialog(
          title: 'Edit Weight',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => selectedDate = picked);
                },
                icon: const Icon(Icons.calendar_today, size: 18),
                label: Text(DateFormat.yMMMd().format(selectedDate)),
              ),
              const SizedBox(height: 8),
              TextField(controller: weightController, decoration: const InputDecoration(labelText: 'Weight (kg)'), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              TextField(controller: fatController, decoration: const InputDecoration(labelText: 'Body Fat %'), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              TextField(controller: muscleController, decoration: const InputDecoration(labelText: 'Muscle Mass %'), keyboardType: TextInputType.number),
            ],
          ),
          onCancel: () => Navigator.pop(context),
          onSave: () {
            if (weightController.text.isNotEmpty) {
               provider.updateWeightLog(log.copyWith(
                 date: selectedDate,
                 weight: double.tryParse(weightController.text) ?? 0,
                 bodyFat: drift.Value(double.tryParse(fatController.text)),
                 muscleMass: drift.Value(double.tryParse(muscleController.text)),
               ));
               Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }
}

class NutritionTab extends StatelessWidget {
  const NutritionTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final summary = provider.dailyNutritionSummary;
    final totalCals = summary['calories']!;
    final protein = summary['protein']!;
    final carbs = summary['carbs']!;
    final goalCals = provider.dailyCalorieGoal;

    return Scaffold(
      body: Column(
        children: [
          // Date Picker Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF252525),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: const Icon(Icons.arrow_back), onPressed: () {
                   provider.setSelectedNutritionDate(provider.selectedNutritionDate.subtract(const Duration(days: 1)));
                }),
                Text(
                  DateFormat.yMMMd().format(provider.selectedNutritionDate),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(icon: const Icon(Icons.arrow_forward), onPressed: () {
                   provider.setSelectedNutritionDate(provider.selectedNutritionDate.add(const Duration(days: 1)));
                }),
              ],
            ),
          ),
          
          // Goal Progress
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Daily Intake", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF80CBC4))),
                const SizedBox(height: 20),
                // Protein Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Protein", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                        Text("${protein}g", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: 1.0,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                      backgroundColor: Colors.blueAccent.withOpacity(0.2),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
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
                        Text("${carbs}g", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: 1.0,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                      backgroundColor: Colors.orangeAccent.withOpacity(0.2),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
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
                        Text("$totalCals / $goalCals kcal", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 12,
                      child: LinearProgressIndicator(
                        value: (totalCals / (goalCals == 0 ? 2000 : goalCals)).clamp(0.0, 1.0),
                        backgroundColor: Colors.grey[800],
                        color: totalCals > goalCals ? Colors.redAccent : const Color(0xFF80CBC4),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(),

          // Log List
          Expanded(
            child: ListView.builder(
              itemCount: provider.nutritionLogs.length,
              itemBuilder: (context, index) {
                final log = provider.nutritionLogs[index];
                if (!provider.isSameDay(log.date, provider.selectedNutritionDate)) {
                  return const SizedBox.shrink();
                }

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    title: Text('${log.calories} kcal', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('P: ${log.protein}g, C: ${log.carbs}g'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFF80CBC4)),
                          onPressed: () => _showEditNutritionDialog(context, provider, log),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.grey),
                          onPressed: () => provider.deleteNutritionLog(log.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNutritionDialog(context, provider),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddNutritionDialog(BuildContext context, AppProvider provider) {
     final kcalController = TextEditingController();
     final proteinController = TextEditingController();
     final carbsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Nutrition'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: kcalController, decoration: const InputDecoration(labelText: 'Calories'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: proteinController, decoration: const InputDecoration(labelText: 'Protein (g)'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: carbsController, decoration: const InputDecoration(labelText: 'Carbs (g)'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (kcalController.text.isNotEmpty) {
                 provider.addNutritionLog(
                   int.tryParse(kcalController.text) ?? 0,
                   int.tryParse(proteinController.text) ?? 0,
                   int.tryParse(carbsController.text) ?? 0,
                   provider.selectedNutritionDate
                 );
                 Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditNutritionDialog(BuildContext context, AppProvider provider, NutritionLog log) {
     final kcalController = TextEditingController(text: log.calories.toString());
     final proteinController = TextEditingController(text: log.protein.toString());
     final carbsController = TextEditingController(text: log.carbs.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Nutrition'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: kcalController, decoration: const InputDecoration(labelText: 'Calories'), keyboardType: TextInputType.number),
            TextField(controller: proteinController, decoration: const InputDecoration(labelText: 'Protein (g)'), keyboardType: TextInputType.number),
            TextField(controller: carbsController, decoration: const InputDecoration(labelText: 'Carbs (g)'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (kcalController.text.isNotEmpty) {
                 provider.updateNutritionLog(log.copyWith(
                   calories: int.tryParse(kcalController.text) ?? 0,
                   protein: int.tryParse(proteinController.text) ?? 0,
                   carbs: int.tryParse(carbsController.text) ?? 0,
                 ));
                 Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}