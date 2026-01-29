import 'dart:ui';

import 'package:equatable/equatable.dart';

import 'car_brand.dart';

enum CarType {
  /// Regular car for sale
  forSale,

  /// Car available for rent
  forRent,

  /// Caravan for sale
  caravanForSale,

  /// Caravan available for rent
  caravanForRent,
}
enum CarStatus { personal, showroom, qarsSpin }

class CarModel{
  final int? offerId;
  final int postId;
  final int pinToTop;
  final String postCode;
  final String postKind;
  final String carNamePl;
  final String carNameSl;
  final String carNameWithYearPl;
  final String carNameWithYearSl;
  final int manufactureYear;
  final String tag;
  final String sourceKind;
  final int mileage;
  final String askingPrice;
  final String rectangleImageFileName;
  final String rectangleImageUrl;
  Color? interiorColor;
  Color? exteriorColor;
  String? description;
  String? technical_Description_SL;
  int? offersCount;
  String? warrantyAvailable;
  int? visitsCount;
  bool? isFavorite;
  int? classId;
  int? makeId;
  String ownerMobile;
  String ownerName;
  String ownerEmail;
  final String? spin360Url;

  CarModel({
    this.offerId=null,
    this.spin360Url,
    this.classId,this.makeId,
    required this.postId,
    required this.pinToTop,
    required this.postCode,
    required this.carNamePl,
    this.interiorColor,
    this.technical_Description_SL,
    this.exteriorColor,
    this.description,
    this.offersCount,
    this.visitsCount,
    this.isFavorite,
    required this.postKind,
    this.warrantyAvailable,
    required this.carNameSl,
    required this.carNameWithYearPl,
    required this.carNameWithYearSl,
    required this.manufactureYear,
    required this.tag,
    required this.sourceKind,
    required this.mileage,
    required this.askingPrice,
    required this.rectangleImageFileName,
    required this.rectangleImageUrl,
    required this.ownerMobile,required this.ownerName,required this.ownerEmail
  });


}
/// Converts a string to CarType enum
//   factory CarType.fromString(String value) {
//   switch (value.toLowerCase()) {
//     case 'forrent':
//     case 'for_rent':
//     case 'rent':
//       return CarType.forRent;
//     case 'caravanforsale':
//     case 'caravan_for_sale':
//       return CarType.caravanForSale;
//     case 'caravanforrent':
//     case 'caravan_for_rent':
//       return CarType.caravanForRent;
//     case 'forsale':
//     case 'for_sale':
//     case 'sale':
//     default:
//       return CarType.forSale;
//   }
// }

/// Converts the enum to a display-friendly string
// String toDisplayString() {
//   switch (this) {
//     case CarType.forSale:
//       return 'For Sale';
//     case CarType.forRent:
//       return 'For Rent';
//     case CarType.caravanForSale:
//       return 'Caravan For Sale';
//     case CarType.caravanForRent:
//       return 'Caravan For Rent';
//   }
// }

/// Converts the enum to a string for API/database
// String toApiString() {
//   switch (this) {
//     case CarType.forSale:
//       return 'for_sale';
//     case CarType.forRent:
//       return 'for_rent';
//     case CarType.caravanForSale:
//       return 'caravan_for_sale';
//     case CarType.caravanForRent:
//       return 'caravan_for_rent';
//   }
// }

/// Returns true if this is a rental type
// bool get isForRent => this == CarType.forRent || this == CarType.caravanForRent;
//
// /// Returns true if this is a sale type
// bool get isForSale => this == CarType.forSale || this == CarType.caravanForSale;
//
// /// Returns true if this is a caravan type
// bool get isCaravan => this == CarType.caravanForSale || this == CarType.caravanForRent;

//
// class CarModel   {
//   final int id;
//   final String countryCode;
//   final String postCode;
//   final CarType type;
//   final bool isPinnedToTop;
//   final String tag;
//   final String sourceKind;
//
//   final int partnerId;
//   final String userName;
//
//   // Media
//   final String? rectangleImageUrl;
//   final String? squareImageUrl;
//   final String? videoUrl;
//   final String? spin360Url;
//
//   // Car Details
//   final int categoryId;
//   final String categoryName;
//   final int makeId;
//   final CarStatus status;
//   final int classId;
//   final int modelId;
//   final String carName;
//   final String carNameWithYear;
//   final String manufactureYear;
//   final String plateNumber;
//   final String chassisNumber;
//   final String technicalDescription;
//   final int mileage;
//
//   // Colors
//   final String? interiorColor;
//   final String? interiorColorName;
//   final String? exteriorColor;
//   final String? exteriorColorName;
//
//   // Metadata
//   final String approvedDate;
//   final int visitsCount;
//   final bool isFavorite;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//
//   const CarModel({
//     required this.id,
//     required this.countryCode,
//     required this.postCode,
//     required this.status,
//     required this.type,
//     this.isPinnedToTop = false,
//     this.tag = '',
//     this.sourceKind = '',
//     this.partnerId = 0,
//     this.userName = '',
//     this.rectangleImageUrl,
//     this.squareImageUrl,
//     this.videoUrl,
//     this.spin360Url,
//     required this.categoryId,
//     required this.categoryName,
//     required this.makeId,
//     required this.classId,
//     required this.modelId,
//     required this.carName,
//     required this.carNameWithYear,
//     required this.manufactureYear,
//     this.plateNumber = '',
//     this.chassisNumber = '',
//     this.technicalDescription = '',
//     this.mileage = 0,
//     this.interiorColor,
//     this.interiorColorName,
//     this.exteriorColor,
//     this.exteriorColorName,
//     this.approvedDate = '',
//     this.visitsCount = 0,
//     this.isFavorite = false,
//     this.createdAt,
//     this.updatedAt,
//   });
//
//   // @override
//   // List<Object?> get props => [
//   //   id,
//   //   countryCode,
//   //   postCode,
//   //   type,
//   //   isPinnedToTop,
//   //   tag,
//   //   sourceKind,
//   //   partnerId,
//   //   userName,
//   //   rectangleImageUrl,
//   //   squareImageUrl,
//   //   videoUrl,
//   //   spin360Url,
//   //   categoryId,
//   //   categoryName,
//   //   makeId,
//   //   classId,
//   //   modelId,
//   //   carName,
//   //   carNameWithYear,
//   //   manufactureYear,
//   //   plateNumber,
//   //   chassisNumber,
//   //   technicalDescription,
//   //   mileage,
//   //   interiorColor,
//   //   interiorColorName,
//   //   exteriorColor,
//   //   exteriorColorName,
//   //   approvedDate,
//   //   visitsCount,
//   //   isFavorite,
//   //   createdAt,
//   //   updatedAt,
//   // ];
// }
