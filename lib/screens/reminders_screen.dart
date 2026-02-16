import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:drift/drift.dart' as drift;
import 'package:collection/collection.dart';
import '../providers/app_provider.dart';
import '../database/database.dart';
import '../widgets/ui_helpers.dart';
import 'settings_screen.dart';

enum AgendaViewMode { month, week, day, list }

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> with TickerProviderStateMixin {
  final ScrollController _timelineScrollController = ScrollController();
  final ScrollController _listScrollController = ScrollController();
  
  // Calendar State
  AgendaViewMode _viewMode = AgendaViewMode.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Task List State
  final Map<int, bool> _expandedCategories = {};
  int? _highlightedReminderId;
  final Map<int, GlobalKey> _categoryKeys = {};
  
  // Day View States
  bool _tasksExpanded = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // Scroll to 8:00 AM by default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_timelineScrollController.hasClients) {
        _timelineScrollController.jumpTo(8 * 60.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _viewMode == AgendaViewMode.month,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _viewMode != AgendaViewMode.month) {
          setState(() => _viewMode = AgendaViewMode.month);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _viewMode == AgendaViewMode.list ? 'Categories' : DateFormat.yMMMM().format(_focusedDay),
              key: ValueKey(_focusedDay.month + (_viewMode.index * 100)),
            ),
          ),
          leading: _viewMode != AgendaViewMode.month && _viewMode != AgendaViewMode.list
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _viewMode = AgendaViewMode.month))
            : null,
          actions: [
            _buildViewModeToggle(),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              ),
            )
          ],
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          switchInCurve: Curves.easeInOutCubic,
          switchOutCurve: Curves.easeInOutCubic,
          transitionBuilder: (Widget child, Animation<double> animation) {
            if (child.key == const ValueKey(AgendaViewMode.day) || child.key == const ValueKey(AgendaViewMode.week)) {
              return ScaleTransition(scale: animation, child: FadeTransition(opacity: animation, child: child));
            }
            return FadeTransition(opacity: animation, child: child);
          },
          child: _buildBody(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddOptions(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildViewModeToggle() {
    IconData icon;
    switch (_viewMode) {
      case AgendaViewMode.month: icon = Icons.calendar_view_month; break;
      case AgendaViewMode.week: icon = Icons.calendar_view_week; break;
      case AgendaViewMode.day: icon = Icons.calendar_view_day; break;
      case AgendaViewMode.list: icon = Icons.format_list_bulleted; break;
    }

    return PopupMenuButton<AgendaViewMode>(
      icon: Icon(icon, color: const Color(0xFF80CBC4)),
      onSelected: (mode) => setState(() => _viewMode = mode),
      itemBuilder: (context) => [
        const PopupMenuItem(value: AgendaViewMode.month, child: Text('Monthly')),
        const PopupMenuItem(value: AgendaViewMode.week, child: Text('Weekly')),
        const PopupMenuItem(value: AgendaViewMode.day, child: Text('Daily')),
        const PopupMenuItem(value: AgendaViewMode.list, child: Text('List / Categories')),
      ],
    );
  }

  Widget _buildBody() {
    switch (_viewMode) {
      case AgendaViewMode.month:
        return _buildMonthlyView(key: const ValueKey(AgendaViewMode.month));
      case AgendaViewMode.week:
        return _buildTimelineView(isWeek: true, key: const ValueKey(AgendaViewMode.week));
      case AgendaViewMode.day:
        return _buildTimelineView(isWeek: false, key: const ValueKey(AgendaViewMode.day));
      case AgendaViewMode.list:
        return _buildCategoryListView(context, key: const ValueKey(AgendaViewMode.list));
    }
  }

  // --- MONTHLY VIEW ---
  Widget _buildMonthlyView({required Key key}) {
    final provider = Provider.of<AppProvider>(context);
    final allItems = provider.categories.expand((c) => c.reminders.map((r) => r.reminder)).toList();

    return TableCalendar(
      key: key,
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: CalendarFormat.month,
      shouldFillViewport: true,
      headerVisible: false,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
          _viewMode = AgendaViewMode.day;
        });
      },
      onPageChanged: (focusedDay) => setState(() => _focusedDay = focusedDay),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          final dayItems = allItems.where((r) {
            if (r.dueDate == null) return false;
            if (r.isEvent && r.endDate != null) {
              final start = DateTime(r.dueDate!.year, r.dueDate!.month, r.dueDate!.day);
              final end = DateTime(r.endDate!.year, r.endDate!.month, r.endDate!.day);
              return (day.isAfter(start) || isSameDay(day, start)) && 
                     (day.isBefore(end) || isSameDay(day, end));
            }
            return isSameDay(r.dueDate!, day);
          }).toList();
          
          if (dayItems.isEmpty) return null;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: dayItems.take(4).map((t) {
              bool isStart = t.isEvent && t.endDate != null && isSameDay(day, t.dueDate!);
              bool isEnd = t.isEvent && t.endDate != null && isSameDay(day, t.endDate!);

              return Container(
                margin: EdgeInsets.only(
                  left: isStart || !t.isEvent ? 2 : 0,
                  right: isEnd || !t.isEvent ? 2 : 0,
                  top: 0.5,
                  bottom: 0.5
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: (t.isEvent ? const Color(0xFF80CBC4) : Colors.blueAccent).withOpacity(0.8),
                  borderRadius: BorderRadius.horizontal(
                    left: isStart || !t.isEvent ? const Radius.circular(4) : Radius.zero,
                    right: isEnd || !t.isEvent ? const Radius.circular(4) : Radius.zero,
                  ),
                ),
                child: Text(
                  isStart || !t.isEvent || day.weekday == 1 ? t.title : "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
          );
        },
        todayBuilder: (context, day, focusedDay) => _buildDayCell(day, isToday: true),
        defaultBuilder: (context, day, focusedDay) => _buildDayCell(day),
        selectedBuilder: (context, day, focusedDay) => _buildDayCell(day, isSelected: true),
      ),
    );
  }

  Widget _buildDayCell(DateTime day, {bool isToday = false, bool isSelected = false}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white10, width: 0.5),
        color: isSelected ? const Color(0xFF80CBC4).withOpacity(0.1) : null,
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: isToday ? const BoxDecoration(color: Color(0xFF80CBC4), shape: BoxShape.circle) : null,
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: isToday ? Colors.black : (isSelected ? const Color(0xFF80CBC4) : Colors.white),
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- TIMELINE VIEW ---
  Widget _buildTimelineView({required bool isWeek, required Key key}) {
    final provider = Provider.of<AppProvider>(context);
    final days = isWeek 
      ? List.generate(7, (i) {
          final firstDayOfWeek = _focusedDay.subtract(Duration(days: _focusedDay.weekday - 1));
          return firstDayOfWeek.add(Duration(days: i));
        })
      : [_focusedDay];

    return Column(
      key: key,
      children: [
        // Days Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: const BoxDecoration(color: Color(0xFF1E1E1E), border: Border(bottom: BorderSide(color: Colors.white10))),
          child: Row(
            children: [
              const SizedBox(width: 60),
              ...days.map((d) => Expanded(
                child: Column(
                  children: [
                    Text(DateFormat('E').format(d), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: isSameDay(d, DateTime.now()) ? const BoxDecoration(color: Color(0xFF80CBC4), shape: BoxShape.circle) : null,
                      child: Text('${d.day}', style: TextStyle(fontWeight: FontWeight.bold, color: isSameDay(d, DateTime.now()) ? Colors.black : Colors.white)),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
        // Sections
        Expanded(
          child: Column(
            children: [
              _buildTopSection(days, provider),
              const Divider(height: 1, color: Colors.white24),
              Expanded(
                child: SingleChildScrollView(
                  controller: _timelineScrollController,
                  child: _buildTimelineGrid(days, provider, isWeek),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopSection(List<DateTime> days, AppProvider provider) {
    // Multi-day events and tasks
    final allMultiDayEvents = days.expand((d) => provider.categories
        .expand((c) => c.reminders)
        .where((r) => r.reminder.isEvent && r.reminder.dueDate != null && r.reminder.endDate != null && 
               r.reminder.endDate!.difference(r.reminder.dueDate!).inHours > 24)
        .where((r) {
          final start = DateTime(r.reminder.dueDate!.year, r.reminder.dueDate!.month, r.reminder.dueDate!.day);
          final end = DateTime(r.reminder.endDate!.year, r.reminder.endDate!.month, r.reminder.endDate!.day);
          return (d.isAfter(start) || isSameDay(d, start)) && (d.isBefore(end) || isSameDay(d, end));
        })
    ).toSet().toList();

    final allTasks = days.expand((d) => provider.categories
        .expand((c) => c.reminders)
        .where((r) => !r.reminder.isEvent && r.reminder.dueDate != null && isSameDay(r.reminder.dueDate!, d))
    ).toSet().toList();

    return Container(
      color: Colors.black12,
      child: Column(
        children: [
          // Tidy Task List
          if (allTasks.isNotEmpty)
            Column(
              children: [
                ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  title: Text("${allTasks.length} Tasks", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                  trailing: Icon(_tasksExpanded ? Icons.expand_less : Icons.expand_more, size: 16),
                  onTap: () => setState(() => _tasksExpanded = !_tasksExpanded),
                ),
                if (_tasksExpanded)
                   ...allTasks.map((t) => Padding(
                     padding: const EdgeInsets.only(left: 60),
                     child: _buildCompactReminderTile(t),
                   )),
              ],
            ),
          
          // Multi-day Events
          if (allMultiDayEvents.isNotEmpty)
            Row(
              children: [
                const SizedBox(width: 60, child: Center(child: Icon(Icons.event, size: 14, color: Color(0xFF80CBC4)))),
                ...days.map((d) {
                  final eventsForDay = allMultiDayEvents.where((r) {
                    final start = DateTime(r.reminder.dueDate!.year, r.reminder.dueDate!.month, r.reminder.dueDate!.day);
                    final end = DateTime(r.reminder.endDate!.year, r.reminder.endDate!.month, r.reminder.endDate!.day);
                    return (d.isAfter(start) || isSameDay(d, start)) && (d.isBefore(end) || isSameDay(d, end));
                  }).toList();

                  return Expanded(
                    child: Column(
                      children: eventsForDay.map((e) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        width: double.infinity,
                        decoration: BoxDecoration(color: const Color(0xFF80CBC4).withOpacity(0.8), borderRadius: BorderRadius.circular(4)),
                        child: Text(e.reminder.title, style: const TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      )).toList(),
                    ),
                  );
                }),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCompactReminderTile(ReminderWithSubs data) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: Checkbox(
        value: data.reminder.isCompleted,
        onChanged: (val) => Provider.of<AppProvider>(context, listen: false).toggleReminderCompletion(data.reminder.id, val ?? false),
        activeColor: Colors.blueAccent,
      ),
      title: Text(
        data.reminder.title,
        style: TextStyle(
          fontSize: 14,
          decoration: data.reminder.isCompleted ? TextDecoration.lineThrough : null,
          color: data.reminder.isCompleted ? Colors.grey : Colors.white,
        ),
      ),
      onTap: () => _showReminderDetails(data),
    );
  }

  Widget _buildTimelineGrid(List<DateTime> days, AppProvider provider, bool isWeek) {
    return SizedBox(
      height: 24 * 60.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Stack(
              children: List.generate(24, (i) => Positioned(
                top: i * 60.0 - 7,
                left: 0,
                right: 8,
                child: Text(
                  DateFormat('HH:mm').format(DateTime(2024, 1, 1, i)),
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
              )),
            ),
          ),
          ...days.map((d) => Expanded(
            child: Container(
              decoration: const BoxDecoration(border: Border(left: BorderSide(color: Colors.white10))),
              child: Stack(
                children: [
                  ...List.generate(24, (i) => Positioned(
                    top: i * 60.0,
                    left: 0,
                    right: 0,
                    child: const Divider(height: 1, color: Colors.white10),
                  )),
                  ..._buildTimedEvents(d, provider, isWeek),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  List<Widget> _buildTimedEvents(DateTime day, AppProvider provider, bool isWeek) {
    final events = provider.categories
        .expand((c) => c.reminders)
        .where((r) => r.reminder.isEvent && r.reminder.dueDate != null)
        .where((r) {
          // Only show single-day events (duration <= 24h) on the grid
          if (r.reminder.endDate != null && r.reminder.endDate!.difference(r.reminder.dueDate!).inHours > 24) {
             return false;
          }
          return isSameDay(r.reminder.dueDate!, day);
        })
        .toList();

    return events.map((data) {
      final r = data.reminder;
      final start = r.dueDate!;
      final end = r.endDate ?? start.add(const Duration(hours: 1));
      
      final top = (start.hour * 60.0) + (start.minute);
      final height = end.difference(start).inMinutes.toDouble();

      return Positioned(
        top: top,
        left: 2,
        right: 2,
        height: height.clamp(20.0, 1440.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showReminderDetails(data),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF80CBC4).withOpacity(0.9),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.title, style: const TextStyle(fontSize: 11, color: Colors.black, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (height > 30 && !isWeek)
                    Text("${DateFormat.Hm().format(start)} - ${DateFormat.Hm().format(end)}", style: const TextStyle(fontSize: 9, color: Colors.black87)),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  void _showReminderDetails(ReminderWithSubs data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                _ReminderTile(
                  key: ValueKey("details-${data.reminder.id}"),
                  categoryId: data.reminder.categoryId,
                  reminderData: data,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Category List View ---
  Widget _buildCategoryListView(BuildContext context, {required Key key}) {
    final provider = Provider.of<AppProvider>(context);
    final upcoming = provider.upcomingReminders;

    return Column(
      key: key,
      children: [
        Expanded(
          child: ReorderableListView.builder(
            scrollController: _listScrollController,
            itemCount: provider.categories.length,
            onReorder: (oldIndex, newIndex) => provider.reorderCategories(oldIndex, newIndex),
            itemBuilder: (context, index) {
              final categoryData = provider.categories[index];
              final category = categoryData.category;
              if (!_categoryKeys.containsKey(category.id)) _categoryKeys[category.id] = GlobalKey();
              final isExpanded = _expandedCategories[category.id] ?? false;

              return Card(
                key: ValueKey(category.id),
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    ListTile(
                      key: _categoryKeys[category.id],
                      leading: const Icon(Icons.drag_handle, color: Colors.grey),
                      title: GestureDetector(
                        onLongPress: () => _showEditCategoryDialog(context, provider, category),
                        child: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: AnimatedRotation(
                              turns: isExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 300),
                              child: const Icon(Icons.expand_more),
                            ),
                            onPressed: () => setState(() => _expandedCategories[category.id] = !isExpanded),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') _showEditCategoryDialog(context, provider, category);
                              else if (value == 'delete') _confirmDeleteCategory(context, provider, category.id);
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'edit', child: Text('Edit')),
                              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        ],
                      ),
                      onTap: () => setState(() => _expandedCategories[category.id] = !isExpanded),
                    ),
                    AnimatedCrossFade(
                      firstChild: const SizedBox(width: double.infinity),
                      secondChild: Column(
                        children: [
                          if (categoryData.reminders.isEmpty)
                            const Padding(padding: EdgeInsets.all(16.0), child: Text("No items", style: TextStyle(color: Colors.grey)))
                          else
                            ReorderableListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: categoryData.reminders.length,
                                onReorder: (oldIndex, newIndex) => provider.reorderReminders(category.id, oldIndex, newIndex),
                                itemBuilder: (context, rIndex) {
                                   final reminderData = categoryData.reminders[rIndex];
                                   return _ReminderTile(
                                      key: ValueKey(reminderData.reminder.id),
                                      categoryId: category.id,
                                      reminderData: reminderData,
                                      isHighlighted: _highlightedReminderId == reminderData.reminder.id,
                                   );
                                },
                             ),
                           ListTile(
                             leading: const Icon(Icons.add_circle, color: Color(0xFF80CBC4)),
                             title: const Text('Add Task', style: TextStyle(color: Color(0xFF80CBC4))),
                             onTap: () => _showAddReminderDialog(context, category.id),
                           ),
                        ],
                      ),
                      crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                    )
                  ],
                ),
              );
            },
          ),
        ),
        if (upcoming.isNotEmpty) _buildUpcomingBar(upcoming),
      ],
    );
  }

  Widget _buildUpcomingBar(List<Reminder> upcoming) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Upcoming Items", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF80CBC4))),
          const SizedBox(height: 12),
          ...upcoming.take(3).map((r) => InkWell(
            onTap: () => _jumpToReminder(r.categoryId, r.id),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Text(DateFormat.MMMd().format(r.dueDate!), style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  Icon(r.isEvent ? Icons.event : Icons.task_alt, size: 18, color: const Color(0xFF80CBC4)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(r.title, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16))),
                ],
              ),
            ),
          ))
        ],
      ),
    );
  }

  // --- ACTIONS & DIALOGS ---

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
          ListTile(leading: const Icon(Icons.category, color: Color(0xFF80CBC4)), title: const Text("New Category"), onTap: () { Navigator.pop(context); _showAddCategoryDialog(context); }),
          ListTile(leading: const Icon(Icons.task_alt, color: Color(0xFF80CBC4)), title: const Text("New Task"), onTap: () { Navigator.pop(context); _showAddReminderDialog(context, null); }),
          ListTile(leading: const Icon(Icons.event, color: Color(0xFF80CBC4)), title: const Text("New Event"), onTap: () { Navigator.pop(context); _showAddEventDialog(context); }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _jumpToReminder(int categoryId, int reminderId) {
    setState(() {
      _viewMode = AgendaViewMode.list;
      _expandedCategories[categoryId] = true;
      _highlightedReminderId = reminderId;
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      final key = _categoryKeys[categoryId];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(key!.currentContext!, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
      }
    });
    Future.delayed(const Duration(seconds: 2), () { if (mounted) setState(() => _highlightedReminderId = null); });
  }

  void _confirmDeleteCategory(BuildContext context, AppProvider provider, int id) {
    showDialog(context: context, builder: (ctx) => StyledDialog(
      title: 'Delete Category?',
      content: const Text('This will delete all items inside it.'),
      onCancel: () => Navigator.pop(ctx),
      onSave: () { provider.deleteCategory(id); Navigator.pop(ctx); },
      saveText: 'Delete',
    ));
  }

  void _showAddCategoryDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(context: context, builder: (context) => StyledDialog(title: 'Add Category', content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Category Name'), autofocus: true), onCancel: () => Navigator.pop(context), onSave: () { if (controller.text.isNotEmpty) { Provider.of<AppProvider>(context, listen: false).addCategory(controller.text); Navigator.pop(context); } }));
  }

  void _showEditCategoryDialog(BuildContext context, AppProvider provider, Category category) {
    final controller = TextEditingController(text: category.name);
    showDialog(context: context, builder: (context) => StyledDialog(title: 'Edit Category', content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Category Name'), autofocus: true), onCancel: () => Navigator.pop(context), onSave: () { if (controller.text.isNotEmpty) { provider.updateCategory(category.copyWith(name: controller.text)); Navigator.pop(context); } }));
  }

  void _showAddReminderDialog(BuildContext context, int? categoryId) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final controller = TextEditingController();
    String? pickedImagePath;
    DateTime? selectedDate = _selectedDay;
    String selectedRecurrence = 'none';
    int? selectedCategoryId = categoryId ?? (provider.categories.isNotEmpty ? provider.categories.first.category.id : null);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => StyledDialog(
          title: 'Add Task',
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (provider.categories.isEmpty) const Text("Please add a category first.") else ...[
                  DropdownButton<int>(value: selectedCategoryId, isExpanded: true, dropdownColor: const Color(0xFF2C2C2C), items: provider.categories.map((c) => DropdownMenuItem(value: c.category.id, child: Text(c.category.name))).toList(), onChanged: (val) => setState(() => selectedCategoryId = val)),
                  TextField(controller: controller, decoration: const InputDecoration(labelText: 'Task Title'), autofocus: true),
                  const SizedBox(height: 16),
                  DropdownButton<String>(
                    value: selectedRecurrence,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF2C2C2C),
                    items: ['none', 'daily', 'weekly', 'monthly'].map((r) => DropdownMenuItem(value: r, child: Text("Recurrence: $r"))).toList(),
                    onChanged: (val) => setState(() => selectedRecurrence = val!),
                  ),
                  const SizedBox(height: 16),
                  Row(children: [Text(selectedDate == null ? 'No Date' : DateFormat.yMMMd().format(selectedDate!)), const Spacer(), TextButton(onPressed: () async { final picked = await showDatePicker(context: context, initialDate: selectedDate ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100)); if (picked != null) setState(() => selectedDate = picked); }, child: const Text('Set Date', style: TextStyle(color: Color(0xFF80CBC4))))]),
                  if (pickedImagePath != null) SizedBox(height: 100, child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(pickedImagePath!), fit: BoxFit.cover))),
                  TextButton.icon(onPressed: () async { final picked = await ImagePicker().pickImage(source: ImageSource.gallery); if (picked != null) setState(() => pickedImagePath = picked.path); }, icon: const Icon(Icons.image, color: Color(0xFF80CBC4)), label: const Text('Add Image', style: TextStyle(color: Color(0xFF80CBC4))))
                ]
              ],
            ),
          ),
          onCancel: () => Navigator.pop(context),
          onSave: () { if (controller.text.isNotEmpty && selectedCategoryId != null) { provider.addReminder(selectedCategoryId!, controller.text, imagePath: pickedImagePath, dueDate: selectedDate, recurrence: selectedRecurrence); Navigator.pop(context); } },
        ),
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final titleController = TextEditingController();
    DateTime startDate = _selectedDay ?? DateTime.now();
    DateTime endDate = startDate.add(const Duration(hours: 2));
    TimeOfDay startTime = TimeOfDay.fromDateTime(startDate);
    TimeOfDay endTime = TimeOfDay.fromDateTime(endDate);
    int? selectedCategoryId = provider.categories.isNotEmpty ? provider.categories.first.category.id : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => StyledDialog(
          title: "Add Event",
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (provider.categories.isEmpty) const Text("Please add a category first.") else ...[
                  DropdownButton<int>(value: selectedCategoryId, isExpanded: true, dropdownColor: const Color(0xFF2C2C2C), items: provider.categories.map((c) => DropdownMenuItem(value: c.category.id, child: Text(c.category.name))).toList(), onChanged: (val) => setState(() => selectedCategoryId = val)),
                  TextField(controller: titleController, decoration: const InputDecoration(labelText: "Event Name")),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text("Start Date"),
                    subtitle: Text(DateFormat.yMMMd().format(startDate)),
                    onTap: () async {
                      final picked = await showDatePicker(context: context, initialDate: startDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
                      if (picked != null) setState(() => startDate = picked);
                    },
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Start Time:"), TextButton(onPressed: () async { final picked = await showTimePicker(context: context, initialTime: startTime); if (picked != null) setState(() => startTime = picked); }, child: Text(startTime.format(context)))]),
                  ListTile(
                    title: const Text("End Date"),
                    subtitle: Text(DateFormat.yMMMd().format(endDate)),
                    onTap: () async {
                      final picked = await showDatePicker(context: context, initialDate: endDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
                      if (picked != null) setState(() => endDate = picked);
                    },
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("End Time:"), TextButton(onPressed: () async { final picked = await showTimePicker(context: context, initialTime: endTime); if (picked != null) setState(() => endTime = picked); }, child: Text(endTime.format(context)))]),
                ]
              ],
            ),
          ),
          onCancel: () => Navigator.pop(context),
          onSave: () { 
            if (titleController.text.isNotEmpty && selectedCategoryId != null) { 
              final start = DateTime(startDate.year, startDate.month, startDate.day, startTime.hour, startTime.minute);
              final end = DateTime(endDate.year, endDate.month, endDate.day, endTime.hour, endTime.minute);
              provider.addEvent(selectedCategoryId!, titleController.text, start, end); 
              Navigator.pop(context); 
            } 
          },
        ),
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final int categoryId;
  final ReminderWithSubs reminderData;
  final bool isHighlighted;

  const _ReminderTile({required Key key, required this.categoryId, required this.reminderData, this.isHighlighted = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final reminder = reminderData.reminder;
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(color: isHighlighted ? const Color(0xFFFFF9C4).withOpacity(0.1) : null, borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        controlAffinity: ListTileControlAffinity.leading,
        shape: const Border(),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reminder.title, style: TextStyle(decoration: reminder.isCompleted ? TextDecoration.lineThrough : null, color: reminder.isCompleted ? Colors.grey : null, fontWeight: FontWeight.w500)),
                  if (reminder.isEvent) Text("${DateFormat.Hm().format(reminder.dueDate!)} - ${DateFormat.Hm().format(reminder.endDate ?? reminder.dueDate!.add(const Duration(hours: 1)))}", style: TextStyle(fontSize: 12, color: theme.colorScheme.primary.withOpacity(0.7)))
                  else if (reminder.dueDate != null) Text(DateFormat.yMMMd().format(reminder.dueDate!), style: TextStyle(fontSize: 12, color: theme.colorScheme.primary.withOpacity(0.7))),
                  if (reminder.recurrence != 'none') Text("Recurrence: ${reminder.recurrence}", style: const TextStyle(fontSize: 10, color: Color(0xFF80CBC4))),
                ],
              ),
            ),
            if (reminder.imagePath != null)
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
                 child: GestureDetector(
                   onTap: () => showDialog(context: context, builder: (ctx) => Dialog(child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(File(reminder.imagePath!))))),
                   child: CircleAvatar(backgroundImage: FileImage(File(reminder.imagePath!)), radius: 18),
                 ),
               )
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(value: reminder.isCompleted, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), activeColor: theme.colorScheme.primary, onChanged: (val) => provider.toggleReminderCompletion(reminder.id, val ?? false)),
            PopupMenuButton<String>(icon: const Icon(Icons.more_vert, color: Colors.grey), onSelected: (value) { if (value == 'edit') _showEditReminderDialog(context, provider, reminder); else if (value == 'delete') provider.deleteReminder(reminder.id); }, itemBuilder: (context) => [const PopupMenuItem(value: 'edit', child: Text('Edit')), const PopupMenuItem(value: 'delete', child: Text('Delete'))]),
          ],
        ),
        children: [
          ...reminderData.subs.map((sub) => ListTile(
                contentPadding: const EdgeInsets.only(left: 16, right: 16),
                leading: const Icon(Icons.subdirectory_arrow_right_rounded, size: 20, color: Colors.grey),
                title: Row(
                  children: [
                     Expanded(child: Text(sub.title, style: TextStyle(decoration: sub.isCompleted ? TextDecoration.lineThrough : null, color: sub.isCompleted ? Colors.grey : null, fontSize: 15))),
                     if (sub.imagePath != null) GestureDetector(onTap: () => showDialog(context: context, builder: (ctx) => Dialog(child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(File(sub.imagePath!))))), child: CircleAvatar(backgroundImage: FileImage(File(sub.imagePath!)), radius: 12))
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(value: sub.isCompleted, onChanged: (val) => provider.toggleSubReminderCompletion(sub.id, val ?? false)),
                    IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey), onPressed: () => provider.deleteSubReminder(sub.id)),
                  ],
                ),
              )),
          ListTile(contentPadding: const EdgeInsets.only(left: 40.0), leading: Icon(Icons.add_circle_outline, size: 22, color: theme.colorScheme.primary), title: Text('Add Sub-task', style: TextStyle(color: theme.colorScheme.primary)), onTap: () => _showAddSubReminderDialog(context, reminder.id)),
        ],
      ),
    );
  }

  void _showEditReminderDialog(BuildContext context, AppProvider provider, Reminder reminder) {
    final controller = TextEditingController(text: reminder.title);
    String? pickedImagePath = reminder.imagePath;
    DateTime? selectedDate = reminder.dueDate;
    showDialog(context: context, builder: (context) => StatefulBuilder(builder: (context, setState) => StyledDialog(title: 'Edit Reminder', content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: controller, decoration: const InputDecoration(labelText: 'Reminder Title')), const SizedBox(height: 16), Row(children: [Text(selectedDate == null ? 'No Date' : DateFormat.yMMMd().format(selectedDate!)), const Spacer(), TextButton(onPressed: () async { final picked = await showDatePicker(context: context, initialDate: selectedDate ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100)); if (picked != null) setState(() => selectedDate = picked); }, child: const Text('Change Date', style: TextStyle(color: Color(0xFF80CBC4))))]), const SizedBox(height: 10), if (pickedImagePath != null) Stack(children: [SizedBox(height: 100, child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(pickedImagePath!)))), Positioned(right: 0, top: 0, child: IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => pickedImagePath = null)))]), TextButton.icon(onPressed: () async { final picked = await ImagePicker().pickImage(source: ImageSource.gallery); if (picked != null) setState(() => pickedImagePath = picked.path); }, icon: const Icon(Icons.image, color: Color(0xFF80CBC4)), label: const Text('Change Image', style: TextStyle(color: Color(0xFF80CBC4))))])), onCancel: () => Navigator.pop(context), onSave: () { if (controller.text.isNotEmpty) { provider.updateReminder(reminder.copyWith(title: controller.text, imagePath: drift.Value(pickedImagePath), dueDate: drift.Value(selectedDate))); Navigator.pop(context); } })));
  }

  void _showAddSubReminderDialog(BuildContext context, int reminderId) {
    final controller = TextEditingController();
    String? pickedImagePath;
    showDialog(context: context, builder: (context) => StatefulBuilder(builder: (context, setState) => StyledDialog(title: 'Add Sub-task', content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: controller, decoration: const InputDecoration(labelText: 'Sub-task Title'), autofocus: true), const SizedBox(height: 10), if (pickedImagePath != null) SizedBox(height: 100, child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(pickedImagePath!)))), TextButton.icon(onPressed: () async { final picked = await ImagePicker().pickImage(source: ImageSource.gallery); if (picked != null) setState(() => pickedImagePath = picked.path); }, icon: const Icon(Icons.image, color: Color(0xFF80CBC4)), label: const Text('Add Image', style: TextStyle(color: Color(0xFF80CBC4))))]), onCancel: () => Navigator.pop(context), onSave: () { if (controller.text.isNotEmpty) { Provider.of<AppProvider>(context, listen: false).addSubReminder(reminderId, controller.text, imagePath: pickedImagePath); Navigator.pop(context); } })));
  }
}
