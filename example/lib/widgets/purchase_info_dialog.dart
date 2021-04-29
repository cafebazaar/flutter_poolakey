import 'package:flutter/material.dart';
import 'package:foolakey/foolakey.dart';

class PurchaseInfoDialog {
  static void show(
    BuildContext context,
    PurchaseInfo purchaseInfo, {
    bool showConsume = false,
    VoidCallback? onConsumeClicked,
  }) {
    AlertDialog alert = AlertDialog(
      title: Text("PurchaseInfo"),
      content: SingleChildScrollView(
        child: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              TextSpan(text: 'orderId: ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ' ${purchaseInfo.orderId}\n'),
              TextSpan(text: 'purchaseToken: ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ' ${purchaseInfo.purchaseToken}\n'),
              TextSpan(text: 'payload: ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ' ${purchaseInfo.payload}\n'),
              TextSpan(text: 'packageName: ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ' ${purchaseInfo.packageName}\n'),
              TextSpan(text: 'purchaseState: ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ' ${purchaseInfo.purchaseState}\n'),
              TextSpan(text: 'purchaseTime: ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ' ${purchaseInfo.purchaseTime}\n'),
              TextSpan(text: 'productId: ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ' ${purchaseInfo.productId}\n'),
              TextSpan(text: 'originalJson: ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ' ${purchaseInfo.originalJson}\n'),
              TextSpan(text: 'dataSignature: ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ' ${purchaseInfo.dataSignature}\n'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        if (showConsume)
          ElevatedButton(
            child: Text(
              'Consume',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {
              onConsumeClicked!();
              Navigator.of(context).pop();
            },
          ),
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
