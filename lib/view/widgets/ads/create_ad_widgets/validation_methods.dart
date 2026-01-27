import 'dart:developer';

import 'package:flutter/material.dart';

class ValidationMethods {
  static bool validateForm({
    required String make,
    required String carClass,
    required String model,
    required String type,
    required String year,
    required String askingPrice,
    required String mileage,
    required String description,
    required String coverImage,
    required bool termsAccepted,
    required bool infoConfirmed,
    required BuildContext context,
    required bool  isRequest360,
    required bool  isFeaturedPost,
    required String fuelType,
    required String cylinders,
    required String transmission,
    required Function(String) showMissingFieldsDialog,
    required Function() showMissingCoverImageDialog, required postData,
  }) {
    // Check if all mandatory fields are filled
    if(postData==null){  if (make.isEmpty ||
        carClass.isEmpty ||
        model.isEmpty ||
        type.isEmpty ||
        year.isEmpty ||
        askingPrice.isEmpty ||
        mileage.isEmpty||
        fuelType.isEmpty||
        cylinders.isEmpty||
        transmission.isEmpty
    //  ||  description.isEmpty
    ) {
      showMissingFieldsDialog("Please fill all (*)  mandatory fields");
      return false;
    }}else{
      if (make.isEmpty ||
          carClass.isEmpty ||
          model.isEmpty ||
          type.isEmpty ||
          year.isEmpty ||
          askingPrice.isEmpty ||
          mileage.isEmpty

      //  ||  description.isEmpty
      ) {
        showMissingFieldsDialog("Please fill all (*)  mandatory fields");
        return false;
      }
    }


    // Check if cover image is selected
    if (coverImage.isEmpty) {
      showMissingCoverImageDialog();
      return false;
    }//k

    // Check if terms are accepted
    if (!termsAccepted) {
      showMissingFieldsDialog("Please accept the Terms and Conditions");
      return false;
    }

    // Check if info is confirmed
    if (!infoConfirmed) {
      showMissingFieldsDialog("Please confirm the accuracy of the information provided");
      return false;
    }

    return true;
  }

  static bool validateNumericFields({
    required String askingPrice,
    required String minimumPrice,
    required String mileage,
    required String plateNumber,
    required String chassisNumber,
    required BuildContext context,
    required Function(String) showErrorDialog,
  }) {
    // Validate asking price
    if (askingPrice.isNotEmpty) {
      try {
        double price = double.parse(askingPrice);
        if (price <= 0) {
          showErrorDialog("Asking price must be greater than 0");
          return false;
        }
      } catch (e) {
        showErrorDialog("Please enter a valid asking price");
        return false;
      }
    }

    // Validate minimum price
    // if (minimumPrice.isNotEmpty) {
    //   try {
    //     double minPrice = double.parse(minimumPrice);
    //     if (minPrice <= 0) {
    //       showErrorDialog("Minimum bidding price must be greater than 0");
    //       return false;
    //     }
    //   } catch (e) {
    //     showErrorDialog("Please enter a valid minimum bidding price");
    //     return false;
    //   }
    // }

    // Validate mileage
    if (mileage.isNotEmpty) {
      try {
        int mileageValue = int.parse(mileage);
        if (mileageValue < 0) {
          showErrorDialog("Mileage cannot be negative");
          return false;
        }
      } catch (e) {
        showErrorDialog("Please enter a valid mileage");
        return false;
      }
    }

    // Validate plate number (if provided)
    if (plateNumber.isNotEmpty) {
      try {
        int.parse(plateNumber);
      } catch (e) {
        showErrorDialog("Please enter a valid plate number");
        return false;
      }
    }

    // Validate chassis number (if provided)
    // if (chassisNumber.isNotEmpty) {
    //   try {
    //     int.parse(chassisNumber);
    //   } catch (e) {
    //     showErrorDialog("Please enter a valid chassis number");
    //     return false;
    //   }
    // }

    return true;
  }

  static bool validateManufactureYear({
    required String year,
    required BuildContext context,
    required Function(String) showErrorDialog,
  }) {
    if (year.isEmpty) return true;

    try {
      int yearValue = int.parse(year);
      int currentYear = DateTime.now().year;

      if (yearValue < 1900 || yearValue > currentYear + 1) {
        showErrorDialog("Please enter a valid manufacture year");
        return false;
      }
    } catch (e) {
      showErrorDialog("Please enter a valid manufacture year");
      return false;
    }

    return true;
  }

  static String? validateTextField(String value, String fieldName) {
    if (value.isEmpty) {
      return "$fieldName is required";
    }
    return null;
  }

  static String? validateNumericField(String value, String fieldName, {bool allowZero = false}) {
    if (value.isEmpty) {
      return "$fieldName is required";
    }

    try {
      double numericValue = double.parse(value);
      if (!allowZero && numericValue <= 0) {
        return "$fieldName must be greater than 0";
      }
    } catch (e) {
      return "Please enter a valid $fieldName";
    }

    return null;
  }
}