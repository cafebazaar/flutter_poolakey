package ir.cafebazaar.foolakey

import android.app.Activity
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import ir.cafebazaar.poolakey.Connection
import ir.cafebazaar.poolakey.Payment
import ir.cafebazaar.poolakey.config.PaymentConfiguration
import ir.cafebazaar.poolakey.config.SecurityCheck

class FoolakeyPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null

    private val requireActivity: Activity
        get() = activity!!

    private var binaryMessenger: BinaryMessenger? = null

    private lateinit var paymentConnection: Connection
    private lateinit var payment: Payment

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        binaryMessenger = flutterPluginBinding.binaryMessenger
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        channel = MethodChannel(binaryMessenger, "ir.cafebazaar.foolakey")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "init" -> {
                val inAppBillingKey = call.argument<String>("in_app_billing_key")!!
                startPaymentConnection(inAppBillingKey, result)
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
                result.error("connection has failed", it.toString(), null)
            }
            disconnected {
                // TODO: What can we do here?
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
        activity = null
        channel.setMethodCallHandler(null)
        paymentConnection.disconnect()
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        binaryMessenger = null
    }

}
