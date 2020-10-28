# apphud_flutter

Unofficial Apphud SDK for Flutter.

Required:
 - Minimum iOS 11.2 and Xcode 10 and Swift version 5.0.
 - Minimum Android 4.1 and supports only Google Play store.

## Info
- Android: ✅
- IOS: ✅


## Doc
 - ApphudFlutter.init(String apiKey, String userID)
    >Initialize Apphud SDK

 - ApphudFlutter.getProducts()
    >Return current awailable products for purchase

 - ApphudFlutter.purchaseProduct(String productId)
    >Start purchasing product.
    >Return null if purchase has error or canceled
    >Return PurchaseResult if purchase complete

 - ApphudFlutter.activedSubscriptions()
    >Return current actived subscriptions

 - ApphudFlutter.logout()
    >Logout from Apphud
