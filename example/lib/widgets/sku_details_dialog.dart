import 'package:flutter/material.dart';
import 'package:flutter_poolakey/flutter_poolakey.dart';
import 'package:flutter_poolakey/sku_details.dart';

class SkuDetailsDialog {
  static void show(BuildContext context, SkuDetails skuDetails) {
    AlertDialog alert = AlertDialog(
      title: Text("SKU Details"),
      content: SingleChildScrollView(
        child: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              TextSpan(
                  text: 'sku: ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ' ${skuDetails.sku}\n'),
              TextSpan(
                  text: 'type: ',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ' ${skuDetails.type}\n'),
              TextSpan(
                  text: 'price: ',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ' ${skuDetails.price}\n'),
              TextSpan(
                  text: 'title: ',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ' ${skuDetails.title}\n'),
              TextSpan(
                  text: 'description: ',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ' ${skuDetails.description}\n'),
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
