import 'package:get/get.dart';
import 'package:flutter_application_1/app/data/models/task_model.dart';
import 'package:flutter_application_1/app/data/services/storage_service.dart';

class TaskDetailsController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final Rx<Task> task = Task().obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      task.value = Get.arguments as Task;
    }
  }

  void markTaskCompleted() {
    // We need to update the actual task in the list
    List<Task> tasks = _storageService.readTasks();
    int index = tasks.indexWhere((e) => e.id == task.value.id);
    if (index != -1) {
      tasks[index].isCompleted = 1;
      _storageService.writeTasks(tasks);
      task.update((val) {
        val?.isCompleted = 1;
      });
      Get.back(); // Go back to refresh
    }
  }

  void deleteTask() {
    List<Task> tasks = _storageService.readTasks();
    tasks.removeWhere((e) => e.id == task.value.id);
    _storageService.writeTasks(tasks);
    Get.back(); // Go back to refresh
  }
}
