import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../model/car_model.dart';
import '../model/rental_car_model.dart';
import '../model/specification.dart';
import 'const/base_url.dart';
import 'package:timeago/timeago.dart' as timeago;

class RentalCarsController extends GetxController {
  bool loadingMode = true;

  switchLoading() {
    loadingMode = true;
    update();
  }

  List<RentalCar> rentalCars = [];
  List<Specifications> spec = [];

  /*
    Favorite status للرنتال:
    استخدمنا Map بدل ما نعدل RentalCar model
    عشان الموديل الحالي عندك مفيهوش isFavorite.
  */
  Map<int, bool> rentalFavoriteStatus = {};

  bool isRentalFavorite(int postId) {
    return rentalFavoriteStatus[postId] ?? false;
  }

  bool _parseFavoriteValue(dynamic value) {
    if (value == null) return false;

    if (value is bool) return value;

    if (value is int) return value == 1;

    if (value is String) {
      final String lowerValue = value.toLowerCase().trim();
      return lowerValue == 'true' ||
          lowerValue == '1' ||
          lowerValue == 'yes';
    }

    return false;
  }

  Future<void> alterRentalFavorite({
    required bool add,
    required int postId,
  }) async {
    /*
      حاليا بنحدث حالة الفيفوريت محليا عشان RentalCarsController
      مفيهوش endpoint واضح للفيفوريت.

      لما تبعتيلي endpoint بتاع favorite للرنتال أو فانكشن alterPostFavorite
      من BrandController، هنضيف هنا call للـ API قبل update().
    */

    rentalFavoriteStatus[postId] = add;
    update();

    /*
      مثال مكان API لاحقا:

      final uri = Uri.parse(
        "$base_url/BrowsingRelatedApi.asmx/YOUR_ENDPOINT?Post_ID=$postId&Add=$add",
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        rentalFavoriteStatus[postId] = !add;
        update();
        throw Exception("Failed to update rental favorite: ${response.statusCode}");
      }
    */
  }

  String convertToTimeAgo(BuildContext context, String dateString) {
    // نحول التاريخ لتوقيت الجهاز المحلي
    DateTime dateTime = DateTime.parse(dateString).toLocal();

    // نعرف اللغة الحالية للتطبيق
    String currentLocale = Localizations.localeOf(context).languageCode;

    // نختار اللغة المناسبة
    String locale = currentLocale == 'ar' ? 'ar' : 'en';

    return timeago.format(dateTime, locale: locale);
  }

  Color hexToColor(String hex) {
    hex = hex.replaceAll("#", ""); // remove the "#"
    if (hex.length == 6) {
      hex = "FF$hex"; // add alpha (opacity) if missing
    }
    return Color(int.parse(hex, radix: 16));
  }

