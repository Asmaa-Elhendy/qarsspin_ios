import 'package:qarsspin/controller/const/base_url.dart';
import 'package:qarsspin/model/car_model.dart';
import 'package:qarsspin/model/rental_car_model.dart';

class Showroom {
  final int partnerId;
  final String countryCode;
  final String partnerKind;
  final String joiningDate;
  final bool pinToTop;
  final String partnerNamePl;
  final String partnerNameSl;
  final String branchNamePl;
  final String branchNameSl;
  final String partnerDescPl;
  final String partnerDescSl;
  final String logoFileName;
  final String logoUrl;
  final String bannerUrlPl;
  final String bannerFileNamePl;
  final String bannerUrlSl;
  final String bannerFileNameSl;
  final String spin360Url;
  final String contactPhone;
  final String contactWhatsApp;
  final String mapsUrl;
  final int visitsCount;
  final int activePosts;
  final int followersCount;
  final String avgRating;
  int? carsCount;
  List<RentalCar>? rentalCars;
  List<CarModel>? carsForSale;



  Showroom({
    this.carsCount,
    this.rentalCars,
    this.carsForSale,
    required this.partnerId,
    required this.countryCode,
    required this.partnerKind,
    required this.joiningDate,
    required this.pinToTop,
    required this.partnerNamePl,
    required this.partnerNameSl,
    required this.branchNamePl,
    required this.branchNameSl,
    required this.partnerDescPl,
    required this.partnerDescSl,
    required this.logoFileName,
    required this.logoUrl,
    required this.bannerUrlPl,
    required this.bannerFileNamePl,
    required this.bannerUrlSl,
    required this.bannerFileNameSl,
    required this.spin360Url,
    required this.contactPhone,
    required this.contactWhatsApp,
    required this.mapsUrl,
    required this.visitsCount,
    required this.activePosts,
    required this.followersCount,
    required this.avgRating,
  });

  /// True when this partner is the official "Qars Spin" account. Identified
  /// by [kQarsSpinPartnerId] — more reliable than matching on `partnerNamePl`,
  /// which can carry hidden whitespace, bidi marks, or case differences from
  /// the backend.
  bool get isQarsSpinPartner => partnerId == kQarsSpinPartnerId;
}