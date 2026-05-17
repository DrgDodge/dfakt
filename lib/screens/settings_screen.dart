import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../database/database.dart';
import '../widgets/ui_helpers.dart';
import 'sync_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Database'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'General', icon: Icon(Icons.settings)),
            Tab(text: 'Database', icon: Icon(Icons.storage)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const GeneralSettingsTab(),
          const DatabaseTab(),
        ],
      ),
    );
  }
}

class GeneralSettingsTab extends StatelessWidget {
  const GeneralSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
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
        _buildSectionHeader("Sync"),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.sync, color: Color(0xFF80CBC4)),
                title: const Text("Device Sync"),
                subtitle: const Text("Sync data with other devices on local network"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SyncScreen())),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              if (provider.isPbLoggedIn) ...[
                ListTile(
                  leading: const Icon(Icons.cloud_done, color: Color(0xFF80CBC4)),
                  title: const Text("Cloud Sync"),
                  subtitle: Text("Logged in as ${provider.pbUserEmail ?? 'Unknown'}"),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      try {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Syncing...')));
                        await provider.syncToCloud();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sync complete!')));
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sync failed: $e')));
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF80CBC4),
                      foregroundColor: Colors.black,
                    ),
                    child: const Text("Sync Now"),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text("Logout"),
                  onTap: () {
                    provider.logoutPb();
                  },
                ),
              ] else ...[
                ListTile(
                  leading: const Icon(Icons.cloud_off, color: Colors.grey),
                  title: const Text("Cloud Sync Login"),
                  subtitle: const Text("Login to sync with PocketBase"),
                  trailing: const Icon(Icons.login, size: 16),
                  onTap: () => _showPbLoginDialog(context, provider),
                ),
              ],
            ],
          ),
        ),
      ],
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

  void _showPbLoginDialog(BuildContext context, AppProvider provider) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    
    showDialog(
      context: context, 
      builder: (ctx) => StyledDialog(
        title: "PocketBase Login",
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
          ],
        ),
        onCancel: () => Navigator.pop(ctx),
        onSave: () async {
          if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
            try {
              await provider.loginPb(emailController.text, passwordController.text);
              if (ctx.mounted) Navigator.pop(ctx);
            } catch (e) {
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text("Login failed: $e")));
              }
            }
          }
        },
        saveText: "Login",
      )
    );
  }
}

class DatabaseTab extends StatefulWidget {
  const DatabaseTab({super.key});

  @override
  State<DatabaseTab> createState() => _DatabaseTabState();
}

class _DatabaseTabState extends State<DatabaseTab> {
  String _searchQuery = "";
  String _viewMode = "Exercises"; // "Exercises" or "Food Items"

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _viewMode,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF2C2C2C),
                      items: ["Exercises", "Food Items"].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: const TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _viewMode = val);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search...",
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF80CBC4), size: 20),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              if (_viewMode == "Exercises") ...[
                _buildExercisesList(provider),
              ] else ...[
                _buildFoodItemsList(provider),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExercisesList(AppProvider provider) {
    final filteredExercises = provider.exercises
        .where((e) => e.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Exercises (${filteredExercises.length})"),
        Card(
          child: Column(
            children: [
              if (filteredExercises.isEmpty)
                const ListTile(title: Text("No exercises matched.")),
              ...filteredExercises.map((e) => ListTile(
                title: Text(e.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20, color: Color(0xFF80CBC4)),
                      onPressed: () => _showEditExerciseDialog(context, provider, e),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
                      onPressed: () => _confirmDeleteExercise(context, provider, e),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFoodItemsList(AppProvider provider) {
    return FutureBuilder<List<FoodItem>>(
      future: provider.getAllFoodItems(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final items = snapshot.data!
            .where((f) => f.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                           f.barcode.contains(_searchQuery))
            .toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Scanned Food Items (${items.length})"),
            Card(
              child: Column(
                children: [
                  if (items.isEmpty)
                    const ListTile(title: Text("No food items found.")),
                  ...items.map((f) => ListTile(
                    title: Text(f.name),
                    subtitle: Text("Barcode: ${f.barcode}\n${f.caloriesPer100g.round()} kcal/100g"),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20, color: Color(0xFF80CBC4)),
                          onPressed: () => _showEditFoodDialog(context, provider, f),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
                          onPressed: () => _confirmDeleteFood(context, provider, f),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        );
      }
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

  void _confirmDeleteFood(BuildContext context, AppProvider provider, FoodItem food) {
    showDialog(
      context: context, 
      builder: (ctx) => StyledDialog(
        title: "Delete '${food.name}'?",
        content: const Text("This will remove this product from your database."),
        onCancel: () => Navigator.pop(ctx),
        onSave: () {
          provider.deleteFoodItem(food.id);
          setState(() {}); // Refresh future
          Navigator.pop(ctx);
        },
        saveText: "Delete",
      )
    );
  }

  void _showEditFoodDialog(BuildContext context, AppProvider provider, FoodItem food) {
    final nameController = TextEditingController(text: food.name);
    final kcalController = TextEditingController(text: food.caloriesPer100g.toString());
    final proteinController = TextEditingController(text: food.proteinPer100g.toString());
    final carbsController = TextEditingController(text: food.carbsPer100g.toString());

    showDialog(
      context: context, 
      builder: (ctx) => StyledDialog(
        title: "Edit Product",
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
              TextField(controller: kcalController, decoration: const InputDecoration(labelText: "Kcal/100g"), keyboardType: TextInputType.number),
              TextField(controller: proteinController, decoration: const InputDecoration(labelText: "Protein/100g"), keyboardType: TextInputType.number),
              TextField(controller: carbsController, decoration: const InputDecoration(labelText: "Carbs/100g"), keyboardType: TextInputType.number),
            ],
          ),
        ),
        onCancel: () => Navigator.pop(ctx),
        onSave: () {
          provider.updateFoodItem(food.copyWith(
            name: nameController.text,
            caloriesPer100g: double.tryParse(kcalController.text) ?? food.caloriesPer100g,
            proteinPer100g: double.tryParse(proteinController.text) ?? food.proteinPer100g,
            carbsPer100g: double.tryParse(carbsController.text) ?? food.carbsPer100g,
          ));
          setState(() {}); // Refresh future
          Navigator.pop(ctx);
        },
        saveText: "Save",
      )
    );
  }
}
