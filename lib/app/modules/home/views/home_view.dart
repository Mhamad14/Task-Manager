import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import 'package:flutter_application_1/app/data/models/task_model.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.toNamed('/settings'),
          ),
          IconButton(
            icon: Icon(
              Get.isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round,
            ),
            onPressed: () {
              Get.changeThemeMode(
                Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.toAddTask,
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.tasks.isEmpty) {
          return const Center(
            child: Text(
              'No tasks yet!\nAdd some tasks to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }
        return Column(
          children: [
            _dateBar(context, controller),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                onChanged: (value) => controller.searchQuery.value = value,
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            controller.searchQuery.value = '';
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Priority filters
                  _buildFilterChip(
                    label: 'All',
                    isSelected: controller.priorityFilter.value == -1,
                    onSelected: () => controller.priorityFilter.value = -1,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Low',
                    isSelected: controller.priorityFilter.value == 0,
                    onSelected: () => controller.priorityFilter.value = 0,
                    color: const Color(0xFF2196F3),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Medium',
                    isSelected: controller.priorityFilter.value == 1,
                    onSelected: () => controller.priorityFilter.value = 1,
                    color: const Color(0xFFFF9800),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'High',
                    isSelected: controller.priorityFilter.value == 2,
                    onSelected: () => controller.priorityFilter.value = 2,
                    color: const Color(0xFFF44336),
                  ),
                  const SizedBox(width: 16),
                  // Completion filters
                  _buildFilterChip(
                    label: 'Todo',
                    isSelected: controller.completionFilter.value == 0,
                    onSelected: () => controller.completionFilter.value = 
                        controller.completionFilter.value == 0 ? -1 : 0,
                    icon: Icons.radio_button_unchecked,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Done',
                    isSelected: controller.completionFilter.value == 1,
                    onSelected: () => controller.completionFilter.value = 
                        controller.completionFilter.value == 1 ? -1 : 1,
                    icon: Icons.check_circle,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Task List
            Expanded(
              child: controller.filteredTasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No tasks match your filters',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => controller.clearFilters(),
                            child: const Text('Clear Filters'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: controller.filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = controller.filteredTasks[index];
                        return Dismissible(
                          key: Key(task.id!),
                          background: Container(
                            color: Colors.green,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Icon(Icons.check, color: Colors.white),
                          ),
                          secondaryBackground: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              // Swipe right - mark complete
                              controller.markTaskCompleted(task.id!);
                              return false;
                            } else {
                              // Swipe left - delete
                              return true;
                            }
                          },
                          onDismissed: (direction) {
                            controller.deleteTask(task);
                          },
                          child: TaskTile(
                            task: task,
                            onTap: () => controller.toTaskDetails(task),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  Container _dateBar(BuildContext context, HomeController controller) {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat.yMMMd().format(controller.selectedDate.value),
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              Text(
                "Today",
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              Icons.calendar_month,
              color: Get.isDarkMode
                  ? Colors.white
                  : Colors.black, // Explicit color for visibility
              size: 30, // Make it a bit bigger for tap target
            ),
            onPressed: () async {
              DateTime? pickedDate = await showDialog<DateTime>(
                context: context,
                builder: (context) => _TaskCalendarDialog(
                  initialDate: controller.selectedDate.value,
                  controller: controller,
                ),
              );
              if (pickedDate != null) {
                controller.selectedDate.value = pickedDate;
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    Color? color,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? (color ?? Theme.of(Get.context!).primaryColor)
              : (color ?? Theme.of(Get.context!).primaryColor).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color ?? Theme.of(Get.context!).primaryColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : (color ?? Theme.of(Get.context!).primaryColor),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : (color ?? Theme.of(Get.context!).primaryColor),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const TaskTile({super.key, required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color getPriorityColor(int? priority) {
      switch (priority) {
        case 0:
          return const Color(0xFF2196F3); // Vibrant blue
        case 1:
          return const Color(0xFFFF9800); // Vibrant orange
        case 2:
          return const Color(0xFFF44336); // Vibrant red
        default:
          return const Color(0xFF2196F3); // Vibrant blue
      }
    }

    IconData getCategoryIcon(String? category) {
      switch (category) {
        case 'Work':
          return Icons.work_outline;
        case 'Personal':
          return Icons.person_outline;
        case 'Shopping':
          return Icons.shopping_cart_outlined;
        case 'Health':
          return Icons.favorite_outline;
        case 'Other':
          return Icons.more_horiz;
        default:
          return Icons.category_outlined;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: getPriorityColor(task.priority),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title ?? "",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: Colors.white.withOpacity(0.9),
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "${task.startTime} - ${task.endTime}",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (task.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            getCategoryIcon(task.category),
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            task.category!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  const SizedBox(height: 12),
                  Text(
                    task.note ?? "",
                    style: const TextStyle(fontSize: 15, color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              height: 60,
              width: 0.5,
              color: Colors.grey[200]!.withOpacity(0.7),
            ),
            RotatedBox(
              quarterTurns: 3,
              child: Text(
                task.isCompleted == 1 ? "COMPLETED" : "TODO",
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Calendar Dialog with Task Indicators
class _TaskCalendarDialog extends StatefulWidget {
  final DateTime initialDate;
  final HomeController controller;

  const _TaskCalendarDialog({
    required this.initialDate,
    required this.controller,
  });

  @override
  State<_TaskCalendarDialog> createState() => _TaskCalendarDialogState();
}

class _TaskCalendarDialogState extends State<_TaskCalendarDialog> {
  late DateTime _selectedDate;
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _displayedMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 350, maxHeight: 450),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Month/Year header with navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _displayedMonth = DateTime(
                        _displayedMonth.year,
                        _displayedMonth.month - 1,
                      );
                    });
                  },
                ),
                Text(
                  DateFormat.yMMMM().format(_displayedMonth),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _displayedMonth = DateTime(
                        _displayedMonth.year,
                        _displayedMonth.month + 1,
                      );
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Day of week headers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                  .map((day) => SizedBox(
                        width: 40,
                        child: Center(
                          child: Text(
                            day,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            // Calendar grid
            Expanded(
              child: _buildCalendarGrid(),
            ),
            const SizedBox(height: 16),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(_selectedDate),
                  child: const Text('OK'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final lastDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0
    final daysInMonth = lastDayOfMonth.day;

    final List<Widget> dayWidgets = [];

    // Add empty cells for days before the first of the month
    for (int i = 0; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 40, height: 45));
    }

    // Add day cells
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_displayedMonth.year, _displayedMonth.month, day);
      final tasksForDate = widget.controller.getTasksForDate(date);
      final isSelected = _selectedDate.year == date.year &&
          _selectedDate.month == date.month &&
          _selectedDate.day == date.day;
      final isToday = DateTime.now().year == date.year &&
          DateTime.now().month == date.month &&
          DateTime.now().day == date.day;

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          child: Container(
            width: 40,
            height: 45,
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : isToday
                      ? Theme.of(context).primaryColor.withOpacity(0.2)
                      : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : isToday
                            ? Theme.of(context).primaryColor
                            : null,
                    fontWeight: isToday || isSelected ? FontWeight.bold : null,
                  ),
                ),
                if (tasksForDate.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: tasksForDate.take(3).map((task) {
                        // Get priority color: 0=blue(low), 1=orange(medium), 2=red(high)
                        Color dotColor;
                        if (isSelected) {
                          dotColor = Colors.white;
                        } else {
                          switch (task.priority) {
                            case 0:
                              dotColor = Colors.blue;
                              break;
                            case 1:
                              dotColor = Colors.orange;
                              break;
                            case 2:
                              dotColor = Colors.red;
                              break;
                            default:
                              dotColor = Colors.blue;
                          }
                        }
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: dotColor,
                            shape: BoxShape.circle,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: dayWidgets,
    );
  }
}
