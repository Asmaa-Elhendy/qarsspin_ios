import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:qarsspin/controller/ads/data_layer.dart';
import 'package:qarsspin/controller/rental_cars_controller.dart';
import 'package:qarsspin/model/car_model.dart';
import 'package:qarsspin/model/showroom_model.dart';
import 'package:http/http.dart' as http;
import 'auth/auth_controller.dart';
import 'dart:developer';

import '../model/partner_rating.dart';
import '../model/rental_car_model.dart';
import '../model/specification.dart';
import 'brand_controller.dart';
import 'const/base_url.dart';
import 'package:timeago/timeago.dart' as timeago;

class ShowRoomsController extends GetxController {
  bool loadingMode = true;

  List<Showroom> showRooms = [];
  List<RentalCar> rentalCarsOfShowRoom = [];
  List<CarModel> carsForSale = [];
  List<Specifications> spec = [];
  PartnerRating partnerRating = PartnerRating(total: 0, ratingData: []);
  List<String> gallery = [];
  bool following = false;

  switchLoading(){
    loadingMode = true;
    update();
  }

  //helpful functions
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
  fetchShowrooms({required BuildContext context,required bool forSale,String partnerKind = "Car Showroom",String sort = "lb_Sort_By_Avg_Rating_Desc", }) async {

    showRooms = [];
    for (var showRoom in showRooms) {
      showRoom.rentalCars = [];
      showRoom.carsForSale = [];

    }

    final url = Uri.parse(
      "$base_url/BrowsingRelatedApi.asmx/GetListOfApprovedPartners?Partner_Kind=$partnerKind&Sort_By=$sort",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      List<CarModel> myCars = [];
      List<RentalCar> myRentalCars = [];
      for (int i = 0; i < body["Data"].length; i++) {
        String time = convertToTimeAgo(context,body["Data"][i]["Joining_Date"]);
        showRooms.add(Showroom(
            carsCount: await getCarsCount(forSale: forSale, postId: "0", sourceKind: "Partner", partnerid: body["Data"][i]["Partner_ID"].toString(), userName: userName??""),
            rentalCars: rentalCarsOfShowRoom,
            carsForSale: carsForSale,
            partnerId: body["Data"][i]["Partner_ID"],
            partnerNamePl: body["Data"][i]["Partner_Name_PL"],
            logoUrl: body["Data"][i]["Logo_URL"]??"",
            visitsCount: body["Data"][i]["Visits_Count"],
            avgRating: body["Data"][i]["Avg_Rating"],
            pinToTop: body["Data"][i]["Pin_To_Top"] == 1 ? true : false,
            partnerKind: body["Data"][i]["Avg_Rating"],
            activePosts: body["Data"][i]["Active_Posts"],
            bannerFileNamePl: body["Data"][i]["Banner_FileName_PL"]??"",
            bannerFileNameSl: body["Data"][i]["Banner_URL_SL"]??"",
            bannerUrlPl: body["Data"][i]["Banner_URL_PL"]??"",
            bannerUrlSl: body["Data"][i]["Banner_URL_SL"]??"",
            branchNamePl: body["Data"][i]["Branch_Name_PL"]??"",
            branchNameSl: body["Data"][i]["Branch_Name_SL"]??"",
            contactPhone: body["Data"][i]["Contact_Phone"]??"",
            contactWhatsApp: body["Data"][i]["Contact_WhatsApp"]??'',
            countryCode: body["Data"][i]["Country_Code"],
            followersCount: body["Data"][i]["Followers_Count"],
            joiningDate: time,
            logoFileName: body["Data"][i]["Logo_FileName"]??"",
            mapsUrl: body["Data"][i]["Maps_URL"]??"",
            partnerDescPl: body["Data"][i]["Partner_Desc_PL"]??"",
            partnerDescSl: body["Data"][i]["Partner_Desc_SL"]??"",
            partnerNameSl: body["Data"][i]["Partner_Name_SL"]??"",
            spin360Url: body["Data"][i]["Spin360_URL"]??""));
      }
      loadingMode = false;
      update();

    } else {
      throw Exception("Failed to load data: ${response.statusCode}");
    }
  }

