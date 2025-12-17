import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:qarsspin/controller/const/base_url.dart';
import 'package:qarsspin/model/post_media.dart';

class MyAdDataLayer {
  /// Delete a post by marking it as inactive
  Future<Map<String, dynamic>> deletePost({
    required String postId,
    required String loggedInUser,
  }) async {
    final url = Uri.parse('$base_url/BrowsingRelatedApi.asmx/SetPostInactive');

    log('Deleting post with ID: $postId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {
          'Post_ID': postId,
          'Logged_In_User': loggedInUser,
        },
      );

      log('Delete post response status: ${response.statusCode}');
      log('Delete post response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return {
          'Code': responseData['Code'] ?? 'Error',
          'Desc': responseData['Desc'] ?? 'Unknown error',
          'AffectedRows': responseData['AffectedRows'] ?? 0,
        };
      } else {
        log('❌ HTTP Error: Status code ${response.statusCode}');
        log('Response Body: ${response.body}');
        return {
          'Code': 'Error',
          'Desc': 'Failed to delete post. Status code: ${response.statusCode}',
          'AffectedRows': 0,
        };
      }
    } catch (e) {
      log('❌ Exception in deletePost: $e');
      return {
        'Code': 'Error',
        'Desc': 'Exception: $e',
        'AffectedRows': 0,
      };
    }
  }

  /// Get list of posts by user name
  Future<Map<String, dynamic>> getListOfPostsByUserName({
    required String userName,
    required String ourSecret,
  }) async
  {
    final url = Uri.parse(
      '$base_url/BrowsingRelatedApi.asmx/GetListOfPostsByUserName',
    );

    // Prepare the request body
    final requestBody = {
      'UserName': userName,
      'Our_Secret': ourSecret,
    };

    log('Getting posts for user: $userName');


    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: requestBody,
      );

      log('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Parse JSON response
        return _parseJsonResponse(response.body);
      } else {
        print('❌ HTTP Error: Status code ${response.statusCode}');
        print('Response Body: ${response.body}');
        return {
          'Code': 'Error',
          'Desc': 'Failed to get posts. Status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      log('Error getting posts: $e');
      return {
        'Code': 'Error',
        'Desc': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Get media of post by ID
  Future<PostMedia> getMediaOfPostByID({
    required String postId,
  }) async
  {
    final url = Uri.parse(
      '$base_url/BrowsingRelatedApi.asmx/GetMediaOfPostByID',
    );

    // Prepare the request body
    final requestBody = {
      'Post_ID': postId,
    };

    log('Getting media for post ID: $postId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: requestBody,
      );

      log('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Parse JSON response
        final parsedJson = jsonDecode(response.body);
        log('Parsed JSON: $parsedJson');

        return PostMedia.fromJson(parsedJson);
      } else {
        print('❌ HTTP Error: Status code ${response.statusCode}');
        print('Response Body: ${response.body}');
        return PostMedia(
          code: 'Error',
          desc: 'Failed to get media. Status code: ${response.statusCode}',
          count: 0,
          data: [],
        );
      }
    } catch (e) {
      log('Error getting media: $e');
      return PostMedia(
        code: 'Error',
        desc: 'Network error: ${e.toString()}',
        count: 0,
        data: [],
      );
    }
  }

  /// Parse JSON response from API
  Map<String, dynamic> _parseJsonResponse(String jsonString) {
    try {
      final parsedJson = jsonDecode(jsonString);

      return {
        'Code': parsedJson['Code'] ?? 'Error',
        'Desc': parsedJson['Desc'] ?? 'Unknown error',
        'Data': parsedJson['Data'] ?? [],
      };
    } catch (e) {
      log('Error parsing JSON response: $e');
      return {
        'Code': 'Error',
        'Desc': 'Failed to parse response: ${e.toString()}',
        'Data': [],
      };
    }
  }

  /// Upload post gallery photo
  Future<Map<String, dynamic>> uploadPostGalleryPhoto({
    required String postId,
    required File photoFile,
    required String ourSecret,
  }) async {
    final url = Uri.parse('$base_url/BrowsingRelatedApi.asmx/UploadPostGalleryPhoto');

    try {
      print('📤 Uploading photo for post ID: $postId');
      print('📤 Request URL: $url');
      print('📤 Photo file: ${photoFile.path}');
      print('📤 Photo size: ${await photoFile.length()} bytes');

      // Read file as bytes
      final photoBytes = await photoFile.readAsBytes();

      // Create multipart request
      var request = http.MultipartRequest('POST', url);

      // Add form fields
      request.fields['Post_ID'] = postId;
      request.fields['Our_Secret'] = ourSecret;

      // Add photo file
      request.files.add(
        http.MultipartFile.fromBytes(
          'PhotoBytes',
          photoBytes,
          filename: 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );

      print('📤 Sending request with fields: ${request.fields}');
      print('📤 Sending request with files: ${request.files.length} file(s)');

      // Send request
      final response = await request.send();

      print('📤 Response status: ${response.statusCode}');

      // Get response body
      final responseBody = await response.stream.bytesToString();
      print('📤 Response body: $responseBody');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        print('📤 Upload successful: $jsonResponse');
        return jsonResponse;
      } else {
        throw Exception('Failed to upload photo: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error uploading photo: $e');
      throw Exception('Error uploading photo: $e');
    }
  }

  /// Upload cover photo for a post
  Future<Map<String, dynamic>> uploadCoverPhoto({
    required String postId,
    required String ourSecret,
    required String imagePath,
  }) async {
    final url = Uri.parse(
      '$base_url/BrowsingRelatedApi.asmx/UploadPostCoverPhoto',
    );

    try {
      log('Uploading cover photo for post ID: $postId');

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

      log('Response status: ${response.statusCode}');
      log('Response body: $responseBody');

      if (response.statusCode == 200) {
        // Parse XML response
        return _parseUploadResponse(responseBody);
      } else {
        print('❌ HTTP Error: Status code ${response.statusCode}');
        print('Response Body: $responseBody');
        return {
          'Code': 'Error',
          'Desc': 'Failed to upload cover photo. Status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error uploading cover photo: $e');
      return {
        'Code': 'Error',
        'Desc': 'Error uploading cover photo: $e',
      };
    }
  }

  /// Delete gallery image
  Future<Map<String, dynamic>> deleteGalleryImage({
    required String mediaId,
    required String ourSecret,
  }) async
  {
    final url = Uri.parse(
      '$base_url/BrowsingRelatedApi.asmx/DeleteGalleryImage',
    );

    // Prepare the request body
    final requestBody = {
      'Media_ID': mediaId,
      'Our_Secret': ourSecret,
    };

    log('Deleting gallery image with media ID: $mediaId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: requestBody,
      );

      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Parse JSON response
        final parsedJson = jsonDecode(response.body);
        log('Parsed JSON: $parsedJson');

        return {
          'Code': parsedJson['Code'] ?? 'Error',
          'Desc': parsedJson['Desc'] ?? 'Unknown error',
          'Count': parsedJson['Count'] ?? 0,
        };
      } else {
        print('❌ HTTP Error: Status code ${response.statusCode}');
        print('Response Body: ${response.body}');
        return {
          'Code': 'Error',
          'Desc': 'Failed to delete image. Status code: ${response.statusCode}',
          'Count': 0,
        };
      }
    } catch (e) {
      log('Error deleting gallery image: $e');
      return {
        'Code': 'Error',
        'Desc': 'Network error: ${e.toString()}',
        'Count': 0,
      };
    }
  }

  /// Get post details by post ID
  Future<Map<String, dynamic>> getPostById({
    required String postKind,
    required String postId,
    required String loggedInUser,
  }) async {
    final url = Uri.parse(
      '$base_url/BrowsingRelatedApi.asmx/GetPostByID',
    );

    // Prepare the request body
    final requestBody = {
      'Post_Kind': postKind,
      'Post_ID': postId,
      'Logged_In_User': loggedInUser,
    };

    log('Getting post details for post ID: $postId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: requestBody,
      );

      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Parse JSON response
        final parsedJson = jsonDecode(response.body);
        log('Parsed JSON: $parsedJson');

        return {
          'Code': parsedJson['Code'] ?? 'Error',
          'Desc': parsedJson['Desc'] ?? 'Unknown error',
          'Count': parsedJson['Count'] ?? 0,
          'Data': parsedJson['Data'] ?? [],
        };
      } else {
        print('❌ HTTP Error: Status code ${response.statusCode}');
        print('Response Body: ${response.body}');
        return {
          'Code': 'Error',
          'Desc': 'Failed to get post details. Status code: ${response.statusCode}',
          'Count': 0,
          'Data': [],
        };
      }
    } catch (e) {
      log('Error getting post details: $e');
      return {
        'Code': 'Error',
        'Desc': 'Network error: ${e.toString()}',
        'Count': 0,
        'Data': [],
      };
    }
  }

  // Request types for RegisterPostRequest
  static const String requestTypeFeaturePost = 'Request to Feature a Post';
  static const String requestType360Session = 'Request 360 Photo Session';
  // static const String requestTypePublish = 'Publish Post';
  // static const String requestTypeArchive = 'Archive Post';

  /// Register Post Request (e.g., Feature Post, 360 Session)
  Future<Map<String, dynamic>> registerPostRequest({
    required String userName,
    required String postId,
    required String requestType,
    required String ourSecret,
  }) async {
    final url = Uri.parse(
      '$base_url/BrowsingRelatedApi.asmx/RegisterPostRequest',
    );

    // Basic validation to avoid backend "Missing One or More Parameter"
    if (userName.trim().isEmpty || postId.trim().isEmpty || requestType.trim().isEmpty || ourSecret.trim().isEmpty) {
      return {
        'Code': 'Error',
        'Desc': 'Missing one or more required parameters',
        'Count': 0,
        'Data': null,
      };
    }

    final requestBody = {
      'UserName': userName,
      'Post_ID': postId,
      'Request_Type': requestType,
      'Our_Secret': ourSecret,
    };

    log('Registering post request: user=$userName, postId=$postId, type=$requestType');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: requestBody,
      );

      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final parsedJson = jsonDecode(response.body);
        return {
          'Code': parsedJson['Code'] ?? 'Error',
          'Desc': parsedJson['Desc'] ?? 'Unknown error',
          'Count': parsedJson['Count'] ?? 0,
          'Data': parsedJson['Data'],
        };
      } else {
        return {
          'Code': 'Error',
          'Desc': 'Failed to register post request. Status code: ${response.statusCode}',
          'Count': 0,
          'Data': null,
        };
      }
    } catch (e) {
      log('Error registering post request: $e');
      return {
        'Code': 'Error',
        'Desc': 'Network error: ${e.toString()}',
        'Count': 0,
        'Data': null,
      };
    }
  }

  /// Convenience: request to feature a post (pin to top)
  Future<Map<String, dynamic>> requestToFeaturePost({
    required String userName,
    required String postId,
    required String ourSecret,
  }) {
    return registerPostRequest(
      userName: userName,
      postId: postId,
      requestType: requestTypeFeaturePost,
      ourSecret: ourSecret,
    );
  }

  /// Convenience: request a 360 photo session
  Future<Map<String, dynamic>> request360PhotoSession({
    required String userName,
    required String postId,
    required String ourSecret,
  }) {
    return registerPostRequest(
      userName: userName,
      postId: postId,
      requestType: requestType360Session,
      ourSecret: ourSecret,
    );
  }

  /// Request publish/approval for a post
  Future<Map<String, dynamic>> requestPostApproval({
    required String userName,
    required String postId,
    required String ourSecret,
  }) async {
    final url = Uri.parse(
      '$base_url/BrowsingRelatedApi.asmx/RequestPostApproval',
    );

    // Basic validation
    if (userName.trim().isEmpty || postId.trim().isEmpty || ourSecret.trim().isEmpty) {
      return {
        'Code': 'Error',
        'Desc': 'Missing one or more required parameters',
        'Count': 0,
        'Data': null,
      };
    }

    final requestBody = {
      'UserName': userName,
      'Post_ID': postId,
      'Our_Secret': ourSecret,
    };

    log('Requesting post approval: user=$userName, postId=$postId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: requestBody,
      );

      log('Approval Response status: ${response.statusCode}');
      log('Approval Response body: ${response.body}');

      if (response.statusCode == 200) {
        final parsedJson = jsonDecode(response.body);
        return {
          'Code': parsedJson['Code'] ?? 'Error',
          'Desc': parsedJson['Desc'] ?? 'Unknown error',
          'Count': parsedJson['Count'] ?? 0,
          'Data': parsedJson['Data'],
        };
      } else {
        return {
          'Code': 'Error',
          'Desc': 'Failed to request post approval. Status code: ${response.statusCode}',
          'Count': 0,
          'Data': null,
        };
      }
    } catch (e) {
      log('Error requesting post approval: $e');
      return {
        'Code': 'Error',
        'Desc': 'Network error: ${e.toString()}',
        'Count': 0,
        'Data': null,
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

  /// Get Qars request status for a post (feature / 360 / ...).
  /// This calls:
  /// GET https://qarspartnersportalapitest.smartvillageqatar.com/api/v1/QarsRequests/Get-Request
  /// and returns the decoded JSON list ([] if no records).
  Future<List<dynamic>> getQarsRequestStatus({
    required int postId,
    required String requestType,
  }) async {
    // بنبني الـ URL بالـ query parameters
    final uri = Uri.https(
      'qarspartnersportalapitest.smartvillageqatar.com',
      '/api/v1/QarsRequests/Get-Request',
      <String, String>{
        'postId': postId.toString(),
        'RequestType': requestType,
        'RequestFrom': 'Individual',
      },
    );

    log('🔍 Calling Get-Request: $uri');

    try {
      final response = await http.get(
        uri,
        headers: {
          'accept': '*/*',
        },
      );

      log('🔍 Get-Request status: ${response.statusCode}');
      log('🔍 Get-Request body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // الـ API بيرجع [] أو List من الـ requests
        if (decoded is List) {
          return decoded;
        } else {
          log('⚠️ Unexpected Get-Request response type: ${decoded.runtimeType}');
          return [];
        }
      } else {
        log('❌ Get-Request HTTP error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('❌ Exception in getQarsRequestStatus: $e');
      return [];
    }
  }

}