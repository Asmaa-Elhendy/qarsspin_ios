import 'package:get/get.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:qarsspin/controller/ads/data_layer.dart';
import 'package:qarsspin/controller/const/base_url.dart';
import 'package:qarsspin/model/offer.dart';
import 'package:qarsspin/model/specification.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../model/car_brand.dart';
import '../model/car_model.dart';
import 'auth/auth_controller.dart';

class BrandController extends GetxController{
  bool loadingMode = true;
  List<CarModel> carsList = [];
  List<CarModel> similarCars = [];
  List<CarModel> ownersAds = [];
  List<CarModel> favoriteList = [];
  List<CarModel> myOffersList = [];
  List <String> postMedia = [];
  final RxBool isLoadingOffers = false.obs;
  bool oldData = true;
  final authController = Get.find<AuthController>();

  switchOldData(){
    oldData = true;
    update();
  }

  CarModel carDetails =
  CarModel(postId: 0, pinToTop: 0, postCode: "postCode", carNamePl: "carNamePl",
      postKind: "",
      ownerMobile: "",
      ownerEmail:"",
      ownerName: "",
      carNameSl: "carNameSl", carNameWithYearPl: "carNameWithYearPl",
      carNameWithYearSl: "carNameWithYearSl", manufactureYear: 0, tag: "tag",
      sourceKind: "sourceKind", mileage: 0, askingPrice: "askingPrice",
      description: "",
      exteriorColor: Colors.white,
      interiorColor: Colors.white,
      isFavorite: false,

      offersCount: 0,
      visitsCount: 0,
      warrantyAvailable: "No",
      rectangleImageFileName: "rectangleImageFileName", rectangleImageUrl: "rectangleImageUrl");
  String currentModelPointer = "";
  List<Specifications> spec = [];
  List<CarBrand>  carBrands= [
    CarBrand(
      id: 0,
      make_count: 0,
      name: 'All Cars',
      slName: "جميع السيارات",
      imageUrl: 'assets/images/ic_all_cars.png',
      isAllCars: true,
    ),

  ];
  List<Offer> offers = [];
  String currentSourceKind = "All";
  int currentMakeId = 0;
  String currentMakeName ="";

  Color hexToColor(String hex) {
    hex = hex.replaceAll("#", ""); // remove the "#"
    if (hex.length == 6) {
      hex = "FF$hex"; // add alpha (opacity) if missing
    }
    return Color(int.parse(hex, radix: 16));
  }
  String convertToTimeAgo(BuildContext context, String dateString) {
    // نحول التاريخ لتوقيت الجهاز المحلي
    DateTime dateTime = DateTime.parse(dateString).toLocal();

    // استخدمي اللغة الحالية من GetX بدل الـ context
    String currentLocale = Get.locale?.languageCode ?? 'en';
    String locale = currentLocale == 'ar' ? 'ar' : 'en';

    return timeago.format(dateTime, locale: locale);
  }

  Future<Map<String, dynamic>> deleteOffer({
    required String offerId,
    String?postID,
    required String loggedInUser,
    required BuildContext context
  }) async {
    final url = Uri.parse('$base_url/BrowsingRelatedApi.asmx/SetOfferInactive');

    log('Deleting offer with ID: $offerId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {
          'Offer_ID': offerId,
          'Logged_In_User': loggedInUser,
        },
      );

      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final parsedJson = jsonDecode(response.body);
        log('Parsed JSON: $parsedJson');

        // If deletion was successful, refresh the offers list
        if (parsedJson['Code'] == 'OK') {
          getOffers(postID,context: context);
          await getMyOffers();
        }

