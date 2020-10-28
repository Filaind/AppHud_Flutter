
class Subscriptions {
  final String productIdentifier;
  final bool actived;

  Subscriptions(this.productIdentifier, this.actived);
}

class InAppProduct {
  final String productIdentifier;
  final String price;
  final String languageCode;

  InAppProduct(this.productIdentifier, this.price, this.languageCode);
}


enum PurchaseType { SUBSCRIPTION, NONRENEWINGPURCHASE  }
class PurchaseResult {
  final PurchaseType type;
  final String productIdentifier;
  final bool actived;

  PurchaseResult(this.type, this.productIdentifier, this.actived);
}