class MyAdModel {
  final int postId;
  final String countryCode;
  final String postCode;
  final String postKind;
  final String postStatus;
  final int pinToTop;
  final String tag;
  final String sourceKind;
  final String? sourceName;
  final int partnerId;
  final String userName;
  final String? rectangleImageFileName;
  final String? rectangleImageUrl;
  final String? squareImageFileName;
  final String? squareImageUrl;
  final String? videoFileName;
  final String? videoUrl;
  final String? spin360Url;
  final String createdBy;
  final String createdDateTime;
  final String expirationDate;
  final String? approvedBy;
  final String approvedDateTime;
  final String? rejectedBy;
  final String rejectedDateTime;
  final String? rejectedReason;
  final String? suspendedBy;
  final String suspendedDateTime;
  final String? suspendedReason;
  final String? archivedBy;
  final String archivedDateTime;
  final String? archivedReason;
  final int visitsCount;
  final int biddersCount;
  final int offersCount;
  final String leastPrice;
  final String highestPrice;
  final String avgPrice;
  final String firstOffer;
  final String latestOffer;
  final int Active;

  MyAdModel({
    required this.postId,
    required this.countryCode,
    required this.postCode,
    required this.postKind,
    required this.postStatus,
    required this.pinToTop,
    required this.tag,
    required this.sourceKind,
    this.sourceName,
    required this.partnerId,
    required this.userName,
    this.rectangleImageFileName,
    this.rectangleImageUrl,
    this.squareImageFileName,
    this.squareImageUrl,
    this.videoFileName,
    this.videoUrl,
    this.spin360Url,
    required this.createdBy,
    required this.createdDateTime,
    required this.expirationDate,
    this.approvedBy,
    required this.approvedDateTime,
    this.rejectedBy,
    required this.rejectedDateTime,
    this.rejectedReason,
    this.suspendedBy,
    required this.suspendedDateTime,
    this.suspendedReason,
    this.archivedBy,
    required this.archivedDateTime,
    this.archivedReason,
    required this.visitsCount,
    required this.biddersCount,
    required this.offersCount,
    required this.leastPrice,
    required this.highestPrice,
    required this.avgPrice,
    required this.firstOffer,
    required this.latestOffer,
    required this.Active
  });

  factory MyAdModel.fromJson(Map<String, dynamic> json) {
    return MyAdModel(
      postId: json['Post_ID'] ?? 0,
      countryCode: json['Country_Code'] ?? '',
      postCode: json['Post_Code'] ?? '',
      postKind: json['Post_Kind'] ?? '',
      postStatus: json['Post_Status'] ?? '',
      pinToTop: json['Pin_To_Top'] ?? 0,
      tag: json['Tag'] ?? '',
      sourceKind: json['Source_Kind'] ?? '',
      sourceName: json['Source_Name'],
      partnerId: json['Partner_ID'] ?? 0,
      userName: json['UserName'] ?? '',
      rectangleImageFileName: json['Rectangle_Image_FileName'],
      rectangleImageUrl: json['Rectangle_Image_URL'],
      squareImageFileName: json['Square_Image_FileName'],
      squareImageUrl: json['Square_Image_URL'],
      videoFileName: json['Video_FileName'],
      videoUrl: json['Video_URL'],
      spin360Url: json['Spin360_URL'],
      createdBy: json['Created_By'] ?? '',
      createdDateTime: json['Created_DateTime'] ?? '',
      expirationDate: json['Expiration_Date'] ?? '',
      approvedBy: json['Approved_By'],
      approvedDateTime: json['Approved_DateTime'] ?? '',
      rejectedBy: json['Rejected_By'],
      rejectedDateTime: json['Rejected_DateTime'] ?? '',
      rejectedReason: json['Rejected_Reason'],
      suspendedBy: json['Suspended_By'],
      suspendedDateTime: json['Suspended_DateTime'] ?? '',
      suspendedReason: json['Suspended_Reason'],
      archivedBy: json['Archived_By'],
      archivedDateTime: json['Archived_DateTime'] ?? '',
      archivedReason: json['Archived_Reason'],
      visitsCount: json['Visits_Count'] ?? 0,
      biddersCount: json['Bidders_Count'] ?? 0,
      offersCount: json['Offers_Count'] ?? 0,
      leastPrice: json['Least_Price'] ?? '',
      highestPrice: json['Highest_Price'] ?? '',
      avgPrice: json['Avg_Price'] ?? '',
      firstOffer: json['First_Offer'] ?? '',
      latestOffer: json['Latest_Offer'] ?? '',
        Active:json['Active']??''
    );
  }
}

class MyAdResponse {
  final String code;
  final String desc;
  final int count;
  final List<MyAdModel> data;

  MyAdResponse({
    required this.code,
    required this.desc,
    required this.count,
    required this.data,
  });

  factory MyAdResponse.fromJson(Map<String, dynamic> json) {
    return MyAdResponse(
      code: json['Code'] ?? '',
      desc: json['Desc'] ?? '',
      count: json['Count'] ?? 0,
      data: (json['Data'] as List<dynamic>?)
          ?.map((item) => MyAdModel.fromJson(item))
          .toList() ??
          [],
    );
  }
}