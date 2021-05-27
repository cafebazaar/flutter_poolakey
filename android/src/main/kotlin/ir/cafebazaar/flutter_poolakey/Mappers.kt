package ir.cafebazaar.flutter_poolakey

import ir.cafebazaar.poolakey.entity.PurchaseInfo

internal fun PurchaseInfo.toMap() = hashMapOf(
    "orderId" to orderId,
    "purchaseToken" to purchaseToken,
    "payload" to payload,
    "packageName" to packageName,
    "purchaseState" to purchaseState.toString(),
    "purchaseTime" to purchaseTime,
    "productId" to productId,
    "originalJson" to originalJson,
    "dataSignature" to dataSignature
)