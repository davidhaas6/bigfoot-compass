// import 'dart:math';

import 'package:flutter/material.dart';


class TriangleShape extends BoxPainter  {
  Paint painter = Paint()
    ..color = Colors.purpleAccent
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas,  Offset offset, ImageConfiguration configuration) {
    var size = configuration.size!;
    var path = Path();

    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.height, size.width);
    path.close();

    canvas.drawPath(path, painter);
  }

}
