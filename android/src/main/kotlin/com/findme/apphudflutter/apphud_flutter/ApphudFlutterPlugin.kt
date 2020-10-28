package com.findme.apphudflutter.apphud_flutter

import android.app.Activity
import android.content.Context
import androidx.annotation.NonNull
import com.android.billingclient.api.*
import com.apphud.sdk.Apphud
import com.apphud.sdk.ApphudListener
import com.apphud.sdk.isSuccess
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONArray
import org.json.JSONObject
import java.lang.Exception


/** ApphudFlutterPlugin */
class ApphudFlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, ApphudListener {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel : MethodChannel
    private lateinit var context: Context
    private lateinit var activity: Activity
    private lateinit var mBillingClient: BillingClient
    private lateinit var skus: List<SkuDetails>
    private var result: Result? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "AppHudFlutter")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext

        mBillingClient = BillingClient.newBuilder(context).enablePendingPurchases().setListener { billingResult, mutableList ->
            if(billingResult.isSuccess()){
                var pr = mutableList?.get(0)
                if (pr != null) {
                    val params = AcknowledgePurchaseParams.newBuilder()
                            .setPurchaseToken(pr.purchaseToken)
                            .build()
                    mBillingClient.acknowledgePurchase(params) { r: BillingResult ->
                        if(r.isSuccess())
                        {
                            Apphud.syncPurchases()
                            val map = mapOf("type" to "subscription", "productIdentifier" to pr.sku, "actived" to true);
                            result?.success(JSONObject(map).toString())
                        }
                        else
                        {
                            val map = mapOf("msg" to "purchase failed");
                            result?.success(JSONObject(map).toString())
                        }
                    }
                }
            }
            else
            {
                val map = mapOf("msg" to "purchase failed");
                result?.success(JSONObject(map).toString())
            }
        }.build()


        mBillingClient.startConnection(object : BillingClientStateListener {

            override fun onBillingSetupFinished(p0: BillingResult) {

            }

            override fun onBillingServiceDisconnected() {
                // Try to restart the connection on the next request to
                // Google Play by calling the startConnection() method.
            }
        })
    }

    override fun onDetachedFromActivity() {
        TODO("Not yet implemented")
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        TODO("Not yet implemented")
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity;
    }

    override fun onDetachedFromActivityForConfigChanges() {
        TODO("Not yet implemented")
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if(call.method == "initPurchases")
        {
            var apiKey = call.argument<String>("apiKey").toString()
            var userid = call.argument<String>("userID").toString()

            Apphud.start(context, apiKey, userid)
            Apphud.setListener(this)
            result.success(true)
        }

        if(call.method == "logout")
        {

            try {
                Apphud.logout()
                println("Logout from apphud")
            } catch (e: Exception){

            }
            result.success(true)
        }

        if(call.method == "getProducts")
        {
            if(skus.isNotEmpty())
            {
                var res = ArrayList<Map<String, String>>()

                skus.forEach{
                    res.add(mapOf("productIdentifier" to it.sku, "price" to it.price.toString(), "languageCode" to it.priceCurrencyCode))
                }

                var json = JSONArray(res).toString();

                result.success(json)
                return;
            }
            else
            {
                val map = mapOf("msg" to "skus is empty");
                result.success(JSONObject(map).toString())
                return;
            }
        }

        if(call.method == "purchase")
        {
            this.result = result

            var productID = call.argument<String>("productID").toString()

            val billingFlowParams = BillingFlowParams.newBuilder()
                    .setSkuDetails(skus.first { it.sku == productID }).build()
            mBillingClient.launchBillingFlow(activity, billingFlowParams)
//            Apphud.purchase(activity, skus.first { it.sku == productID }) {
//                var pr = it.get(0)
//                if (pr != null) {
//                    Apphud.syncPurchases()
//                    val map = mapOf("type" to "subscription", "productIdentifier" to pr.sku, "actived" to true);
//                    result.success(JSONObject(map).toString())
//                }
//            }

        }

         if(call.method == "subscriptions")
         {
             var subscriptions = Apphud.subscriptions()

             if(subscriptions != null && subscriptions.size >= 1){
                 var res = ArrayList<Map<String, String>>()
                 subscriptions.forEach{
                     res.add(mapOf("productIdentifier" to it.productId, "actived" to it.isActive().toString()))
                 }
                 var json = JSONArray(res).toString();

                 result.success(json)
                 return;
             }
             else
             {
                val map = mapOf("msg" to "subscriptions not found");
                result.success(JSONObject(map).toString())
             }

         }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun apphudFetchSkuDetailsProducts(details: List<SkuDetails>) {
        if(details != null && details.isNotEmpty())
            skus = details
    }
}
