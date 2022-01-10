import 'package:flutter_poolakey/flutter_poolakey.dart';

class ProductItem {
  final String icon;
  final bool consumable;
  SkuDetails? skuDetails;
  PurchaseInfo? purchaseInfo;

  ProductItem(this.icon, this.consumable);
}
