import 'package:flutter/material.dart';

// Common surface to stabilize golden sizes
Widget goldenSurface(Widget child, {Size size = const Size(1200, 800)}) {
  return Center(
    child: SizedBox(
      width: size.width,
      height: size.height,
      child: MaterialApp(home: Material(child: child)),
    ),
  );
}
