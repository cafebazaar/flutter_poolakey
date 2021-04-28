
import 'dart:async';

import 'package:flutter/services.dart';

class Foolakey {
  static const MethodChannel _channel = const MethodChannel('ir.cafebazaar.foolakey');

  static Future<bool> init(String inAppBillingKey) =>
      _channel.invokeMethod('init', {'in_app_billing_key': inAppBillingKey});

}
