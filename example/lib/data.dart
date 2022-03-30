import 'package:flutter_poolakey/flutter_poolakey.dart';

class ProductItem {
  final String id;
  final String icon;
  final bool consumable;
  SkuDetails? skuDetails;
  PurchaseInfo? purchaseInfo;

  ProductItem(this.id, this.icon, this.consumable);
}
