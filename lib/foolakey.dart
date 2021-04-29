
import 'dart:async';

import 'package:flutter/services.dart';

class Foolakey {
  static const MethodChannel _channel = const MethodChannel('ir.cafebazaar.foolakey');

  static Future<bool> init(String inAppBillingKey) async {
    return await _channel.invokeMethod('init', {'in_app_billing_key': inAppBillingKey});
  }

  static Future<PurchaseInfo> purchase(
    String productId, {
    String payload = "",
  }) async {
    final map = await _channel.invokeMethod('purchase', {'product_id': productId, 'payload': payload});
    return PurchaseInfo.fromMap(map);
  }

  static Future<PurchaseInfo> subscribe(
    String productId, {
    String payload = "",
  }) async {
    final map = await _channel.invokeMethod('subscribe', {'product_id': productId, 'payload': payload});
    return PurchaseInfo.fromMap(map);
  }

  static Future<bool> consume(String purchaseToken) async {
    return await _channel.invokeMethod('consume', {'purchase_token': purchaseToken});
  }
  
  static Future<PurchaseInfo?> queryPurchasedProduct(String productId) async {
    final map = await _channel.invokeMethod('query_purchased_product', {'product_id': productId});
    if (map == null) {
      return null;
    }
    return PurchaseInfo.fromMap(map);
  }

  static Future<PurchaseInfo?> querySubscribedProduct(String productId) async {
    final map = await _channel.invokeMethod('query_subscribed_product', {'product_id': productId});
    if (map == null) {
      return null;
    }
    return PurchaseInfo.fromMap(map);
  }
}

class PurchaseInfo {
  final String orderId;
  final String purchaseToken;
  final String payload;
  final String packageName;
  final PurchaseState purchaseState;
  final int purchaseTime;
  final String productId;
  final String originalJson;
  final String dataSignature;

  PurchaseInfo(this.orderId, this.purchaseToken, this.payload, this.packageName, this.purchaseState, this.purchaseTime,
      this.productId, this.originalJson, this.dataSignature);

  factory PurchaseInfo.fromMap(Map<dynamic, dynamic> typeName) {
    return PurchaseInfo(
      typeName['orderId'] as String,
      typeName['purchaseToken'] as String,
      typeName['payload'] as String,
      typeName['packageName'] as String,
      parsePurchaseState(typeName['purchaseState']),
      typeName['purchaseTime'] as int,
      typeName['productId'] as String,
      typeName['originalJson'] as String,
      typeName['dataSignature'] as String,
    );
  }

  @override
  String toString() => 'orderId: $orderId,'
      '\npurchaseToken: $purchaseToken,'
      '\npayload: $payload,'
      '\npackageName: $packageName,'
      '\npurchaseState: $purchaseState,'
      '\npurchaseTime: $purchaseTime,'
      '\nproductId: $productId,'
      '\noriginalJson: $originalJson,'
      '\ndataSignature: $dataSignature';
}

enum PurchaseState { PURCHASED, REFUNDED }

PurchaseState parsePurchaseState(String state) {
  switch (state) {
    case 'PURCHASED':
      return PurchaseState.PURCHASED;
    case 'REFUNDED':
      return PurchaseState.REFUNDED;
  }
  throw StateError('state is not defined');
}
