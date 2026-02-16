import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import '../database/database.dart';
import 'package:collection/collection.dart';
import '../services/widget_service.dart';

// UI Helpers to map Database classes to UI needs
class ReminderWithSubs {
  final Reminder reminder;
  final List<SubReminder> subs;
  ReminderWithSubs(this.reminder, this.subs);
}

class CategoryWithReminders {
  final Category category;
  final List<ReminderWithSubs> reminders;
  CategoryWithReminders(this.category, this.reminders);
}

class AppProvider with ChangeNotifier {
  final AppDatabase _db = AppDatabase();

  List<CategoryWithReminders> _categories = [];
  List<GymLogWithExercise> _gymLogs = [];
  List<WeightLog> _weightLogs = [];
  List<NutritionLog> _nutritionLogs = [];
  List<Exercise> _exercises = []; // Cached exercises for autocomplete
  int _dailyCalorieGoal = 2000;
  String? _userName;
  DateTime _selectedNutritionDate = DateTime.now();
  DateTime _selectedStatisticsDate = DateTime.now();

  List<CategoryWithReminders> get categories => _categories;
  List<GymLogWithExercise> get gymLogs => _gymLogs;
  List<WeightLog> get weightLogs => _weightLogs;
  List<NutritionLog> get nutritionLogs => _nutritionLogs;
  List<Exercise> get exercises => _exercises;
  int get dailyCalorieGoal => _dailyCalorieGoal;
  String? get userName => _userName;
  DateTime get selectedNutritionDate => _selectedNutritionDate;
  DateTime get selectedStatisticsDate => _selectedStatisticsDate;

  // Urgent Tasks (Sorted by Overdue -> Today -> Soon)
  List<Reminder> get urgentTasks {
    List<Reminder> all = [];
    for (var cat in _categories) {
      for (var r in cat.reminders) {
        if (!r.reminder.isCompleted && r.reminder.dueDate != null) {
          all.add(r.reminder);
        }
      }
    }
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    all.sort((a, b) {
      if (a.dueDate == null || b.dueDate == null) return 0;
      final aDate = DateTime(a.dueDate!.year, a.dueDate!.month, a.dueDate!.day);
      final bDate = DateTime(b.dueDate!.year, b.dueDate!.month, b.dueDate!.day);
      
      // Overdue priority
      bool aOverdue = aDate.isBefore(today);
      bool bOverdue = bDate.isBefore(today);
      if (aOverdue && !bOverdue) return -1;
      if (!aOverdue && bOverdue) return 1;
      
      // Date comparison
      return a.dueDate!.compareTo(b.dueDate!);
    });
    
    return all;
  }

  // Upcoming Reminders (All categories, incomplete, sorted by due date, limited to top 5?)
  List<Reminder> get upcomingReminders {
    List<Reminder> all = [];
    for (var cat in _categories) {
      for (var r in cat.reminders) {
        if (!r.reminder.isCompleted && r.reminder.dueDate != null) {
          all.add(r.reminder);
        }
      }
    }
    all.sort((a, b) {
      if (a.dueDate == null || b.dueDate == null) return 0;
      return a.dueDate!.compareTo(b.dueDate!);
    });
    return all;
  }
  
  // Exercise History
  List<GymLogWithExercise> getHistoryForExercise(String exerciseName) {
    return _gymLogs.where((l) => l.exercise.name == exerciseName).toList()
      ..sort((a, b) => a.log.date.compareTo(b.log.date)); // Oldest first for charts
  }

  // Computed Nutrition for Selected Day (Nutrition Tab)
  Map<String, int> get dailyNutritionSummary {
     int cals = 0;
     int prot = 0;
     int carb = 0;
     for (var log in _nutritionLogs) {
       if (isSameDay(log.date, _selectedNutritionDate)) {
         cals += log.calories;
         prot += log.protein;
         carb += log.carbs;
       }
     }
     return {'calories': cals, 'protein': prot, 'carbs': carb};
  }

