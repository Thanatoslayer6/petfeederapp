import 'package:flutter/material.dart';

double getadaptiveTextSize(BuildContext context, dynamic value) {
  // 720 is medium screen height
  // return (value / 720) * size.height;
  return (value / 720) * MediaQuery.of(context).size.height;
}
