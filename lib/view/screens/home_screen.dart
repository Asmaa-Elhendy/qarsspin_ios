import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:qarsspin/controller/showrooms_controller.dart';
import '../../controller/notifications_controller.dart';
import '../../controller/brand_controller.dart';
import '../../controller/const/colors.dart';
import '../../controller/rental_cars_controller.dart';
import '../../l10n/app_localization.dart';
import '../widgets/ad_container.dart';
import '../widgets/main_card.dart';
import '../widgets/navigation_bar.dart';
import 'ads/create_ad_options_screen.dart';
import 'ads/create_new_ad.dart';
import 'auth/my_account.dart';
import 'cars_for_rent/all_rental_cars.dart';
import 'cars_for_sale/all_cars.dart';
import 'cars_for_sale/cars_brand_list.dart';
import 'cars_for_sale/showrooms.dart';
import 'favourites/favourite_screen.dart';
import 'general/contact_us.dart';
import 'general/main_menu.dart';
import 'my_offers_screen.dart';

class HomeScreen extends StatefulWidget {

  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  // Get the notifications controller
  final NotificationsController notificationsController = Get.find<NotificationsController>();
  VoidCallback onMenuTap = () {};
  VoidCallback onAccountTap = () {};
  bool _isMenuVisible = false;
  String cardView = "forSale";

  void _toggleMenu(bool value) {
    setState(() {
      _isMenuVisible = value;
    });
  }