  // Computed Nutrition for Selected Day (Statistics Tab)
  Map<String, int> get statisticsDailyNutritionSummary {
     int cals = 0;
     int prot = 0;
     int carb = 0;
     for (var log in _nutritionLogs) {
       if (isSameDay(log.date, _selectedStatisticsDate)) {
         cals += log.calories;
         prot += log.protein;
         carb += log.carbs;
       }
     }
     return {'calories': cals, 'protein': prot, 'carbs': carb};
  }
  
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Get Workout Progress (Total Volume / Sets / 10)
  List<Map<String, dynamic>> getWorkoutProgress({String? exerciseName}) {
    List<GymLogWithExercise> filteredLogs = exerciseName == null || exerciseName == "Daily Summary"
        ? _gymLogs 
        : _gymLogs.where((l) => l.exercise.name == exerciseName).toList();

    // Group logs by day
    final grouped = groupBy(filteredLogs, (GymLogWithExercise l) {
      final d = l.log.date;
      return DateTime(d.year, d.month, d.day);
    });

    final List<Map<String, dynamic>> results = [];
    grouped.forEach((date, logs) {
      if (logs.isEmpty) return;
      
      double totalVolume = 0;
      for (var l in logs) {
        totalVolume += (l.log.weight * l.log.reps);
      }
      
      // Formula: (Total Volume / Number of Sets) / 10
      results.add({
        'date': date,
        'value': (totalVolume / logs.length) / 10,
      });
    });

    // Sort by date ascending for charts
    results.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
    return results;
  }

  void setSelectedNutritionDate(DateTime date) {
    _selectedNutritionDate = date;
    notifyListeners();
  }

  void setSelectedStatisticsDate(DateTime date) {
    _selectedStatisticsDate = date;
    notifyListeners();
  }

  int _activeTab = 0;
  Map<String, int>? _pendingJumpRequest;

  int get activeTab => _activeTab;
  Map<String, int>? get pendingJumpRequest => _pendingJumpRequest;

  void setActiveTab(int index) {
    _activeTab = index;
    notifyListeners();
  }

  void requestJumpToReminder(int categoryId, int reminderId) {
    _pendingJumpRequest = {'categoryId': categoryId, 'reminderId': reminderId};
    _activeTab = 1; // Switch to Reminders tab
    notifyListeners();
  }

  void clearJumpRequest() {
    _pendingJumpRequest = null;
    notifyListeners();
  }

  Future<void> loadData() async {
    await _loadCategories();
    await _loadGymLogs();
    await _loadWeightLogs();
    await _loadNutritionLogs();
    await _loadExercises();
    
    // Auto-delete 'Pushups' placeholder if it exists (User request)
    final pushups = _exercises.firstWhereOrNull((e) => e.name == 'Pushups');
    if (pushups != null) {
      // Check if it has logs first? Or just delete. 
      // User said "no workout exists" implying logs are empty or they just want it gone.
      // deleteExercise deletes logs too via cascade or manual logic.
      await deleteExercise(pushups.id); 
    }

    await _loadUserGoal();
    await WidgetService.updateWidget(urgentTasks);
    notifyListeners();
  }


  Future<void> _loadUserGoal() async {
    final goal = await _db.getUserGoal();
    if (goal != null) {
      _dailyCalorieGoal = goal.dailyCalorieGoal;
      _userName = goal.userName;
    }
  }

  Future<void> setUserGoal(int calories) async {
    await _db.setUserGoal(calories);
    _dailyCalorieGoal = calories;
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    await _db.setUserName(name);
    _userName = name;
    notifyListeners();
  }

  // --- Categories & Reminders ---

  Future<void> _loadCategories() async {
    final cats = await _db.getAllCategories();
    List<CategoryWithReminders> tempCats = [];
    
    for (var cat in cats) {
      final reminders = await _db.getRemindersForCategory(cat.id);
      List<ReminderWithSubs> tempReminders = [];
      for (var r in reminders) {
        final subs = await _db.getSubRemindersForReminder(r.id);
        tempReminders.add(ReminderWithSubs(r, subs));
      }
      tempCats.add(CategoryWithReminders(cat, tempReminders));
    }
    _categories = tempCats;
  }

  Future<void> addCategory(String name) async {
    int nextOrder = _categories.length;
    await _db.insertCategory(CategoriesCompanion(
        name: drift.Value(name),
        orderIndex: drift.Value(nextOrder)
    ));
    await _loadCategories();
    await WidgetService.updateWidget(urgentTasks);
    notifyListeners();
  }

  Future<void> updateCategory(Category category) async {
    await _db.updateCategory(category);
    await _loadCategories();
    await WidgetService.updateWidget(urgentTasks);
    notifyListeners();
  }

  Future<void> reorderCategories(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _categories.removeAt(oldIndex);
    _categories.insert(newIndex, item);

    for (int i = 0; i < _categories.length; i++) {
        final c = _categories[i].category;
        if (c.orderIndex != i) {
           await _db.updateCategoryIndex(c.id, i);
        }
    }
    
    // Refresh
    await _loadCategories();
    await WidgetService.updateWidget(urgentTasks);
    notifyListeners();
  }

  Future<void> deleteCategory(int id) async {
    await _db.deleteCategory(id);
    await _loadCategories();
    await WidgetService.updateWidget(urgentTasks);
    notifyListeners();
  }

