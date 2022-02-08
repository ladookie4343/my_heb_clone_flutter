import 'package:flutter/material.dart';

Rect? getWidgetRect(GlobalKey globalKey) {
  var renderObject = globalKey.currentContext?.findRenderObject();
  var translation = renderObject?.getTransformTo(null).getTranslation();
  var size = renderObject?.semanticBounds.size;

  if (translation != null && size != null) {
    return Rect.fromLTWH(translation.x, translation.y, size.width, size.height);
  } else {
    return null;
  }
}