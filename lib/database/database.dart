import 'package:drift/drift.dart';
import 'connection/connection.dart';

part 'database.g.dart';

// --- Tables ---

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
}

class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get categoryId => integer().references(Categories, #id, onDelete: KeyAction.cascade)();
  TextColumn get imagePath => text().nullable()();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  BoolColumn get isEvent => boolean().withDefault(const Constant(false))();
  TextColumn get recurrence => text().withDefault(const Constant('none'))();
  IntColumn get color => integer().nullable()();
}

class SubReminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get reminderId => integer().references(Reminders, #id, onDelete: KeyAction.cascade)();
  TextColumn get imagePath => text().nullable()();
}

// Fitness Tables

class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

class GymLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get exerciseId => integer().references(Exercises, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get date => dateTime()();
  RealColumn get weight => real()();
  IntColumn get reps => integer()();
  IntColumn get sets => integer().withDefault(const Constant(1))(); // kept for schema compatibility, unused
}

class WeightLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  RealColumn get weight => real()();
  RealColumn get bodyFat => real().nullable()();
  RealColumn get muscleMass => real().nullable()();
}

class NutritionLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  IntColumn get calories => integer()();
  IntColumn get protein => integer()();
  IntColumn get carbs => integer()();
}

class UserGoals extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get dailyCalorieGoal => integer().withDefault(const Constant(2000))();
  TextColumn get userName => text().nullable()();
}

// --- Database Class ---