  Future<void> addReminder(int categoryId, String title, {String? imagePath, DateTime? dueDate, DateTime? endDate, bool isEvent = false, String recurrence = 'none'}) async {
    // Find current max order index for this category to append at the end
    int nextOrder = 0;
    final category = _categories.firstWhereOrNull((c) => c.category.id == categoryId);
    if (category != null && category.reminders.isNotEmpty) {
       nextOrder = category.reminders.length;
    }

    await _db.insertReminder(RemindersCompanion(
      categoryId: drift.Value(categoryId),
      title: drift.Value(title),
      imagePath: drift.Value(imagePath),
      orderIndex: drift.Value(nextOrder),
      dueDate: drift.Value(dueDate),
      endDate: drift.Value(endDate),
      isEvent: drift.Value(isEvent),
      recurrence: drift.Value(recurrence),
    ));
    await _loadCategories();
    await WidgetService.updateWidget(urgentTasks);
    notifyListeners();
  }

  Future<void> addEvent(int categoryId, String title, DateTime start, DateTime end, {String recurrence = 'none'}) async {
    await addReminder(categoryId, title, dueDate: start, endDate: end, isEvent: true, recurrence: recurrence);
  }

  Future<void> updateReminder(Reminder reminder) async {
    await _db.updateReminder(reminder);
    await _loadCategories();
    await WidgetService.updateWidget(urgentTasks);
    notifyListeners();
  }

  Future<void> reorderReminders(int categoryId, int oldIndex, int newIndex) async {
    final category = _categories.firstWhereOrNull((c) => c.category.id == categoryId);
    if (category == null) return;

    final reminders = category.reminders;
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = reminders.removeAt(oldIndex);
    reminders.insert(newIndex, item);

    // Update all affected indices in DB
    // Optimization: Batch update or transaction
    // For now, simple loop
    for (int i = 0; i < reminders.length; i++) {
        final r = reminders[i].reminder;
        if (r.orderIndex != i) {
           await _db.updateReminderIndex(r.id, i);
        }
    }
    
    // Refresh
    await _loadCategories();
    await WidgetService.updateWidget(urgentTasks);
    notifyListeners();
  }

  Future<void> toggleReminderCompletion(int reminderId, bool value) async {
    Reminder? target;
    for (var c in _categories) {
        for (var r in c.reminders) {
            if (r.reminder.id == reminderId) target = r.reminder;
        }
    }

    if (target != null) {
        if (value && target.recurrence != 'none' && target.dueDate != null) {
          // If marking a recurring task as complete, move it to the next date
          DateTime nextDate;
          switch (target.recurrence) {
            case 'daily': nextDate = target.dueDate!.add(const Duration(days: 1)); break;
            case 'weekly': nextDate = target.dueDate!.add(const Duration(days: 7)); break;
            case 'monthly': nextDate = DateTime(target.dueDate!.year, target.dueDate!.month + 1, target.dueDate!.day); break;
            default: nextDate = target.dueDate!;
          }
          
          DateTime? nextEndDate;
          if (target.endDate != null) {
            final diff = target.endDate!.difference(target.dueDate!);
            nextEndDate = nextDate.add(diff);
          }

          await _db.updateReminder(target.copyWith(
            dueDate: drift.Value(nextDate),
            endDate: drift.Value(nextEndDate),
            isCompleted: false, // Keep it active for the next date
          ));
        } else {
          await _db.updateReminder(target.copyWith(isCompleted: value));
        }
        await _loadCategories();
        notifyListeners();
    }
  }

  Future<void> deleteReminder(int id) async {
    await _db.deleteReminder(id);
    await _loadCategories();
    await WidgetService.updateWidget(urgentTasks);
    notifyListeners();
  }

  Future<void> addSubReminder(int reminderId, String title, {String? imagePath}) async {
    await _db.insertSubReminder(SubRemindersCompanion(
      reminderId: drift.Value(reminderId),
      title: drift.Value(title),
      imagePath: drift.Value(imagePath),
    ));
    await _loadCategories();
    await WidgetService.updateWidget(urgentTasks);
    notifyListeners();
  }

  Future<void> toggleSubReminderCompletion(int subId, bool value) async {
    SubReminder? target;
    for(var c in _categories) {
        for(var r in c.reminders) {
            for(var s in r.subs) {
                if(s.id == subId) target = s;
            }
        }
    }

    if(target != null) {
        await _db.updateSubReminder(target.copyWith(isCompleted: value));
        await _loadCategories();
        notifyListeners();
    }
  }

