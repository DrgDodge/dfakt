import 'package:home_widget/home_widget.dart';
import '../database/database.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class WidgetService {
  static const String _androidWidgetName = 'PriorityTasksWidget';

  static Future<void> updateWidget(List<Reminder> urgentTasks) async {
    // Convert tasks to a JSON string for the native side to parse
    final List<Map<String, String>> taskData = urgentTasks.take(10).map((t) => {
      'title': t.title,
      'date': DateFormat.MMMd().format(t.dueDate!),
      'isEvent': t.isEvent.toString(),
    }).toList();

    await HomeWidget.saveWidgetData<String>('tasks_json', jsonEncode(taskData));

    await HomeWidget.updateWidget(
      name: _androidWidgetName,
      iOSName: 'TasksWidget',
    );
  }
}
