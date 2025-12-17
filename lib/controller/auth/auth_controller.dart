// import 'package:get/get.dart';
// import 'package:qarsspin/controller/auth/auth_data_layer.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:developer';
//
// class AuthController extends GetxController {
//   final AuthDataLayer _authDataLayer = AuthDataLayer();
//
//   // Registered state
//   final RxBool _registered = false.obs;
//
//   // Getter for registered state
//   bool get registered => _registered.value;
//
//   // Loading state
//   final RxBool isLoading = false.obs;
//
//   // Error message
//   final RxString errorMessage = ''.obs;
//
//   // Success message
//   final RxString successMessage = ''.obs;
//
//   // Get the current user's full name to use across app
//   String? get userFullName => _fullName.value; //use it  ((owner name))
//   final RxString _fullName = ''.obs;
//
//   String? get userName => _userName.value; //use it
//   final RxString _userName = ''.obs;
//
//   String? get ownerMobile => _ownerMobile.value; //use it  ((owner name)) //"Owner_Mobile"->+    "Mobile":
//   final RxString _ownerMobile = ''.obs;
//
//   String? get ownerEmail => _ownerEmail.value; //use it   // "Owner_Email"   "Email":
//   final RxString _ownerEmail = ''.obs;
//
//
//   @override
//   void onInit() async {
//     super.onInit();
//     // Load user data from SharedPreferences
//     final prefs = await SharedPreferences.getInstance();
//
//     _registered.value = prefs.getString('username')?.isNotEmpty ?? false;
//     if (_registered.value) {
//       _fullName.value = prefs.getString('fullName') ?? '';
//       _userName.value=prefs.getString('username')??'';
//       _ownerEmail.value=prefs.getString('Email')??'';
//       _ownerMobile.value=prefs.getString('Mobile')??'';
//     }
//
//     // Print current user data
//     log('User is ${_registered.value ? 'registered' : 'not registered'}');
//     if (_registered.value) {
//       log('Mobile Number: ${prefs.getString('username')}');
//       log('Full Name: ${_fullName.value}');
//       log('Owner Mobile: ${_ownerMobile.value}');
//       log('Owner Email: ${_ownerEmail.value}');
//       log('real user name: ${_userName.value}');
//     }
//   }
//
//   void updateRegisteredStatus(bool value,String userName,String fullName,String mobile,String email) {
//     _registered.value = value;
//     _userName.value=userName;
//     _fullName.value=fullName;
//     _ownerMobile.value=mobile;
//     _ownerEmail.value=email;
//   }
//
//   // Update user data in SharedPreferences
//   Future<void> _updateUserData(String username, String fullName,String email,String mobile) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('username', username);
//     await prefs.setString('fullName', fullName);
//     await prefs.setString('Mobile',mobile);
//     await prefs.setString('Email', email);
//     _registered.value = true;
//     _fullName.value = fullName;
//     _userName.value=username;
//     _ownerEmail.value=email;
//     _ownerMobile.value=mobile;
//   }
//
//   // Clear user data (for logout)
//   Future<void> clearUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Log the data before clearing (for debugging)
//     final mobileNumber = prefs.getString('username');
//     final fullName = prefs.getString('fullName');
//
//     // Clear all user data
//     await prefs.remove('username');
//     await prefs.remove('fullName');
//     await prefs.remove('Mobile');
//     await prefs.remove('Email');
//
//     // Update the state
//     _registered.value = false;
//     _fullName.value = '';
//     _ownerEmail.value='';
//     _ownerMobile.value='';
//
//     // Log the action
//     log('User signed out. Cleared data:',
//         name: 'AuthController',
//         error: 'Mobile: $mobileNumber, Full Name: $fullName');
//   }
//
//   // Get current user data
//   Map<String, String> getCurrentUser() {
//     return {
//       'username': _registered.value ? _fullName.value : '',
//       'fullName': _fullName.value,
//       'mobile':_ownerMobile.value,
//       'email':_ownerEmail.value
//     };
//   }
//
//   // Register new user
//   // In auth_controller.dart
//   Future<Map<String, dynamic>> registerUser({
//     required String userName,
//     required String fullName,
//     required String email,
//     required String mobileNumber,
//     required String selectedCountry,
//     required String firebaseToken,
//     required String preferredLanguage,
//     required String ourSecret,
//   }) async {
//     try {
//       isLoading.value = true;
//       errorMessage.value = '';
//       successMessage.value = '';
//
//       final response = await _authDataLayer.registerUser(
//         userName: userName,
//         fullName: fullName,
//         email: email,
//         mobileNumber: mobileNumber,
//         selectedCountry: selectedCountry,
//         firebaseToken: firebaseToken,
//         preferredLanguage: preferredLanguage,
//         ourSecret: ourSecret,
//       );
//
//       log('Register user response: ${response.toString()}');
//
//       // Handle response
//       if (response['Code'] == 'OK' && response['Data'] != null && (response['Data'] as List).isNotEmpty) {
//         final userData = response['Data'][0];
//         log('User data: $userData');
//
//         // Save user data
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('username', userData['Mobile'] ?? mobileNumber);
//         if (userData['Full_Name'] != null) {
//           await prefs.setString('fullName', userData['Full_Name']);
//           await prefs.setString('Mobile', userData['Mobile']);
//           await prefs.setString('Email', userData['Email']);
//         }
//
//
//
//         // Update auth state
//         _registered.value = true;
//         _fullName.value = userData['Full_Name'] ?? fullName;
//         _userName.value = userData['Mobile'] ?? mobileNumber;
//         _ownerEmail.value=userData['Email']??email;
//         _ownerMobile.value= userData['Mobile']??mobileNumber;
//
//         return {
//           'success': true,
//           'message': response['Desc'] ?? 'Registration successful',
//           'Code': 'OK',
//           'Data': response['Data'],
//         };
//       }
//
//       // If we get here, it means the response has an OK code but no data
//       return {
//         'success': true,  // Still treat as success since the server returned OK
//         'message': response['Desc'] ?? 'Registration successful',
//         'Code': 'OK',
//         'Data': response['Data'] ?? [],
//       };
//     } catch (e) {
//       log('Error in registerUser: $e');
//       return {
//         'success': false,
//         'message': 'An error occurred: $e',
//         'Code': 'Error',
//       };
//     } finally {
//       isLoading.value = false;
//     }
//   }
//   // Request OTP
//   Future<Map<String, dynamic>> requestOtp({
//     required String userName,
//     required String otpSecret,
//     required String ourSecret,
//   }) async {
//     try {
//       isLoading.value = true;
//       errorMessage.value = '';
//       successMessage.value = '';
//
//       final response = await _authDataLayer.requestOtp(
//         userName: userName,
//         otpSecret: otpSecret,
//         ourSecret: ourSecret,
//       );
//
//       if (response['success'] == true) {
//         successMessage.value = response['message'] ?? 'OTP sent successfully';
//         return {
//           'success': true,
//           'message': successMessage.value,
//           'Count': response['Count'],  // Pass through the Count
//           'data': response['data']     // Pass through the full response data
//         };
//       } else {
//         errorMessage.value = response['message'] ?? 'Failed to send OTP';
//         return {'success': false, 'message': errorMessage.value};
//       }
//     } catch (e) {
//       errorMessage.value = 'An error occurred: $e';
//       return {'success': false, 'message': errorMessage.value};
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   // Clear messages
//   void clearMessages() {
//     errorMessage.value = '';
//     successMessage.value = '';
//   }
// }
import 'dart:developer';

