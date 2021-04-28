import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:foolakey/foolakey.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {

  final _inAppBillingKey = 'MIHNMA0GCSqGSIb3DQEBAQUAA4G7ADCBtwKBrwDbkRScfggn+JSs+DzcZK20ZbxKPKv060aekC4dxqapamlgf9PncC5/4sqhUU4SdeKE770H1s7dJhmV5QEnzLawJTgiTzD3RFcadl2H4dduro/KxVyAe5nNKE/Xg+uRalLU/Hw9Or44m2xDyWESWj8sqweaGDUnsoHWJFsyVwwIj15fx3cDX6kjObC0gYns1o79x+COWCqyIlDwE2Pf7Xum55FASKFH8lqlYpEzR38CAwEAAQ==';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foolakey Sample App'),
      ),
      body: FutureBuilder(
        future: Foolakey.init(_inAppBillingKey),
        builder: (context, snapshot) {
          bool isLoading = snapshot.data == null && snapshot.error == null;
          if (isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          String message = "Connected";
          if (snapshot.hasError) {
            final exception = snapshot.error as PlatformException;
            message = exception.stacktrace;
          }

          return Center(
            child: Text(message),
          );
        },
      ),
    );
  }
}
