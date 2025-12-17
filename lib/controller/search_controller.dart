import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:qarsspin/model/global_model.dart';
import 'ads/data_layer.dart';
import 'const/base_url.dart';

class MySearchController extends GetxController {
  List<GlobalModel> makes = [];
  List<GlobalModel> classes = [];
  List<GlobalModel> types = [];
  List<GlobalModel> models = [];

  @override
  void onInit() {
    print("initit");
    super.onInit();
    fetchCarMakes(); // أول لست تتحمّل مع فتح الفورم
  }

  fetchCarMakes({String sort = "MakeName"}) async {
    print("callllmakes");

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
      final parsedJson = jsonDecode(response.body);
      final List<dynamic> data = parsedJson['Data'];

      makes = data
          .map((e) => GlobalModel(
        id: e["Make_ID"],
        name: e["Make_Name_PL"],
      ))
          .toList();

      update(); // هنا يحدّث الـ GetBuilder
    }
  }

  fetchClasses(makeId) async {
    classes.clear();

    final url = Uri.parse(
      '$base_url/BrowsingRelatedApi.asmx/GetListOfCarClasses?Make_ID=$makeId',
    );

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final parsedJson = jsonDecode(response.body);
      final data = parsedJson['Data'];

      classes = data
          .map<GlobalModel>((e) => GlobalModel(
        id: e["Class_ID"],
        name: e["Class_Name_PL"],
      )).toList();

      update();
    }
  }

  fetchModels(classId,makeId) async {
    models = [];
    //make_id

    final url = Uri.parse(
      '$base_url/BrowsingRelatedApi.asmx/GetListOfCarModels?Class_ID=$classId&Make_ID=$makeId',
    );

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final parsedJson = jsonDecode(response.body);
      final data = parsedJson['Data'];

      models = data
          .map<GlobalModel>((e) => GlobalModel(
        id: e["Model_ID"],
        name: e["Model_Name_PL"],
      ))
          .toList();
      fetchCategories();

      update();
    }
  }

  fetchCategories() async {
    types.clear();

    final url = Uri.parse(
      '$base_url/BrowsingRelatedApi.asmx/GetListOfCarCategories',
    );

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final parsedJson = jsonDecode(response.body);
      final data = parsedJson['Data'];

      types = data
          .map<GlobalModel>((e) => GlobalModel(
        id: e["Category_ID"],
        name: e["Category_Name_PL"],
      ))
          .toList();

      update();
    }
  }
  findMeACar({required String makeId, required String classId,required String modelId,required String categoryId,required String fromYear,required String toYear,required String minPrice,required String maxPrice})async{

    final find = {
      'Make_ID': makeId,
      'Class_ID': classId,
      'Model_ID': modelId,
      'Type_ID': categoryId,
      'Year_Min': fromYear,
      'Year_Max': toYear,
      'Price_Min': minPrice,
      'Price_Max': maxPrice,
      'Warranty_isAvailable': '0',
      'Inspection_Report_isAvailable': '0',
      'Remarks': 'Looking for a family car' };
    // {
    //   "Make_ID": makeId,
    //   "Class_ID": classId,
    //   "Model_ID": modelId,
    //   "Category_ID": categoryId,
    //   "Year_Min": fromYear,
    //   "Year_Max": toYear,
    //   "Price_Min": minPrice,
    //   "Price_Max": maxPrice,
    // "Warranty_isAvailable": "0",
    // "Inspection_Report_isAvailable": "0",
    // "Remarks": "Looking for a family car"
    //
    // };
    final url = Uri.parse('$base_url/BrowsingRelatedApi.asmx/RegisterFindCar');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      },
      body: {
        'UserName': userName,
        'Our_Secret': ourSecret,
        'FindDetails' :jsonEncode(find)
        // {Uri.encodeComponent(jsonEncode(find))}
        //{   "Make_ID": "1",   "Class_ID": "2",   "Model_ID": "3",   "Type_ID": "4",   "Year_Min": "2010",   "Year_Max": "2022",   "Price_Min": "5000",   "Price_Max": "20000",   "Warranty_isAvailable": "0",   "Inspection_Report_isAvailable": "0",   "Remarks": "Looking for a family car" }
      },
    );
    final parsedJson = jsonDecode(response.body);

    print('ssssssssssssssssssss${parsedJson["Desc"]}');

  }
}
