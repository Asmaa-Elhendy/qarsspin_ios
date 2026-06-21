
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

String _normalizePhoneNumber(String phoneNumber) {
  String phone = phoneNumber.trim();

  // remove spaces, dashes, brackets
  phone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

  // remove +
  if (phone.startsWith('+')) {
    phone = phone.substring(1);
  }

  // convert 00974... to 974...
  if (phone.startsWith('00')) {
    phone = phone.substring(2);
  }

  // لو الرقم قطري محلي 8 أرقام، ضيفي كود قطر
  if (phone.length == 8) {
    phone = '974$phone';
  }

  return phone;
}

Future<void> makePhoneCall(String phoneNumber) async {
  final Uri url = Uri(scheme: 'tel', path: phoneNumber.trim());

  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw 'Could not launch $url';
  }
}

Future<void> openWhatsApp(String phoneNumber, {String message = ""}) async {
  final String phone = _normalizePhoneNumber(phoneNumber);
  final String encodedMessage = Uri.encodeComponent(message);

  final Uri whatsappAppUrl = Uri.parse(
    'whatsapp://send?phone=$phone&text=$encodedMessage',
  );

  final Uri whatsappWebUrl = Uri.parse(
    'https://api.whatsapp.com/send?phone=$phone&text=$encodedMessage',
  );

  try {
    final bool launchedApp = await launchUrl(
      whatsappAppUrl,
      mode: LaunchMode.externalApplication,
    );

    if (launchedApp) {
      return;
    }

    final bool launchedWeb = await launchUrl(
      whatsappWebUrl,
      mode: LaunchMode.externalApplication,
    );

    if (!launchedWeb) {
      throw 'Could not launch WhatsApp';
    }
  } catch (e) {
    final bool launchedWeb = await launchUrl(
      whatsappWebUrl,
      mode: LaunchMode.externalApplication,
    );

    if (!launchedWeb) {
      throw 'Could not launch WhatsApp';
    }
  }
}

Future<void> openMap(String url) async {
  final Uri uri = Uri.parse(url);

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw "Could not open the map.";
  }
}

Future<XFile?> _downloadImageToTemp(String url) async {
  try {
    final Uri uri = Uri.parse(url);
    final http.Response response = await http
        .get(uri)
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
      return null;
    }

    String extension = '.jpg';
    final String path = uri.path.toLowerCase();
    if (path.endsWith('.png')) {
      extension = '.png';
    } else if (path.endsWith('.webp')) {
      extension = '.webp';
    } else if (path.endsWith('.jpeg')) {
      extension = '.jpeg';
    }

    final Directory tempDir = Directory.systemTemp;
    final String fileName =
        'qarsspin_share_${DateTime.now().millisecondsSinceEpoch}$extension';
    final File file = File('${tempDir.path}${Platform.pathSeparator}$fileName');
    await file.writeAsBytes(response.bodyBytes, flush: true);

    return XFile(file.path);
  } catch (_) {
    return null;
  }
}