import 'package:get/get.dart';
import 'package:qarsspin/controller/auth/auth_data_layer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  final AuthDataLayer _authDataLayer = AuthDataLayer();

  // Registered state
  final RxBool _registered = false.obs;
  bool get registered => _registered.value;

  // Loading state
  final RxBool isLoading = false.obs;

  // Error message
  final RxString errorMessage = ''.obs;

  // Success message
  final RxString successMessage = ''.obs;

  // User data
  final RxString _fullName = ''.obs;
  String? get userFullName => _fullName.value; // ((owner name))

  final RxString _userName = ''.obs;
  String? get userName => _userName.value;

  final RxString _ownerMobile = ''.obs;
  String? get ownerMobile => _ownerMobile.value;

  final RxString _ownerEmail = ''.obs;
  String? get ownerEmail => _ownerEmail.value;

  @override
  void onInit() async {
    super.onInit();
    await _loadUserFromPrefs();
  }

  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    _registered.value = prefs.getString('username')?.isNotEmpty ?? false;
    if (_registered.value) {
      _fullName.value = prefs.getString('fullName') ?? '';
      _userName.value = prefs.getString('username') ?? '';
      _ownerEmail.value = prefs.getString('Email') ?? '';
      _ownerMobile.value = prefs.getString('Mobile') ?? '';

      log('User is registered');
      log('User Name: ${_userName.value}');
      log('Full Name: ${_fullName.value}');
      log('Owner Mobile: ${_ownerMobile.value}');
      log('Owner Email: ${_ownerEmail.value}');
      log('real user name: ${_userName.value}');
    } else {
      log('User is not registered');
    }
  }

  /// تستخدمها في أي وقت تحب تحدّث حالة التسجيل يدويًا
  void updateRegisteredStatus(
      bool value, String userName, String fullName, String mobile, String email) {
    _registered.value = value;
    _userName.value = userName;
    _fullName.value = fullName;
    _ownerMobile.value = mobile;
    _ownerEmail.value = email;
  }

  /// مكان واحد لتحديث SharedPreferences + الـ state
  Future<void> _updateUserData(
      String username, String fullName, String email, String mobile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('fullName', fullName);
    await prefs.setString('Mobile', mobile);
    await prefs.setString('Email', email);

    _registered.value = true;
    _fullName.value = fullName;
    _userName.value = username;
    _ownerEmail.value = email;
    _ownerMobile.value = mobile;

    log('🔐 Saved user to prefs: username=$username, fullName=$fullName, mobile=$mobile, email=$email');
  }

  /// تحفظ بيانات اليوزر اللي راجعة من الـ API (login أو register)
  Future<void> saveUserFromApiData(Map<String, dynamic> userData) async {
    // نحاول نقرأ بالقيم اللي عندك في السيرفر
    final mobile =
    (userData['Mobile'] ?? userData['UserName'] ?? '').toString();
    final fullName = (userData['Full_Name'] ?? '').toString();
    final email = (userData['Email'] ?? '').toString();

    if (mobile.isEmpty && fullName.isEmpty && email.isEmpty) {
      log('⚠️ saveUserFromApiData: empty data, skipping');
      return;
    }

    final username = userData['UserName'] .toString();
    await _updateUserData(username, fullName, email, mobile.isNotEmpty ? mobile : username);
  }

  // Clear user data (for logout)
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();

    final mobileNumber = prefs.getString('username');
    final fullName = prefs.getString('fullName');

    await prefs.remove('username');
    await prefs.remove('fullName');
    await prefs.remove('Mobile');
    await prefs.remove('Email');

    _registered.value = false;
    _fullName.value = '';
    _ownerEmail.value = '';
    _ownerMobile.value = '';
    _userName.value = '';

    log('User signed out. Cleared data:',
        name: 'AuthController',
        error: 'Mobile: $mobileNumber, Full Name: $fullName');
  }

  // Get current user data
  Map<String, String> getCurrentUser() {
    return {
      // ✅ هنا كانت المشكلة قبل كده: كنت راجع fullName بدل userName
      'username': _registered.value ? _userName.value : '',
      'fullName': _fullName.value,
      'mobile': _ownerMobile.value,
      'email': _ownerEmail.value,
    };
  }

  // Register new user
  Future<Map<String, dynamic>> registerUser({
    required String userName,
    required String fullName,
    required String email,
    required String mobileNumber,
    required String selectedCountry,
    required String firebaseToken,
    required String preferredLanguage,
    required String ourSecret,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      successMessage.value = '';

      final response = await _authDataLayer.registerUser(
        userName: userName,
        fullName: fullName,
        email: email,
        mobileNumber: mobileNumber,
        selectedCountry: selectedCountry,
        firebaseToken: firebaseToken,
        preferredLanguage: preferredLanguage,
        ourSecret: ourSecret,
      );

      log('Register user response: ${response.toString()}');

      if (response['Code'] == 'OK' &&
          response['Data'] != null &&
          (response['Data'] as List).isNotEmpty) {
        final userData = response['Data'][0];
        log('User data: $userData');

        await saveUserFromApiData(userData);

        return {
          'success': true,
          'message': response['Desc'] ?? 'Registration successful',
          'Code': 'OK',
          'Data': response['Data'],
        };
      }

      return {
        'success': true,
        'message': response['Desc'] ?? 'Registration successful',
        'Code': 'OK',
        'Data': response['Data'] ?? [],
      };
    } catch (e) {
      log('Error in registerUser: $e');
      return {
        'success': false,
        'message': 'An error occurred: $e',
        'Code': 'Error',
      };
    } finally {
      isLoading.value = false;
    }
  }

  // Request OTP
  Future<Map<String, dynamic>> requestOtp({
    required String userName,
    required String otpSecret,
    required String ourSecret,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      successMessage.value = '';

      final response = await _authDataLayer.requestOtp(
        userName: userName,
        otpSecret: otpSecret,
        ourSecret: ourSecret,
      );

      if (response['success'] == true) {
        successMessage.value = response['message'] ?? 'OTP sent successfully';
        return {
          'success': true,
          'message': successMessage.value,
          'Count': response['Count'],
          'data': response['data']
        };
      } else {
        errorMessage.value = response['message'] ?? 'Failed to send OTP';
        return {'success': false, 'message': errorMessage.value};
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
      return {'success': false, 'message': errorMessage.value};
    } finally {
      isLoading.value = false;
    }
  }

  // Clear messages
  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }
}
