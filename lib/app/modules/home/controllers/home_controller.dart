import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/app/data/models/task_model.dart';
import 'package:flutter_application_1/app/data/services/storage_service.dart';
import 'package:flutter_application_1/app/routes/app_routes.dart';
import 'package:intl/intl.dart';

class HomeController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final tasks = <Task>[].obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  
  // Search and filter
  final RxString searchQuery = ''.obs;
  final RxInt priorityFilter = (-1).obs; // -1 = all, 0 = low, 1 = medium, 2 = high
  final RxInt completionFilter = (-1).obs; // -1 = all, 0 = incomplete, 1 = complete
  
  Timer? _reminderTimer;
  final Set<String> _notifiedTaskIds = {}; // Track tasks we've already notified

  // Get filtered tasks based on search and filters
  List<Task> get filteredTasks {
    var formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate.value);
    
    return tasks.where((task) {
      // Date filter
      if (task.date != formattedDate && task.repeat != 'Daily') {
        return false;
      }
      
      // Search filter
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        final titleMatch = task.title?.toLowerCase().contains(query) ?? false;
        final noteMatch = task.note?.toLowerCase().contains(query) ?? false;
        if (!titleMatch && !noteMatch) return false;
      }
      
      // Priority filter
      if (priorityFilter.value != -1 && task.priority != priorityFilter.value) {
        return false;
      }
      
      // Completion filter
      if (completionFilter.value != -1 && task.isCompleted != completionFilter.value) {
        return false;
      }
      
      return true;
    }).toList();
  }

  void clearFilters() {
    searchQuery.value = '';
    priorityFilter.value = -1;
    completionFilter.value = -1;
  }

  @override
  void onReady() {
    super.onReady();
    tasks.assignAll(_storageService.readTasks());
    _startReminderCheck();
  }

  @override
  void onClose() {
    _reminderTimer?.cancel();
    super.onClose();
  }

  void _startReminderCheck() {
    // Check for reminders every 30 seconds
    _reminderTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkReminders();
    });
    // Also check immediately
    _checkReminders();
  }

  void _checkReminders() {
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    for (var task in tasks) {
      // Skip if already notified or completed
      if (_notifiedTaskIds.contains(task.id) || task.isCompleted == 1) {
        continue;
      }

      // Check if task is for today or is a daily repeat
      if (task.date != todayStr && task.repeat != 'Daily') {
        continue;
      }

      // Parse task start time
      final taskStartTime = _parseTimeString(task.startTime, now);
      if (taskStartTime == null) continue;

      // Calculate reminder time (start time - remind minutes)
      final reminderMinutes = task.remind ?? 5;
      final reminderTime = taskStartTime.subtract(Duration(minutes: reminderMinutes));

      // Check if we should trigger the reminder
      // Trigger if current time is within 1 minute window of reminder time
      final diff = now.difference(reminderTime).inSeconds;
      if (diff >= 0 && diff < 60) {
        _showReminderPopup(task);
        _notifiedTaskIds.add(task.id!);
      }
    }
  }

  DateTime? _parseTimeString(String? timeStr, DateTime baseDate) {
    if (timeStr == null) return null;
    
    try {
      // Parse time like "10:30 AM" or "2:00 PM"
      final format = DateFormat('h:mm a');
      final parsed = format.parse(timeStr);
      return DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        parsed.hour,
        parsed.minute,
      );
    } catch (e) {
      // Try alternative format "HH:mm"
      try {
        final parts = timeStr.split(':');
        if (parts.length >= 2) {
          final hour = int.parse(parts[0]);
          final minutePart = parts[1].replaceAll(RegExp(r'[^0-9]'), '');
          final minute = int.parse(minutePart.isNotEmpty ? minutePart : '0');
          return DateTime(
            baseDate.year,
            baseDate.month,
            baseDate.day,
            hour,
            minute,
          );
        }
      } catch (_) {}
    }
    return null;
  }

  void _showReminderPopup(Task task) {
    // Get priority color
    Color priorityColor;
    String priorityLabel;
    switch (task.priority) {
      case 0:
        priorityColor = Colors.blue;
        priorityLabel = 'Low Priority';
        break;
      case 1:
        priorityColor = Colors.orange;
        priorityLabel = 'Medium Priority';
        break;
      case 2:
        priorityColor = Colors.red;
        priorityLabel = 'High Priority';
        break;
      default:
        priorityColor = Colors.blue;
        priorityLabel = 'Low Priority';
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.alarm, color: priorityColor, size: 28),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Task Reminder',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: priorityColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                priorityLabel,
                style: TextStyle(
                  color: priorityColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              task.title ?? 'Untitled Task',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (task.note != null && task.note!.isNotEmpty)
              Text(
                task.note!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${task.startTime} - ${task.endTime}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Starting in ${task.remind} minutes!',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: priorityColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Dismiss'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: priorityColor,
            ),
            onPressed: () {
              Get.back();
              toTaskDetails(task);
            },
            child: const Text('View Task', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void refreshTasks() {
    tasks.assignAll(_storageService.readTasks());
    // Clear notified tasks when refreshing (allows re-notification for new tasks)
  }

  void deleteTask(Task task) {
    tasks.remove(task);
    _storageService.writeTasks(tasks);
    _notifiedTaskIds.remove(task.id);
  }

  void markTaskCompleted(String id) {
    var index = tasks.indexWhere((element) => element.id == id);
    if (index != -1) {
      tasks[index].isCompleted = 1;
      tasks.refresh();
      _storageService.writeTasks(tasks);
    }
  }

  void toAddTask() async {
    await Get.toNamed(Routes.ADD_TASK);
    refreshTasks();
  }

  void toTaskDetails(Task task) async {
    await Get.toNamed(Routes.TASK_DETAILS, arguments: task);
    refreshTasks();
  }

  // Get all unique dates that have tasks
  Set<String> get taskDates {
    final dates = <String>{};
    for (var task in tasks) {
      if (task.date != null) {
        dates.add(task.date!);
      }
    }
    return dates;
  }

  // Get tasks for a specific date (returns list of tasks with their priorities)
  List<Task> getTasksForDate(DateTime date) {
    final formattedDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    // Get tasks on this specific date or daily repeating tasks
    return tasks.where((task) => task.date == formattedDate || task.repeat == 'Daily').toList();
  }
}

