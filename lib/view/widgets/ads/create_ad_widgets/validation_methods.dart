import 'dart:developer';

import 'package:flutter/material.dart';

class ValidationMethods {
  /// Validates the non-field-list parts of the form — cover image,
  /// terms consent, accuracy confirmation. The field-list check
  /// (make / class / model / type / year / price / mileage / colors /
  /// fuel / cylinders / transmission) lives in the parent screen
  /// (`_validateAndSubmitForm`) so it can pull localized labels
  /// directly from `AppLocalizations` — this class stays pure and
  /// doesn't need locale awareness.
  ///
  /// The `termsMessage` and `accuracyMessage` params are the exact
  /// user-facing strings to show; the parent passes localized copies
  /// (Arabic or English) based on the app's current locale.
  static bool validateForm({
    required String coverImage,
    required bool termsAccepted,
    required bool infoConfirmed,
    required BuildContext context,
    required String termsMessage,
    required String accuracyMessage,
    required Function(List<String>) showMissingFieldsDialog,
    required Function() showMissingCoverImageDialog,
  }) {
    // Check if cover image is selected
    if (coverImage.isEmpty) {
      showMissingCoverImageDialog();
      return false;
    }

    // Check if terms are accepted
    if (!termsAccepted) {
      showMissingFieldsDialog([termsMessage]);
      return false;
    }

    // Check if info is confirmed
    if (!infoConfirmed) {
      showMissingFieldsDialog([accuracyMessage]);
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