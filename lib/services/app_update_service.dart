import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
// html parser is no longer needed — we scan the raw HTML body directly
// with a list of regex patterns, which is more resilient to Google's
// frequent Play Store DOM restructurings.

class AppUpdateService {
  static const String appStoreId = "6630392818"; // Apple ID
  static const String androidPackageName = "com.qarsspin.mobile";

  /// تجيب نسخة المتجر حسب الـ platform
  static Future<String?> getStoreVersion() async {
    if (Platform.isIOS) {
      final Uri url =
          Uri.parse("https://itunes.apple.com/lookup?id=$appStoreId");
      print('🔎 [AppUpdate] fetching iOS store version from $url');
      try {
        final res = await http.get(url);
        print('🔎 [AppUpdate] iOS lookup status=${res.statusCode}');
        if (res.statusCode == 200) {
          final data = json.decode(res.body);
          if (data['results'] != null && data['results'].isNotEmpty) {
            final String version = data['results'][0]['version'].toString();
            print('🔎 [AppUpdate] iOS store version resolved: $version');
            return version;
          }
          print(
            '🔎 [AppUpdate] iOS lookup returned empty results — is $appStoreId '
            'the correct Apple ID for this app?',
          );
        }
      } catch (e) {
        print('🔎 [AppUpdate] iOS lookup failed: $e');
      }
      return null;
    } else if (Platform.isAndroid) {
      try {
        final url =
            "https://play.google.com/store/apps/details?id=$androidPackageName&hl=en&gl=US";
        print('🔎 [AppUpdate] fetching Android store version from $url');
        final res = await http.get(Uri.parse(url));
        print('🔎 [AppUpdate] Android page status=${res.statusCode}');
        if (res.statusCode == 200) {
          // Google changes the Play Store HTML shape every few months.
          // Try a series of known patterns instead of a single regex.
          // Each patterns pulls out an "X.Y.Z" version string from one
          // of the shapes Google has shipped over the last 2 years.
          final String body = res.body;
          final List<RegExp> patterns = <RegExp>[
            // Old inline JSON key.
            RegExp(r'"softwareVersion":"([0-9]+\.[0-9]+(?:\.[0-9]+)?)"'),
            // Escaped variant (some responses double-escape quotes).
            RegExp(r'\\"softwareVersion\\":\\"([0-9]+\.[0-9]+(?:\.[0-9]+)?)\\"'),
            // Newer structured data — the version sits by itself in the
            // AF_initDataCallback blob as `[["1.2.3"]]`.
            RegExp(r'\[\[\"([0-9]+\.[0-9]+\.[0-9]+)\"\]\]'),
            // itemprop meta tag (rare but still shipped on some locales).
            RegExp(
              r'<meta[^>]+itemprop="softwareVersion"[^>]+content="([^"]+)"',
            ),
            // Last-resort: "Version" label followed by an X.Y.Z string.
            RegExp(r'Current Version[^0-9]{1,80}([0-9]+\.[0-9]+\.[0-9]+)'),
          ];
          for (int i = 0; i < patterns.length; i++) {
            final Match? match = patterns[i].firstMatch(body);
            if (match != null) {
              final String version = match.group(1)!;
              print(
                '🔎 [AppUpdate] Android store version resolved via pattern '
                '#${i + 1}: $version',
              );
              return version;
            }
          }
          // All patterns failed — dump a small window around the word
          // "Version" from the HTML so we can eyeball what Google is
          // actually shipping today and add a new pattern next time.
          final int idx = body.toLowerCase().indexOf('version');
          if (idx >= 0) {
            final int start = idx > 200 ? idx - 200 : 0;
            final int end = idx + 400 < body.length ? idx + 400 : body.length;
            print(
              '🔎 [AppUpdate] All patterns failed. HTML snippet around '
              '"version": ${body.substring(start, end)}',
            );
          } else {
            print(
              '🔎 [AppUpdate] All patterns failed and "version" not found '
              'anywhere in the page — Google may be region-gating or the '
              'app listing may be missing.',
            );
          }
        }
      } catch (e) {
        print("🔎 [AppUpdate] Error fetching Android store version: $e");
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

  /// Returns `true` **only** when the store version is a strictly
  /// higher semantic version than what's on the device.
  ///
  /// The previous implementation used `current != store`, which
  /// triggered the "app outdated" screen whenever the two strings
  /// differed at all — including cases where the phone was actually
  /// AHEAD of the store (dev builds, staged rollouts, TestFlight
  /// previews). Semver comparison eliminates those false positives.
  ///
  /// Segments after `+` (build metadata, e.g. "2.4.2+229") and `-`
  /// (pre-release, e.g. "2.4.2-rc1") are stripped before comparison
  /// so `2.4.2+229` and `2.4.2` compare equal, not different.
  static bool isUpdateAvailable(String current, String store) {
    final int cmp = _compareVersions(store, current);
    final bool needsUpdate = cmp > 0;
    // Verbose so you can eyeball the whole decision in the console.
    print(
      '🔎 [AppUpdate] compare store="$store" vs current="$current" '
      '→ cmp=$cmp, needsUpdate=$needsUpdate',
    );
    return needsUpdate;
  }

  /// -1 if [a] < [b], 0 if equal, 1 if [a] > [b].
  static int _compareVersions(String a, String b) {
    final List<int> aParts = _parseVersion(a);
    final List<int> bParts = _parseVersion(b);
    final int len =
        aParts.length > bParts.length ? aParts.length : bParts.length;
    for (int i = 0; i < len; i++) {
      final int ai = i < aParts.length ? aParts[i] : 0;
      final int bi = i < bParts.length ? bParts[i] : 0;
      if (ai < bi) return -1;
      if (ai > bi) return 1;
    }
    return 0;
  }

  static List<int> _parseVersion(String v) {
    final String core = v.split(RegExp(r'[+\-]')).first.trim();
    return core.split('.').map((s) => int.tryParse(s) ?? 0).toList();
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