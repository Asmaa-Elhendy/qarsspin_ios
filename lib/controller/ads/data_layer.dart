// repositories/car_repository.dart
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:qarsspin/controller/auth/auth_controller.dart';
import '../../controller/const/base_url.dart';
import '../../model/car_brand.dart';
import '../../model/car_category.dart';
import '../../model/class_model.dart';
import '../../model/car_model_class.dart';
import '../../model/create_ad_model.dart';
import 'dart:io';
String ourSecret='1244';
//String userName= 'Asmaa2';
String userName= Get.find<AuthController>().userFullName!;
class AdRepository {
  Future<List<CarBrand>> fetchCarMakes() async {
    final url = Uri.parse(
      '$base_url/BrowsingRelatedApi.asmx/GetListOfCarMakes?Order_By=MakeName',
    );

    final response = await http.get(url, headers: {'Accept': 'application/json'});

    if (response.statusCode == 200) {
      final parsedJson = jsonDecode(response.body);
      final List<dynamic> data = parsedJson['Data'];
      return data.map((item) {
        return CarBrand(
          id: item["Make_ID"],
          make_count: item["Make_Count"],
          name: item["Make_Name_PL"],
          slName: item["Make_Name_SL"],
          imageUrl: item["Image_URL"] ?? "",
        );
      }).toList();
    } else {
      throw Exception("Failed to load car makes");
    }
  }

  /// جلب الكلاسات

  Future<List<CarClass>> fetchCarClasses(String makeId) async {
    final url = Uri.parse(
      '$base_url/BrowsingRelatedApi.asmx/GetListOfCarClasses?Make_ID=$makeId',
    );

    final response = await http.get(url, headers: {'Accept': 'application/json'});

    if (response.statusCode == 200) {
      final parsedJson = jsonDecode(response.body);
      final List<dynamic> data = parsedJson['Data'];
      return data.map((item) {
        return CarClass(
          id: item["Class_ID"],
          name: item["Class_Name_PL"],
        );
      }).toList();
    } else {
      throw Exception("Failed to load car classes");
    }
  }

  /// جلب الموديلات
  Future<List<CarModelClass>> fetchCarModels(String classId,String makeId) async {
    final url = Uri.parse(
      '$base_url/BrowsingRelatedApi.asmx/GetListOfCarModels?Class_ID=$classId&Make_ID=$makeId',
    );

    final response = await http.get(url, headers: {'Accept': 'application/json'});

    if (response.statusCode == 200) {
      final parsedJson = jsonDecode(response.body);
      final List<dynamic> data = parsedJson['Data'];
      return data.map((item) {
        return CarModelClass(
          id: item["Model_ID"],
          name: item["Model_Name_PL"],
        );
      }).toList();
    } else {
      throw Exception("Failed to load car models");
    }
  }

  /// جلب أنواع السيارات
  Future<List<CarCategory>> fetchCarCategories() async {
    final url = Uri.parse(
      '$base_url/BrowsingRelatedApi.asmx/GetListOfCarCategories',
    );

    print('Fetching car categories from: $url');
    final response = await http.get(url, headers: {'Accept': 'application/json'});
    // print('API Response status: ${response.statusCode}');
    // print('API Response body: ${response.body}');
//k
    if (response.statusCode == 200) {
      final parsedJson = jsonDecode(response.body);
      print('Parsed JSON: $parsedJson');
      final List<dynamic> data = parsedJson['Data'];
      print('Data list length: ${data.length}');
      print('First data item: ${data.isNotEmpty ? data[0] : 'No data'}');

      final categories = data.map((item) {
        final category = CarCategory.fromJson(item);
        print('Parsed category: ${category.id} - ${category.name}');
        return category;
      }).toList();

      print('Total categories parsed: ${categories.length}');
      return categories;
    } else {
      print('Failed to load car categories. Status: ${response.statusCode}');
      throw Exception("Failed to load car categories");
    }
  }