   Future<void> deleteSubReminder(int id) async {
    await _db.deleteSubReminder(id);
    await _loadCategories();
    await WidgetService.updateWidget(urgentTasks);
    notifyListeners();
  }


  // --- Fitness ---

  Future<void> _loadExercises() async {
    _exercises = await _db.getAllExercises();
  }

  Future<void> updateExercise(Exercise exercise) async {
    await _db.updateExercise(exercise);
    await _loadExercises();
    await _loadGymLogs(); // Refresh logs as they depend on exercise name
    notifyListeners();
  }

  Future<void> deleteExercise(int id) async {
    await _db.deleteExercise(id);
    await _loadExercises();
    await _loadGymLogs();
    notifyListeners();
  }

  Future<void> _loadGymLogs() async {
    _gymLogs = await _db.getGymLogs();
    // Sort by date desc
    _gymLogs.sort((a, b) => b.log.date.compareTo(a.log.date));
  }

  // Accepts multiple sets
  Future<void> addGymLog(String exerciseName, List<Map<String, dynamic>> sets, {DateTime? date}) async {
    // Check if exercise exists
    Exercise? exercise = await _db.getExerciseByName(exerciseName);
    int exerciseId;
    if (exercise == null) {
        exerciseId = await _db.insertExercise(ExercisesCompanion(name: drift.Value(exerciseName)));
        await _loadExercises(); // Refresh cache
    } else {
        exerciseId = exercise.id;
    }

    final logDate = date ?? DateTime.now();

    for (var set in sets) {
      await _db.insertGymLog(GymLogsCompanion(
          exerciseId: drift.Value(exerciseId),
          date: drift.Value(logDate),
          weight: drift.Value(set['weight']),
          reps: drift.Value(set['reps']),
          sets: drift.Value(1) // Ignoring sets column, using 1 row = 1 set
      ));
    }
    
    await _loadGymLogs();
    notifyListeners();
  }

  Future<void> updateGymLog(GymLog log) async {
    await _db.updateGymLog(log);
    await _loadGymLogs();
    notifyListeners();
  }

  Future<void> deleteGymLogsForExerciseDate(int exerciseId, DateTime date) async {
    // Delete all logs for this exercise on this day
    // We filter locally or add a custom query. 
    // Since we don't have a batch delete query in AppDatabase yet, we iterate.
    final targets = _gymLogs.where((l) => 
        l.exercise.id == exerciseId && 
        isSameDay(l.log.date, date)
    ).toList();
    
    for (var t in targets) {
      await _db.deleteGymLog(t.log.id);
    }
    await _loadGymLogs();
    notifyListeners();
  }

  Future<void> deleteGymLog(int id) async {
    await _db.deleteGymLog(id);
    await _loadGymLogs();
    notifyListeners();
  }

  Future<void> _loadWeightLogs() async {
    _weightLogs = await _db.getAllWeightLogs();
    // sort desc for list view? Keep asc for charts.
    // Let's keep internal list sorted by date ASC for charts, reverse in UI for list.
  }

  Future<void> addWeightLog(double weight, double? bodyFat, double? muscleMass, {DateTime? date}) async {
    await _db.insertWeightLog(WeightLogsCompanion(
        date: drift.Value(date ?? DateTime.now()),
        weight: drift.Value(weight),
        bodyFat: drift.Value(bodyFat),
        muscleMass: drift.Value(muscleMass),
    ));
    await _loadWeightLogs();
    notifyListeners();
  }

  Future<void> updateWeightLog(WeightLog log) async {
    await _db.updateWeightLog(log);
    await _loadWeightLogs();
    notifyListeners();
  }

  Future<void> deleteWeightLog(int id) async {
    await _db.deleteWeightLog(id);
    await _loadWeightLogs();
    notifyListeners();
  }

  Future<void> _loadNutritionLogs() async {
    _nutritionLogs = await _db.getAllNutritionLogs();
  }

  Future<void> addNutritionLog(int calories, int protein, int carbs, DateTime date) async {
    await _db.insertNutritionLog(NutritionLogsCompanion(
        date: drift.Value(date),
        calories: drift.Value(calories),
        protein: drift.Value(protein),
        carbs: drift.Value(carbs)
    ));
    await _loadNutritionLogs();
    notifyListeners();
  }
  
  Future<void> updateNutritionLog(NutritionLog log) async {
    await _db.updateNutritionLog(log);
    await _loadNutritionLogs();
    notifyListeners();
  }

  Future<void> deleteNutritionLog(int id) async {
    await _db.deleteNutritionLog(id);
    await _loadNutritionLogs();
    notifyListeners();
  }
}