import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:qarsspin/controller/payments/payment_controller.dart';
import 'package:qarsspin/controller/rental_cars_controller.dart';
import 'package:qarsspin/controller/search_controller.dart';
import 'package:qarsspin/controller/showrooms_controller.dart';
import 'package:qarsspin/controller/specs/specs_controller.dart';
import 'package:qarsspin/controller/specs/specs_data_layer.dart';


import 'ads/ad_getx_controller_create_ad.dart';
import 'ads/data_layer.dart';
import 'auth/auth_controller.dart';
import 'brand_controller.dart';
import 'my_ads/my_ad_getx_controller.dart';
import 'my_ads/my_ad_data_layer.dart';
import 'notifications_controller.dart';
import 'package:qarsspin/services/notification_database.dart';
import 'package:qarsspin/services/fcm_service.dart';

class MyBinding implements Bindings {
  @override
  void dependencies() {
    // Initialize AuthController first since other controllers depend on it
    Get.put(AuthController(), permanent: true);
    
    // Initialize other controllers
    Get.lazyPut(() => BrandController(), fenix: true);
    Get.lazyPut(() => ShowRoomsController(), fenix: true);
    Get.lazyPut(() => RentalCarsController(), fenix: true);
    Get.lazyPut(() => SpecsController(SpecsDataLayer()), fenix: true);
    Get.lazyPut(() => AdCleanController(AdRepository()), fenix: true);
    Get.lazyPut(() => MyAdCleanController(MyAdDataLayer()), fenix: true);
    Get.lazyPut(() => MySearchController(), fenix: true);
    Get.put(PaymentController(), permanent: true);
  
     // Initialize FCM Service
    Get.lazyPut(() => FCMService(), fenix: true);
    
    // Initialize NotificationsController last since it might depend on other controllers
    Get.lazyPut(() => NotificationsController(), fenix: true);
  }
}