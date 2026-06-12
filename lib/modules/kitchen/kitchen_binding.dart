import 'package:get/get.dart';
import 'kitchen_controller.dart';

class KitchenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KitchenController>(() => KitchenController());
  }
}
