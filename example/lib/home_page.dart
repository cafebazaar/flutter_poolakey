import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foolakey/foolakey.dart';
import 'package:foolakey_example/widgets/purchase_info_dialog.dart';

import 'widgets/service_status_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _inAppBillingKey =
      'MIHNMA0GCSqGSIb3DQEBAQUAA4G7ADCBtwKBrwDbkRScfggn+JSs+DzcZK20ZbxKPKv060aekC4dxqapamlgf9PncC5/4sqhUU4SdeKE770H1s7dJhmV5QEnzLawJTgiTzD3RFcadl2H4dduro/KxVyAe5nNKE/Xg+uRalLU/Hw9Or44m2xDyWESWj8sqweaGDUnsoHWJFsyVwwIj15fx3cDX6kjObC0gYns1o79x+COWCqyIlDwE2Pf7Xum55FASKFH8lqlYpEzR38CAwEAAQ==';

  late TextEditingController _productIdController;

  @override
  void initState() {
    _productIdController = new TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foolakey Sample App'),
      ),
      body: FutureBuilder(
        future: Foolakey.init(_inAppBillingKey),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          bool isLoading = snapshot.data == null && snapshot.error == null;
          if (isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 24,
                  ),
                  ServiceStatusWidget(snapshot),
                  Expanded(child: Container()),
                  TextField(
                    controller: _productIdController,
                    decoration: InputDecoration(labelText: 'Product id'),
                    autofocus: false,
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
                  Expanded(child: Container()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handlePurchase(BuildContext context) async {
    final productId = _productIdController.text;
    if (productId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter the product id')));
      return;
    }
    try {
      final purchaseInfo = await Foolakey.purchase(productId);
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.code)));
    }
  }

  void _handleConsume(String purchaseToken) async {
    try {
      await Foolakey.consume(purchaseToken);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successful Consume')));
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.code)));
    }
  }

  void _handleSubscribe(BuildContext context) async {
    final productId = _productIdController.text;
    if (productId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter the product id')));
      return;
    }
    try {
      final purchaseInfo = await Foolakey.subscribe(productId);
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.code)));
    }
  }

  void _handleQueryPurchasedProduct(BuildContext context) async {
    final productId = _productIdController.text;
    if (productId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter the product id')));
      return;
    }
    try {
      final purchaseInfo = await Foolakey.queryPurchasedProduct(productId);
      if (purchaseInfo == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Not found!')));
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.code)));
    }
  }

  void _handleQuerySubscribedProduct(BuildContext context) async {
    final productId = _productIdController.text;
    if (productId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter the product id')));
      return;
    }
    try {
      final purchaseInfo = await Foolakey.querySubscribedProduct(productId);
      if (purchaseInfo == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Not found!')));
        return;
      }
      PurchaseInfoDialog.show(context, purchaseInfo);
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.code)));
    }
  }

  @override
  void dispose() {
    _productIdController.dispose();
    super.dispose();
  }
}
