import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants.dart';

SnackbarController snackbar(
  String title,
  String content,
  bool isError,
) {
  return Get.snackbar(title, content,
      borderWidth: 1.2,
      borderColor: isError ? Colors.red : kThemeColor,
      colorText: Colors.white,
      backgroundColor: Colors.black.withOpacity(0.8));
}
