import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foolakey/foolakey.dart';

import 'widgets/service_status_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _inAppBillingKey =
      'MIHNMA0GCSqGSIb3DQEBAQUAA4G7ADCBtwKBrwDbkRScfggn+JSs+DzcZK20ZbxKPKv060aekC4dxqapamlgf9PncC5/4sqhUU4SdeKE770H1s7dJhmV5QEnzLawJTgiTzD3RFcadl2H4dduro/KxVyAe5nNKE/Xg+uRalLU/Hw9Or44m2xDyWESWj8sqweaGDUnsoHWJFsyVwwIj15fx3cDX6kjObC0gYns1o79x+COWCqyIlDwE2Pf7Xum55FASKFH8lqlYpEzR38CAwEAAQ==';

  bool _customPurchases;
  TextEditingController _productIdController;

  @override
  void initState() {
    _customPurchases = false;
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
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _customPurchases = !_customPurchases;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Switch(
                            value: _customPurchases,
                            onChanged: (newValue) {
                              setState(() {
                                _customPurchases = newValue;
                              });
                            },
                          ),
                          Text('Consume Purchase')
                        ],
                      ),
                    ),
                  ),
                  ElevatedButton(onPressed: _handlePurchase, child: Text('PURCHASE')),
                  ElevatedButton(onPressed: () {}, child: Text('SUBSCRIBE')),
                  ElevatedButton(onPressed: () {}, child: Text('CHECK IF USER PURCHASED THIS ITEM')),
                  ElevatedButton(onPressed: () {}, child: Text('CHECK IF USER SUBSCRIBED THIS ITEM')),
                  Expanded(child: Container()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handlePurchase() async {
    final productId = _productIdController.text;
    if (productId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter the product id')));
      return;
    }
    try {
      final purchaseInfo = await Foolakey.purchase(productId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Purchase success'),
        action: SnackBarAction(
          label: 'Purchase Info',
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                content: SingleChildScrollView(
                  child: Text(purchaseInfo.toString()),
                ),
              ),
            );
          },
        ),
      ));
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.code)));
    }
  }
}
