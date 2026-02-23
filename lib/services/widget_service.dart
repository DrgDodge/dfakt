import 'package:home_widget/home_widget.dart';
import '../database/database.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';

class WidgetService {
  static const String _tasksWidgetName = 'PriorityTasksWidget';
  static const String _eventsWidgetName = 'EventsWidget';

  static Future<void> updateWidget(List<Reminder> urgentTasks, List<Reminder> upcomingEvents) async {
    // home_widget only supports Android and iOS
    if (!Platform.isAndroid && !Platform.isIOS) return;

    try {
      // 1. Update Tasks Widget
      final List<Map<String, String>> taskData = urgentTasks.take(10).map((t) => {
        'id': t.id.toString(),
        'categoryId': t.categoryId.toString(),
        'title': t.title,
        'date': DateFormat.MMMd().format(t.dueDate!),
        'isEvent': 'false', // Always false now
        'color': (t.color ?? 0xFF448AFF).toString(),
      }).toList();

      await HomeWidget.saveWidgetData<String>('tasks_json', jsonEncode(taskData));

      await HomeWidget.updateWidget(
        name: _tasksWidgetName,
        iOSName: 'TasksWidget',
      );
      
      // 2. Update Events Widget
      final List<Map<String, String>> eventData = upcomingEvents.take(10).map((t) => {
        'id': t.id.toString(),
        'categoryId': t.categoryId.toString(),
        'title': t.title,
        'date': DateFormat.MMMd().format(t.dueDate!),
        'color': (t.color ?? 0xFF80CBC4).toString(),
      }).toList();

      await HomeWidget.saveWidgetData<String>('events_json', jsonEncode(eventData));

      await HomeWidget.updateWidget(
        name: _eventsWidgetName,
        iOSName: 'EventsWidget',
      );
    } catch (e) {
      print("Error updating home widget: $e");
    }
  }
}
