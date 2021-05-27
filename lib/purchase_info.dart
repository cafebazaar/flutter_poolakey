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

  PurchaseInfo(
      this.orderId,
      this.purchaseToken,
      this.payload,
      this.packageName,
      this.purchaseState,
      this.purchaseTime,
      this.productId,
      this.originalJson,
      this.dataSignature);

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
