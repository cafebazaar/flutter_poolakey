import 'package:flutter/material.dart';
import 'package:foolakey/foolakey.dart';

import 'widgets/service_status_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _inAppBillingKey =
      'MIHNMA0GCSqGSIb3DQEBAQUAA4G7ADCBtwKBrwDbkRScfggn+JSs+DzcZK20ZbxKPKv060aekC4dxqapamlgf9PncC5/4sqhUU4SdeKE770H1s7dJhmV5QEnzLawJTgiTzD3RFcadl2H4dduro/KxVyAe5nNKE/Xg+uRalLU/Hw9Or44m2xDyWESWj8sqweaGDUnsoHWJFsyVwwIj15fx3cDX6kjObC0gYns1o79x+COWCqyIlDwE2Pf7Xum55FASKFH8lqlYpEzR38CAwEAAQ==';

  bool customPurchases;

  @override
  void initState() {
    customPurchases = false;
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
                    decoration: InputDecoration(labelText: 'Product id'),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        customPurchases = !customPurchases;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Switch(
                            value: customPurchases,
                            onChanged: (newValue) {
                              setState(() {
                                customPurchases = newValue;
                              });
                            },
                          ),
                          Text('Consume Purchase')
                        ],
                      ),
                    ),
                  ),
                  ElevatedButton(onPressed: () {}, child: Text('PURCHASE')),
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
}
