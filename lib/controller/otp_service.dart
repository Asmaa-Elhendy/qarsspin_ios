/**import 'package:cloud_functions/cloud_functions.dart';
import 'dart:developer' as l;

class OtpService {
  // نحدد المنطقة (Region) اللي رفعنا عليها الـ Functions
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

  // 1. طلب إرسال كود
  Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    try {
      HttpsCallable callable = _functions.httpsCallable('sendOtp');
      final result = await callable.call(<String, dynamic>{
        'phone': phoneNumber,
      });
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      l.log('Error in sendOtp: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // 2. التحقق من الكود
  Future<bool> verifyOtp(String phoneNumber, String smsCode) async {
    try {
      HttpsCallable callable = _functions.httpsCallable('verifyOtp');
      final result = await callable.call(<String, dynamic>{
        'phone': phoneNumber,
        'code': smsCode,
      });
      return result.data['status'] == 'approved';
    } catch (e) {
      l.log('Error in verifyOtp: $e');
      return false;
    }
  }
}**/