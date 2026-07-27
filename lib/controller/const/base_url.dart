

import '../../model/specs.dart';
//  "https://qarsspinapp.smartvillageqatar.com";  Production
//  "https://qarsspintest.smartvillageqatar.com/QarsSpinAPI"; //test
String base_url = "https://qarsspintest.smartvillageqatar.com/QarsSpinAPI";

/// Partner_ID of the official "Qars Spin" partner account. Any car or
/// showroom carrying this id is treated as a Qars Spin entity for chip
/// rendering, regardless of the raw `Source_Kind` or partner name reported
/// by the backend (which is `"Partner"` / unstable name strings).
const int kQarsSpinPartnerId = 59;

/// Robust name match for the official "Qars Spin" partner. Keeps only ASCII
/// letters (handles hidden bidi marks, zero-width chars, extra whitespace,
/// case differences) and compares against `qarsspin`.
///
/// Used as a fallback on car endpoints that don't expose `Partner_ID` —
/// notably `GetListOfCarsForSale` (powers All Cars, inside-make pages, and
/// search results), which only returns `Owner_Name`.
bool isQarsSpinPartnerName(String name) {
  final StringBuffer buffer = StringBuffer();
  for (final int code in name.codeUnits) {
    final bool isUppercase = code >= 0x41 && code <= 0x5A;
    final bool isLowercase = code >= 0x61 && code <= 0x7A;
    if (isUppercase || isLowercase) {
      buffer.writeCharCode(code);
    }
  }
  return buffer.toString().toLowerCase() == 'qarsspin';
}

/// Resolve the `sourceKind` to store on a `CarModel` from a single car-list
/// JSON item, so the qarsSpin chip renders correctly anywhere a card is shown.
///
/// Preferred check is `Partner_ID == kQarsSpinPartnerId`, but the backend's
/// `GetListOfCarsForSale` endpoint (All Cars / inside any make / search)
/// omits `Partner_ID` entirely — it only ships `Owner_Name`. So we fall back
/// to a robust `Owner_Name == "Qars Spin"` match for those payloads. Final
/// fallback is the raw `Source_Kind`.
String resolveCarSourceKind(dynamic data) {
  if (data is! Map) return '';

  // 1) Preferred: Partner_ID matches the canonical Qars Spin id.
  final dynamic partnerIdRaw = data['Partner_ID'];
  final int? partnerId = partnerIdRaw is int
      ? partnerIdRaw
      : int.tryParse(partnerIdRaw?.toString() ?? '');
  if (partnerId == kQarsSpinPartnerId) return 'Qars Spin';

  // 2) Fallback for endpoints that omit Partner_ID (GetListOfCarsForSale):
  //    match on Owner_Name, which carries the partner display name.
  final dynamic ownerNameRaw = data['Owner_Name'];
  if (ownerNameRaw is String && isQarsSpinPartnerName(ownerNameRaw)) {
    return 'Qars Spin';
  }

  // 3) Default: whatever the API said.
  return (data['Source_Kind'] ?? '').toString();
}

 const String baseUrlWeb ='https://qarspartnersportalapitest.smartvillageqatar.com';
 //   'https://qarspartnersportalapitest.smartvillageqatar.com';// test
//      https://qarsspinportal.smartvillageqatar.com production web

String fontFamily = "Gilroy";


