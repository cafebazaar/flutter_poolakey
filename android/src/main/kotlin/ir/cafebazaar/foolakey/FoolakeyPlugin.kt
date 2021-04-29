package ir.cafebazaar.foolakey

import android.app.Activity
import android.content.Intent
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import ir.cafebazaar.poolakey.Connection
import ir.cafebazaar.poolakey.ConnectionState
import ir.cafebazaar.poolakey.Payment
import ir.cafebazaar.poolakey.callback.PurchaseCallback
import ir.cafebazaar.poolakey.config.PaymentConfiguration
import ir.cafebazaar.poolakey.config.SecurityCheck
import ir.cafebazaar.poolakey.entity.PurchaseInfo
import ir.cafebazaar.poolakey.request.PurchaseRequest

class FoolakeyPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
    private lateinit var channel: MethodChannel
    private var activityBinding: ActivityPluginBinding? = null

    private val requireActivity: Activity
        get() = activityBinding!!.activity

    private var binaryMessenger: BinaryMessenger? = null

    private var purchaseCallback: (PurchaseCallback.() -> Unit)? = null

    private lateinit var paymentConnection: Connection
    private lateinit var payment: Payment

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        binaryMessenger = flutterPluginBinding.binaryMessenger
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
        activityBinding!!.addActivityResultListener(this)
        channel = MethodChannel(binaryMessenger, "ir.cafebazaar.foolakey")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "init" -> {
                val inAppBillingKey = call.argument<String>("in_app_billing_key")!!
                startPaymentConnection(inAppBillingKey, result)
            }
            "purchase" -> {
                val productId = call.argument<String>("product_id")!!
                val payload = call.argument<String>("payload")!!
                purchase(productId, payload, result)
            }
            "subscribe" -> {
                val productId = call.argument<String>("product_id")!!
                val payload = call.argument<String>("payload")!!
                subscribe(productId, payload, result)
            }
            "consume" -> {
                val purchaseToken = call.argument<String>("purchase_token")!!
                consume(purchaseToken, result)
            }
            "query_purchased_item" -> {
                val productId = call.argument<String>("product_id")!!
                queryPurchasedItem(productId, result)
            }
            else -> result.notImplemented()
        }
    }

    private fun startPaymentConnection(inAppBillingKey: String, result: Result) {
        val paymentConfiguration = PaymentConfiguration(
            localSecurityCheck = SecurityCheck.Enable(rsaPublicKey = inAppBillingKey)
        )

        payment = Payment(context = requireActivity, config = paymentConfiguration)

        paymentConnection = payment.connect {
            connectionSucceed {
                result.success(true)
            }
            connectionFailed {
                result.error("CONNECTION_HAS_FAILED", it.toString(), null)
            }
            disconnected {
                // TODO: What can we do here?
            }
        }
    }

    private fun purchase(productId: String, payload: String, result: Result) {
        if (paymentConnection.getState() != ConnectionState.Connected) {
            result.error("PAYMENT_CONNECTION_IS_NOT_CONNECTED", "PaymentConnection is not connected (state: ${paymentConnection.getState()})", null)
        }

        purchaseCallback = {
            purchaseSucceed {
                result.success(it.toMap())
                purchaseCallback = null
            }
            purchaseCanceled {
                result.error("PURCHASE_CANCELLED", "Purchase flow has been canceled", null)
                purchaseCallback = null
            }
            purchaseFailed {
                result.error("PURCHASE_FAILED", "Purchase flow has been failed", null)
                purchaseCallback = null
            }
        }

        payment.purchaseProduct(
            activity = requireActivity,
            request = PurchaseRequest(
                productId = productId,
                requestCode = PURCHASE_REQUEST_CODE,
                payload = payload
            )
        ) {
            purchaseFlowBegan {
                // Nothing
            }
            failedToBeginFlow {
                result.error("FAILED_TO_BEGIN_FLOW", it.toString(), null)
            }
        }
    }

    private fun subscribe(productId: String, payload: String, result: Result) {
        if (paymentConnection.getState() != ConnectionState.Connected) {
            result.error("PAYMENT_CONNECTION_IS_NOT_CONNECTED", "PaymentConnection is not connected (state: ${paymentConnection.getState()})", null)
        }

        purchaseCallback = {
            purchaseSucceed {
                result.success(it.toMap())
                purchaseCallback = null
            }
            purchaseCanceled {
                result.error("SUBSCRIBE_CANCELLED", "Subscription flow has been canceled", null)
                purchaseCallback = null
            }
            purchaseFailed {
                result.error("SUBSCRIBE_FAILED", "Subscription flow has been failed", null)
                purchaseCallback = null
            }
        }

        payment.subscribeProduct(
            activity = requireActivity,
            request = PurchaseRequest(
                productId = productId,
                requestCode = SUBSCRIBE_REQUEST_CODE,
                payload = payload
            )
        ) {
            purchaseFlowBegan {
                // Nothing
            }
            failedToBeginFlow {
                result.error("FAILED_TO_BEGIN_FLOW", it.toString(), null)
            }
        }
    }

    private fun consume(purchaseToken: String, result: Result) {
        payment.consumeProduct(purchaseToken) {
            consumeSucceed {
                result.success(true)
            }
            consumeFailed {
                result.error("CONSUME_FAILED", it.toString(), null)
            }
        }
    }

    private fun queryPurchasedItem(productId: String, result: Result) {
        if (paymentConnection.getState() == ConnectionState.Connected) {
            payment.getPurchasedProducts {
                querySucceed { purchasedItems ->
                    purchasedItems.find { it.productId == productId }
                        ?.also { result.success(it.toMap()) }
                        ?: run { result.success(null) }
                }
                queryFailed {
                    result.error("QUERY_PURCHASED_ITEM_FAILED", it.toString(), null)
                }
            }
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        // Todo: What can we do here?
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        // Todo: What can we do here?
    }

    override fun onDetachedFromActivity() {
        activityBinding = null
        activityBinding!!.removeActivityResultListener(this)
        purchaseCallback = null
        channel.setMethodCallHandler(null)
        paymentConnection.disconnect()
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        binaryMessenger = null
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        payment.onActivityResult(requestCode, resultCode, data, purchaseCallback!!)
        return true
    }

    private fun PurchaseInfo.toMap() = hashMapOf(
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

    companion object {
        private const val PURCHASE_REQUEST_CODE = 1000
        private const val SUBSCRIBE_REQUEST_CODE = 1001
    }
}
