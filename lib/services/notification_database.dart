import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:qarsspin/controller/const/base_url.dart';

class NotificationDatabase {
  static final NotificationDatabase _instance = NotificationDatabase._internal();

  factory NotificationDatabase() => _instance;
  NotificationDatabase._internal();
//j
  Future<Map<String, dynamic>> fetchNotificationsFromAPI({
    required String userName,
    required String ourSecret,
  }) async {
    try {
      final url = Uri.parse(
        '$base_url/BrowsingRelatedApi.asmx/GetNotificationsListByUser',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'UserName': userName, 'Our_Secret': ourSecret},
      );

      log('🔹 Raw API response (${response.statusCode}): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse; // Return the complete response
      } else {
        log('❌ HTTP Error: ${response.statusCode}');
        return {
          'Code': 'Error',
          'Desc': 'HTTP Error ${response.statusCode}',
          'Count': 0,
          'Data': []
        };
      }
    } catch (e, s) {
      log('❌ Exception in fetchNotificationsFromAPI: $e');
      log('$s');
      return {
        'Code': 'Error',
        'Desc': 'Exception: $e',
        'Count': 0,
        'Data': []
      };
    }
  }
}