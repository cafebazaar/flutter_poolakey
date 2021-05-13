import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_poolakey/flutter_poolakey.dart';
import 'package:flutter_poolakey_example/widgets/purchase_info_dialog.dart';

import 'widgets/service_status_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _inAppBillingKey =
      'MIHNMA0GCSqGSIb3DQEBAQUAA4G7ADCBtwKBrwCfriLwKr3lCxr0ru81gNWsODfWV8kHGZrMuf3DsV68l/Np89AuRersNcmfqjTpAuDlWkK4X3k4hFTqBJXJr0pjHwRe+OyIKZlXUHCy0MaO+IvJFXosMd8dfFpylPTHBWNN6lV7aTEGz5JCYLcpefalvZ3XoEnTJ/+GF/dcGOPd+JpdJxCLX4e6FrYg/e3LDGEoQIxHbLMkVVqjzUJLsS9q97I4p+uHXpeVJYCV/esCAwEAAQ==';

  late TextEditingController _productIdController;

  late bool _isLoading;

  Exception? _exception;

  @override
  void initState() {
    _productIdController = new TextEditingController();
    initFlutterPoolakey();
    super.initState();
  }

  void initFlutterPoolakey() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await FlutterPoolakey.init(_inAppBillingKey, onDisconnected: _onDisconnect);
      setState(() {
        _exception = null;
        _isLoading = false;
      });
    } on Exception catch (e) {
      setState(() {
        _exception = e;
        _isLoading = false;
      });
    }
  }

  void _onDisconnect() {
    print('Connection to cafebazaar has just disconnected, you may need to call FlutterPoolakey.init() again');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Poolakey Sample App'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 24,
                    ),
                    ServiceStatusWidget(_exception),
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
                            _ProductTextSpan('developerTest', onProductClick),
                            TextSpan(text: ' and '),
                            _ProductTextSpan('developerTestSub', onProductClick),
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
                    Expanded(child: Container()),
                  ],
                ),
              ),
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.code)));
    }
  }

  void _handleConsume(String purchaseToken) async {
    try {
      await FlutterPoolakey.consume(purchaseToken);
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
      final purchaseInfo = await FlutterPoolakey.queryPurchasedProduct(productId);
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
      final purchaseInfo = await FlutterPoolakey.querySubscribedProduct(productId);
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

  void onProductClick(String productId) {
    _productIdController.text = productId;
  }
}

class _ProductTextSpan extends TextSpan {
  _ProductTextSpan(String productId, Function(String) onProductClick)
      : super(
            text: productId,
            style: TextStyle(
              color: Colors.cyan,
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()..onTap = () => onProductClick(productId));
}