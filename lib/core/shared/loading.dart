import 'package:flutter/material.dart';

class Loading {
  Loading._();

  static Widget loader(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
