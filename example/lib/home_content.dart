import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_poolakey/flutter_poolakey.dart';
import 'package:flutter_poolakey_example/widgets/sku_details_dialog.dart';

import 'widgets/product_text_span.dart';
import 'widgets/purchase_info_dialog.dart';
import 'widgets/service_status_widget.dart';

class HomeContent extends StatefulWidget {
  final Exception? exception;

  const HomeContent({Key? key, this.exception}) : super(key: key);

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late TextEditingController _productIdController;

  @override
  void initState() {
    _productIdController = new TextEditingController();
    _getVersion();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 24,
            ),
            ServiceStatusWidget(widget.exception),
            Expanded(child: Container()),
            TextField(
              controller: _productIdController,
              decoration: InputDecoration(labelText: 'Product id'),
              autofocus: false,
            ),
            SizedBox(
              height: 8,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  text: 'You can use ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                  children: <TextSpan>[
                    ProductTextSpan('developerTest', onProductClick),
                    TextSpan(text: ' and '),
                    ProductTextSpan('developerTestSub', onProductClick),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 24,
            ),
            ElevatedButton(
              onPressed: () {
                _handlePurchase(context);
              },
              child: Text('PURCHASE'),
            ),
            ElevatedButton(
              onPressed: () {
                _handleSubscribe(context);
              },
              child: Text('SUBSCRIBE'),
            ),
            ElevatedButton(
              onPressed: () {
                _handleQueryPurchasedProduct(context);
              },
              child: Text('CHECK IF USER PURCHASED THIS PRODUCT'),
            ),
            ElevatedButton(
              onPressed: () {
                _handleQuerySubscribedProduct(context);
              },
              child: Text('CHECK IF USER SUBSCRIBED THIS PRODUCT'),
            ),
            ElevatedButton(
              onPressed: () {
                _handleGetInAppSkuDetails(context);
              },
              child: Text('GET SKU DETAILS OF IN-APP ITEM'),
            ),
            ElevatedButton(
              onPressed: () {
                _handleGetSubscriptionSkuDetails(context);
              },
              child: Text('GET SKU DETAILS OF SUBSCRIPTION ITEM'),
            ),
            Expanded(child: Container()),
          ],
        ),
      ),
    );
  }

  Future<void> _getVersion() async {
    var version = await FlutterPoolakey.getVersion();
    print("Poolakey version: $version");
  }

  void _handlePurchase(BuildContext context) async {
    final productId = _productIdController.text;
    if (productId.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please enter the product id')));
      return;
    }
    try {
      final purchaseInfo = await FlutterPoolakey.purchase(productId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Successful Purchase'),
        action: SnackBarAction(
          label: 'Purchase Info',
          onPressed: () {
            PurchaseInfoDialog.show(
              context,
              purchaseInfo,
              showConsume: true,
              onConsumeClicked: () {
                _handleConsume(purchaseInfo.purchaseToken);
              },
            );
          },
        ),
      ));
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.code)));
    }
  }

  void _handleConsume(String purchaseToken) async {
    try {
      await FlutterPoolakey.consume(purchaseToken);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Successful Consume')));
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.code)));
    }
  }

  void _handleSubscribe(BuildContext context) async {
    final productId = _productIdController.text;
    if (productId.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please enter the product id')));
      return;
    }
    try {
      final purchaseInfo = await FlutterPoolakey.subscribe(productId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Successful Subscription'),
        action: SnackBarAction(
          label: 'Purchase Info',
          onPressed: () {
            PurchaseInfoDialog.show(context, purchaseInfo);
          },
        ),
      ));
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.code)));
    }
  }

  void _handleQueryPurchasedProduct(BuildContext context) async {
    final productId = _productIdController.text;
    if (productId.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please enter the product id')));
      return;
    }
    try {
      final purchaseInfo =
          await FlutterPoolakey.queryPurchasedProduct(productId);
      if (purchaseInfo == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Not found!')));
        return;
      }

      PurchaseInfoDialog.show(
        context,
        purchaseInfo,
        showConsume: true,
        onConsumeClicked: () {
          _handleConsume(purchaseInfo.purchaseToken);
        },
      );
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.code)));
    }
  }

  void _handleQuerySubscribedProduct(BuildContext context) async {
    final productId = _productIdController.text;
    if (productId.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please enter the product id')));
      return;
    }
    try {
      final purchaseInfo =
          await FlutterPoolakey.querySubscribedProduct(productId);
      if (purchaseInfo == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Not found!')));
        return;
      }
      PurchaseInfoDialog.show(context, purchaseInfo);
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.code)));
    }
  }

  void _handleGetInAppSkuDetails(BuildContext context) async {
    final productId = _productIdController.text;
    if (productId.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please enter the product id')));
      return;
    }
    try {
      final skuDetails = await FlutterPoolakey.getInAppSkuDetails([productId]);
      if (skuDetails.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Not found!')));
        return;
      }
      SkuDetailsDialog.show(context, skuDetails.first);
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.code)));
    }
  }

  void _handleGetSubscriptionSkuDetails(BuildContext context) async {
    final productId = _productIdController.text;
    if (productId.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please enter the product id')));
      return;
    }
    try {
      final skuDetails =
          await FlutterPoolakey.getSubscriptionSkuDetails([productId]);
      if (skuDetails.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Not found!')));
        return;
      }
      SkuDetailsDialog.show(context, skuDetails.first);
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.code)));
    }
  }

  void onProductClick(String productId) {
    _productIdController.text = productId;
  }

  @override
  void dispose() {
    _productIdController.dispose();
    super.dispose();
  }
}