        return {
          'Code': parsedJson['Code'] ?? 'Error',
          'Desc': parsedJson['Desc'] ?? 'Unknown error',
          'AffectedRows': parsedJson['AffectedRows'] ?? 0,
        };
      } else {
        log('❌ HTTP Error: Status code ${response.statusCode}');
        log('Response Body: ${response.body}');
        return {
          'Code': 'Error',
          'Desc': 'Failed to delete offer. Status code: ${response.statusCode}',
          'AffectedRows': 0,
        };
      }
    } catch (e) {
      log('Error deleting offer: $e');
      return {
        'Code': 'Error',
        'Desc': 'Network error: ${e.toString()}',
        'AffectedRows': 0,
      };
    }
  }
  updateOffer({required BuildContext context,required String offer_ID,required String updateOffer_Price,required String updateOffer_Origin})async{
    final url = Uri.parse('$base_url/BrowsingRelatedApi.asmx/UpdateOffer ');


    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {
          'Offer_ID': offer_ID,
          'Update_UserName': userName,
          'UpdateOffer_Price': updateOffer_Price,
          'UpdateOffer_Origin':"MobileApp",

        },
      );
      if (response.statusCode == 200) {
        final parsedJson = jsonDecode(response.body);

        // If deletion was successful, refresh the offers list
        if (parsedJson['Code'] == 'OK') {
          getOffers(carDetails.postId.toString(),context: context);
          log("parsedJson$parsedJson");
        }

        return {
          'Code': parsedJson['Code'] ?? 'Error',
          'Desc': parsedJson['Desc'] ?? 'Unknown error',
          'AffectedRows': parsedJson['AffectedRows'] ?? 0,
        };
      } else {
        log('❌ HTTP Error: Status code ${response.statusCode}');
        log('Response Body: ${response.body}');
        return {
          'Code': 'Error',
          'Desc': 'Failed to updating offer. Status code: ${response.statusCode}',
          'AffectedRows': 0,
        };
      }
    } catch (e) {
      log('Error updating offer: $e');
      return {
        'Code': 'Error',
        'Desc': 'Network error: ${e.toString()}',
        'AffectedRows': 0,
      };
    }
  }

  Future<void> getMyOffers() async {
    try {
      isLoadingOffers.value = true;
      update();

      final url = Uri.parse('$base_url/BrowsingRelatedApi.asmx/GetOffersByUser');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'UserName': authController.userFullName,
          'Our_Secret': ourSecret,
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Offers API Response: $responseData'); // Debug log

        if (responseData['Code'] == 'OK') {
          final List<dynamic> offersData = responseData['Data'] ?? [];
          myOffersList = offersData.map((offer) {
            print('Processing offer: $offer'); // Debug log
            return CarModel(
              ownerMobile: "",
              ownerEmail:"",
              ownerName: "",

              offerId: offer['Offer_ID']??0,
              postId: offer['Post_ID'] ?? 0,
              pinToTop: offer['Pin_To_Top'] ?? 0,
              postCode: offer['Post_Code'] ?? '',
              postKind: offer['Post_Kind'] ?? '',
              carNamePl: (offer['Car_Name_PL'] ?? '').trim(),
              carNameSl: (offer['Car_Name_SL'] ?? '').trim(),
              carNameWithYearPl: offer['Car_Name_With_Year_PL']?.toString().trim() ?? '',
              carNameWithYearSl: offer['Car_Name_With_Year_SL']?.toString().trim() ?? '',
              manufactureYear: offer['Manufacture_Year'] ?? 0,
              tag: offer['Tag'] ?? '',
              sourceKind: offer['Source_Kind'] ?? '',
              mileage: offer['Mileage'] is int ? offer['Mileage'] : int.tryParse(offer['Mileage']?.toString() ?? '0') ?? 0,
              askingPrice: offer['Offer_Price']?.toString() ?? '0',
              rectangleImageFileName: offer['Rectangle_Image_FileName'] ?? '',
              rectangleImageUrl: offer['Rectangle_Image_URL'] ?? '',
              offersCount: 0,
              warrantyAvailable: 'No',
              visitsCount: 0,
              isFavorite: false,
            );
          }).toList();
          print('Processed ${myOffersList.length} offers'); // Debug log
        } else {
          print('API Error: ${responseData['Desc']}'); // Debug log
        }
      }
    } catch (e) {
      print('Error fetching offers: $e');
    } finally {
      isLoadingOffers.value = false;
      update();
    }
  }

  fetchCarMakes({String sort = "MakeName"}) async {
    final url = Uri.parse(
      '$base_url/BrowsingRelatedApi.asmx/GetListOfCarMakes?Order_By=$sort',
    );

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final body = response.body;
      final parsedJson = jsonDecode(body);
      final List<dynamic> data = parsedJson['Data'];
      int? allCarsCount = 0;
      for(int i =0; i<data.length;i++){
        allCarsCount = (allCarsCount! + data[i]["Make_Count"]) as int?;
        carBrands.add(CarBrand(
            id:data[i]["Make_ID"] ,
            make_count: data[i]["Make_Count"],
            name: data[i]["Make_Name_PL"],
            slName: data[i]["Make_Name_SL"],
            imageUrl: data[i]["Image_URL"]??""));
      }
      carBrands[0].make_count = allCarsCount!;


      update();
    }

    return carBrands;


  }
  switchLoading(){
    loadingMode = true;
    update();
  }


  getCars({required int make_id, required String makeName,String sourceKind="All",sort = "lb_Sort_By_Post_Date_Desc",}) async {
    log("call$sort ");
    carsList=[];
    currentSourceKind = sourceKind;
    currentMakeId = make_id;
    currentMakeName = makeName;
    final filterDetails = {
      "Source_Kind":sourceKind,
      "Offset": "0",
      "Limit": "1000",
      "Make_ID": "$make_id",
      "Class_ID": "0",
      "Model_ID": "0",
      "Category_ID": "0",
      "Year_Min": "0",
      "Year_Max": "0",
      "Price_Min": "0",
      "Price_Max": "0",
      "Sort_By": sort,
    };

    final uri = Uri.parse(
      "$base_url/BrowsingRelatedApi.asmx/GetListOfCarsForSale?Filter_Details=${Uri.encodeComponent(jsonEncode(filterDetails))}",
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {

      final body = jsonDecode(response.body);
      for(int i = 0; i<body["Data"].length;i++){
        carsList.add(
            CarModel(postId: body["Data"][i]["Post_ID"],
                pinToTop: body["Data"][i]["Pin_To_Top"],
                postKind: "CarForSale",
                ownerEmail: body["Data"][0]["Owner_Email"]??"",
                ownerMobile: body["Data"][0]["Owner_Mobile"]??"",
                ownerName: body["Data"][0]["Owner_Name"]??"",

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
                rectangleImageFileName:  body["Data"][i]["Rectangle_Image_FileName"]??"",
                rectangleImageUrl:  body["Data"][i]["Rectangle_Image_URL"]??""));

      }
      loadingMode = false;
      currentModelPointer = makeName;

      update();
      final data = jsonDecode(response.body);
      return data is List ? data : [];

    } else {
      throw Exception("Failed to load cars: ${response.statusCode}");
    }



  }

  getCarDetails(String postKind,String id,{required BuildContext context}) async{

    final uri = Uri.parse(
      "$base_url/BrowsingRelatedApi.asmx/GetPostByID?Post_Kind=$postKind&Post_ID=$id&Logged_In_User=${authController.userFullName}",
    );
    final response = await http.get(uri);
    getCarSpec(id);
    getOffers(id,context: context);
    if(response.statusCode == 200){
      final body = jsonDecode(response.body);
      Color exterior = hexToColor(body["Data"][0]["Color_Exterior"]);
      Color interior = hexToColor(body["Data"][0]["Color_Interior"]);


      carDetails =
          CarModel(
              postId: body["Data"][0]["Post_ID"],
              pinToTop: body["Data"][0]["Pin_To_Top"],
              postCode: body["Data"][0]["Post_Code"],
              postKind: body["Data"][0]["Post_Kind"],
              carNamePl: body["Data"][0]["Car_Name_PL"],
              carNameSl: body["Data"][0]["Car_Name_SL"],
              carNameWithYearPl: body["Data"][0]["Car_Name_With_Year_PL"],
              carNameWithYearSl: body["Data"][0]["Car_Name_With_Year_SL"],
              manufactureYear: body["Data"][0]["Manufacture_Year"],
              tag: body["Data"][0]["Tag"],
              sourceKind: body["Data"][0]["Source_Kind"],
              mileage: body["Data"][0]["Mileage"],
              askingPrice: body["Data"][0]["Asking_Price"],
              rectangleImageFileName: body["Data"][0]["Rectangle_Image_FileName"],
              rectangleImageUrl: body["Data"][0]["Rectangle_Image_URL"],
              exteriorColor: exterior,
              interiorColor:interior,
              description: body["Data"][0]["Technical_Description_PL"],
              technical_Description_SL:  body["Data"][0]["Technical_Description_SL"],
              offersCount: body["Data"][0]["Offers_Count"],
              warrantyAvailable: body["Data"][0]["Warranty_isAvailable"] ==0? Get.locale?.languageCode=='ar'?"لا":"No":Get.locale?.languageCode=='ar'?"نعم":"Yes",
              visitsCount: body["Data"][0]["Visits_Count"],
              classId:body["Data"][0]["Class_ID"] ,
              makeId: body["Data"][0]["Make_ID"],
              ownerEmail: body["Data"][0]["Owner_Email"]??"",
              ownerMobile: body["Data"][0]["Owner_Mobile"]??"",
              ownerName: body["Data"][0]["Owner_Name"]??"",
              isFavorite: body["Data"][0]["isFavorite"]==0?false:true

          );
      getSimilarCars(classId: body["Data"][0]["Class_ID"].toString(),postId: body["Data"][0]["Post_ID"].toString(),makeId:body["Data"][0]["Make_ID"].toString() );
      getOwnersAds(context:context,postId: body["Data"][0]["Post_ID"].toString(), sourceKind: body["Data"][0]["Source_Kind"], partnerid: "0", userName: userName??"",);      oldData= false;
      update();
      getPostMedia(id);

    }




  }

  getCarSpec(id) async{
    spec =[];
    String selectLanguage = Get.locale?.languageCode=='ar'?"ar":"en";
    final uri = Uri.parse(
      "$base_url/BrowsingRelatedApi.asmx/GetSpecsOfPostByID?Post_ID=$id&Selected_Language=$selectLanguage",
    );
    final response = await http.get(uri);
    if(response.statusCode==200){
      final body = jsonDecode(response.body);
      if(body["Data"]!=null) {
        for (int i = 0; i < body["Data"].length; i++) {
          spec.add(Specifications(value: body["Data"][i]["Spec_Value"],
              key: body["Data"][i]["Spec_Header"]));
        }
      }
      update();

    }


  }

  getOffers(id,{required BuildContext context})async{
    offers =[];
    final uri = Uri.parse(
      "$base_url/BrowsingRelatedApi.asmx/GetOffersOfPostByID?Post_ID=$id",
    );
    final response = await http.get(uri);
    if(response.statusCode==200){
      final body = jsonDecode(response.body);
      if(body["Data"]!=null){
        for(int i =0;i<body["Data"].length;i++){
          String time = convertToTimeAgo(context, body["Data"][i]["Offer_DateTime"]);
          offers.add(Offer(
              id: body["Data"][i]["Offer_ID"],
              price: body["Data"][i]["Offer_Price"],
              avatarUrl: body["Data"][i]["Avatar_URL"]??"",
              dateTime: time,
              fullName: body["Data"][i]["Full_Name"]??"",
              origin: body["Data"][i]["Offer_Origin"],
              postId: body["Data"][i]["Post_ID"],
              userName: body["Data"][i]["UserName"]));

        }}
      print("offersBody${body["Data"]}");
      update();
    }

  }

  makeOffer({ required String offerPrice,required BuildContext context})async{
    try {
      final response = await http.post(
        Uri.parse('$base_url/BrowsingRelatedApi.asmx/RegisterOfferFromUser'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'UserName': Get.find<AuthController>().userFullName!,
          'Post_ID': carDetails.postId.toString(),
          'Offer_Origin': "MobileApp",
          'Our_Secret': ourSecret,
          'Offer_Price': offerPrice,
        },
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        getOffers(carDetails.postId,context: context);
        print("offers${body}");
      }
    }catch(e){
      return {
        'success': false,
        'message': 'Error: $e',
      };

    }
  }

  buyWithLoan({required String downPayment,required String installmentsCount,required String nationality})async{
    final response = await http.post(
      Uri.parse('$base_url/QarsSpinRelatedApi.asmx/RequestForLoan'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'UserName': userName??"",
        'Post_ID': carDetails.postId.toString(),
        'Offer_Origin': "MobileApp",
        'Asking_Price':carDetails.askingPrice.toString(),
        'Down_Payment': downPayment,
        'Installments_Count': installmentsCount,
        'Nationality': nationality,
        'Our_Secret': ourSecret,

      },
    );
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body["Code"];

    }
  }

  inspectReport(id)async{
    try {
      final response = await http.post(
        Uri.parse('$base_url/QarsSpinRelatedApi.asmx/RequestNewInspectionReport'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'UserName':userName,
          'Post_ID': id.toString(),
          'Our_Secret': ourSecret
        },
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
      }

    }catch(e){

    }
  }

  searchCar({required int make_id,  String makeName="All Cars",String sourceKind="All",sort = "lb_Sort_By_Post_Date_Desc", required String classId, required String makeId,required String modelId,required String catId,required String yearMin, yearMax,required String priceMin,required String priceMax}) async {
    carsList=[];
    currentSourceKind = sourceKind;
    currentMakeId = make_id;
    currentMakeName = makeName;

    final filterDetails = {
      "Source_Kind":sourceKind,
      "Offset": "0",
      "Limit": "1000",
      "Make_ID": make_id,
      "Class_ID": classId,
      "Model_ID": modelId,
      "Category_ID": catId,
      "Year_Min": yearMin,
      "Year_Max": yearMax,
      "Price_Min": priceMin,
      "Price_Max": priceMax,
      "Sort_By": sort,
    };

    final uri = Uri.parse(
      "$base_url/BrowsingRelatedApi.asmx/GetListOfCarsForSale?Filter_Details=${Uri.encodeComponent(jsonEncode(filterDetails))}",
    );

    final response = await http.get(uri);


    if (response.statusCode == 200) {

      final body = jsonDecode(response.body);
      if(body["Data"]==null){
        carsList = [];

      }else{
        for(int i = 0; i<body["Data"].length;i++){
          carsList.add(
              CarModel(postId: body["Data"][i]["Post_ID"],
                  pinToTop: body["Data"][i]["Pin_To_Top"],
                  postCode:body["Data"][i]["Post_Code"],
                  carNamePl:body["Data"][i]["Car_Name_PL"],
                  postKind: "CarForSale",
                  ownerMobile: "",
                  ownerEmail:"",
                  ownerName: "",


                  carNameSl: body["Data"][i]["Car_Name_SL"],
                  carNameWithYearPl: body["Data"][i]["Car_Name_With_Year_PL"],
                  carNameWithYearSl: body["Data"][i]["Car_Name_With_Year_SL"],
                  manufactureYear: body["Data"][i]["Manufacture_Year"],
                  tag: body["Data"][i]["Tag"],
                  sourceKind: body["Data"][i]["Source_Kind"],
                  mileage: body["Data"][i]["Mileage"],

                  askingPrice:  body["Data"][i]["Asking_Price"],
                  rectangleImageFileName:  body["Data"][i]["Rectangle_Image_FileName"],
                  rectangleImageUrl:  body["Data"][i]["Rectangle_Image_URL"]));

        }
      }
      loadingMode = false;
      currentModelPointer = makeName;

      update();
      final data = jsonDecode(response.body);
      return data is List ? data : [];

    } else {
      throw Exception("Failed to load cars: ${response.statusCode}");
    }



  }

  setCars(List<CarModel> cars,String showroomName){//in case got the list from room
    currentMakeName = showroomName;

    carsList = cars;
    loadingMode= false;
    update();

  }

  getSimilarCars({required String postId,required String makeId,required String classId})async{
    similarCars=[];
    final uri = Uri.parse(
      "$base_url/BrowsingRelatedApi.asmx/GetSimilarCarsForSale?Post_ID=$postId&Make_ID=$makeId&Class_ID=$classId",

    );

    final response = await http.get(uri);


    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      for(int i =0; i<body["Data"].length;i++){
        similarCars.add(CarModel(postId: body["Data"][i]["Post_ID"],
            pinToTop: body["Data"][i]["Pin_To_Top"],
            postCode:body["Data"][i]["Post_Code"],
            carNamePl:body["Data"][i]["Car_Name_PL"],
            postKind: "",
            ownerMobile: "",
            ownerEmail:"",
            ownerName: "",

            carNameSl: body["Data"][i]["Car_Name_SL"],
            carNameWithYearPl: body["Data"][i]["Car_Name_With_Year_PL"],
            carNameWithYearSl: body["Data"][i]["Car_Name_With_Year_SL"],
            manufactureYear: body["Data"][i]["Manufacture_Year"],
            tag: body["Data"][i]["Tag"],
            sourceKind: body["Data"][i]["Source_Kind"],
            mileage: body["Data"][i]["Mileage"],

            askingPrice:  body["Data"][i]["Asking_Price"],
            rectangleImageFileName:  body["Data"][i]["Rectangle_Image_FileName"],
            rectangleImageUrl:  body["Data"][i]["Rectangle_Image_URL"]));
      }
      update();


    }



  }

  getOwnersAds({required BuildContext context,required String postId,required String sourceKind, required String partnerid,  required String userName})async{    print("owwwnenrnr");
  ownersAds=[];
  final url = Uri.parse(
    "$base_url/BrowsingRelatedApi.asmx/GetOwnerCarsForSale?Post_ID=$postId&Source_Kind=$sourceKind&Partner_ID=$partnerid&UserName=$userName",
  );
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final body = json.decode(response.body);
    if(body["Data"]==null){
      ownersAds=[];
      update();

    }
    else{ for (int i = 0; i < body["Data"].length; i++) {
      getCarSpec(body["Data"][i]["Post_ID"]);
      Color interior = hexToColor(body["Data"][i]["Color_Interior"]);
      Color exterior = hexToColor(body["Data"][i]["Color_Exterior"]);
      String time = convertToTimeAgo(context,body["Data"][i]["Created_DateTime"]);
      ownersAds.add(CarModel(postId: body["Data"][i]["Post_ID"],
          pinToTop: body["Data"][i]["Pin_To_Top"],
          ownerMobile: "",
          ownerEmail:"",
          ownerName: "",
          postKind: "",
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
          rectangleImageUrl:  body["Data"][i]["Rectangle_Image_URL"]));

    }
    update();
    }
  }
  }

  alterPostFavorite({required bool add,required int postId})async{
    try {
      final response = await http.post(
        Uri.parse('$base_url/GlobalApi.asmx/AlterPostFavorite'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'UserName': userName,
          'Post_ID': postId.toString(),
          'Operation': add?"Add":"Remove",
          'Our_Secret': ourSecret,
        },
      );
      if(response.statusCode==200){
        final body = jsonDecode(response.body);
        if(body["Code"] == "OK"){
          carDetails.isFavorite = add?true:false;
          update();
        }



      }



    }catch (e){
      return "error";
    }
  }
  removeFavItem(CarModel car){
    favoriteList.remove(car);
    update();
  }
  getFavList()async{
    favoriteList=[];
    print("Authhh${authController.userFullName}");
    final uri = Uri.parse(
      "$base_url/BrowsingRelatedApi.asmx/GetFavoritesByUser?UserName=${authController.userFullName}&Our_Secret=$ourSecret",
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      print("favvvv${body["Data"]}");
      for(int i = 0; i<body["Data"].length;i++){
        favoriteList.add(
            CarModel(postId: body["Data"][i]["Post_ID"],
                pinToTop: body["Data"][i]["Pin_To_Top"],
                postKind: body["Data"][i]["Post_Kind"],
                postCode:body["Data"][i]["Post_Code"],
                carNamePl:body["Data"][i]["Car_Name_PL"],
                carNameSl: body["Data"][i]["Car_Name_SL"],
                ownerMobile: "",
                ownerEmail:"",
                ownerName: "",
                carNameWithYearPl: body["Data"][i]["Car_Name_With_Year_PL"],
                carNameWithYearSl: body["Data"][i]["Car_Name_With_Year_SL"],
                manufactureYear: body["Data"][i]["Manufacture_Year"],
                tag: body["Data"][i]["Tag"],
                sourceKind: body["Data"][i]["Source_Kind"],
                mileage: body["Data"][i]["Mileage"],
                askingPrice:  body["Data"][i]["Asking_Price"],


                rectangleImageFileName:  body["Data"][i]["Rectangle_Image_FileName"],
                rectangleImageUrl:  body["Data"][i]["Rectangle_Image_URL"]));

      }
      loadingMode =false;
      update();


    }


  }
  getPostMedia(id)async{
    postMedia = [
      carDetails.rectangleImageUrl
    ];
    final uri = Uri.parse(
      "$base_url/BrowsingRelatedApi.asmx/GetMediaOfPostByID?Post_ID=$id",
    );

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      for(int i = 0; i<body["Data"].length;i++){
        postMedia.add(body["Data"][i]["Media_URL"]);

      }}
    update();


  }


}