@DriftDatabase(tables: [
  Categories,
  Reminders,
  SubReminders,
  Exercises,
  GymLogs,
  WeightLogs,
  NutritionLogs,
  UserGoals
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(connect());

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.addColumn(reminders, reminders.imagePath);
        await m.addColumn(subReminders, subReminders.imagePath);
        await m.addColumn(weightLogs, weightLogs.bodyFat);
        await m.addColumn(weightLogs, weightLogs.muscleMass);
        await m.createTable(userGoals);
      }
      if (from < 3) {
        await m.addColumn(reminders, reminders.orderIndex);
      }
      if (from < 4) {
        await m.addColumn(categories, categories.orderIndex);
        await m.addColumn(reminders, reminders.dueDate);
      }
      if (from < 5) {
        await m.addColumn(userGoals, userGoals.userName);
      }
      if (from < 6) {
        await m.addColumn(reminders, reminders.endDate);
      }
      if (from < 7) {
        await m.addColumn(reminders, reminders.isEvent);
        await m.addColumn(reminders, reminders.recurrence);
      }
      if (from < 8) {
        await m.addColumn(reminders, reminders.color);
      }
    },
  );

  // --- Queries ---

  // Categories & Reminders
  Future<List<Category>> getAllCategories() => (select(categories)..orderBy([(t) => OrderingTerm(expression: t.orderIndex)])).get();
  Future<int> insertCategory(CategoriesCompanion entry) => into(categories).insert(entry);
  Future<bool> updateCategory(Category entry) => update(categories).replace(entry);
  Future<int> deleteCategory(int id) => (delete(categories)..where((tbl) => tbl.id.equals(id))).go();
  Future<void> updateCategoryIndex(int id, int index) {
    return (update(categories)..where((t) => t.id.equals(id))).write(CategoriesCompanion(orderIndex: Value(index)));
  }

  Future<List<Reminder>> getRemindersForCategory(int categoryId) {
    return (select(reminders)
      ..where((tbl) => tbl.categoryId.equals(categoryId))
      ..orderBy([(t) => OrderingTerm(expression: t.orderIndex)]))
      .get();
  }
  Future<int> insertReminder(RemindersCompanion entry) => into(reminders).insert(entry);
  Future<bool> updateReminder(Reminder entry) => update(reminders).replace(entry);
  Future<int> deleteReminder(int id) => (delete(reminders)..where((tbl) => tbl.id.equals(id))).go();
  Future<void> updateReminderIndex(int id, int index) {
    return (update(reminders)..where((t) => t.id.equals(id))).write(RemindersCompanion(orderIndex: Value(index)));
  }

  Future<List<SubReminder>> getSubRemindersForReminder(int reminderId) {
    return (select(subReminders)..where((tbl) => tbl.reminderId.equals(reminderId))).get();
  }
  Future<int> insertSubReminder(SubRemindersCompanion entry) => into(subReminders).insert(entry);
  Future<bool> updateSubReminder(SubReminder entry) => update(subReminders).replace(entry);
  Future<int> deleteSubReminder(int id) => (delete(subReminders)..where((tbl) => tbl.id.equals(id))).go();

  // Fitness
  Future<List<Exercise>> getAllExercises() => select(exercises).get();
  Future<int> insertExercise(ExercisesCompanion entry) => into(exercises).insert(entry);
  Future<bool> updateExercise(Exercise entry) => update(exercises).replace(entry);
  Future<int> deleteExercise(int id) => (delete(exercises)..where((tbl) => tbl.id.equals(id))).go();
  Future<Exercise?> getExerciseByName(String name) async {
      return (select(exercises)..where((tbl) => tbl.name.equals(name))).getSingleOrNull();
  }

  // Define a custom class to hold the joined result
  Future<List<GymLogWithExercise>> getGymLogs() async {
    final query = select(gymLogs).join([
      innerJoin(exercises, exercises.id.equalsExp(gymLogs.exerciseId))
    ]);
    
    return query.map((row) {
      return GymLogWithExercise(
        log: row.readTable(gymLogs),
        exercise: row.readTable(exercises),
      );
    }).get();
  }

  Future<int> insertGymLog(GymLogsCompanion entry) => into(gymLogs).insert(entry);
  Future<bool> updateGymLog(GymLog entry) => update(gymLogs).replace(entry);
  Future<int> deleteGymLog(int id) => (delete(gymLogs)..where((tbl) => tbl.id.equals(id))).go();

  Future<List<WeightLog>> getAllWeightLogs() => (select(weightLogs)..orderBy([(t) => OrderingTerm(expression: t.date)])).get();
  Future<int> insertWeightLog(WeightLogsCompanion entry) => into(weightLogs).insert(entry);
  Future<bool> updateWeightLog(WeightLog entry) => update(weightLogs).replace(entry);
  Future<int> deleteWeightLog(int id) => (delete(weightLogs)..where((tbl) => tbl.id.equals(id))).go();

  Future<List<NutritionLog>> getAllNutritionLogs() => (select(nutritionLogs)..orderBy([(t) => OrderingTerm(expression: t.date)])).get();
  Future<int> insertNutritionLog(NutritionLogsCompanion entry) => into(nutritionLogs).insert(entry);
  Future<bool> updateNutritionLog(NutritionLog entry) => update(nutritionLogs).replace(entry);
  Future<int> deleteNutritionLog(int id) => (delete(nutritionLogs)..where((tbl) => tbl.id.equals(id))).go();
  
  // User Goals
  Future<UserGoal?> getUserGoal() => select(userGoals).getSingleOrNull();
  
  Future<int> setUserGoal(int calories) async {
    final current = await getUserGoal();
    if (current == null) {
      return into(userGoals).insert(UserGoalsCompanion(dailyCalorieGoal: Value(calories)));
    } else {
      return (update(userGoals)..where((t) => t.id.equals(current.id))).write(UserGoalsCompanion(dailyCalorieGoal: Value(calories)));
    }
  }

  Future<int> setUserName(String name) async {
    final current = await getUserGoal();
    if (current == null) {
      return into(userGoals).insert(UserGoalsCompanion(userName: Value(name)));
    } else {
      return (update(userGoals)..where((t) => t.id.equals(current.id))).write(UserGoalsCompanion(userName: Value(name)));
    }
  }
}

// Helper class for joined data
class GymLogWithExercise {
  final GymLog log;
  final Exercise exercise;
  GymLogWithExercise({required this.log, required this.exercise});
}


