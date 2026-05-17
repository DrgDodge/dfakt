import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import '../database/database.dart';
import 'package:collection/collection.dart';
import '../services/widget_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:archive/archive.dart';
import 'package:image/image.dart' as img;
import 'package:pdfx/pdfx.dart';
import 'package:pocketbase/pocketbase.dart';

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
  AppDatabase _db = AppDatabase();
  final pb = PocketBase('https://api.sinulzyn.com');

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

  Future<void> replaceDatabase(List<int> bytes) async {
     // Legacy support or fallback
     await _restoreFromBytes(bytes);
  }

  Future<void> restoreFromZip(List<int> bytes) async {
    // 0. Clear UI state to release file locks from Image widgets
    _categories = [];
    _gymLogs = [];
    _weightLogs = [];
    _nutritionLogs = [];
    _exercises = [];
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 100));

    final tempDir = await getTemporaryDirectory();
    final tempZipFile = File(p.join(tempDir.path, 'restore_temp.zip'));
    await tempZipFile.writeAsBytes(bytes);

    final archive = ZipDecoder().decodeBytes(bytes);
    final dbFolder = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(dbFolder.path, 'images'));
    final storageDir = Directory(p.join(dbFolder.path, 'storage'));
    
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    if (!await storageDir.exists()) {
      await storageDir.create(recursive: true);
    }

    // 1. Close DB and Clear Cache
    await _closeDb();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    await Future.delayed(const Duration(milliseconds: 500));

    // 2. Extract and Move Files
    for (final file in archive) {
      if (file.isFile) {
        if (file.name == 'dragonfakt.sqlite') {
           final dbFile = File(p.join(dbFolder.path, 'dragonfakt.sqlite'));
           
           // Retry loop for DB file deletion
           int retries = 0;
           while (retries < 5) {
             try {
               await _deleteWal(dbFile);
               if (await dbFile.exists()) await dbFile.delete();
               break;
             } catch (e) {
               print("DB Delete Retry $retries: $e");
               await Future.delayed(const Duration(milliseconds: 200));
               retries++;
             }
           }

           await dbFile.writeAsBytes(file.content as List<int>, flush: true);
        } else if (file.name.startsWith('images/')) {
           final filename = p.basename(file.name);
           final outFile = File(p.join(imagesDir.path, filename));
           
           try {
             if (await outFile.exists()) {
                try { await outFile.delete(); } catch (_) {}
             }
             await outFile.writeAsBytes(file.content as List<int>, flush: true);
           } catch (e) {
             print("Failed to overwrite image $filename: $e");
           }
        } else if (file.name.startsWith('storage/')) {
           final filename = p.basename(file.name);
           final outFile = File(p.join(storageDir.path, filename));
           
           try {
             if (await outFile.exists()) {
                try { await outFile.delete(); } catch (_) {}
             }
             await outFile.writeAsBytes(file.content as List<int>, flush: true);
           } catch (e) {
             print("Failed to overwrite storage file $filename: $e");
           }
        }
      }
    }

    // 3. Re-open DB
    _db = AppDatabase();
    
    // 4. Fix paths in DB to match new local path
    await _fixDatabaseImagePaths(imagesDir.path);
    await _fixDatabaseStoragePaths(storageDir.path);

    await loadData();
    
    // Cleanup temp
    if (await tempZipFile.exists()) await tempZipFile.delete();
  }

  Future<void> _closeDb() async {
    await _db.close();
  }

  Future<void> _deleteWal(File dbFile) async {
    final wal = File('${dbFile.path}-wal');
    final shm = File('${dbFile.path}-shm');
    if (await wal.exists()) await wal.delete();
    if (await shm.exists()) await shm.delete();
  }

  Future<void> _restoreFromBytes(List<int> bytes) async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'dragonfakt.sqlite'));
    await _closeDb();
    await _deleteWal(file);
    await file.writeAsBytes(bytes, flush: true);
    _db = AppDatabase();
    await loadData();
  }

  Future<void> _fixDatabaseImagePaths(String localImagesPath) async {
    // Iterate all reminders with images
    final reminders = await _db.select(_db.reminders).get();
    for (var r in reminders) {
      if (r.imagePath != null) {
        final filename = p.basename(r.imagePath!);
        final newPath = p.join(localImagesPath, filename);
        if (r.imagePath != newPath) {
           await _db.updateReminder(r.copyWith(imagePath: drift.Value(newPath)));
        }
      }
    }
    
    // Iterate sub-reminders
    final subs = await _db.select(_db.subReminders).get();
    for (var s in subs) {
      if (s.imagePath != null) {
        final filename = p.basename(s.imagePath!);
        final newPath = p.join(localImagesPath, filename);
        if (s.imagePath != newPath) {
           await _db.updateSubReminder(s.copyWith(imagePath: drift.Value(newPath)));
        }
      }
    }
  }

  Future<void> _fixDatabaseStoragePaths(String localStoragePath) async {
    final files = await _db.select(_db.storageFiles).get();
    for (var f in files) {
      final filename = p.basename(f.path);
      final newPath = p.join(localStoragePath, filename);
      if (f.path != newPath) {
        await _db.updateFile(f.copyWith(path: newPath));
      }
    }
  }

  Future<List<String>> getAllImagePaths() async {
    final paths = <String>[];
    // Reminders
    final reminders = await _db.select(_db.reminders).get();
    for(var r in reminders) {
      if (r.imagePath != null) paths.add(r.imagePath!);
    }
    // SubReminders
    final subs = await _db.select(_db.subReminders).get();
    for(var s in subs) {
      if (s.imagePath != null) paths.add(s.imagePath!);
    }
    // Storage Files
    final storageFiles = await _db.select(_db.storageFiles).get();
    for(var f in storageFiles) {
      paths.add(f.path);
    }
    return paths;
  }

  Future<Map<String, String>> getAllFilesForSync() async {
    final Map<String, String> files = {};
    // Reminders
    final reminders = await _db.select(_db.reminders).get();
    for(var r in reminders) {
      if (r.imagePath != null) files["images/${p.basename(r.imagePath!)}"] = r.imagePath!;
    }
    // SubReminders
    final subs = await _db.select(_db.subReminders).get();
    for(var s in subs) {
      if (s.imagePath != null) files["images/${p.basename(s.imagePath!)}"] = s.imagePath!;
    }
    // Storage Files
    final storageFiles = await _db.select(_db.storageFiles).get();
    for(var f in storageFiles) {
      files["storage/${p.basename(f.path)}"] = f.path;
    }
    return files;
  }

  Future<String?> _saveFile(String? sourcePath, String subDir) async {
    if (sourcePath == null) return null;
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) return sourcePath; // Fallback

      final appDir = await getApplicationDocumentsDirectory();
      final targetDir = Directory(p.join(appDir.path, subDir));
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      final filename = "${DateTime.now().millisecondsSinceEpoch}_${p.basename(sourcePath)}";
      final newPath = p.join(targetDir.path, filename);
      
      await sourceFile.copy(newPath);
      return newPath;
    } catch (e) {
      print("Error saving file: $e");
      return sourcePath;
    }
  }

  Future<String?> _saveImage(String? sourcePath) async {
    return _saveFile(sourcePath, 'images');
  }

  // --- Storage ---

  Future<List<StorageFolder>> getFolders(int? parentId) => _db.getFoldersIn(parentId);
  Future<List<StorageFile>> getFiles(int? folderId) => _db.getFilesIn(folderId);

  Stream<List<StorageFolder>> watchFolders(int? parentId) => _db.watchFoldersIn(parentId);
  Stream<List<StorageFile>> watchFiles(int? folderId) => _db.watchFilesIn(folderId);
  
  Future<void> addFolder(String name, int? parentId, [int? color]) async {
    await _db.insertFolder(StorageFoldersCompanion(
      name: drift.Value(name),
      parentId: drift.Value(parentId),
      color: drift.Value(color),
    ));
    notifyListeners();
  }

  Future<void> updateFolder(StorageFolder folder) async {
    await _db.updateFolder(folder);
    notifyListeners();
  }

  Future<void> moveFolderToFolder(int folderId, int? targetFolderId) async {
    // Avoid cyclic moves superficially by ensuring target is not the folder itself
    if (folderId == targetFolderId) return;
    
    final folder = await _db.getFolderById(folderId);
    await _db.updateFolder(folder.copyWith(parentId: drift.Value(targetFolderId)));
    notifyListeners();
  }

  Future<void> deleteFolder(int id) async {
    await _db.deleteFolder(id);
    notifyListeners();
  }

  Future<void> addFile(String name, String sourcePath, String type, int? folderId) async {
    final savedPath = await _saveFile(sourcePath, 'storage');
    if (savedPath != null) {
      final thumbPath = await _generateThumbnail(savedPath, type);
      await _db.insertFile(StorageFilesCompanion(
        name: drift.Value(name),
        path: drift.Value(savedPath),
        type: drift.Value(type),
        thumbnailPath: drift.Value(thumbPath),
        folderId: drift.Value(folderId),
      ));
      notifyListeners();
    }
  }

  Future<void> generateMissingThumbnails() async {
    final files = await _db.select(_db.storageFiles).get();
    bool updated = false;
    for (var f in files) {
      if (f.thumbnailPath == null || !await File(f.thumbnailPath!).exists()) {
        final thumbPath = await _generateThumbnail(f.path, f.type);
        if (thumbPath != null) {
          await _db.updateFile(f.copyWith(thumbnailPath: drift.Value(thumbPath)));
          updated = true;
        }
      }
    }
    if (updated) notifyListeners();
  }

  Future<String?> _generateThumbnail(String sourcePath, String type) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final thumbDir = Directory(p.join(appDir.path, 'storage', 'thumbnails'));
      if (!await thumbDir.exists()) {
        await thumbDir.create(recursive: true);
      }

      final fileName = "${DateTime.now().millisecondsSinceEpoch}_${p.basenameWithoutExtension(sourcePath)}";
      final thumbPath = p.join(thumbDir.path, "${fileName}_thumb.jpg");

      if (type == 'image') {
        final bytes = await File(sourcePath).readAsBytes();
        final image = img.decodeImage(bytes);
        if (image == null) return null;

        // Resize the image to a smaller version for the preview
        final thumbnail = img.copyResize(image, width: 250);
        await File(thumbPath).writeAsBytes(img.encodeJpg(thumbnail, quality: 75));
        return thumbPath;
      } else if (type == 'pdf') {
        final document = await PdfDocument.openFile(sourcePath);
        final page = await document.getPage(1);
        final pageImage = await page.render(
          width: page.width * 0.5,
          height: page.height * 0.5,
          format: PdfPageImageFormat.jpeg,
          quality: 75,
        );
        if (pageImage == null) return null;
        await File(thumbPath).writeAsBytes(pageImage.bytes);
        await page.close();
        await document.close();
        return thumbPath;
      }
    } catch (e) {
      print("Error generating thumbnail: $e");
    }
    return null;
  }

  Future<void> updateFile(StorageFile entry) => _db.updateFile(entry);

  Future<void> moveFileToFolder(int fileId, int? targetFolderId) async {
    final file = await _db.getFileById(fileId);
    await _db.updateFile(file.copyWith(folderId: drift.Value(targetFolderId)));
    notifyListeners();
  }

  Future<void> deleteFile(int id) async {
    final file = await _db.getFileById(id);
    try {
      final f = File(file.path);
      if (await f.exists()) await f.delete();
      
      if (file.thumbnailPath != null) {
        final t = File(file.thumbnailPath!);
        if (await t.exists()) await t.delete();
      }
    } catch (e) {
      print("Error deleting physical file: $e");
    }
    await _db.deleteFile(id);
    notifyListeners();
  }

  Future<List<FileComment>> getComments(int fileId) => _db.getCommentsForFile(fileId);
  
  Future<void> addComment(int fileId, String content) async {
    await _db.insertComment(FileCommentsCompanion(
      fileId: drift.Value(fileId),
      content: drift.Value(content),
    ));
    notifyListeners();
  }

  Future<void> deleteComment(int id) async {
    await _db.deleteComment(id);
    notifyListeners();
  }

  // Urgent Tasks (Sorted by Overdue -> Today -> Soon)
  List<Reminder> get urgentTasks {
    List<Reminder> all = [];
    for (var cat in _categories) {
      for (var r in cat.reminders) {
        if (!r.reminder.isCompleted && r.reminder.dueDate != null && !r.reminder.isEvent) {
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
  
  // Upcoming Events (Sorted by date)
  List<Reminder> get upcomingEvents {
    List<Reminder> all = [];
    for (var cat in _categories) {
      for (var r in cat.reminders) {
        if (!r.reminder.isCompleted && r.reminder.isEvent && r.reminder.dueDate != null) {
          all.add(r.reminder);
        }
      }
    }
    all.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    return all;
  }
  
  Future<void> _updateWidgets() async {
    await WidgetService.updateWidget(urgentTasks, upcomingEvents);
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

  void requestJumpToCategories() {
    _activeTab = 1; // Reminders Tab
    _pendingJumpRequest = {'categoryId': -1, 'reminderId': -1}; // Special code for just list view
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
    await _updateWidgets();
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

  // --- PocketBase Sync & Auth ---

  bool get isPbLoggedIn => pb.authStore.isValid;
  
  String? get pbUserEmail {
    final record = pb.authStore.record;
    if (record != null) {
      return record.getStringValue('email');
    }
    return null;
  }

  Future<void> loginPb(String email, String password) async {
    await pb.collection('users').authWithPassword(email, password);
    notifyListeners();
  }

  Future<void> logoutPb() async {
    pb.authStore.clear();
    notifyListeners();
  }

  bool _isSameDate(String pbDate, DateTime localDate) {
    try {
      final pd = DateTime.parse(pbDate).toUtc();
      final ld = localDate.toUtc();
      return pd.year == ld.year && pd.month == ld.month && pd.day == ld.day && 
             pd.hour == ld.hour && pd.minute == ld.minute && pd.second == ld.second;
    } catch (e) {
      return false;
    }
  }

  Future<void> syncToCloud() async {
    if (!isPbLoggedIn) return;
    
    final record = pb.authStore.record;
    if (record == null) return;
    final userId = record.id;

    // Fetch existing logs
    final records = await pb.collection('fitness_logs').getFullList(
      filter: 'user = "$userId"',
    );

    // Keep track of which PB records we've already matched to avoid double-syncing
    final syncedIds = <String>{};

    // Sync Gym logs
    final gymLogs = await _db.getGymLogs();
    for (var gl in gymLogs) {
      final existing = records.where((r) => 
        !syncedIds.contains(r.id) &&
        r.getStringValue('type') == 'gym' && 
        _isSameDate(r.getStringValue('date'), gl.log.date) &&
        r.getDoubleValue('weight') == gl.log.weight &&
        r.getIntValue('reps') == gl.log.reps
      ).firstOrNull;

      if (existing != null) {
        syncedIds.add(existing.id);
        // Only update the name field if it's different/missing
        if (existing.getStringValue('exercise_name') != gl.exercise.name) {
          await pb.collection('fitness_logs').update(existing.id, body: {
            'exercise_name': gl.exercise.name,
          });
        }
      } else {
        await pb.collection('fitness_logs').create(body: {
          'user': userId,
          'type': 'gym',
          'date': gl.log.date.toUtc().toIso8601String(),
          'exercise_name': gl.exercise.name,
          'weight': gl.log.weight,
          'reps': gl.log.reps,
          'sets': gl.log.sets,
        });
      }
    }

    // Sync Weight logs
    final weightLogs = await _db.getAllWeightLogs();
    for (var wl in weightLogs) {
      final existing = records.where((r) => 
        !syncedIds.contains(r.id) &&
        r.getStringValue('type') == 'weight' && 
        _isSameDate(r.getStringValue('date'), wl.date) &&
        r.getDoubleValue('weight') == wl.weight
      ).firstOrNull;

      if (existing != null) {
        syncedIds.add(existing.id);
        if (existing.getStringValue('exercise_name') != 'Weight') {
          await pb.collection('fitness_logs').update(existing.id, body: {
            'exercise_name': 'Weight',
          });
        }
      } else {
        await pb.collection('fitness_logs').create(body: {
          'user': userId,
          'type': 'weight',
          'date': wl.date.toUtc().toIso8601String(),
          'exercise_name': 'Weight',
          'weight': wl.weight,
          'body_fat': wl.bodyFat ?? 0.0,
        });
      }
    }

    // Sync Nutrition logs
    final nutritionLogs = await _db.getAllNutritionLogs();
    for (var nl in nutritionLogs) {
      final localName = nl.foodName ?? 'Nutrition';
      final existing = records.where((r) => 
        !syncedIds.contains(r.id) &&
        r.getStringValue('type') == 'nutrition' && 
        _isSameDate(r.getStringValue('date'), nl.date) &&
        r.getIntValue('calories') == nl.calories &&
        r.getIntValue('protein') == nl.protein &&
        r.getIntValue('carbs') == nl.carbs
      ).firstOrNull;

      if (existing != null) {
        syncedIds.add(existing.id);
        if (existing.getStringValue('exercise_name') != localName) {
          await pb.collection('fitness_logs').update(existing.id, body: {
            'exercise_name': localName,
          });
        }
      } else {
        await pb.collection('fitness_logs').create(body: {
          'user': userId,
          'type': 'nutrition',
          'date': nl.date.toUtc().toIso8601String(),
          'exercise_name': localName,
          'calories': nl.calories,
          'protein': nl.protein,
          'carbs': nl.carbs,
        });
      }
    }
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
    await _updateWidgets();
    notifyListeners();
  }

  Future<void> updateCategory(Category category) async {
    await _db.updateCategory(category);
    await _loadCategories();
    await _updateWidgets();
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
    await _updateWidgets();
    notifyListeners();
  }

  Future<void> deleteCategory(int id) async {
    await _db.deleteCategory(id);
    await _loadCategories();
    await _updateWidgets();
    notifyListeners();
  }

  Future<void> addReminder(int categoryId, String title, {String? imagePath, DateTime? dueDate, DateTime? endDate, bool isEvent = false, String recurrence = 'none', int? color}) async {
    // Find current max order index for this category to append at the end
    int nextOrder = 0;
    final category = _categories.firstWhereOrNull((c) => c.category.id == categoryId);
    if (category != null && category.reminders.isNotEmpty) {
       nextOrder = category.reminders.length;
    }

    final savedImagePath = await _saveImage(imagePath);

    await _db.insertReminder(RemindersCompanion(
      categoryId: drift.Value(categoryId),
      title: drift.Value(title),
      imagePath: drift.Value(savedImagePath),
      orderIndex: drift.Value(nextOrder),
      dueDate: drift.Value(dueDate),
      endDate: drift.Value(endDate),
      isEvent: drift.Value(isEvent),
      recurrence: drift.Value(recurrence),
      color: drift.Value(color),
    ));
    await _loadCategories();
    await _updateWidgets();
    notifyListeners();
  }

  Future<void> addEvent(int categoryId, String title, DateTime start, DateTime end, {String recurrence = 'none', int? color}) async {
    await addReminder(categoryId, title, dueDate: start, endDate: end, isEvent: true, recurrence: recurrence, color: color);
  }

  Future<void> updateReminder(Reminder reminder) async {
    String? finalPath = reminder.imagePath;
    if (finalPath != null) {
       // Check if it's already in our managed directory
       final appDir = await getApplicationDocumentsDirectory();
       final imagesDir = Directory(p.join(appDir.path, 'images'));
       if (!finalPath.startsWith(imagesDir.path)) {
          finalPath = await _saveImage(finalPath);
       }
    }

    await _db.updateReminder(reminder.copyWith(imagePath: drift.Value(finalPath)));
    await _loadCategories();
    await _updateWidgets();
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
    await _updateWidgets();
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
        await _updateWidgets();
        notifyListeners();
    }
  }

  Future<void> deleteReminder(int id) async {
    await _db.deleteReminder(id);
    await _loadCategories();
    await _updateWidgets();
    notifyListeners();
  }

  Future<void> addSubReminder(int reminderId, String title, {String? imagePath}) async {
    final savedPath = await _saveImage(imagePath);
    await _db.insertSubReminder(SubRemindersCompanion(
      reminderId: drift.Value(reminderId),
      title: drift.Value(title),
      imagePath: drift.Value(savedPath),
    ));
    await _loadCategories();
    await _updateWidgets();
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
    await _updateWidgets();
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

  Future<void> addNutritionLog(int calories, int protein, int carbs, DateTime date, {String? foodName}) async {
    await _db.insertNutritionLog(NutritionLogsCompanion(
        date: drift.Value(date),
        calories: drift.Value(calories),
        protein: drift.Value(protein),
        carbs: drift.Value(carbs),
        foodName: drift.Value(foodName),
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

  // --- Food Items (Barcode) ---

  Future<FoodItem?> getFoodByBarcode(String barcode) => _db.getFoodByBarcode(barcode);
  Future<List<FoodItem>> getAllFoodItems() => _db.getAllFoodItems();

  Future<void> addFoodItem({
    required String barcode,
    required String name,
    required double caloriesPer100g,
    required double proteinPer100g,
    required double carbsPer100g,
    double lastPortion = 100.0,
  }) async {
    await _db.insertFoodItem(FoodItemsCompanion(
      barcode: drift.Value(barcode),
      name: drift.Value(name),
      caloriesPer100g: drift.Value(caloriesPer100g),
      proteinPer100g: drift.Value(proteinPer100g),
      carbsPer100g: drift.Value(carbsPer100g),
      lastPortion: drift.Value(lastPortion),
    ));
    notifyListeners();
  }

  Future<void> updateLastPortion(int foodId, double portion) async {
    final food = await _db.getFoodById(foodId);
    await _db.updateFoodItem(food.copyWith(lastPortion: portion));
    notifyListeners();
  }

  Future<void> updateFoodItem(FoodItem food) async {
    await _db.updateFoodItem(food);
    notifyListeners();
  }

  Future<void> deleteFoodItem(int id) async {
    await _db.deleteFoodItem(id);
    notifyListeners();
  }
}
