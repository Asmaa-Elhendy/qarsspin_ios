class CreateAdModel {
  final String makeId;
  final String classId;
  final String modelId;
  final String categoryId;
  final String manufactureYear;
  final String minimumPrice;
  final String askingPrice;
  final String mileage;
  final String plateNumber;
  final String chassisNumber;
  final String postDescription;
  final String interiorColor;
  final String exteriorColor;
  final String warrantyAvailable;
  final String userName;
  final String ourSecret;
  final String selectedLanguage;
  final String? postId; // Add postId field for update mode
  final String? Owner_Name;
  final String? Owner_Mobile;
  final String? Owner_Email;

  CreateAdModel({
    required this.Owner_Name,
    required this.Owner_Mobile,
    required this.Owner_Email,
    required this.makeId,
    required this.classId,
    required this.modelId,
    required this.categoryId,
    required this.manufactureYear,
    required this.minimumPrice,
    required this.askingPrice,
    required this.mileage,
    required this.plateNumber,
    required this.chassisNumber,
    required this.postDescription,
    required this.interiorColor,
    required this.exteriorColor,
    required this.warrantyAvailable,
    required this.userName,
    required this.ourSecret,
    this.selectedLanguage = 'en',
    this.postId, // Add postId parameter
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      "Owner_Name":Owner_Name,
      "Owner_Mobile":Owner_Mobile,
      "Owner_Email":Owner_Email,
      'Make_ID': makeId,
      'Class_ID': classId,
      'Model_ID': modelId,
      'Category_ID': categoryId,
      'Manufacture_Year': manufactureYear,
      'Minimum_Price': minimumPrice,
      'Asking_Price': askingPrice,
      'Mileage': mileage,
      'Plate_Number': plateNumber,
      'Chassis_Number': chassisNumber,
      'Post_Description': postDescription,
      'Interior_Color': interiorColor,
      'Exterior_Color': exteriorColor,
      'Warranty_isAvailable': warrantyAvailable,
    };
  }

  /// Create JSON payload for API
  Map<String, dynamic> toApiPayload() {
    return {
      'dic_PostDetails': toJson(),
    };
  }
}