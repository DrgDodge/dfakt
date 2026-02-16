import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../database/database.dart';
import '../widgets/ui_helpers.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader("Goals"),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text("Your Name"),
                      subtitle: Text(provider.userName ?? "Not set"),
                      trailing: const Icon(Icons.edit, color: Color(0xFF80CBC4)),
                      onTap: () => _showEditNameDialog(context, provider),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      title: const Text("Daily Calorie Limit"),
                      subtitle: Text("${provider.dailyCalorieGoal} kcal"),
                      trailing: const Icon(Icons.edit, color: Color(0xFF80CBC4)),
                      onTap: () => _showEditGoalDialog(context, provider),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionHeader("Manage Data"),
              Card(
                child: ExpansionTile(
                  shape: const Border(),
                  collapsedShape: const Border(),
                  title: const Text("Manage Exercises"),
                  iconColor: const Color(0xFF80CBC4),
                  textColor: const Color(0xFF80CBC4),
                  children: [
                    if (provider.exercises.isEmpty)
                      const ListTile(title: Text("No exercises found")),
                    ...provider.exercises.map((e) => ListTile(
                      title: Text(e.name),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _confirmDeleteExercise(context, provider, e),
                      ),
                      onTap: () => _showEditExerciseDialog(context, provider, e),
                    ))
                  ],
                ),
              ),
              if (provider.exercises.any((e) => e.name == "Pushups"))
                 Card(
                   child: ListTile(
                     title: const Text("Delete 'Pushups' Placeholder", style: TextStyle(color: Colors.redAccent)),
                     onTap: () {
                        final e = provider.exercises.firstWhere((e) => e.name == "Pushups");
                        provider.deleteExercise(e.id);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Deleted 'Pushups'")));
                     },
                   ),
                 )
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF80CBC4),
        ),
      ),
    );
  }

  void _showEditGoalDialog(BuildContext context, AppProvider provider) {
    final controller = TextEditingController(text: provider.dailyCalorieGoal.toString());
    showDialog(
      context: context, 
      builder: (ctx) => StyledDialog(
        title: "Set Daily Calorie Goal",
        content: TextField(
          controller: controller, 
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Calories"),
        ),
        onCancel: () => Navigator.pop(ctx),
        onSave: () {
          final val = int.tryParse(controller.text);
          if (val != null) {
            provider.setUserGoal(val);
            Navigator.pop(ctx);
          }
        },
        saveText: "Save",
      )
    );
  }

  void _showEditNameDialog(BuildContext context, AppProvider provider) {
    final controller = TextEditingController(text: provider.userName ?? "");
    showDialog(
      context: context, 
      builder: (ctx) => StyledDialog(
        title: "Set Your Name",
        content: TextField(
          controller: controller, 
          decoration: const InputDecoration(labelText: "Name"),
        ),
        onCancel: () => Navigator.pop(ctx),
        onSave: () {
          if (controller.text.isNotEmpty) {
            provider.setUserName(controller.text);
            Navigator.pop(ctx);
          }
        },
        saveText: "Save",
      )
    );
  }

  void _confirmDeleteExercise(BuildContext context, AppProvider provider, Exercise exercise) {
    showDialog(
      context: context, 
      builder: (ctx) => StyledDialog(
        title: "Delete '${exercise.name}'?",
        content: const Text("This will delete ALL workout history associated with this exercise."),
        onCancel: () => Navigator.pop(ctx),
        onSave: () {
          provider.deleteExercise(exercise.id);
          Navigator.pop(ctx);
        },
        saveText: "Delete",
      )
    );
  }

  void _showEditExerciseDialog(BuildContext context, AppProvider provider, Exercise exercise) {
    final controller = TextEditingController(text: exercise.name);
    showDialog(
      context: context, 
      builder: (ctx) => StyledDialog(
        title: "Rename Exercise",
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "New Name"),
        ),
        onCancel: () => Navigator.pop(ctx),
        onSave: () {
          if (controller.text.isNotEmpty) {
            provider.updateExercise(exercise.copyWith(name: controller.text));
            Navigator.pop(ctx);
          }
        },
        saveText: "Save",
      )
    );
  }
}