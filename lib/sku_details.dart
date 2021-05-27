class SkuDetails {
  final String sku;
  final String type;
  final String price;
  final String title;
  final String description;

  SkuDetails(this.sku, this.type, this.price, this.title, this.description);

  factory SkuDetails.fromMap(Map<dynamic, dynamic> skuDetailsMap) {
    return SkuDetails(
      skuDetailsMap['sku'] as String,
      skuDetailsMap['type'] as String,
      skuDetailsMap['price'] as String,
      skuDetailsMap['title'] as String,
      skuDetailsMap['description'] as String,
    );
  }

  @override
  String toString() => 'sku: $sku,'
      '\ntype: $type,'
      '\nprice: $price,'
      '\ntitle: $title,'
      '\ndescription: $description';
}