  //ApI calls
  fetchCarsOfShowRooms({required bool forSale,required String postId,required String sourceKind, required String partnerid,  required String userName,required String showroomName,required BuildContext context}) async {

    log("callalalla${sourceKind}");

    rentalCarsOfShowRoom = [];
    carsForSale = [];

    var count = 0;
    final url = forSale?
    Uri.parse(
      "$base_url/BrowsingRelatedApi.asmx/GetOwnerCarsForSale?Post_ID=$postId&Source_Kind=$sourceKind&Partner_ID=$partnerid&UserName=${userName}",
    )
        :Uri.parse(
      "$base_url/BrowsingRelatedApi.asmx/GetOwnerCarsForRent?Post_ID=$postId&Source_Kind=$sourceKind&Partner_ID=$partnerid&UserName=$userName",
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      count = body["Count"];
      if (body["Data"] == null) {
        rentalCarsOfShowRoom = [];
        carsForSale = [];
        Get.find<BrandController>().setCars(carsForSale, showroomName);
        Get.find<RentalCarsController>().setRentalCars(rentalCarsOfShowRoom);
        loadingMode = false;
        update();
        log("empty updattes");
        //return [];
      } else {
        for (int i = 0; i < body["Data"].length; i++) {
          getCarSpec(body["Data"][i]["Post_ID"]);
          Color interior = hexToColor(body["Data"][i]["Color_Interior"]);
          Color exterior = hexToColor(body["Data"][i]["Color_Exterior"]);
          String time = convertToTimeAgo(context,body["Data"][i]["Created_DateTime"]);
          forSale?carsForSale.add(
              CarModel(postId: body["Data"][i]["Post_ID"],
                  pinToTop: body["Data"][i]["Pin_To_Top"],
                  postKind: "",
                  technical_Description_SL: "",
                  ownerMobile: "",
                  ownerEmail:"",
                  ownerName: "",

                  postCode:body["Data"][i]["Post_Code"],
                  carNamePl:body["Data"][i]["Car_Name_PL"],
                  carNameSl: body["Data"][i]["Car_Name_SL"],
                  carNameWithYearPl: body["Data"][i]["Car_Name_With_Year_PL"],
                  carNameWithYearSl: body["Data"][i]["Car_Name_With_Year_SL"],
                  manufactureYear: body["Data"][i]["Manufacture_Year"],
                  tag: body["Data"][i]["Tag"],
                  sourceKind: body["Data"][i]["Source_Kind"],
                  mileage: body["Data"][i]["Mileage"],
                  askingPrice:  body["Data"][i]["Asking_Price"],
                  rectangleImageFileName:  body["Data"][i]["Rectangle_Image_FileName"],
                  rectangleImageUrl:  body["Data"][i]["Rectangle_Image_URL"]))

              :rentalCarsOfShowRoom.add(RentalCar(
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
              technicalDescriptionPL: body["Data"][i]
              ["Technical_Description_PL"],
              technicalDescriptionSL: body["Data"][i]
              ["Technical_Description_SL"],
              mileage: body["Data"][i]["Mileage"],
              colorInterior: interior,
              interiorColorNamePL: body["Data"][i]["Interior_Color_Name_PL"],
              interiorColorNameSL: body["Data"][i]["Interior_Color_Name_SL"],
              colorExterior: exterior,
              exteriorColorNamePL: body["Data"][i]["Exterior_Color_Name_PL"],
              exteriorColorNameSL: body["Data"][i]["Exterior_Color_Name_SL"],
              isReadyForRent: body["Data"][i]["isReady_For_Rent"],
              internalRemarks: body["Data"][i]["Internal_Remarks"],
              availableForDailyRent: body["Data"][i]
              ["Available_For_Daily_Rent"],
              rentPerDay: body["Data"][i]["Rent_Per_Day"],
              availableForWeeklyRent: body["Data"][i]
              ["Available_For_Weekly_Rent"],
              rentPerWeek: body["Data"][i]["Rent_Per_Week"],
              availableForMonthlyRent: body["Data"][i]
              ["Available_For_Monthly_Rent"],
              rentPerMonth: body["Data"][i]["Rent_Per_Month"],
              availableForLease: body["Data"][i]["Available_For_Lease"],
              ownerName: body["Data"][i]["Owner_Name"],
              rectangleImageUrl: body["Data"][i]["Rectangle_Image_URL"],
              spin360Url: body["Data"][i]["Spin360_URL"],
              ownerMobile: body["Data"][i]["Owner_Mobile"]));
          //Get.find<BrandController>().switchLoading();
          if(forSale) {

            Get.find<BrandController>().setCars(carsForSale, showroomName);
          }else{

            Get.find<RentalCarsController>().setRentalCars(rentalCarsOfShowRoom);

          }

          loadingMode = false;

          update();

        }
      }
    }


    for (int i = 0; i < showRooms.length; i++) {
      if (showRooms[i].partnerId == int.parse(partnerid)) {
        // if(forSale){
        //   showRooms[i].carsCount =showRooms[i].carsForSale!.length;
        //   update();
        //
        // }
        showRooms[i].rentalCars = rentalCarsOfShowRoom;
        showRooms[i].carsForSale = carsForSale;
        update();
      }
    }


    if(forSale){

      return carsForSale;
    }else{

      return rentalCarsOfShowRoom;
    }
    //  return forSale?carsForSale:rentalCarsOfShowRoom;
  }
  checkFollowing(partnerId)async{
    print("soososos$partnerId");
    final url = Uri.parse(
      "$base_url/BrowsingRelatedApi.asmx/GetPartnerByID?Partner_ID=${partnerId}&UserName=${Get.find<AuthController>().userName!}",
    );

    final response = await http.get(url);
    print("on check${json.decode(response.body)}");

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      following = body["Data"][0]["IsFollower"]==0?false:true;
      print("foloecheck$following");
      update();
    }


  }
  follow(partnerId)async{
    print("follow");
    final url = Uri.parse(
      "$base_url/BrowsingRelatedApi.asmx/RegisterPartnerFollower?Partner_ID=${partnerId}&UserName=${Get.find<AuthController>().userName!}&Country_Code=QA&Follow_Source=MobileApp&User_Type=Registered",
    );

    final response = await http.get(url);
    print("folowwbody=${json.decode(response.body)}");

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      print("folowwbody=${body}");
      if(body["Code"]=="OK"){
        print("olkkkkkkkkkk00");
        following = true;
        print(follow);
        update();

        return true;
      }else{
        return false;

      }
    }

  }
  unFollow(partnerId)async{
    print("unfollow");
    final url = Uri.parse(
      "$base_url/BrowsingRelatedApi.asmx/RegisterPartnerUnFollow ?Partner_ID=$partnerId&UserName=${Get.find<AuthController>().userName!}",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      if(body["Code"]=="OK"){
        following = false;
        update();

        return true;
      }else{
        return false;

      }
    }

  }
  getCarsCount({required bool forSale,required String postId,required String sourceKind, required String partnerid,  required String userName})async{
    final url = forSale?
    Uri.parse(
      "$base_url/BrowsingRelatedApi.asmx/GetOwnerCarsForSale?Post_ID=$postId&Source_Kind=$sourceKind&Partner_ID=$partnerid&UserName=$userName",
    )
        :Uri.parse(
      "$base_url/BrowsingRelatedApi.asmx/GetOwnerCarsForRent?Post_ID=$postId&Source_Kind=$sourceKind&Partner_ID=$partnerid&UserName=$userName",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);

      return body["Count"];
    }

  }
  getPartnerGallery(partnerId)async{
    gallery = [];
    final url = Uri.parse(
      "$base_url/BrowsingRelatedApi.asmx/GetPartnerGallery?Partner_ID=$partnerId",
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      for(int i =0;i < body["Data"].length;i++){
        gallery.add(body["Data"][i]["Image_URL"]);
      }
    }
    update();

  }
  getCarSpec(id) async {
    final uri = Uri.parse(
      "$base_url/BrowsingRelatedApi.asmx/GetSpecsOfPostByID?Post_ID=$id&Selected_Language=PL",
    );
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body["Data"] != null) {
        for (int i = 0; i < body["Data"].length; i++) {
          spec.add(Specifications(
              value: body["Data"][i]["Spec_Value"],
              key: body["Data"][i]["Spec_Header"]));
        }
      }
      update();
    }
  }

  getShowRoomRating(id) async {
    partnerRating = PartnerRating(total: 0, ratingData: []);
    final url =
        "$base_url/BrowsingRelatedApi.asmx/GetPartnerRating?Partner_ID=$id";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<RatingData> ratingData = [];
      final body = json.decode(response.body);

      num totalVote = 0;
      if (body["Data"] != null) {
        for (int i = 0; true; i++) {
          if (body["Data"][0]["Count_Rating_${i + 1}"] != null) {
            totalVote += body["Data"][0]["Count_Rating_${i + 1}"];
            ratingData.add(RatingData(name: "${(i + 1)}",
                value: body["Data"][0]["Count_Rating_${i + 1}"]));
            partnerRating =
                PartnerRating(total: totalVote, ratingData: ratingData);

            update();
          }
          else {
            return;
          }
        }
      } else {
        partnerRating = PartnerRating(total: 0, ratingData: []);
        update();
      }
    }
  }
  rateShowroom({  required String partnerId,    required int rating,  required String countryCode,  required String ratingSource,  required String userType,  required String username,  }) async {
    try {
      final response = await http.post(
        Uri.parse('$base_url/BrowsingRelatedApi.asmx/RegisterPartnerRating'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'Partner_ID': partnerId,
          'Rating_Value': rating.toString(),
          'Country_Code': "QA",
          'Rating_Source': "APP",
          'User_Type': "User",
          'UserName': username,
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        // Parse XML response (you might need to adjust this based on actual response format)
        getShowRoomRating(partnerId);
        return {
          'success': true,
          'message': 'Rating submitted successfully',
          'data': response.body,

        };
      } else {
        return {
          'success': false,
          'message': 'Failed to submit rating: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}



