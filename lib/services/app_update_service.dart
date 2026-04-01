import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

class AppUpdateService {
  static const String appStoreId = "6630392818"; // Apple ID
  static const String androidPackageName = "YOUR_PACKAGE_NAME"; // Android Package

  /// تجيب نسخة المتجر حسب الـ platform
  static Future<String?> getStoreVersion() async {
    if (Platform.isIOS) {
      final res = await http.get(
        Uri.parse("https://itunes.apple.com/lookup?id=$appStoreId"),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          return data['results'][0]['version'];
        }
      }
      return null;
    } else if (Platform.isAndroid) {
       try {
      //   final url =
      //       "https://play.google.com/store/apps/details?id=$androidPackageName&hl=en&gl=US";
      //   final res = await http.get(Uri.parse(url));
      //   if (res.statusCode == 200) {
      //     final document = parse(res.body);
      //     // جلب النسخة من الـ meta tag
      //     Element? versionElement;
      //     for (var element in document.querySelectorAll('script')) {
      //       if (element.text.contains('key: "softwareVersion"')) {
      //         versionElement = element;
      //         break;
      //       }
      //     }
      //
      //     if (versionElement != null) {
      //       final regex = RegExp(r'"softwareVersion":"(.*?)"');
      //       final match = regex.firstMatch(versionElement.text);
      //       if (match != null) {
             // return match.group(1);
        //     }
        //   }
        // }

      } catch (e) {
        print("Error fetching Android store version: $e");
      }
      return null;
    } else {
      return null;
    }
  }

  /// تجيب نسخة التطبيق الحالية من الجهاز
  static Future<String> getCurrentVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  /// تتحقق إذا في تحديث
  static bool isUpdateAvailable(String current, String store) {
    return current != store;
  }

  /// ترجّع رابط المتجر حسب الـ platform
  static String getStoreUrl() {
    if (Platform.isIOS) {
      return "https://apps.apple.com/app/id$appStoreId";
    } else if (Platform.isAndroid) {
      return "https://play.google.com/store/apps/details?id=$androidPackageName";
    } else {
      return "";
    }
  }
}