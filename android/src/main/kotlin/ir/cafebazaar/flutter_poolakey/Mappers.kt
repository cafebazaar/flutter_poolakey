package ir.cafebazaar.flutter_poolakey

import ir.cafebazaar.poolakey.entity.PurchaseInfo
import ir.cafebazaar.poolakey.entity.SkuDetails

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

internal fun SkuDetails.toMap() = hashMapOf(
    "sku" to sku,
    "type" to type,
    "price" to price,
    "title" to title,
    "description" to description
)
