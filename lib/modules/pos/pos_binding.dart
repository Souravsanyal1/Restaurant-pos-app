import 'package:get/get.dart';
import 'pos_controller.dart';

class PosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PosController>(() => PosController());
  }
}
