import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

bool _isSharing = false;

/// iOS needs a valid popover origin, especially on iPad and sometimes
/// on real iPhone release builds.
Rect _sharePositionOrigin(BuildContext context) {
  final RenderObject? renderObject = context.findRenderObject();

  if (renderObject is RenderBox && renderObject.hasSize) {
    return renderObject.localToGlobal(Offset.zero) & renderObject.size;
  }

  return const Rect.fromLTWH(0, 0, 100, 100);
}

String _normalizePhoneNumber(String phoneNumber) {
  String phone = phoneNumber.trim();

  // Remove spaces, dashes, and brackets.
  phone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

  // Remove +.
  if (phone.startsWith('+')) {
    phone = phone.substring(1);
  }

  // Convert 00974... to 974...
  if (phone.startsWith('00')) {
    phone = phone.substring(2);
  }

  // If the number is a local Qatar number with 8 digits, add Qatar code.
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
  } catch (_) {
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

/// Uses cache instead of downloading the image manually every time.
/// This makes sharing faster on iOS because the image is usually already cached
/// from the car details screen.
Future<XFile?> _downloadImageToTemp(String url) async {
  try {
    final File file = await DefaultCacheManager().getSingleFile(url);

    if (!await file.exists()) {
      return null;
    }

    return XFile(file.path);
  } catch (_) {
    return null;
  }
}

Future<void> _shareQarsSpinContent({
  required BuildContext context,
  required String message,
  required String subject,
  String? imageUrl,
  VoidCallback? onShareSheetWillOpen,
}) async {
  if (_isSharing) return;

  _isSharing = true;

  try {
    final Rect shareOrigin = _sharePositionOrigin(context);

    XFile? imageFile;
    if (imageUrl != null && imageUrl.trim().isNotEmpty) {
      imageFile = await _downloadImageToTemp(imageUrl.trim());
    }

    // Reset the button loading before the iOS share sheet opens.
    // Share.share / shareXFiles returns only after the share sheet is closed,
    // so we should not keep the button loading until then.
    onShareSheetWillOpen?.call();

    await Future.delayed(const Duration(milliseconds: 80));

    if (imageFile != null) {
      try {
        await Share.shareXFiles(
          <XFile>[imageFile],
          text: message,
          subject: subject,
          sharePositionOrigin: shareOrigin,
        );
      } catch (_) {
        await Share.share(
          message,
          subject: subject,
          sharePositionOrigin: shareOrigin,
        );
      }
    } else {
      await Share.share(
        message,
        subject: subject,
        sharePositionOrigin: shareOrigin,
      );
    }
  } finally {
    _isSharing = false;
  }
}

Future<void> shareCarFromQarsSpin({
  required BuildContext context,
  required String carName,
  required String year,
  required String price,
  required String adCode,
  VoidCallback? onShareSheetWillOpen,
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

  await _shareQarsSpinContent(
    context: context,
    message: message,
    subject: subject,
    imageUrl: imageUrl,
    onShareSheetWillOpen: onShareSheetWillOpen,
  );
}

Future<void> shareCarCareFromQarsSpin({
  required BuildContext context,
  required String name,
  required String rating,
  required String type,
  VoidCallback? onShareSheetWillOpen,
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

  await _shareQarsSpinContent(
    context: context,
    message: message,
    subject: subject,
    imageUrl: imageUrl,
    onShareSheetWillOpen: onShareSheetWillOpen,
  );
}