  void _onNavBarTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  void initState() {
    super.initState();
    Get.find<BrandController>().fetchCarMakes();

    // Load notifications when home screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🔔 HomeScreen - Loading notifications...');
      notificationsController.getNotifications().then((_) {
        debugPrint('🔔 HomeScreen - Notifications loaded: ${notificationsController.notifications.length}');
      }).catchError((error) {
        debugPrint('🔔 HomeScreen - Error loading notifications: $error');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var lc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor:AppColors.background(context),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor:AppColors.background(context),
        toolbarHeight: 60.h,
        shadowColor: Colors.grey.shade300,
        // elevation: 3,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: AppColors.background(context),
            boxShadow: [
              BoxShadow( //update asmaa
                color: AppColors.blackColor(context).withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5.h,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        leading: // Menu Button
        GestureDetector(onTap: () {
          Get.to(MainMenu());
        }, child: Icon(Icons.menu,color: AppColors.iconColor(context),)),
        actions: [
          // Account Button with Notification Counter (smaller)

          GestureDetector(
            onTap: () {
              Get.to(MyAccount());
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding:  EdgeInsets.symmetric(horizontal: 15.w),
                  child: Image.asset(
                    'assets/images/ic_personal_account.png',
                    width: 20.w, //update asmaa
                    height: 20.h,
                    color: AppColors.blackColor(context),
                  ),
                ),
                Obx(() {
                  final count = notificationsController.notifications.length;
                  debugPrint('🔔 Notification count: $count');

                  // if (count == 0) {
                  //   return const SizedBox.shrink();
                  // }

                  return Positioned(
                    right: 25.w,
                    top: 15.h,
                    child: Container(
                      height: 17.h,
                      width: 18.w,
                      constraints: const BoxConstraints(minWidth: 14, minHeight: 8),
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(6.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Center(
                        child: Text(
                          count > 99 ? '99+' : count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ),
                  );
                })
              ],
            ),
          )
        ],

        title: SizedBox(
          height: 195.h,
          width: 195.w,
          child: Image.asset(
            'assets/images/ic_top_logo_colored.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (_isMenuVisible) {
                _toggleMenu(false);
              }
            },
            child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height:10.h),
                    // adContainer(bigAdHome: true,),
                    // For big banner (like in home screen)
                    AdContainer(
                      bigAdHome: true,
                      targetPage: 'Home Page',
                    ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final screenWidth = constraints.maxWidth;
                        final crossAxisCount = screenWidth >= 600 ? 3 : 2;
                        final horizontalPadding =
                            screenWidth * 0.02 + 6; // responsive
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding),
                          child:
                          GridView.count(
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: crossAxisCount,
                            shrinkWrap: true,
                            mainAxisSpacing: 3,
                            crossAxisSpacing: 5,
                            childAspectRatio: 1.42, //instead 1.2 update asmaa
                            children: [
                              HomeServiceCard(
                                onTap: () {
                                  _toggleMenu(true);
                                  setState(() {
                                    cardView = "forSale";
                                  });
                                },
                                title: lc.cars_for_sale,//'Cars For Sale',
                                imageAsset:
                                Get.locale?.languageCode=='ar'?'assets/images/QS D-Mode-21.svg':
                                Theme.of(context).brightness == Brightness.dark?'assets/images/Dark mode icons/QS D-Mode-01.svg' :'assets/images/new_svg/home1.svg',

                                large: true,fromHome: 'true',
                              ),
                              HomeServiceCard(
                                onTap: () {
                                  _toggleMenu(true);
                                  setState(() {
                                    cardView = "forRent";
                                  });
                                },
                                title: lc.cars_for_rent,
                                imageAsset:
                                Theme.of(context).brightness == Brightness.dark?'assets/images/Dark mode icons/QS D-Mode-02.svg' :'assets/images/new_svg/home2.svg',
                                large: true,fromHome: 'true',
                              ),
                              HomeServiceCard(
                                onTap: () {
                                  Get.find<ShowRoomsController>().switchLoading();
                                  Get.find<ShowRoomsController>().fetchShowrooms(partnerKind: "Car Care Shop",forSale: false,context: context);
                                  Get.to(CarsShowRoom(notificationsController,carCare: true,title: lc.car_care,rentRoom: false,));
                                },
                                title: lc.car_care,
                                imageAsset:
                                Theme.of(context).brightness == Brightness.dark?'assets/images/Dark mode icons/QS D-Mode-03.svg' :'assets/images/new_svg/home3.svg',
                                large: true,fromHome: 'true',
                              ),
                              HomeServiceCard(
                                // onTap: () => _toggleMenu(true),
                                plate: true,

                                imageAsset2: Get.locale?.languageCode=='ar'?'assets/images/Dark mode icons/QS D-Mode-69.svg':
                                Theme.of(context).brightness == Brightness.dark?'assets/images/soon.svg':'assets/images/soon.svg',

                                title: lc.garages,
                                imageAsset:
                                Theme.of(context).brightness == Brightness.dark?'assets/images/Dark mode icons/QS D-Mode-04.svg' :'assets/images/new_svg/home4.svg',
                                large: true,
                                fromHome: 'true',
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    // For big banner (like in home screen)
                    AdContainer(
                      bigAdHome: false,
                      targetPage: 'Home Page',
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 1.0),
                      child: SizedBox(height: 140.h,   //update asmaa
                        child: SingleChildScrollView(padding: EdgeInsets.zero,
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 125.w, //update asmaa
                                child: HomeServiceCard(
                                  title: lc.bikes,
                                  plate: true,

                                  imageAsset2: Get.locale?.languageCode=='ar'?'assets/images/Dark mode icons/QS D-Mode-69.svg':
                                  Theme.of(context).brightness == Brightness.dark?'assets/images/soon.svg':'assets/images/soon.svg',

                                  imageAsset:
                                  Theme.of(context).brightness == Brightness.dark?'assets/images/Dark mode icons/QS D-Mode-05.svg' :'assets/images/new_svg/bikes.svg',
                                  large: false,fromHome: 'true',fromHomeSmall: true,
                                ),
                              ),
                              SizedBox(width: 12),
                              SizedBox(
                                width: 125.w, //update asmaa
                                child: HomeServiceCard(
                                  title: lc.caravans,
                                  plate: true,

                                  imageAsset2:
                                  Get.locale?.languageCode=='ar'?'assets/images/Dark mode icons/QS D-Mode-69.svg':
                                  Theme.of(context).brightness == Brightness.dark?'assets/images/soon.svg':'assets/images/soon.svg',

                                  imageAsset: Theme.of(context).brightness == Brightness.dark?'assets/images/Dark mode icons/QS D-Mode-06.svg' :'assets/images/new_svg/caravans.svg',
                                  large: false,fromHome: 'true',fromHomeSmall: true,
                                ),
                              ),
                              SizedBox(width: 12),
                              SizedBox(
                                width: 125.w, //update asmaa
                                child: HomeServiceCard(
                                  title: lc.plates,
                                  imageAsset2: Get.locale?.languageCode=='ar'?'assets/images/Dark mode icons/QS D-Mode-69.svg':
                                  Theme.of(context).brightness == Brightness.dark?'assets/images/soon.svg':'assets/images/soon.svg',
                                  plate: true,
                                  imageAsset: Theme.of(context).brightness == Brightness.dark?'assets/images/Dark mode icons/QS D-Mode-07.svg' :'assets/images/new_svg/plates.svg',
                                  large: false,fromHome: 'true',fromHomeSmall: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ]),
            ),
          ),
          // Slide-up menu
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: 0,
            right: 0,
            bottom: _isMenuVisible ? 0 : -400, // Slide from bottom
            // height: 320,
            child: GestureDetector(
              onTap: () {}, // prevent tap on menu from closing it
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Main menu container
                  Container(
                      padding: EdgeInsets.only(top: 35.h, left: 12, right: 12,),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, -4),
                          ),
                        ],
                      ),
                      child: sildeUpGridView(lc)
                  ),

                  // Arrow tab at top center
                  Positioned(
                    top: -15,
                    left: 0,
                    right: 0,
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: InkWell( //update asmaa
                            onTap: (){
                              setState(() {
                                _isMenuVisible=false;
                              });
                            },
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,size: 45.h,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(

        selectedIndex: _selectedIndex,
        onTabSelected: (index) {
          setState(() {

            _selectedIndex = index;
          });
          switch (index) {
            case 0:
              Get.offAll(HomeScreen());
              break;
            case 1:
              Get.offAll(OffersScreen());

              break;
            case 2:
              Get.offAll(CreateNewAdOptions());

              break;

            case 3:
              Get.find<BrandController>().switchLoading();
              Get.find<BrandController>().getFavList();
              Get.offAll(FavouriteScreen());
              break;
            case 4:
              Get.offAll(ContactUsScreen());
              break;
          }
        },
        onAddPressed: () {
          // TODO: Handle Add button tap
          Get.to(CreateNewAdOptions());
        },
      ),
    );

  }
  sildeUpGridView(lc){

    switch (cardView) {
      case 'forSale':
        {
          return  GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            padding: EdgeInsets.only(bottom: 25.h,),
            physics: NeverScrollableScrollPhysics(),
            mainAxisSpacing: 1,
            crossAxisSpacing: 30.w,
            childAspectRatio: 1.3,
            children: [
              HomeServiceCard(
                onTap: () {
                  Get.to(AllCars(notificationsController));
                },
                title: lc.all_cars,fromHome: 'true',
                imageAsset: Theme.of(context).brightness == Brightness.dark?'assets/images/Dark mode icons/QS D-Mode-09.svg' :'assets/images/new_svg/Group.svg',
                large: false,
              ),
              HomeServiceCard(
                onTap: () {
                  // qar spin show room
                  Get.find<BrandController>().switchLoading();
                  Get.find<BrandController>().getCars(make_id: 0, makeName: "Qars Spin Showrooms",sourceKind: "Qars spin");
                  Get.to(CarsBrandList(notificationsController,brandName: lc.qar_spin_showroom,postKind: "CarForSale",));
                },
                title: lc.qar_spin_showroom,fromHome: 'true',
                imageAsset: Theme.of(context).brightness == Brightness.dark?'assets/images/Dark mode icons/QS D-Mode-11.svg' :'assets/images/new_svg/Group (1).svg',
                large: false,
              ),
              HomeServiceCard(
                onTap: () {
                  Get.find<ShowRoomsController>().switchLoading();
                  Get.find<ShowRoomsController>().fetchShowrooms(context:context,forSale: true);
                  Get.to(CarsShowRoom(notificationsController,title: lc.cars_showroom,rentRoom: false,));
                },
                title: lc.cars_showroom,fromHome: 'true',
                imageAsset: Theme.of(context).brightness == Brightness.dark?'assets/images/Dark mode icons/QS D-Mode-10.svg' :'assets/images/new_svg/Group (2).svg',
                large: false,
              ),
              HomeServiceCard(fromHome: 'true',
                title: lc.personal_cars,
                onTap: () {
                  Get.find<BrandController>().switchLoading();
                  // personal cars
                  Get.find<BrandController>().switchLoading();
                  Get.find<BrandController>().getCars(make_id: 0, makeName: "Personal Cars",sourceKind: "Individual");

                  Get.to(CarsBrandList(notificationsController,brandName: lc.personal_cars,postKind: "CarForSale",));
                },
                imageAsset: Theme.of(context).brightness == Brightness.dark?'assets/images/Dark mode icons/QS D-Mode-12.svg' :'assets/images/new_svg/Group (3).svg',
                large: false,
              ),
            ],
          );
          print("object");
          break;
        }


      case 'forRent':
        {
          return GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            padding: EdgeInsets.only(bottom: 25.h,),
            physics: NeverScrollableScrollPhysics(),
            mainAxisSpacing: 1,
            crossAxisSpacing: 30.w,
            childAspectRatio: 1.3,

            children: [
              HomeServiceCard(
                onTap: () {
                  Get.find<RentalCarsController>().switchLoading();
                  Get.find<RentalCarsController>().fetchRentalCars(context: context);
                  Get.to(AllRentalCars(notificationsController));
                },
                title: lc.all_rental_cars,
                fromHome: 'true',
                imageAsset: Theme.of(context).brightness == Brightness.dark?'assets/images/Dark mode icons/QS D-Mode-02.svg' :'assets/images/new_svg/home2.svg',
                large: false,
              ),
              HomeServiceCard(
                onTap: () {
                  Get.find<ShowRoomsController>().fetchShowrooms(partnerKind: "Rent a Car",forSale: false,context: context);
                  Get.to(CarsShowRoom(notificationsController,title: lc.rental_showroom,rentRoom: true,));
                },
                title: lc.rental_showroom,fromHome: 'true',
                imageAsset: Get.locale?.languageCode=='ar'?'assets/images/Dark mode icons/QS D-Mode-22.svg':Theme.of(context).brightness == Brightness.dark?'assets/images/Dark mode icons/QS D-Mode-20.svg' :'assets/images/new_svg/Group (5).svg',
                large: false,
              ),

            ],
          );
          break;
        }
    }
  }
}