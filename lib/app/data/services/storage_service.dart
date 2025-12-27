import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/task_model.dart';

class StorageService extends GetxService {
  final _box = GetStorage();
  final _key = 'tasks';

  Future<StorageService> init() async {
    await GetStorage.init();
    return this;
  }

  List<Task> readTasks() {
    var check = _box.read(_key);
    if (check == null) return [];
    return (check as List).map((e) => Task.fromJson(e)).toList();
  }

  void writeTasks(List<Task> tasks) {
    _box.write(_key, tasks.map((e) => e.toJson()).toList());
  }
}
