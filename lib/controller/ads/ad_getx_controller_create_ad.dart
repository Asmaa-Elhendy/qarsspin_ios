import 'package:get/get.dart';
import 'package:qarsspin/controller/auth/auth_controller.dart';
import '../../model/car_brand.dart';
import '../../model/car_category.dart';
import '../../model/class_model.dart';
import '../../model/car_model_class.dart';
import '../../model/create_ad_model.dart';
import 'data_layer.dart';

class AdCleanController extends GetxController {
  final AdRepository repository;
  AdCleanController(this.repository);

  // قائمة الماركات
  var carBrands = <CarBrand>[].obs;
  var selectedMake = Rxn<CarBrand>();

  // قائمة الكلاسات
  var carClasses = <CarClass>[].obs;
  var selectedClass = Rxn<CarClass>();

  // قائمة الموديلات
  var carModels = <CarModelClass>[].obs;
  var selectedModel = Rxn<CarModelClass>();

  // قائمة أنواع السيارات
  var carCategories = <CarCategory>[].obs;
  var selectedCategory = Rxn<CarCategory>();

  // loading flags
  var isLoadingCategories = false.obs;

  // Create ad state
  var isCreatingAd = false.obs;
  var createAdError = Rxn<String>();
  var createAdSuccess = Rxn<Map<String, dynamic>>();

  // Video upload state
  var isUploadingVideo = false.obs;
  var videoUploadError = Rxn<String>();
  var videoUploadSuccess = Rxn<Map<String, dynamic>>();

  // loading flags
  var isLoadingMakes = false.obs;
  var isLoadingClasses = false.obs;
  var isLoadingModels = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMakes();
    fetchCarCategories();
  }

  void fetchMakes() async {
    isLoadingMakes.value = true;
    try {
      final makes = await repository.fetchCarMakes();
      carBrands.assignAll(makes);
    } finally {
      isLoadingMakes.value = false;
    }
  }

  void fetchCarClasses(String makeId) async {
    isLoadingClasses.value = true;
    carClasses.clear();
    selectedClass.value = null;

    try {
      final classes = await repository.fetchCarClasses(makeId);
      carClasses.assignAll(classes);
    } catch (e) {
      print("Error fetching classes: $e");
    } finally {
      isLoadingClasses.value = false;
    }
  }

  void fetchCarModels(String classId,String makeId) async {
    isLoadingModels.value = true;
    carModels.clear();
    selectedModel.value = null;

    try {
      final models = await repository.fetchCarModels(classId,makeId);
      carModels.assignAll(models);
    } catch (e) {//k
      print("Error fetching models: $e");
    } finally {
      isLoadingModels.value = false;
    }
  }

  void fetchCarCategories() async {
    print('fetchCarCategories called');
    isLoadingCategories.value = true;
    try {
      print('Calling repository.fetchCarCategories()');
      final categories = await repository.fetchCarCategories();
      print('Received ${categories.length} categories from repository');
      carCategories.assignAll(categories);
      print('carCategories list now has ${carCategories.length} items');
      print('carCategories content: ${carCategories.map((c) => "${c.id}-${c.name}").toList()}');
    } catch (e) {
      print("Error fetching categories: $e");
    } finally {
      isLoadingCategories.value = false;
    }
  }



  /// إنشاء إعلان جديد
  Future<void> createAd({
    required CreateAdModel adData,
  }) async
  {
    isCreatingAd.value = true;
    createAdError.value = null;
    createAdSuccess.value = null;

    try {
      // Validate required selections
      if (selectedMake.value == null ||
          selectedClass.value == null ||
          selectedModel.value == null) {
        throw Exception('Please select valid Make, Class, and Model');
      }

      // Update the adData with selected make, class, and model
      CreateAdModel updatedAdData = CreateAdModel(
          Owner_Name: Get.find<AuthController>().userFullName,
          Owner_Mobile: Get.find<AuthController>().ownerMobile,
          Owner_Email: Get.find<AuthController>().ownerEmail,
        makeId: selectedMake.value!.id.toString(),
        classId: selectedClass.value!.id.toString(),
        modelId: selectedModel.value!.id.toString(),
        categoryId: adData.categoryId,
        manufactureYear: adData.manufactureYear,
        minimumPrice: adData.minimumPrice,
        askingPrice: adData.askingPrice,
        mileage: adData.mileage,
        plateNumber: adData.plateNumber,
        chassisNumber: adData.chassisNumber,
        postDescription: adData.postDescription,
        interiorColor: adData.interiorColor,
        exteriorColor: adData.exteriorColor,
        warrantyAvailable: adData.warrantyAvailable,
        userName: adData.userName,
        ourSecret: adData.ourSecret,
        selectedLanguage: adData.selectedLanguage,
      );

      // Call API
      final result = await repository.createCarAd(adModel: updatedAdData);

      // Handle response
      if (result['Code'] == 'OK') {
        createAdSuccess.value = result;
      } else {
        throw Exception(result['Desc'] ?? 'Failed to create ad');
      }

    } catch (e) {
      createAdError.value = e.toString();
      print("Error creating ad: $e");
    } finally {
      isCreatingAd.value = false;
    }
  }

  /// Reset create ad state
  void resetCreateAdState() {
    isCreatingAd.value = false;
    createAdError.value = null;
    createAdSuccess.value = null;
  }

  /// Upload video for a post
  Future<void> uploadVideo({
    required String postId,
    required String ourSecret,
    required String videoPath,
  }) async {
    isUploadingVideo.value = true;
    videoUploadError.value = null;
    videoUploadSuccess.value = null;

    try {
      final result = await repository.uploadVideoForPost(
        postId: postId,
        ourSecret: ourSecret,
        videoPath: videoPath,
      );

      if (result['Code'] == 'OK') {
        videoUploadSuccess.value = result;
      } else {
        throw Exception(result['Desc'] ?? 'Failed to upload video');
      }
    } catch (e) {
      videoUploadError.value = e.toString();
      print("Error uploading video: $e");
    } finally {
      isUploadingVideo.value = false;
    }
  }

  /// Reset video upload state
  void resetVideoUploadState() {
    isUploadingVideo.value = false;
    videoUploadError.value = null;
    videoUploadSuccess.value = null;
  }

  /// Get missing required fields for validation
  List<String> getMissingRequiredFields({
    required CreateAdModel adData,
  })
  {
    List<String> missingFields = [];

    if (selectedMake.value == null) missingFields.add('Make');
    if (selectedClass.value == null) missingFields.add('Class');
    if (selectedModel.value == null) missingFields.add('Model');
    if (adData.categoryId.isEmpty) missingFields.add('Type');
    if (adData.manufactureYear.isEmpty) missingFields.add('Manufacture Year');
    if (adData.askingPrice.isEmpty) missingFields.add('Asking Price');
    if (adData.mileage.isEmpty) missingFields.add('Mileage');
    if (adData.plateNumber.isEmpty) missingFields.add('Plate Number');
    if (adData.chassisNumber.isEmpty) missingFields.add('Chassis Number');
    if (adData.postDescription.isEmpty) missingFields.add('Description');
    if (adData.interiorColor.isEmpty) missingFields.add('Interior Color');
    if (adData.exteriorColor.isEmpty) missingFields.add('Exterior Color');
    if (adData.warrantyAvailable.isEmpty) missingFields.add('Warranty');

    return missingFields;
  }
}