  /// إنشاء إعلان سيارة جديدة للبيع
  Future<Map<String, dynamic>> createCarAd({
    required CreateAdModel adModel,
  }) async
  {
    final url = Uri.parse(
      '$base_url/BrowsingRelatedApi.asmx/InsertCarForSalePost',
    );

    // Create JSON payload
    String postDetails = jsonEncode(adModel.toApiPayload());

    // Prepare the request body
    final requestBody = {
      'Post_Details': postDetails,
      'UserName': adModel.userName,
      'Our_Secret': adModel.ourSecret,
      'Selected_Language': adModel.selectedLanguage,
      'partnerID':''

    };
    log(requestBody.toString());
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        // Parse JSON response
        return _parseJsonResponse(response.body);
      } else {
        return {
          'Code': 'Error',
          'Desc': 'Failed to create ad. Status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'Code': 'Error',
        'Desc': 'Network error: ${e.toString()}',
      };
    }
  }

  /// تحديث إعلان سيارة موجود
  Future<Map<String, dynamic>> updateCarAd({
    required String postId,
    required CreateAdModel adModel,
  }) async
  {
    final url = Uri.parse(
      '$base_url/BrowsingRelatedApi.asmx/UpdateCarForSalePost',
    );

    // Create JSON payload
    String postDetails = jsonEncode(adModel.toApiPayload());

    // Prepare the request body
    final requestBody = {
      'Post_ID': postId,
      'Post_Details': postDetails,
      'UserName': adModel.userName,
      'Our_Secret': adModel.ourSecret,
      'Selected_Language': adModel.selectedLanguage,
    };

    log('body req for update ${requestBody.toString()}');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        // Parse JSON response
        log('body response of update ${_parseJsonResponse(response.body)}');
        return _parseJsonResponse(response.body);
      } else {
        return {
          'Code': 'Error',
          'Desc': 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        };
      }
    } catch (e) {
      return {
        'Code': 'Error',
        'Desc': 'Network error: $e',
      };
    }
  }

  /// Upload cover photo for a post
  Future<Map<String, dynamic>> uploadCoverPhoto({
    required String postId,
    required String ourSecret,
    required String imagePath,
  }) async
  {
    final url = Uri.parse(
      '$base_url/BrowsingRelatedApi.asmx/UploadPostCoverPhoto',
    );

    try {
      // Read the image file
      final file = File(imagePath);
      if (!await file.exists()) {
        return {
          'Code': 'Error',
          'Desc': 'Image file not found',
        };
      }

      // Create multipart request
      final request = http.MultipartRequest('POST', url);

      // Add form fields
      request.fields['Post_ID'] = postId;
      request.fields['Our_Secret'] = ourSecret;

      // Add image file
      final imageFile = await http.MultipartFile.fromPath(
        'PhotoBytes',
        imagePath,
        filename: 'cover.jpg',
      );
      request.files.add(imageFile);

      // Send the request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        // Parse XML response
        return _parseUploadResponse(responseBody);
      } else {
        return {
          'Code': 'Error',
          'Desc': 'Failed to upload cover photo. Status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'Code': 'Error',
        'Desc': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Upload video for a post
  Future<Map<String, dynamic>> uploadVideoForPost({
    required String postId,
    required String ourSecret,
    required String videoPath,
  }) async
  {
    log('viideo $videoPath');
    final url = Uri.parse(
      '$base_url/BrowsingRelatedApi.asmx/UploadVideoForPost',
    );

    try {
      // Read the video file
      final file = File(videoPath);
      if (!await file.exists()) {
        return {
          'Code': 'Error',
          'Desc': 'Video file not found',
        };
      }
      // اقرأ bytes وحولها Base64
      final bytes = await file.readAsBytes();
      final base64Video = base64Encode(bytes);
      log('Base64 length: ${base64Video.length}');
      log('Base64 preview: ${base64Video.substring(0, 50)}...${base64Video.substring(base64Video.length - 50)}');
      // Since UploadVideoForPost doesn't accept multipart, we need to send it differently
      // The API description says "Upload Video, Update Post, Add Media & Post Log (fixed fields except video)"
      // This suggests the video might be handled separately or through a different mechanism

      // For now, let's try sending the basic parameters as form-urlencoded with video path
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'Post_ID': postId,
          'Our_Secret': ourSecret,
          'video': base64Video, // Try adding video path as parameter
        },
      );

      log('Video upload response status: ${response.statusCode}');
      log('Video upload response body: ${response.body}');

      if (response.statusCode == 200) {
        // Parse JSON response
        return _parseUploadResponse(response.body);
      } else {
        return {
          'Code': 'Error',
          'Desc': 'Failed to upload video. Status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      log('Video upload error: $e');
      return {
        'Code': 'Error',
        'Desc': 'Network error: ${e.toString()}',
      };
    }
  }





  /// Parse JSON response from API
  Map<String, dynamic> _parseJsonResponse(String jsonString) {
    try {
      final parsedJson = jsonDecode(jsonString);

      return {
        'Code': parsedJson['Code'] ?? 'Error',
        'Desc': parsedJson['Desc'] ?? 'Unknown error',
        'ID': parsedJson['Created_ID'],
      };
    } catch (e) {
      return {
        'Code': 'Error',
        'Desc': 'Failed to parse response: ${e.toString()}',
      };
    }
  }

  /// Parse JSON response from upload endpoint
  Map<String, dynamic> _parseUploadResponse(String jsonString) {
    try {
      final parsedJson = jsonDecode(jsonString);

      return {
        'Code': parsedJson['Code'] ?? 'Error',
        'Desc': parsedJson['Desc'] ?? 'Upload failed',
      };
    } catch (e) {
      return {
        'Code': 'Error',
        'Desc': 'Failed to parse upload response: ${e.toString()}',
      };
    }
  }

}