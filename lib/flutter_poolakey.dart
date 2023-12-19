import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'purchase_info.dart';
import 'sku_details.dart';

export 'purchase_info.dart';
export 'sku_details.dart';

/// [FlutterPoolakey] is a Flutter In-App Billing SDK for Cafe Bazaar App Store.
///
/// It only works in the Android platform (Because [Cafebazaar](https://cafebazaar.ir/?l=en) only supports Android)
/// It uses [Poolakey](https://github.com/cafebazaar/Poolakey) SDK under the hood.
class FlutterPoolakey {
  static const MethodChannel _channel =
      const MethodChannel('ir.cafebazaar.flutter_poolakey');

  static Future<String> getVersion() async {
    return await _channel.invokeMethod('version', {});
  }

  /// Initializes the connection between your app and the bazaar app
  ///
  /// You must call this method before any other methods of this library.
  /// [inAppBillingKey] is the RSA key which you can find it in your (pishkhan panel)[https://pishkhan.cafebazaar.ir].
  /// You can also disable the local security check (only if you are using Bazaar's REST API)
  /// by passing null as [inAppBillingKey].
  ///
  /// You should listen to [onDisconnected] callback and call [FlutterPoolakey.connect] to reconnect again.
  ///
  /// This function may return an error, you should handle the error and check the stacktrace to resolve it.
  static Future<bool> connect(String? inAppBillingKey,
      {VoidCallback? onDisconnected}) async {
    _registerOnDisconnect(onDisconnected);
    return await _channel
        .invokeMethod('connect', {'in_app_billing_key': inAppBillingKey});
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


  ///To avoid problems such as Memory Leak, 
  ///you must disconnect from the market in the dispose method of your page widget
  /// or when you no longer have anything to do with it:
  static Future<void> disconnect() async {
    return _channel.invokeMethod('disconnect');
  }


  /// Initiates the purchase flow
  ///
  /// [productId] is your product's identifier (also known as SKU).
  /// [payload] is an optional parameter that you can send, bazaar saves it in the [PurchaseInfo].
  /// You can access it through your back-end API.
  /// [dynamicPriceToken] This is a token that the developer can apply to any user to change the price of the product.
  /// for more info about this please read the site documentation.
  ///
  /// If any error happened (like when user cancels the flow) it throws a [PlatformException] with a stacktrace.
  /// You must handle the error with your logic.
  ///
  /// If it succeeded, it returns the [PurchaseInfo] of the purchased product.
  static Future<PurchaseInfo> purchase(
    String productId, {
    String payload = "",
    String dynamicPriceToken = "",
  }) async {
    final map = await _channel.invokeMethod('purchase', {
      'product_id': productId,
      'payload': payload,
      'dynamicPriceToken': dynamicPriceToken
    });
    return PurchaseInfo.fromMap(map);
  }

  /// Initializes the subscription flow
  ///
  /// [productId] is your product's identifier (also known as SKU).
  /// [payload] is an optional parameter that you can send, bazaar saves it in the [PurchaseInfo].
  /// You can access it through your back-end API.
  /// [dynamicPriceToken] This is a token that the developer can apply to any user to change the price of the product.
  /// for more info about this please read the site documentation.
  ///
  /// If any error happened (like when user cancels the flow) it throws a [PlatformException] with a stacktrace.
  /// You must handle the error with your logic.
  ///
  /// If it succeeded, it returns the [PurchaseInfo] of the purchased product.
  static Future<PurchaseInfo> subscribe(
    String productId, {
    String payload = "",
    String dynamicPriceToken = "",
  }) async {
    final map = await _channel.invokeMethod('subscribe', {
      'product_id': productId,
      'payload': payload,
      'dynamicPriceToken': dynamicPriceToken
    });
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
    return await _channel
        .invokeMethod('consume', {'purchase_token': purchaseToken});
  }

  /// Returns all purchases list
  ///
  /// Retrieves list of [PurchaseInfo] which contains all purchased products in user's inventory.
  static Future<List<PurchaseInfo>> getAllPurchasedProducts() async {
    final List list = await _channel.invokeMethod("get_all_purchased_products");
    return list.map((map) => PurchaseInfo.fromMap(map)).toList();
  }

  /// Check Trial-Subscription existanse
  /// 
  /// It availbles if not subscribe any item.
  static Future<Map> checkTrialSubscription() async {
    return await _channel.invokeMethod("checkTrialSubscription");
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
    try {
      return (await getAllPurchasedProducts()).find(productId);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// Returns all subscribed products
  ///
  /// Retrieves list of [PurchaseInfo] which contains all subscribed products in user's inventory.
  static Future<List<PurchaseInfo>> getAllSubscribedProducts() async {
    final List list =
        await _channel.invokeMethod("get_all_subscribed_products");
    return list.map((map) => PurchaseInfo.fromMap(map)).toList();
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
    try {
      return (await getAllSubscribedProducts()).find(productId);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// Returns sku details of your purchasable products
  ///
  /// You can use this function to get detail of inApp product sku's,
  /// [skuIds] Contain all sku id's that you want to get info about it.
  static Future<List<SkuDetails>> getInAppSkuDetails(
      List<String> skuIds) async {
    final List list = await _channel
        .invokeMethod("get_in_app_sku_details", {'sku_ids': skuIds});
    return list.map((map) => SkuDetails.fromMap(map)).toList();
  }

  /// Returns sku details of your subscribable products
  ///
  /// You can use this function to get detail of subscription product sku's,
  /// [skuIds] Contain all sku id's that you want to get info about it.
  static Future<List<SkuDetails>> getSubscriptionSkuDetails(
      List<String> skuIds) async {
    final List list = await _channel
        .invokeMethod("get_subscription_sku_details", {'sku_ids': skuIds});
    return list.map((map) => SkuDetails.fromMap(map)).toList();
  }
}

extension _purchaseInfoExtension on List<PurchaseInfo> {
  PurchaseInfo? find(String productId) {
    for (final info in this) {
      if (info.productId == productId) {
        return info;
      }
    }
    return null;
  }
}