Future<void> shareCarFromQarsSpin({
  required String carName,
  required String year,
  required String price,
  required String adCode,
  String priceLabel = 'Price',
  String? category,
  String? mileage,
  String? exteriorColor,
  String? interiorColor,
  String? description,
  String? sourceKind,
  String? imageUrl,
  Map<String, String>? extraInfo,
  List<MapEntry<String, String>>? specifications,
}) async {
  const String playStoreLink =
      'https://play.google.com/store/apps/details?id=com.qarsspin.mobile';

  const String appStoreLink =
      'https://apps.apple.com/eg/app/qars-spin/id6630392818';

  final List<String> lines = <String>[
    'Car you may like from Qars Spin app 🚗',
    '',
    carName,
    'Year: $year',
    '$priceLabel: $price',
  ];

  void addIfPresent(String label, String? value) {
    if (value != null && value.trim().isNotEmpty) {
      lines.add('$label: ${value.trim()}');
    }
  }

  addIfPresent('Category', category);
  addIfPresent('Mileage', mileage);
  addIfPresent('Exterior color', exteriorColor);
  addIfPresent('Interior color', interiorColor);
  addIfPresent('Source', sourceKind);

  if (extraInfo != null) {
    extraInfo.forEach((String label, String value) {
      addIfPresent(label, value);
    });
  }

  addIfPresent('Description', description);

  if (specifications != null && specifications.isNotEmpty) {
    final List<String> specLines = <String>[];
    for (final MapEntry<String, String> entry in specifications) {
      final String label = entry.key.trim();
      final String value = entry.value.trim();
      if (label.isEmpty || value.isEmpty) continue;
      specLines.add('• $label: $value');
    }
    if (specLines.isNotEmpty) {
      lines.add('');
      lines.add('Specifications:');
      lines.addAll(specLines);
    }
  }

  lines.add('');
  lines.add('AD Code: $adCode');
  lines.add('');
  lines.add('Download Qars Spin app:');
  lines.add('Android: $playStoreLink');
  lines.add('iOS: $appStoreLink');

  final String message = lines.join('\n');
  const String subject = 'Car you may like from Qars Spin app';

  XFile? imageFile;
  if (imageUrl != null && imageUrl.trim().isNotEmpty) {
    imageFile = await _downloadImageToTemp(imageUrl.trim());
  }

  if (imageFile != null) {
    await Share.shareXFiles(
      <XFile>[imageFile],
      text: message,
      subject: subject,
    );
  } else {
    await Share.share(message, subject: subject);
  }
}
Future<void> shareCarCareFromQarsSpin({
  required String name,
  required String rating,
  required String type,
  String? branchName,
  String? description,
  String? phone,
  String? whatsapp,
  String? mapsUrl,
  String? joiningDate,
  int? visitsCount,
  int? activePosts,
  int? followersCount,
  int? carsCount,
  String? imageUrl,
}) async {
  const String playStoreLink =
      'https://play.google.com/store/apps/details?id=com.qarsspin.mobile';

  const String appStoreLink =
      'https://apps.apple.com/eg/app/qars-spin/id6630392818';

  final List<String> lines = <String>[
    '$type you may like from Qars Spin app 🚗',
    '',
    name,
  ];

  void addIfPresent(String label, String? value) {
    if (value != null && value.trim().isNotEmpty) {
      lines.add('$label: ${value.trim()}');
    }
  }

  addIfPresent('Branch', branchName);
  if (rating.trim().isNotEmpty) {
    lines.add('Rating: ${rating.trim()} / 5');
  }
  if (activePosts != null && activePosts > 0) {
    lines.add('Active posts: $activePosts');
  }
  if (carsCount != null && carsCount > 0) {
    lines.add('Cars: $carsCount');
  }
  if (followersCount != null && followersCount > 0) {
    lines.add('Followers: $followersCount');
  }
  if (visitsCount != null && visitsCount > 0) {
    lines.add('Visits: $visitsCount');
  }
  addIfPresent('Joined', joiningDate);
  addIfPresent('Phone', phone);
  addIfPresent('WhatsApp', whatsapp);
  addIfPresent('Location', mapsUrl);
  addIfPresent('About', description);

  lines.add('');
  lines.add('Download Qars Spin app:');
  lines.add('Android: $playStoreLink');
  lines.add('iOS: $appStoreLink');

  final String message = lines.join('\n');
  final String subject = '$type you may like from Qars Spin app';

  XFile? imageFile;
  if (imageUrl != null && imageUrl.trim().isNotEmpty) {
    imageFile = await _downloadImageToTemp(imageUrl.trim());
  }

  if (imageFile != null) {
    await Share.shareXFiles(
      <XFile>[imageFile],
      text: message,
      subject: subject,
    );
  } else {
    await Share.share(message, subject: subject);
  }
}