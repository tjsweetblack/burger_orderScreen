import 'package:flutter/material.dart';


class ProgressIndicator {
  static void showProgressIndicator(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}