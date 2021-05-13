import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ProductTextSpan extends TextSpan {
  ProductTextSpan(String productId, Function(String) onProductClick)
      : super(
            text: productId,
            style: TextStyle(
              color: Colors.cyan,
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()..onTap = () => onProductClick(productId));
}