  fetchRentalCars({
    String sort = 'lb_Sort_By_Post_Date_Desc',
    required BuildContext context,
  }) async {
    rentalCars = [];
    spec = [];
    rentalFavoriteStatus = {};

    // body مع الفلتر
    final filterDetails = {
      'Source_Kind': 'All', // Or 'All' if you want to include all sources

      'Limit': '100', // Number of items per page
      'Make_ID': '0', // Toyota's ID from your example
      'Class_ID': '0', // 0 for all classes, or specify if needed
      'Model_ID': '0', // 0 for all models, or specify if needed
      'Category_ID': '0', // 0 for all categories, or specify (1=New, 2=Used)
      'Year_Min': '0', // No minimum year
      'Year_Max': '0', // No maximum year
      'Price_Min': '0', // No minimum price
      'Price_Max': '0', // No maximum price
      'Sort_By': sort
    };

    final uri = Uri.parse(
      "$base_url/BrowsingRelatedApi.asmx/GetListOfCarsForRent?Filter_Details=${Uri.encodeComponent(jsonEncode(filterDetails))}",
    );
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      for (int i = 0; i < body["Data"].length; i++) {
        final int postId = body["Data"][i]["Post_ID"];

        getCarSpec(postId);

        Color interior = hexToColor(body["Data"][i]["Color_Interior"]);
        Color exterior = hexToColor(body["Data"][i]["Color_Exterior"]);
        String time =
        convertToTimeAgo(context, body["Data"][i]["Created_DateTime"]);

        /*
          بنحاول نقرأ favorite من أكتر من اسم محتمل
          عشان لو الـ API بيرجعه باسم مختلف.
        */
        rentalFavoriteStatus[postId] = _parseFavoriteValue(
          body["Data"][i]["Is_Favorite"] ??
              body["Data"][i]["IsFavorite"] ??
              body["Data"][i]["isFavorite"] ??
              body["Data"][i]["Is_Favourite"] ??
              body["Data"][i]["Favorite"],
        );

        rentalCars.add(
          RentalCar(
            postId: body["Data"][i]["Post_ID"],
            countryCode: body["Data"][i]["Country_Code"],
            postCode: body["Data"][i]["Post_Code"],
            postKind: body["Data"][i]["Post_Kind"],
            postStatus: body["Data"][i]["Post_Status"],
            pinToTop: body["Data"][i]["Pin_To_Top"],
            tag: body["Data"][i]["Tag"],
            sourceKind: body["Data"][i]["Source_Kind"],
            partnerId: body["Data"][i]["Partner_ID"],
            userName: body["Data"][i]["UserName"],
            createdBy: body["Data"][i]["Created_By"],
            createdDateTime: time,
            expirationDate: body["Data"][i]["Expiration_Date"],
            approvedBy: body["Data"][i]["Approved_By"],
            approvedDateTime: body["Data"][i]["Approved_DateTime"],
            rejectedDateTime: body["Data"][i]["Rejected_DateTime"],
            suspendedDateTime: body["Data"][i]["Suspended_DateTime"],
            archivedDateTime: body["Data"][i]["Archived_DateTime"],
            visitsCount: body["Data"][i]["Visits_Count"],
            carId: body["Data"][i]["Car_ID"],
            categoryId: body["Data"][i]["Category_ID"],
            categoryNamePL: body["Data"][i]["Category_Name_PL"],
            categoryNameSL: body["Data"][i]["Category_Name_SL"],
            makeId: body["Data"][i]["Make_ID"],
            classId: body["Data"][i]["Class_ID"],
            modelId: body["Data"][i]["Model_ID"],
            carNamePL: body["Data"][i]["Car_Name_PL"],
            carNameSL: body["Data"][i]["Car_Name_SL"],
            carNameWithYearPL: body["Data"][i]["Car_Name_With_Year_PL"],
            carNameWithYearSL: body["Data"][i]["Car_Name_With_Year_SL"],
            manufactureYear: body["Data"][i]["Manufacture_Year"],
            plateNumber: body["Data"][i]["Plate_Number"],
            chassisNumber: body["Data"][i]["Chassis_Number"],
            technicalDescriptionPL:
            body["Data"][i]["Technical_Description_PL"],
            technicalDescriptionSL:
            body["Data"][i]["Technical_Description_SL"],
            mileage: body["Data"][i]["Mileage"],
            colorInterior: interior,
            interiorColorNamePL: body["Data"][i]["Interior_Color_Name_PL"],
            interiorColorNameSL: body["Data"][i]["Interior_Color_Name_SL"],
            colorExterior: exterior,
            exteriorColorNamePL: body["Data"][i]["Exterior_Color_Name_PL"],
            exteriorColorNameSL: body["Data"][i]["Exterior_Color_Name_SL"],
            isReadyForRent: body["Data"][i]["isReady_For_Rent"],
            internalRemarks: body["Data"][i]["Internal_Remarks"],
            availableForDailyRent:
            body["Data"][i]["Available_For_Daily_Rent"],
            rentPerDay: body["Data"][i]["Rent_Per_Day"],
            availableForWeeklyRent:
            body["Data"][i]["Available_For_Weekly_Rent"],
            rentPerWeek: body["Data"][i]["Rent_Per_Week"],
            availableForMonthlyRent:
            body["Data"][i]["Available_For_Monthly_Rent"],
            rentPerMonth: body["Data"][i]["Rent_Per_Month"],
            availableForLease: body["Data"][i]["Available_For_Lease"],
            ownerName: body["Data"][i]["Owner_Name"],
            rectangleImageUrl: body["Data"][i]["Rectangle_Image_URL"],
            spin360Url: body["Data"][i]["Spin360_URL"],
            ownerMobile: body["Data"][i]["Owner_Mobile"],
          ),
        );
      }

      loadingMode = false;

      update();
    } else {
      throw Exception("Failed to load cars: ${response.statusCode}");
    }
  }

  getCarSpec(id) async {
    spec = [];
    final String selectLanguage =
        Get.locale?.languageCode == 'ar' ? 'SL' : 'PL';
    final uri = Uri.parse(
      "$base_url/BrowsingRelatedApi.asmx/GetSpecsOfPostByID?Post_ID=$id&Selected_Language=$selectLanguage",
    );
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body["Data"] != null) {
        for (int i = 0; i < body["Data"].length; i++) {
          spec.add(
            Specifications(
              value: body["Data"][i]["Spec_Value"],
              key: body["Data"][i]["Spec_Header"],
            ),
          );
        }
      }
      update();
    }
  }

  setRentalCars(List<RentalCar> cars) {
    //in case got the list from other
    rentalCars = [];
    rentalFavoriteStatus = {};

    print("cars gggg ${cars.length},, $cars");

    rentalCars = cars;

    for (final car in cars) {
      rentalFavoriteStatus[car.postId] = rentalFavoriteStatus[car.postId] ?? false;
    }

    loadingMode = false;
    update();
  }
}