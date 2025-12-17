import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// The current Language
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language;

  /// No description provided for @app_name.
  ///
  /// In en, this message translates to:
  /// **'Qars Spin'**
  String get app_name;

  /// No description provided for @navigation_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navigation_home;

  /// No description provided for @navigation_offers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get navigation_offers;

  /// No description provided for @navigation_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get navigation_add;

  /// No description provided for @cars_for_sale.
  ///
  /// In en, this message translates to:
  /// **'Cars For Sale'**
  String get cars_for_sale;

  /// No description provided for @cars_for_rent.
  ///
  /// In en, this message translates to:
  /// **'Cars For Rent'**
  String get cars_for_rent;

  /// No description provided for @car_care.
  ///
  /// In en, this message translates to:
  /// **'Car Care'**
  String get car_care;

  /// No description provided for @garages.
  ///
  /// In en, this message translates to:
  /// **'Garages'**
  String get garages;

  /// No description provided for @bikes.
  ///
  /// In en, this message translates to:
  /// **'Bikes'**
  String get bikes;

  /// No description provided for @caravans.
  ///
  /// In en, this message translates to:
  /// **'Caravans'**
  String get caravans;

  /// No description provided for @plates.
  ///
  /// In en, this message translates to:
  /// **'Plates'**
  String get plates;

  /// No description provided for @all_cars.
  ///
  /// In en, this message translates to:
  /// **'All Cars'**
  String get all_cars;

  /// No description provided for @ads.
  ///
  /// In en, this message translates to:
  /// **'Ads'**
  String get ads;

  /// No description provided for @create_car_ads.
  ///
  /// In en, this message translates to:
  /// **'Create Car Ads'**
  String get create_car_ads;

  /// No description provided for @cars.
  ///
  /// In en, this message translates to:
  /// **'Cars'**
  String get cars;

  /// No description provided for @personal_cars.
  ///
  /// In en, this message translates to:
  /// **'Personal Cars'**
  String get personal_cars;

  /// No description provided for @qar_spin_showroom.
  ///
  /// In en, this message translates to:
  /// **'Qars Spin Showroom'**
  String get qar_spin_showroom;

  /// No description provided for @cars_showroom.
  ///
  /// In en, this message translates to:
  /// **'Cars Showrooms'**
  String get cars_showroom;

  /// No description provided for @all_rental_cars.
  ///
  /// In en, this message translates to:
  /// **'All Rental Cars'**
  String get all_rental_cars;

  /// No description provided for @rental_showroom.
  ///
  /// In en, this message translates to:
  /// **'Rental Showrooms'**
  String get rental_showroom;

  /// No description provided for @all_makes.
  ///
  /// In en, this message translates to:
  /// **'All Makes'**
  String get all_makes;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @find_me_car.
  ///
  /// In en, this message translates to:
  /// **'Find Me A Car'**
  String get find_me_car;

  /// No description provided for @find_car_notify.
  ///
  /// In en, this message translates to:
  /// **'Get notified when a car of your choice is\\n                   added to our showroom.'**
  String get find_car_notify;

  /// No description provided for @any_comment.
  ///
  /// In en, this message translates to:
  /// **'Any Comments?'**
  String get any_comment;

  /// No description provided for @active_notification.
  ///
  /// In en, this message translates to:
  /// **'Activate Notification'**
  String get active_notification;

  /// No description provided for @success_request.
  ///
  /// In en, this message translates to:
  /// **'your Request has been sent successfully '**
  String get success_request;

  /// No description provided for @comment_hint.
  ///
  /// In en, this message translates to:
  /// **'eg.exterior or interior color of the car, options,\\nengine...'**
  String get comment_hint;

  /// No description provided for @no_result.
  ///
  /// In en, this message translates to:
  /// **'No Result Found'**
  String get no_result;

  /// No description provided for @sorry.
  ///
  /// In en, this message translates to:
  /// **'Unfortunately what you are looking for is\\ncurrently not available. Please activate a'**
  String get sorry;

  /// No description provided for @sorry_notify.
  ///
  /// In en, this message translates to:
  /// **'notification using\\\"Find me a car\\\"yp be updates'**
  String get sorry_notify;

  /// No description provided for @sort_result.
  ///
  /// In en, this message translates to:
  /// **'Sort Results'**
  String get sort_result;

  /// No description provided for @sort_by_post_count.
  ///
  /// In en, this message translates to:
  /// **'Sort By Posts Count'**
  String get sort_by_post_count;

  /// No description provided for @sort_by_rating.
  ///
  /// In en, this message translates to:
  /// **'Sort By Rating'**
  String get sort_by_rating;

  /// No description provided for @sort_by_visits.
  ///
  /// In en, this message translates to:
  /// **'Sort By Visits'**
  String get sort_by_visits;

  /// No description provided for @sort_by_date.
  ///
  /// In en, this message translates to:
  /// **'Sort By joining Date'**
  String get sort_by_date;

  /// No description provided for @sort_by_post_date_new.
  ///
  /// In en, this message translates to:
  /// **'Sort By Post Date (Newest First)'**
  String get sort_by_post_date_new;

  /// No description provided for @sort_by_post_date_old.
  ///
  /// In en, this message translates to:
  /// **'Sort By Post Date (Oldest First)'**
  String get sort_by_post_date_old;

  /// No description provided for @sort_by_price_high.
  ///
  /// In en, this message translates to:
  /// **'Sort By Price (From High To Low)'**
  String get sort_by_price_high;

  /// No description provided for @sort_by_price_low.
  ///
  /// In en, this message translates to:
  /// **'Sort By Price (From Low To High)'**
  String get sort_by_price_low;

  /// No description provided for @sort_by_manufacture_year_new.
  ///
  /// In en, this message translates to:
  /// **'Sort By Manufacture Year (Newest First)'**
  String get sort_by_manufacture_year_new;

  /// No description provided for @sort_by_manufacture_year_old.
  ///
  /// In en, this message translates to:
  /// **'Sort By Manufacture Year (Oldest First)'**
  String get sort_by_manufacture_year_old;

  /// No description provided for @make_name.
  ///
  /// In en, this message translates to:
  /// **'Make Name'**
  String get make_name;

  /// No description provided for @ads_count.
  ///
  /// In en, this message translates to:
  /// **'Ads Count'**
  String get ads_count;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @choose_make.
  ///
  /// In en, this message translates to:
  /// **'Choose Make'**
  String get choose_make;

  /// No description provided for @choose_class.
  ///
  /// In en, this message translates to:
  /// **'Choose Class'**
  String get choose_class;

  /// No description provided for @choose_model.
  ///
  /// In en, this message translates to:
  /// **'Choose Model'**
  String get choose_model;

  /// No description provided for @choose_type.
  ///
  /// In en, this message translates to:
  /// **'Choose Type'**
  String get choose_type;

  /// No description provided for @from_year.
  ///
  /// In en, this message translates to:
  /// **'From Year'**
  String get from_year;

  /// No description provided for @to_year.
  ///
  /// In en, this message translates to:
  /// **'To Year'**
  String get to_year;

  /// No description provided for @from_price.
  ///
  /// In en, this message translates to:
  /// **'From Price'**
  String get from_price;

  /// No description provided for @to_price.
  ///
  /// In en, this message translates to:
  /// **'To Price'**
  String get to_price;

  /// No description provided for @not_register.
  ///
  /// In en, this message translates to:
  /// **'Not Registered'**
  String get not_register;

  /// No description provided for @register_now.
  ///
  /// In en, this message translates to:
  /// **'Would you like to register now?'**
  String get register_now;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @register_account.
  ///
  /// In en, this message translates to:
  /// **'Register Now'**
  String get register_account;

  /// No description provided for @register_account_cap.
  ///
  /// In en, this message translates to:
  /// **'REGISTER NOW'**
  String get register_account_cap;

  /// No description provided for @verify_msg.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get verify_msg;

  /// No description provided for @enter_otp_msg.
  ///
  /// In en, this message translates to:
  /// **'Please enter the OTP sent to your phone'**
  String get enter_otp_msg;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading....\nplease wait....'**
  String get loading;

  /// No description provided for @carStatus_personal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get carStatus_personal;

  /// No description provided for @carStatus_showroom.
  ///
  /// In en, this message translates to:
  /// **'Showroom'**
  String get carStatus_showroom;

  /// No description provided for @carStatus_qarsSpin.
  ///
  /// In en, this message translates to:
  /// **'Qars Spin'**
  String get carStatus_qarsSpin;

  /// No description provided for @featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featured;

  /// No description provided for @people_view.
  ///
  /// In en, this message translates to:
  /// **'people viewed this car'**
  String get people_view;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @people_made_offer.
  ///
  /// In en, this message translates to:
  /// **'People made an offer on this car'**
  String get people_made_offer;

  /// No description provided for @ad_code.
  ///
  /// In en, this message translates to:
  /// **'AD Code'**
  String get ad_code;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @mileage.
  ///
  /// In en, this message translates to:
  /// **'Mileage'**
  String get mileage;

  /// No description provided for @warranty.
  ///
  /// In en, this message translates to:
  /// **'Warranty'**
  String get warranty;

  /// No description provided for @exterior.
  ///
  /// In en, this message translates to:
  /// **'Exterior'**
  String get exterior;

  /// No description provided for @interior.
  ///
  /// In en, this message translates to:
  /// **'Interior'**
  String get interior;

  /// No description provided for @specifications.
  ///
  /// In en, this message translates to:
  /// **'Specifications'**
  String get specifications;

  /// No description provided for @offers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get offers;

  /// No description provided for @btn_request_to_buy.
  ///
  /// In en, this message translates to:
  /// **'Request\n To Buy'**
  String get btn_request_to_buy;

  /// No description provided for @btn_make_offer.
  ///
  /// In en, this message translates to:
  /// **'Make \nOffer'**
  String get btn_make_offer;

  /// No description provided for @make_offer_one_line.
  ///
  /// In en, this message translates to:
  /// **'Make Offer'**
  String get make_offer_one_line;

  /// No description provided for @btn_byu_loan.
  ///
  /// In en, this message translates to:
  /// **'Buy With \n Loan'**
  String get btn_byu_loan;

  /// No description provided for @what_offer.
  ///
  /// In en, this message translates to:
  /// **'What is your offer?'**
  String get what_offer;

  /// No description provided for @request_buy_text.
  ///
  /// In en, this message translates to:
  /// **'You are making an offer matching the request price'**
  String get request_buy_text;

  /// No description provided for @condition_agreement.
  ///
  /// In en, this message translates to:
  /// **'You agree to Qars Spin Terms & Conditions'**
  String get condition_agreement;

  /// No description provided for @inspection_report.
  ///
  /// In en, this message translates to:
  /// **'Request Inspection Report'**
  String get inspection_report;

  /// No description provided for @inspection_text.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to request new car inspection for this car? (this is a prepaid service. Our team will contact you soon to get more details.)'**
  String get inspection_text;

  /// No description provided for @get_loan.
  ///
  /// In en, this message translates to:
  /// **'Get a Loan'**
  String get get_loan;

  /// No description provided for @describe_your_self.
  ///
  /// In en, this message translates to:
  /// **'How would you describe yourself?'**
  String get describe_your_self;

  /// No description provided for @down_payment.
  ///
  /// In en, this message translates to:
  /// **'Your Down Payment'**
  String get down_payment;

  /// No description provided for @loan_installments.
  ///
  /// In en, this message translates to:
  /// **'loan Installments (Months)'**
  String get loan_installments;

  /// No description provided for @calculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get calculate;

  /// No description provided for @qatari_national.
  ///
  /// In en, this message translates to:
  /// **'I Am Qatari National'**
  String get qatari_national;

  /// No description provided for @resident_qatar.
  ///
  /// In en, this message translates to:
  /// **'I Am A Resident In Qatar'**
  String get resident_qatar;

  /// No description provided for @month_number.
  ///
  /// In en, this message translates to:
  /// **'Month(s)'**
  String get month_number;

  /// No description provided for @legal_status.
  ///
  /// In en, this message translates to:
  /// **'Legal Status'**
  String get legal_status;

  /// No description provided for @loan_installments_count.
  ///
  /// In en, this message translates to:
  /// **'Loan Installments Count'**
  String get loan_installments_count;

  /// No description provided for @total_loan_value.
  ///
  /// In en, this message translates to:
  /// **'Total Loan Value'**
  String get total_loan_value;

  /// No description provided for @loan_figure.
  ///
  /// In en, this message translates to:
  /// **'These figures are estimates, the accurate and\\n    final figures will be sent to you by email.'**
  String get loan_figure;

  /// No description provided for @re_calculate.
  ///
  /// In en, this message translates to:
  /// **'Re-Calculate'**
  String get re_calculate;

  /// No description provided for @request_success.
  ///
  /// In en, this message translates to:
  /// **'Your request has been submitted successfully!'**
  String get request_success;

  /// No description provided for @wnt_wrg.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong please try again later'**
  String get wnt_wrg;

  /// No description provided for @invalid_loan.
  ///
  /// In en, this message translates to:
  /// **'Invalid loan amount. Check price and down payment.'**
  String get invalid_loan;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @all_price_qar.
  ///
  /// In en, this message translates to:
  /// **'All prices are in Qatari Riyals'**
  String get all_price_qar;

  /// No description provided for @rental_prices.
  ///
  /// In en, this message translates to:
  /// **'Rental Prices'**
  String get rental_prices;

  /// No description provided for @chassis_number.
  ///
  /// In en, this message translates to:
  /// **'Chassis Number'**
  String get chassis_number;

  /// No description provided for @for_leasing.
  ///
  /// In en, this message translates to:
  /// **'For Leasing'**
  String get for_leasing;

  /// No description provided for @call_now.
  ///
  /// In en, this message translates to:
  /// **'Call Now'**
  String get call_now;

  /// No description provided for @whats_app.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whats_app;

  /// No description provided for @dark_mode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get dark_mode;

  /// No description provided for @terms_list.
  ///
  /// In en, this message translates to:
  /// **'A car sale request on our website must be submitted by the owner or someone with an authorization letter.|Car sale requests from companies or showrooms must be submitted by the licensed person in that company or showroom.|Priority is given to cars with an inspection report or to those willing to bring their cars to the recommended inspection center by the Qars Spin team.|Acceptance and approval of the terms and conditions that will be shared with you via WhatsApp as the car owner or as an authorized person for individuals and companies.|Our commission is 1.8% from the seller and 1.8% from the buyer, with a minimum of 1000 QAR.|If the buyer wants a specific inspection for a certain car, the inspection fee must be paid in advance, and the Qars Spin team will share the report once it’s ready.|After all parties agree to purchase the car and sign the contracts, the funds will be transferred to the Qars Spin bank account.|Once an oral, written, or voice expression of intent to buy the car is made, Qars Spin is not allowed to continue presenting the car to other potential buyers.|Car registration fees at Metrash are paid by the buyer as is customary in Qatar.'**
  String get terms_list;

  /// No description provided for @active_ads.
  ///
  /// In en, this message translates to:
  /// **'Active Ads:'**
  String get active_ads;

  /// No description provided for @adv_lbl.
  ///
  /// In en, this message translates to:
  /// **'My Advertisements'**
  String get adv_lbl;

  /// No description provided for @fav_lbl.
  ///
  /// In en, this message translates to:
  /// **'My Favorites'**
  String get fav_lbl;

  /// No description provided for @delete_account.
  ///
  /// In en, this message translates to:
  /// **'Delete My Account'**
  String get delete_account;

  /// No description provided for @person_notification.
  ///
  /// In en, this message translates to:
  /// **'Personalized Notifications'**
  String get person_notification;

  /// No description provided for @specialized_techno.
  ///
  /// In en, this message translates to:
  /// **'Specialized in selling cars using 360° technology'**
  String get specialized_techno;

  /// No description provided for @live_chat.
  ///
  /// In en, this message translates to:
  /// **'Live Chat'**
  String get live_chat;

  /// No description provided for @cnt_reason.
  ///
  /// In en, this message translates to:
  /// **'To sell your car, buy a car, or any other questions'**
  String get cnt_reason;

  /// No description provided for @for_business.
  ///
  /// In en, this message translates to:
  /// **'For Business Inquiries'**
  String get for_business;

  /// No description provided for @social_accounts.
  ///
  /// In en, this message translates to:
  /// **'Social Media Accounts'**
  String get social_accounts;

  /// No description provided for @my_fav.
  ///
  /// In en, this message translates to:
  /// **'My Favourites'**
  String get my_fav;

  /// No description provided for @empty_lbl.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get empty_lbl;

  /// No description provided for @no_offers.
  ///
  /// In en, this message translates to:
  /// **'No offers found'**
  String get no_offers;

  /// No description provided for @ask_price.
  ///
  /// In en, this message translates to:
  /// **'Asking Price:'**
  String get ask_price;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @join_data.
  ///
  /// In en, this message translates to:
  /// **'Join Date'**
  String get join_data;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @un_follow.
  ///
  /// In en, this message translates to:
  /// **'Un Follow'**
  String get un_follow;

  /// No description provided for @followers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followers;

  /// No description provided for @create_new_Ad.
  ///
  /// In en, this message translates to:
  /// **'Create New Ad'**
  String get create_new_Ad;

  /// No description provided for @create_bike_ad.
  ///
  /// In en, this message translates to:
  /// **'Create Bike Ads'**
  String get create_bike_ad;

  /// No description provided for @create_caravan_ad.
  ///
  /// In en, this message translates to:
  /// **'Create Caravan Ads'**
  String get create_caravan_ad;

  /// No description provided for @create_plate_ad.
  ///
  /// In en, this message translates to:
  /// **'Create Plate Ads'**
  String get create_plate_ad;

  /// No description provided for @free_ads.
  ///
  /// In en, this message translates to:
  /// **'Free Ads'**
  String get free_ads;

  /// No description provided for @free_360.
  ///
  /// In en, this message translates to:
  /// **'Free 360 shooting session'**
  String get free_360;

  /// No description provided for @after_sale_commission.
  ///
  /// In en, this message translates to:
  /// **'1.8% after sale on the sold price.'**
  String get after_sale_commission;

  /// No description provided for @private_seller_info.
  ///
  /// In en, this message translates to:
  /// **'Seller information stay private (Buyers can\'t see your contact details).'**
  String get private_seller_info;

  /// No description provided for @standard_advertise.
  ///
  /// In en, this message translates to:
  /// **'Standard advertise.'**
  String get standard_advertise;

  /// No description provided for @show_contact_details.
  ///
  /// In en, this message translates to:
  /// **'People can see your contact details.'**
  String get show_contact_details;

  /// No description provided for @upload_pictures_videos.
  ///
  /// In en, this message translates to:
  /// **'You can upload pictures and video.'**
  String get upload_pictures_videos;

  /// No description provided for @optional_360_session.
  ///
  /// In en, this message translates to:
  /// **'Optional 360 Shooting session.'**
  String get optional_360_session;

  /// No description provided for @qars_spin_showroom_adv.
  ///
  /// In en, this message translates to:
  /// **'Qars Spin Showroom Advertisement'**
  String get qars_spin_showroom_adv;

  /// No description provided for @request_appointment.
  ///
  /// In en, this message translates to:
  /// **'Request Appointment'**
  String get request_appointment;

  /// No description provided for @free_personal_ad.
  ///
  /// In en, this message translates to:
  /// **'Free Personal Advertisement'**
  String get free_personal_ad;

  /// No description provided for @post_ad.
  ///
  /// In en, this message translates to:
  /// **'Post Ad'**
  String get post_ad;

  /// No description provided for @modify_car.
  ///
  /// In en, this message translates to:
  /// **'Modify Car'**
  String get modify_car;

  /// No description provided for @sell_car.
  ///
  /// In en, this message translates to:
  /// **'Sell Your Car'**
  String get sell_car;

  /// No description provided for @upload_txt.
  ///
  /// In en, this message translates to:
  /// **'Upload up to 15 photos and one video'**
  String get upload_txt;

  /// No description provided for @video_cover.
  ///
  /// In en, this message translates to:
  /// **'Video Cover'**
  String get video_cover;

  /// No description provided for @only_one_video.
  ///
  /// In en, this message translates to:
  /// **'You can only add one video'**
  String get only_one_video;

  /// No description provided for @max.
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get max;

  /// No description provided for @img_allowed.
  ///
  /// In en, this message translates to:
  /// **'images allowed'**
  String get img_allowed;

  /// No description provided for @only.
  ///
  /// In en, this message translates to:
  /// **'Only'**
  String get only;

  /// No description provided for @more_img.
  ///
  /// In en, this message translates to:
  /// **'more images can be added'**
  String get more_img;

  /// No description provided for @failed_img.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image'**
  String get failed_img;

  /// No description provided for @add_media.
  ///
  /// In en, this message translates to:
  /// **'Add Media'**
  String get add_media;

  /// No description provided for @add_img.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get add_img;

  /// No description provided for @add_video.
  ///
  /// In en, this message translates to:
  /// **'Add Video'**
  String get add_video;

  /// No description provided for @cover.
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get cover;

  /// No description provided for @mandatory_choice.
  ///
  /// In en, this message translates to:
  /// **'(*) Mandatory Choice'**
  String get mandatory_choice;

  /// No description provided for @manufacture_year.
  ///
  /// In en, this message translates to:
  /// **'Manufacture Year'**
  String get manufacture_year;

  /// No description provided for @enter_price.
  ///
  /// In en, this message translates to:
  /// **'Enter asking price'**
  String get enter_price;

  /// No description provided for @mini_biding_price.
  ///
  /// In en, this message translates to:
  /// **'Minimum biding price you want to see'**
  String get mini_biding_price;

  /// No description provided for @enter_mini_price.
  ///
  /// In en, this message translates to:
  /// **'Enter minimum price'**
  String get enter_mini_price;

  /// No description provided for @enter_mileage.
  ///
  /// In en, this message translates to:
  /// **'Enter mileage'**
  String get enter_mileage;

  /// No description provided for @plate_number.
  ///
  /// In en, this message translates to:
  /// **'Plate Number'**
  String get plate_number;

  /// No description provided for @enter_plate_number.
  ///
  /// In en, this message translates to:
  /// **'Enter plate number'**
  String get enter_plate_number;

  /// No description provided for @enter_chassis.
  ///
  /// In en, this message translates to:
  /// **'Enter chassis number'**
  String get enter_chassis;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @under_warranty.
  ///
  /// In en, this message translates to:
  /// **'Under Warranty'**
  String get under_warranty;

  /// No description provided for @car_desc.
  ///
  /// In en, this message translates to:
  /// **'Car Description'**
  String get car_desc;

  /// No description provided for @enter_desc.
  ///
  /// In en, this message translates to:
  /// **'Enter car description...'**
  String get enter_desc;

  /// No description provided for @make_360_first.
  ///
  /// In en, this message translates to:
  /// **'Make Your Advertisement special by 360 session'**
  String get make_360_first;

  /// No description provided for @make_360_second.
  ///
  /// In en, this message translates to:
  /// **'riyal only for full shooting session)'**
  String get make_360_second;

  /// No description provided for @pin_ad_first.
  ///
  /// In en, this message translates to:
  /// **'Pin your advertisement at the top for '**
  String get pin_ad_first;

  /// No description provided for @pin_ad_second.
  ///
  /// In en, this message translates to:
  /// **',) QR only'**
  String get pin_ad_second;

  /// No description provided for @agreement.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms and Conditions'**
  String get agreement;

  /// No description provided for @confirm_info.
  ///
  /// In en, this message translates to:
  /// **'I confirm the accuracy of the information provided'**
  String get confirm_info;

  /// No description provided for @save_draft.
  ///
  /// In en, this message translates to:
  /// **'Save as draft'**
  String get save_draft;

  /// No description provided for @republish.
  ///
  /// In en, this message translates to:
  /// **'RePublish'**
  String get republish;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @loading_car_data.
  ///
  /// In en, this message translates to:
  /// **'Loading car data...'**
  String get loading_car_data;

  /// No description provided for @update_ad.
  ///
  /// In en, this message translates to:
  /// **'Updating Ad'**
  String get update_ad;

  /// No description provided for @creating_ad.
  ///
  /// In en, this message translates to:
  /// **'Creating Ad'**
  String get creating_ad;

  /// No description provided for @please_wait_update.
  ///
  /// In en, this message translates to:
  /// **'Please wait while your ad is being updated...'**
  String get please_wait_update;

  /// No description provided for @please_wait_create.
  ///
  /// In en, this message translates to:
  /// **'Please wait while your ad is being created...'**
  String get please_wait_create;

  /// No description provided for @ok_lbl.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok_lbl;

  /// No description provided for @of_lbl.
  ///
  /// In en, this message translates to:
  /// **'Of'**
  String get of_lbl;

  /// No description provided for @error_lbl.
  ///
  /// In en, this message translates to:
  /// **'Error:'**
  String get error_lbl;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @no_ads.
  ///
  /// In en, this message translates to:
  /// **'No Ads Found'**
  String get no_ads;

  /// No description provided for @delete_ad.
  ///
  /// In en, this message translates to:
  /// **'Delete Ad'**
  String get delete_ad;

  /// No description provided for @delete_ad_confirm_msg.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this ad?'**
  String get delete_ad_confirm_msg;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update Offer'**
  String get update;

  /// No description provided for @request_360.
  ///
  /// In en, this message translates to:
  /// **'Request 360 Service'**
  String get request_360;

  /// No description provided for @ready_pro.
  ///
  /// In en, this message translates to:
  /// **'Ready to showCase your vehicle like a pro?'**
  String get ready_pro;

  /// No description provided for @msg_360_first.
  ///
  /// In en, this message translates to:
  /// **'Our 360 photo session will beautifully highlight your post \nclick Confirm, and we \'ll handle the rest! \n   Additional charges'**
  String get msg_360_first;

  /// No description provided for @msg_360_second.
  ///
  /// In en, this message translates to:
  /// **'can apply.'**
  String get msg_360_second;

  /// No description provided for @confirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get confirmation;

  /// No description provided for @receive_request_msg.
  ///
  /// In en, this message translates to:
  /// **'We Have Received Your Request'**
  String get receive_request_msg;

  /// No description provided for @cancellation.
  ///
  /// In en, this message translates to:
  /// **'Cancellation'**
  String get cancellation;

  /// No description provided for @request_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed To Send A Request'**
  String get request_failed;

  /// No description provided for @payment_failed.
  ///
  /// In en, this message translates to:
  /// **'Payment Failed'**
  String get payment_failed;

  /// No description provided for @payment_failed_or_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Payment failed or cancelled.'**
  String get payment_failed_or_cancelled;

  /// No description provided for @feature_ad.
  ///
  /// In en, this message translates to:
  /// **'Feature Your Ad'**
  String get feature_ad;

  /// No description provided for @centered_ad.
  ///
  /// In en, this message translates to:
  /// **'Let\'s make your post the center \\n of orientation'**
  String get centered_ad;

  /// No description provided for @feature_ad_msg_first.
  ///
  /// In en, this message translates to:
  /// **'Featuring your post ensures it stands out at the top for everyone to see.\n Additional charges'**
  String get feature_ad_msg_first;

  /// No description provided for @feature_ad_msg_second.
  ///
  /// In en, this message translates to:
  /// **'can apply.\n Click confirm to proceed!'**
  String get feature_ad_msg_second;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @modify.
  ///
  /// In en, this message translates to:
  /// **'Modify'**
  String get modify;

  /// No description provided for @specs.
  ///
  /// In en, this message translates to:
  /// **'Specs'**
  String get specs;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get info;

  /// No description provided for @waiting_ad_approval.
  ///
  /// In en, this message translates to:
  /// **'This ad is pending approval, Please wait \\n while we review your ad'**
  String get waiting_ad_approval;

  /// No description provided for @creation_date.
  ///
  /// In en, this message translates to:
  /// **'Creation Date:'**
  String get creation_date;

  /// No description provided for @ex_date.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date:'**
  String get ex_date;

  /// No description provided for @please_edit_img.
  ///
  /// In en, this message translates to:
  /// **'Please edit image'**
  String get please_edit_img;

  /// No description provided for @only_15_img.
  ///
  /// In en, this message translates to:
  /// **'You can only select up to 15 images.'**
  String get only_15_img;

  /// No description provided for @tap_save.
  ///
  /// In en, this message translates to:
  /// **'and tap SAVE when done'**
  String get tap_save;

  /// No description provided for @upload_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload'**
  String get upload_failed;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'image'**
  String get image;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @cancel_edit_img.
  ///
  /// In en, this message translates to:
  /// **'Image Editing Cancelled'**
  String get cancel_edit_img;

  /// No description provided for @was_cancelled.
  ///
  /// In en, this message translates to:
  /// **'was cancelled. Do you want to retry editing it?'**
  String get was_cancelled;

  /// No description provided for @video_not_play.
  ///
  /// In en, this message translates to:
  /// **'Video cannot be played'**
  String get video_not_play;

  /// No description provided for @over_video.
  ///
  /// In en, this message translates to:
  /// **'This video may be too high resolution for your device'**
  String get over_video;

  /// No description provided for @open_external_player.
  ///
  /// In en, this message translates to:
  /// **'Open in External Player'**
  String get open_external_player;

  /// No description provided for @no_video_app.
  ///
  /// In en, this message translates to:
  /// **'Could not play video. Please check your video player app.'**
  String get no_video_app;

  /// No description provided for @field_video.
  ///
  /// In en, this message translates to:
  /// **'Failed to play video. Please try again.'**
  String get field_video;

  /// No description provided for @delete_generally_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this'**
  String get delete_generally_confirm;

  /// No description provided for @gallery_management.
  ///
  /// In en, this message translates to:
  /// **'Gallery Management'**
  String get gallery_management;

  /// No description provided for @images.
  ///
  /// In en, this message translates to:
  /// **'images'**
  String get images;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'video'**
  String get video;

  /// No description provided for @error_loading_image.
  ///
  /// In en, this message translates to:
  /// **'Error loading images'**
  String get error_loading_image;

  /// No description provided for @no_img.
  ///
  /// In en, this message translates to:
  /// **'No images found'**
  String get no_img;

  /// No description provided for @missing_info.
  ///
  /// In en, this message translates to:
  /// **'Missing Information'**
  String get missing_info;

  /// No description provided for @please_fill_info.
  ///
  /// In en, this message translates to:
  /// **'Please fill in the following required fields'**
  String get please_fill_info;

  /// No description provided for @specs_management.
  ///
  /// In en, this message translates to:
  /// **'Specs Management'**
  String get specs_management;

  /// No description provided for @hidden.
  ///
  /// In en, this message translates to:
  /// **'(Hidden)'**
  String get hidden;

  /// No description provided for @full_name.
  ///
  /// In en, this message translates to:
  /// **'Full Name(*)'**
  String get full_name;

  /// No description provided for @enter_full_name.
  ///
  /// In en, this message translates to:
  /// **'Enter Full Name'**
  String get enter_full_name;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email(*)'**
  String get email;

  /// No description provided for @enter_email.
  ///
  /// In en, this message translates to:
  /// **'Enter Email'**
  String get enter_email;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country(*)'**
  String get country;

  /// No description provided for @mbl_number.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number(*)'**
  String get mbl_number;

  /// No description provided for @please_fill_fields.
  ///
  /// In en, this message translates to:
  /// **'PLease fill all fields'**
  String get please_fill_fields;

  /// No description provided for @register_success.
  ///
  /// In en, this message translates to:
  /// **'Registered Successfully'**
  String get register_success;

  /// No description provided for @no_notify.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get no_notify;

  /// No description provided for @delete_notification_title.
  ///
  /// In en, this message translates to:
  /// **'Delete Notification'**
  String get delete_notification_title;

  /// No description provided for @delete_notification_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this notification?'**
  String get delete_notification_message;

  /// No description provided for @clear_all_notifications_title.
  ///
  /// In en, this message translates to:
  /// **'Clear All Notifications'**
  String get clear_all_notifications_title;

  /// No description provided for @clear_all_notifications_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all notifications?'**
  String get clear_all_notifications_message;

  /// No description provided for @btn_delete_all.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get btn_delete_all;

  /// No description provided for @redirecting_payment.
  ///
  /// In en, this message translates to:
  /// **'Redirecting to payment page...'**
  String get redirecting_payment;

  /// No description provided for @no_payment_methods_available.
  ///
  /// In en, this message translates to:
  /// **'No payment methods available'**
  String get no_payment_methods_available;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @choose_payment_method.
  ///
  /// In en, this message translates to:
  /// **'Choose Payment Method'**
  String get choose_payment_method;

  /// No description provided for @out_of_5.
  ///
  /// In en, this message translates to:
  /// **'Out of 5'**
  String get out_of_5;

  /// No description provided for @rate_room.
  ///
  /// In en, this message translates to:
  /// **'Rate Showroom'**
  String get rate_room;

  /// No description provided for @five_stars.
  ///
  /// In en, this message translates to:
  /// **'Five Stars'**
  String get five_stars;

  /// No description provided for @four_stars.
  ///
  /// In en, this message translates to:
  /// **'Four Stars'**
  String get four_stars;

  /// No description provided for @three_stars.
  ///
  /// In en, this message translates to:
  /// **'Three Stars'**
  String get three_stars;

  /// No description provided for @two_stars.
  ///
  /// In en, this message translates to:
  /// **'Two Stars'**
  String get two_stars;

  /// No description provided for @one_star.
  ///
  /// In en, this message translates to:
  /// **'One Star'**
  String get one_star;

  /// No description provided for @delete_offer.
  ///
  /// In en, this message translates to:
  /// **'Delete Offer'**
  String get delete_offer;

  /// No description provided for @sure_delete_offer.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this offer?'**
  String get sure_delete_offer;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @offer_deleted.
  ///
  /// In en, this message translates to:
  /// **'Offer deleted successfully'**
  String get offer_deleted;

  /// No description provided for @failed_delete_offer.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete offer'**
  String get failed_delete_offer;

  /// No description provided for @error_on_delete.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while deleting the offer'**
  String get error_on_delete;

  /// No description provided for @navigation_services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get navigation_services;

  /// No description provided for @navigation_call_us.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get navigation_call_us;

  /// No description provided for @navigation_favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navigation_favorites;

  /// No description provided for @navigation_find_me_car.
  ///
  /// In en, this message translates to:
  /// **'Find'**
  String get navigation_find_me_car;

  /// No description provided for @boldFont.
  ///
  /// In en, this message translates to:
  /// **'gilroy_bold'**
  String get boldFont;

  /// No description provided for @regularFont.
  ///
  /// In en, this message translates to:
  /// **'gilroy_regular'**
  String get regularFont;

  /// No description provided for @lightFont.
  ///
  /// In en, this message translates to:
  /// **'gilroy_light'**
  String get lightFont;

  /// No description provided for @currency_Symbol.
  ///
  /// In en, this message translates to:
  /// **'QAR'**
  String get currency_Symbol;

  /// No description provided for @mileage_Unit.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get mileage_Unit;

  /// No description provided for @tag_New.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get tag_New;

  /// No description provided for @tag_Inspected.
  ///
  /// In en, this message translates to:
  /// **'Inspected'**
  String get tag_Inspected;

  /// No description provided for @tag_Sold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get tag_Sold;

  /// No description provided for @tag_Featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get tag_Featured;

  /// No description provided for @msg_Loading.
  ///
  /// In en, this message translates to:
  /// **'Working on it'**
  String get msg_Loading;

  /// No description provided for @msg_No_Internet.
  ///
  /// In en, this message translates to:
  /// **'Please Check Your Internet Connection'**
  String get msg_No_Internet;

  /// No description provided for @value_Yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get value_Yes;

  /// No description provided for @value_No.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get value_No;

  /// No description provided for @value_Not_Yet.
  ///
  /// In en, this message translates to:
  /// **'Not Yet'**
  String get value_Not_Yet;

  /// No description provided for @tv_No_Data_Was_Found.
  ///
  /// In en, this message translates to:
  /// **'No Data Was Found'**
  String get tv_No_Data_Was_Found;

  /// No description provided for @tv_DatePicker_Dialog_Title.
  ///
  /// In en, this message translates to:
  /// **'Please Choose Date'**
  String get tv_DatePicker_Dialog_Title;

  /// No description provided for @msg_Working_Hard_To_Make_Feature_Ready.
  ///
  /// In en, this message translates to:
  /// **'We are working hard to make this feature ready, please check here after a while'**
  String get msg_Working_Hard_To_Make_Feature_Ready;

  /// No description provided for @msg_This_Version_is_Very_Old.
  ///
  /// In en, this message translates to:
  /// **'This version is old, we recommend updating to the newest version available from Google Play Store'**
  String get msg_This_Version_is_Very_Old;

  /// No description provided for @msg_Please_Confirm.
  ///
  /// In en, this message translates to:
  /// **'Please Confirm'**
  String get msg_Please_Confirm;

  /// No description provided for @msg_Received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get msg_Received;

  /// No description provided for @msg_Request_Received.
  ///
  /// In en, this message translates to:
  /// **'Your request was received successfully'**
  String get msg_Request_Received;

  /// No description provided for @msg_This_car_is_not_available_for_sale_anymore.
  ///
  /// In en, this message translates to:
  /// **'This car is not available for sale anymore!'**
  String get msg_This_car_is_not_available_for_sale_anymore;

  /// No description provided for @msg_You_Are_Not_Registered_Yet.
  ///
  /// In en, this message translates to:
  /// **'You are not registered yet! please go to My Account section to register and verify your mobile number.'**
  String get msg_You_Are_Not_Registered_Yet;

  /// No description provided for @btn_Cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btn_Cancel;

  /// No description provided for @btn_Verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get btn_Verify;

  /// No description provided for @btn_Confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get btn_Confirm;

  /// No description provided for @btn_Close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get btn_Close;

  /// No description provided for @btn_Not_Now.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get btn_Not_Now;

  /// No description provided for @btn_Download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get btn_Download;

  /// No description provided for @btn_Send_Request.
  ///
  /// In en, this message translates to:
  /// **'Send Request'**
  String get btn_Send_Request;

  /// No description provided for @title_Main_Menu.
  ///
  /// In en, this message translates to:
  /// **'Main Menu'**
  String get title_Main_Menu;

  /// No description provided for @lbl_change_language.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get lbl_change_language;

  /// No description provided for @lbl_support_help_desk.
  ///
  /// In en, this message translates to:
  /// **'Support / Help Desk'**
  String get lbl_support_help_desk;

  /// No description provided for @lbl_privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get lbl_privacy_policy;

  /// No description provided for @lbl_terms_and_conditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get lbl_terms_and_conditions;

  /// No description provided for @lbl_about_qars_spin.
  ///
  /// In en, this message translates to:
  /// **'About Qars Spin'**
  String get lbl_about_qars_spin;

  /// No description provided for @title_Personal_Information.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get title_Personal_Information;

  /// No description provided for @lbl_register_now.
  ///
  /// In en, this message translates to:
  /// **'Register Now'**
  String get lbl_register_now;

  /// No description provided for @lbl_my_offers.
  ///
  /// In en, this message translates to:
  /// **'My Offers'**
  String get lbl_my_offers;

  /// No description provided for @lbl_notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get lbl_notifications;

  /// No description provided for @lbl_sign_out.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get lbl_sign_out;

  /// No description provided for @msg_Sign_Out.
  ///
  /// In en, this message translates to:
  /// **'By clicking on the confirm button you will be signed out from this mobile device, are you sure?'**
  String get msg_Sign_Out;

  /// No description provided for @title_create_new_account.
  ///
  /// In en, this message translates to:
  /// **'Create New Account'**
  String get title_create_new_account;

  /// No description provided for @lbl_your_mobile_number.
  ///
  /// In en, this message translates to:
  /// **'Your Mobile Number'**
  String get lbl_your_mobile_number;

  /// No description provided for @hint_enter_your_mobile_number.
  ///
  /// In en, this message translates to:
  /// **'Enter your mobile number'**
  String get hint_enter_your_mobile_number;

  /// No description provided for @lbl_your_country.
  ///
  /// In en, this message translates to:
  /// **'Your Country'**
  String get lbl_your_country;

  /// No description provided for @hint_choose_your_country.
  ///
  /// In en, this message translates to:
  /// **'Choose your country'**
  String get hint_choose_your_country;

  /// No description provided for @msg_Please_Choose_Country.
  ///
  /// In en, this message translates to:
  /// **'Please Choose Your Country'**
  String get msg_Please_Choose_Country;

  /// No description provided for @msg_Please_Provide_Mobile_Number.
  ///
  /// In en, this message translates to:
  /// **'Please Provide Your Mobile Number'**
  String get msg_Please_Provide_Mobile_Number;

  /// No description provided for @msg_registering_new_user.
  ///
  /// In en, this message translates to:
  /// **'Creating New Account'**
  String get msg_registering_new_user;

  /// No description provided for @msg_Verification_In_Progress.
  ///
  /// In en, this message translates to:
  /// **'Verifying Your Mobile Number'**
  String get msg_Verification_In_Progress;

  /// No description provided for @msg_Requesting_Verification_Code.
  ///
  /// In en, this message translates to:
  /// **'Requesting Verification Code, Please Wait...'**
  String get msg_Requesting_Verification_Code;

  /// No description provided for @tv_Verify_Mobile_Number_Dialog_Title.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Mobile Number'**
  String get tv_Verify_Mobile_Number_Dialog_Title;

  /// No description provided for @msg_Verification_Code_Is_Empty.
  ///
  /// In en, this message translates to:
  /// **'Verification Code is Empty!'**
  String get msg_Verification_Code_Is_Empty;

  /// No description provided for @msg_Verification_Code_Is_wrong.
  ///
  /// In en, this message translates to:
  /// **'Verification Code is Wrong!'**
  String get msg_Verification_Code_Is_wrong;

  /// No description provided for @youHaveRequestedThisServiceBefore.
  ///
  /// In en, this message translates to:
  /// **'You Have Requested This Service Before'**
  String get youHaveRequestedThisServiceBefore;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @serviceFee.
  ///
  /// In en, this message translates to:
  /// **'Service Fee'**
  String get serviceFee;

  /// No description provided for @qarOnlyForRequest360Session.
  ///
  /// In en, this message translates to:
  /// **'QAR Only For Request 360 Session.'**
  String get qarOnlyForRequest360Session;

  /// No description provided for @qarOnlyForFeaturePost.
  ///
  /// In en, this message translates to:
  /// **'QAR Only For Feature Post.'**
  String get qarOnlyForFeaturePost;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @pleaseFillAllInformationBelow.
  ///
  /// In en, this message translates to:
  /// **'Please fill all information below'**
  String get pleaseFillAllInformationBelow;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @enterFirstName.
  ///
  /// In en, this message translates to:
  /// **'Enter first name'**
  String get enterFirstName;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @enterLastName.
  ///
  /// In en, this message translates to:
  /// **'Enter last name'**
  String get enterLastName;

  /// No description provided for @mobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get mobile;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhoneNumber;

  /// No description provided for @invalidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get invalidPhoneNumber;

  /// No description provided for @enterEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter email address'**
  String get enterEmailAddress;

  /// No description provided for @cemail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get cemail;

  /// No description provided for @proceedToPayment.
  ///
  /// In en, this message translates to:
  /// **'PROCEED TO PAYMENT'**
  String get proceedToPayment;

  /// No description provided for @invalidEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmailAddress;

  /// No description provided for @paymentSucceeded.
  ///
  /// In en, this message translates to:
  /// **'Payment Succeeded'**
  String get paymentSucceeded;

  /// No description provided for @paymentWasCompleted.
  ///
  /// In en, this message translates to:
  /// **'Payment was completed.'**
  String get paymentWasCompleted;

  /// No description provided for @paymentWasNotCompleted.
  ///
  /// In en, this message translates to:
  /// **'Payment was not completed.'**
  String get paymentWasNotCompleted;

  /// No description provided for @failedToLoadPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Failed to load payment methods'**
  String get failedToLoadPaymentMethods;

  /// No description provided for @paymentflowfailed.
  ///
  /// In en, this message translates to:
  /// **'Payment flow failed'**
  String get paymentflowfailed;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
