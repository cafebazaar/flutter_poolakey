
import 'dart:async';

import 'package:flutter/services.dart';
import 'purchase_info.dart';

export 'purchase_info.dart';

/// [Foolakey] is a Flutter In-App Billing SDK for Cafe Bazaar App Store.
///
/// It only works in the Android platform (Because [Cafebazaar](https://cafebazaar.ir/?l=en) only supports Android)
/// It uses [Poolakey](https://github.com/cafebazaar/Poolakey) SDK under the hood.
class Foolakey {
  static const MethodChannel _channel = const MethodChannel('ir.cafebazaar.foolakey');

  /// Initializes the connection between your app and the bazaar app
  ///
  /// You must call this method before any other methods of this library.
  /// [inAppBillingKey] is the RSA key which you can find it in your (pishkhan panel)[https://pishkhan.cafebazaar.ir].
  /// You can also disable the local security check (only if you are using Bazaar's REST API)
  /// by passing null as [inAppBillingKey].
  /// 
  /// You should listen to [onDisconnected] callback and call [Foolakey.init] to reconnect again.
  ///
  /// This function may return an error, you should handle the error and check the stacktrace to resolve it.
  static Future<bool> init(String? inAppBillingKey, {VoidCallback? onDisconnected}) async {
    _registerOnDisconnect(onDisconnected);
    return await _channel.invokeMethod('init', {'in_app_billing_key': inAppBillingKey});
  }

  static void _registerOnDisconnect(VoidCallback? onDisconnected) {
    if (onDisconnected == null) {
      return;
    }
    _channel.setMethodCallHandler((call) {
      if (call.method == 'disconnected') {
        onDisconnected.call();
        return Future.value(true);
      }
      throw StateError('method ${call.method} is not supported');
    });
  }

  /// Initiates the purchase flow
  ///
  /// [productId] is your product's identifier (also known as SKU).
  /// [payload] is an optional parameter that you can send, bazaar saves it in the [PurchaseInfo].
  /// You can access it through your back-end API.
  ///
  /// If any error happened (like when user cancels the flow) it throws a [PlatformException] with a stacktrace.
  /// You must handle the error with your logic.
  ///
  /// If it succeeded, it returns the [PurchaseInfo] of the purchased product.
  static Future<PurchaseInfo> purchase(
    String productId, {
    String payload = "",
  }) async {
    final map = await _channel.invokeMethod('purchase', {'product_id': productId, 'payload': payload});
    return PurchaseInfo.fromMap(map);
  }

  /// Initializes the subscription flow
  ///
  /// [productId] is your product's identifier (also known as SKU).
  /// [payload] is an optional parameter that you can send, bazaar saves it in the [PurchaseInfo].
  /// You can access it through your back-end API.
  ///
  /// If any error happened (like when user cancels the flow) it throws a [PlatformException] with a stacktrace.
  /// You must handle the error with your logic.
  ///
  /// If it succeeded, it returns the [PurchaseInfo] of the purchased product.
  static Future<PurchaseInfo> subscribe(
    String productId, {
    String payload = "",
  }) async {
    final map = await _channel.invokeMethod('subscribe', {'product_id': productId, 'payload': payload});
    return PurchaseInfo.fromMap(map);
  }

  /// Consumes a consumable product
  ///
  /// It consumes a product which you defined consumable in your business logic.
  /// If you consume a product, user can buy that product again.
  /// Otherwise user can only buy a purchasable product once.
  ///
  /// If any error happened it throws a [PlatformException] with a stacktrace.
  /// You must handle the error with your logic.
  ///
  /// [purchaseToken] is the purchase identifier, you can find it in [PurchaseInfo.purchaseToken]
  ///
  /// It returns true if the process is successful
  static Future<bool> consume(String purchaseToken) async {
    return await _channel.invokeMethod('consume', {'purchase_token': purchaseToken});
  }


  /// Queries a purchased product in the user's inventory
  ///
  /// It queries and finds a [PurchaseInfo] (or null if it doesn't find) using provided [productId]
  /// in the user's purchased products.
  ///
  /// If any error happened during the query flow, it throws a [PlatformException] with a stack trace.
  /// You must handle the error with your logic.
  ///
  /// It returns a [PurchaseInfo] if this product exists in the user's inventory.
  /// If it doesn't find any, it returns null (That's why [PurchaseInfo] is nullable).
  static Future<PurchaseInfo?> queryPurchasedProduct(String productId) async {
    final map = await _channel.invokeMethod('query_purchased_product', {'product_id': productId});
    if (map == null) {
      return null;
    }
    return PurchaseInfo.fromMap(map);
  }

  /// Queries a subscribed product in the user's inventory
  ///
  /// It queries and finds a [PurchaseInfo] (or null if it doesn't find) using provided [productId]
  /// in the user's subscribed products.
  ///
  /// If any error happened during the query flow, it throws a [PlatformException] with a stack trace.
  /// You must handle the error with your logic.
  ///
  /// It returns a [PurchaseInfo] if this product exists in the user's inventory.
  /// If it doesn't find any, it returns null (That's why [PurchaseInfo] is nullable).
  static Future<PurchaseInfo?> querySubscribedProduct(String productId) async {
    final map = await _channel.invokeMethod('query_subscribed_product', {'product_id': productId});
    if (map == null) {
      return null;
    }
    return PurchaseInfo.fromMap(map);
  }
}
