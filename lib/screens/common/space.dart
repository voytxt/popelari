import 'package:flutter/material.dart';

List<Widget> spaceBetween(double? space, List<Widget> widgets) {
  return [
    widgets[0],
    for (final widget in widgets.skip(1)) ...[SizedBox(height: space), widget],
  ];
}

List<Widget> spaceBeforeEach(double? space, List<Widget> widgets) {
  return [
    for (final widget in widgets) ...[SizedBox(height: space), widget],
  ];
}
