import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/app/data/models/task_model.dart';
import 'package:flutter_application_1/app/data/services/storage_service.dart';

class AddTaskController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxString startTime = DateFormat(
    "hh:mm a",
  ).format(DateTime.now()).toString().obs;
  final RxString endTime = "9:30 PM".obs;
  final RxInt selectedRemind = 5.obs;
  final RxString selectedRepeat = "None".obs;
  final RxInt selectedColor = 0
      .obs; // Using color index as priority proxy or separate? Model has both color and priority.
  // Let's map color 0:Blue(Low), 1:Orange(Medium), 2:Red(High) which matches Model priority comments.

  List<int> remindList = [5, 10, 15, 20];
  List<String> repeatList = ["None", "Daily", "Weekly", "Monthly"];
  List<String> categoryList = ["Work", "Personal", "Shopping", "Health", "Other"];
  final RxString selectedCategory = "Personal".obs;

  void validateDate() {
    if (titleController.text.isNotEmpty && noteController.text.isNotEmpty) {
      _addTaskToDb();
      Get.back();
    } else {
      Get.snackbar(
        "Required",
        "All fields are required !",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: Colors.red,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.red),
      );
    }
  }

  void _addTaskToDb() {
    List<Task> currentTasks = _storageService.readTasks();

    // Priority based on selectedColor for simplicity in this implementation
    int priority = selectedColor.value;

    Task task = Task(
      id: DateTime.now().toString(),
      note: noteController.text,
      title: titleController.text,
      date: DateFormat('yyyy-MM-dd').format(selectedDate.value),
      startTime: startTime.value,
      endTime: endTime.value,
      remind: selectedRemind.value,
      repeat: selectedRepeat.value,
      color: selectedColor.value,
      priority: priority,
      category: selectedCategory.value,
      isCompleted: 0,
    );

    currentTasks.add(task);
    _storageService.writeTasks(currentTasks);
  }

  void getDateFromUser(BuildContext context) async {
    DateTime? pickerDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2121),
    );

    if (pickerDate != null) {
      selectedDate.value = pickerDate;
    }
  }

  void getTimeFromUser({
    required bool isStartTime,
    required BuildContext context,
  }) async {
    var pickedTime = await _showTimePicker(context);
    String formattedTime = pickedTime.format(context);
    if (pickedTime == null) {
      print("Time cancelled");
    } else if (isStartTime == true) {
      startTime.value = formattedTime;
    } else if (isStartTime == false) {
      endTime.value = formattedTime;
    }
  }

  Future<TimeOfDay?> _showTimePicker(BuildContext context) {
    return showTimePicker(
      initialEntryMode: TimePickerEntryMode.input,
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(startTime.value.split(":")[0]),
        minute: int.parse(startTime.value.split(":")[1].split(" ")[0]),
      ),
    );
  }
}
