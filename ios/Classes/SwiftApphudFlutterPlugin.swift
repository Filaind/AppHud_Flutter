import Flutter
import UIKit
import ApphudSDK

func json(from object:Any) -> String? {
  guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
      return nil
  }
  return String(data: data, encoding: String.Encoding.utf8)
}

public class SwiftApphudFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "AppHudFlutter", binaryMessenger: registrar.messenger())
    let instance = SwiftApphudFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if(call.method == "initPurchases")
        {
            let args = call.arguments as? Dictionary<String, Any>;

            let appid = args?["apiKey"] as? String ?? "";
            let userid = args?["userID"] as? String ?? "";
            
            Apphud.start(apiKey: appid, userID: userid)
            
            result(true);
        }

        if(call.method == "logout")
        {
            Apphud.logout()
            result(true);
        }

        if(call.method == "getProducts")
        {
            Apphud.refreshStoreKitProducts(){ r in
                let products = Apphud.products()
                
                if(products != nil){
                    var res = Array<Any>();
                    
                    for prod in products! {
                        res.append(
                        [
                            "productIdentifier" : prod.productIdentifier,
                            "price" : prod.price,
                            "languageCode":prod.priceLocale.currencySymbol ?? "",
                        ]
                        );
                    }
                    
                    let jsonRes = json(from: res);
                    result(jsonRes);
                }
                else{
                    result(json(from: ["msg": "products not found" ]));
                }
            };
        }

        if(call.method == "purchase")
        {
            let products = Apphud.products()
            if(products != nil){
                let args = call.arguments as? Dictionary<String, Any>;

                let productID = args?["productID"] as? String ?? "";
                let product = products!.first(where: { $0.productIdentifier == productID})
                
                if(product != nil)
                {
                    Apphud.purchase(product!) { res in
                        if let subscription = res.subscription, subscription.isActive(){
                         let id = subscription.productId;
                         let actived = subscription.isActive();

                          result(json(from: [
                            "type":"subscription",
                            "productIdentifier": id,
                            "actived" : actived
                          ]));
                         
                        } else if let purchase = res.nonRenewingPurchase, purchase.isActive(){
                            let id = purchase.productId;
                            let actived = purchase.isActive();
                            
                            result(json(from: [
                              "type":"nonRenewingPurchase",
                              "productIdentifier": id,
                              "actived" : actived,
                            ]));
                            
                        } else {
                            result(json(from: ["msg":"failed","productIdentifier": productID]));
                        }
                    }
                }
                else{
                    result(json(from: ["msg": "product not found" ]));
                }
            }
            else{
                result(json(from: ["msg": "product not found" ]));
            }
            
        }

        if(call.method == "subscriptions")
        {
            let subscriptions = Apphud.subscriptions();
            
            if(subscriptions != nil){
                var res = Array<Any>();
                
                for sub in subscriptions! {
                    
                    res.append(
                    [
                        "productIdentifier" : sub.productId,
                        "actived" : sub.isActive(),
                    ]
                    );
                }
                
                let jsonRes = json(from: res);
                result(jsonRes);
            }
            else{
                result(json(from: ["msg": "subscriptions not found" ]));
            }
            
        }
  }
}
