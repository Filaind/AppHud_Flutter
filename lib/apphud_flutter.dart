
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import 'models.dart';

class ApphudFlutter {
  static const MethodChannel _channel =
      const MethodChannel('AppHudFlutter');

  static Future<bool> init(String apiKey, {String userID}) async {
    final bool initState = await _channel.invokeMethod('initPurchases',{"apiKey": apiKey, "userID": userID});
    //hack for complete init
    await Future.delayed(const Duration(milliseconds: 3000), () {});
    return initState;
  }

  static Future<List<InAppProduct>> getProducts() async {
    final String result = await _channel.invokeMethod('getProducts');
    var json = jsonDecode(result);
    try{
      if(json['msg'] != null)
      {
        return null;
      }
    } catch(a){}

    var products = List<InAppProduct>();
    for(var i=0;i<json.length;i++)
    {
      var p = json[i];

      //Hack
      //Because ApphudSKD not clean up products array
      var existProduct = products.indexWhere((element) => element.productIdentifier == p['productIdentifier']);
      var price = p['price'].toString();


      if(Platform.isAndroid)
      {
         price = price.split(new RegExp('\\s+'))[1];
         price = price.split(".")[0];
      }

      if(existProduct == -1)
        products.add(InAppProduct(p['productIdentifier'],price,p['languageCode']));
    }
    return products;
  }

  static Future<PurchaseResult> purchaseProduct(String productId) async {
    final String result = await _channel.invokeMethod('purchase', {"productID": productId});
    var json = jsonDecode(result);
    try{
      if(json['msg'] != null)
      {
        return null;
      }
    } catch(a){}

    var type = PurchaseType.SUBSCRIPTION;
    if(json['type'] == "subscription")
      type = PurchaseType.SUBSCRIPTION;
    if(json['type'] == "nonRenewingPurchase")
      type = PurchaseType.NONRENEWINGPURCHASE;

    var productIdentifier = json['productIdentifier'];
    var actived = json['actived'];

    var purchaseResult = PurchaseResult(type,productIdentifier,actived);
    return purchaseResult;
  }

  static Future<List<Subscriptions>> activedSubscriptions() async {
    final String result = await _channel.invokeMethod('subscriptions');
    var json = jsonDecode(result);
    try{
      if(json['msg'] != null)
      {
        return null;
      }
    } catch(a){}

    var subscriptions = List<Subscriptions>();
    for(var i=0;i<json.length;i++)
    {
      var p = json[i];
      var active = p['actived'].toString() == "true" ? true : false;

      subscriptions.add(Subscriptions(p['productIdentifier'],active));
    }
    return subscriptions;
  }

  static Future<bool> logout() async {
    final bool result = await _channel.invokeMethod('logout');
    await Future.delayed(const Duration(milliseconds: 3000), () {});
    return result;
  }
}
