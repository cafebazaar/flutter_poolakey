package ir.cafebazaar.flutter_poolakey

import android.app.Activity
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import ir.cafebazaar.poolakey.Connection
import ir.cafebazaar.poolakey.ConnectionState
import ir.cafebazaar.poolakey.Payment
import ir.cafebazaar.poolakey.callback.PurchaseCallback
import ir.cafebazaar.poolakey.config.PaymentConfiguration
import ir.cafebazaar.poolakey.config.SecurityCheck

class FlutterPoolakeyPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var activityBinding: ActivityPluginBinding? = null
    private lateinit var flutterPluginBinding: FlutterPlugin.FlutterPluginBinding

    private val requireActivity: Activity
        get() = activityBinding!!.activity

    private var purchaseCallback: (PurchaseCallback.() -> Unit)? = null

    private lateinit var paymentConnection: Connection
    private lateinit var payment: Payment

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        this.flutterPluginBinding = flutterPluginBinding
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
        channel =
            MethodChannel(flutterPluginBinding.binaryMessenger, "ir.cafebazaar.flutter_poolakey")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "version" -> {
                getVersion(result);
            }
            "connect" -> {
                val inAppBillingKey = call.argument<String>("in_app_billing_key")
                connect(inAppBillingKey, result)
            }
            "purchase" -> {
                startActivity(
                    activity = requireActivity,
                    command = PaymentActivity.Command.Purchase,
                    productId = call.argument<String>("product_id")!!,
                    result = result,
                    payload = call.argument<String>("payload"),
                    dynamicPriceToken = call.argument<String>("dynamicPriceToken"),
                )
            }
            "subscribe" -> {
                startActivity(
                    activity = requireActivity,
                    command = PaymentActivity.Command.Subscribe,
                    productId = call.argument<String>("product_id")!!,
                    result = result,
                    payload = call.argument<String>("payload"),
                    dynamicPriceToken = call.argument<String>("dynamicPriceToken"),
                )
            }
            "consume" -> {
                val purchaseToken = call.argument<String>("purchase_token")!!
                consume(purchaseToken, result)
            }
            "get_all_purchased_products" -> {
                getAllPurchasedProducts(result)
            }
            "get_all_subscribed_products" -> {
                getAllSubscribedProducts(result)
            }
            "get_in_app_sku_details" -> {
                val skuIds = call.argument<List<String>>("sku_ids")!!
                getInAppSkuDetails(skuIds, result)
            }
            "get_subscription_sku_details" -> {
                val skuIds = call.argument<List<String>>("sku_ids")!!
                getSubscriptionSkuDetails(skuIds, result)
            }
            "checkTrialSubscription" -> {
                checkTrialSubscription(result)
            }
            else -> result.notImplemented()
        }
    }

    private fun getVersion(result: Result) {
        result.success(BuildConfig.POOLAKEY_VERSION)
    }

    private fun connect(inAppBillingKey: String?, result: Result) {
        val securityCheck = if (inAppBillingKey != null) {
            SecurityCheck.Enable(rsaPublicKey = inAppBillingKey)
        } else {
            SecurityCheck.Disable
        }
        val paymentConfiguration = PaymentConfiguration(localSecurityCheck = securityCheck)

        payment = Payment(context = requireActivity, config = paymentConfiguration)

        paymentConnection = payment.connect {
            connectionSucceed {
                result.success(true)
            }
            connectionFailed {
                result.error("CONNECTION_HAS_FAILED", it.toString(), null)
            }
            disconnected {
                channel.invokeMethod("disconnected", null)
            }
        }
    }

    fun startActivity(
        activity: Activity,
        command: PaymentActivity.Command,
        productId: String,
        result: Result,
        payload: String
        ?,
        dynamicPriceToken: String
        ?
    ) {
        if (paymentConnection.getState() != ConnectionState.Connected) {
            result.error("PURCHASE_FAILED", "In order to purchasing, connect to Poolakey!", null)
            return
        }

        PaymentActivity.start(
            activity,
            command,
            productId,
            payment,
            result,
            payload,
            dynamicPriceToken
        )
    }

    private fun consume(purchaseToken: String, result: Result) {
        if (paymentConnection.getState() != ConnectionState.Connected) {
            result.error(
                "PAYMENT_CONNECTION_IS_NOT_CONNECTED",
                "PaymentConnection is not connected (state: ${paymentConnection.getState()})",
                null
            )
            return
        }
        payment.consumeProduct(purchaseToken) {
            consumeSucceed {
                result.success(true)
            }
            consumeFailed {
                result.error("CONSUME_FAILED", it.toString(), null)
            }
        }
    }

    private fun checkTrialSubscription(result: Result) {
        if (paymentConnection.getState() != ConnectionState.Connected) {
            result.error(
                "PAYMENT_CONNECTION_IS_NOT_CONNECTED",
                "PaymentConnection is not connected (state: ${paymentConnection.getState()})",
                null
            )
            return
        }
        payment.checkTrialSubscription {
            checkTrialSubscriptionSucceed { trialSubscriptionInfo ->
                result.success(hashMapOf(
                    "isAvailable" to trialSubscriptionInfo.isAvailable,
                    "trialPeriodDays" to trialSubscriptionInfo.trialPeriodDays))
            }

            checkTrialSubscriptionFailed {
                result.error("CHECK_TRIAL_FAILED", it.toString(), null)

            }
        }
    }

    private fun getAllPurchasedProducts(result: Result) {
        if (paymentConnection.getState() != ConnectionState.Connected) {
            result.error(
                "PAYMENT_CONNECTION_IS_NOT_CONNECTED",
                "PaymentConnection is not connected (state: ${paymentConnection.getState()})",
                null
            )
            return
        }
        payment.getPurchasedProducts {
            querySucceed { purchasedItems ->
                result.success(purchasedItems.map { it.toMap() })
            }
            queryFailed {
                result.error("QUERY_PURCHASED_PRODUCT_FAILED", it.toString(), null)
            }
        }
    }

    private fun getAllSubscribedProducts(result: Result) {
        if (paymentConnection.getState() != ConnectionState.Connected) {
            result.error(
                "PAYMENT_CONNECTION_IS_NOT_CONNECTED",
                "PaymentConnection is not connected (state: ${paymentConnection.getState()})",
                null
            )
            return
        }
        payment.getSubscribedProducts {
            querySucceed { purchasedItems ->
                result.success(purchasedItems.map { it.toMap() })
            }
            queryFailed {
                result.error("QUERY_SUBSCRIBED_PRODUCT_FAILED", it.toString(), null)
            }
        }
    }

    private fun getInAppSkuDetails(skuIds: List<String>, result: Result) {
        if (paymentConnection.getState() != ConnectionState.Connected) {
            result.error(
                "PAYMENT_CONNECTION_IS_NOT_CONNECTED",
                "PaymentConnection is not connected (state: ${paymentConnection.getState()})",
                null
            )
            return
        }

        payment.getInAppSkuDetails(skuIds = skuIds) {
            getSkuDetailsSucceed {
                result.success(it.map { skuDetails -> skuDetails.toMap() })
            }
            getSkuDetailsFailed {
                result.error("QUERY_GET_IN_APP_SKU_DETAILS_FAILED", it.toString(), null)
            }
        }
    }

    private fun getSubscriptionSkuDetails(skuIds: List<String>, result: Result) {
        if (paymentConnection.getState() != ConnectionState.Connected) {
            result.error(
                "PAYMENT_CONNECTION_IS_NOT_CONNECTED",
                "PaymentConnection is not connected (state: ${paymentConnection.getState()})",
                null
            )
            return
        }

        payment.getSubscriptionSkuDetails(skuIds = skuIds) {
            getSkuDetailsSucceed {
                result.success(it.map { skuDetails -> skuDetails.toMap() })
            }
            getSkuDetailsFailed {
                result.error("QUERY_GET_SUBSCRIPTION_SKU_DETAILS_FAILED", it.toString(), null)
            }
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        // No op
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        // No op
    }

    override fun onDetachedFromActivity() {
        activityBinding = null
        purchaseCallback = null
        channel.setMethodCallHandler(null)
        if(::paymentConnection.isInitialized){
            paymentConnection.disconnect()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    }
}
