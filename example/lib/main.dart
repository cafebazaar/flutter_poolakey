import 'package:flutter/material.dart';
import 'package:flutter_poolakey/flutter_poolakey.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trivial Example for Flutter-Poolakey',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.green,
        brightness: Brightness.dark,
      ),
      home: const MyHomePage(title: 'Trivial Example for Flutter-Poolakey'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final dynamicPriceTokenController = TextEditingController();
  final productIdController = TextEditingController();
  bool connected = false;
  String status = "";
  bool consume = true;

  @override
  void initState() {
    _initShop();
    super.initState();
  }

  Future<void> _initShop() async {
    var rsaKey =
        "MIHNMA0GCSqGSIb3DQEBAQUAA4G7ADCBtwKBrwDbkRScfggn+JSs+DzcZK20ZbxKPKv060aekC4dxqapamlgf9PncC5/4sqhUU4SdeKE770H1s7dJhmV5QEnzLawJTgiTzD3RFcadl2H4dduro/KxVyAe5nNKE/Xg+uRalLU/Hw9Or44m2xDyWESWj8sqweaGDUnsoHWJFsyVwwIj15fx3cDX6kjObC0gYns1o79x+COWCqyIlDwE2Pf7Xum55FASKFH8lqlYpEzR38CAwEAAQ== ";
    try {
      connected = await FlutterPoolakey.connect(
        rsaKey,
        onDisconnected: () => showSnackBar("Poolakey disconnected!"),
      );
    } on Exception catch (e) {
      showSnackBar(e.toString());
      setState(() {
        status = "Service: Failed to Connect";
      });
    }

    setState(() {
      if (!connected) {
        status = "Service: Not Connected";
      } else {
        status = "Service: Connected";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(status),
              const SizedBox(height: 8),
              TextField(
                controller: productIdController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Product id',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: dynamicPriceTokenController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Dynamic price token',
                ),
              ),
              Row(
                children: [
                  Text('Consume Purchase'),
                  Spacer(),
                  Switch(
                      value: consume,
                      onChanged: (checked) {
                        setState(() {
                          consume = checked;
                        });
                      }),
                ],
              ),
              FilledButton(
                  onPressed: () {
                    purchaseProduct(
                      productIdController.text,
                      "purchasePayload",
                      dynamicPriceTokenController.text,
                    );
                  },
                  child: Text('Purchase')),
              FilledButton(
                  onPressed: () {
                    subscribeProduct(
                      productIdController.text,
                      "subscribePayload",
                      dynamicPriceTokenController.text,
                    );
                  },
                  child: Text('Subscribe')),
              FilledButton(
                  onPressed: checkUserPurchasedItem,
                  child: Text('Check if user purchased this item')),
              FilledButton(
                  onPressed: checkUserSubscribedItem,
                  child: Text('Check if user subscribed this item')),
              FilledButton(
                  onPressed: () {
                    getSkuDetailOfInAppItem(productIdController.text);
                  },
                  child: Text('Get Sku detail of in-app item')),
              FilledButton(
                  onPressed: () {
                    getSkuDetailOfSubscriptionItem(productIdController.text);
                  },
                  child: Text('Get Sku detail of subscription item')),
              FilledButton(
                  onPressed: checkTrialSubscription,
                  child: Text('Check Trial subscription'))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> subscribeProduct(
    String productId,
    String payload,
    String? dynamicPriceToken,
  ) async {
    if (!connected) {
      showSnackBar('Service: Not Connected');
      return;
    }

    try {
      PurchaseInfo? response = await FlutterPoolakey.subscribe(productId,
          payload: payload, dynamicPriceToken: dynamicPriceToken ?? "");
    } catch (e) {
      showSnackBar("subscribeProduct ${e.toString()}");
      return;
    }
  }

  Future<void> purchaseProduct(
    String productId,
    String payload,
    String? dynamicPriceToken,
  ) async {
    if (!connected) {
      showSnackBar('Service: Not Connected');
      return;
    }
    try {
      PurchaseInfo? response = await FlutterPoolakey.purchase(productId,
          payload: payload, dynamicPriceToken: dynamicPriceToken ?? "");
      if (consume) {
        consumePurchasedItem(response.purchaseToken);
      }
    } catch (e) {
      showSnackBar("purchaseProduct ${e.toString()}");
      return;
    }
  }

  Future<void> checkUserSubscribedItem() async {
    if (!connected) {
      showSnackBar('Service: Not Connected');
      return;
    }

    try {
      List<PurchaseInfo>? response =
          await FlutterPoolakey.getAllSubscribedProducts();
      bool result = response
          .any((element) => element.productId == productIdController.text);
      if (result) {
        showSnackBar("User has bought this item");
      } else {
        showSnackBar("User has not bought this item");
      }
    } catch (e) {
      showSnackBar("checkUserSubscribedItem ${e.toString()}");
      return;
    }
  }

  Future<void> checkUserPurchasedItem() async {
    if (!connected) {
      showSnackBar('Service: Not Connected');
      return;
    }

    try {
      List<PurchaseInfo>? response =
          await FlutterPoolakey.getAllPurchasedProducts();
      bool result = response
          .any((element) => element.productId == productIdController.text);
      if (result) {
        showSnackBar("User has bought this item");
      } else {
        showSnackBar("User has not bought this item");
      }
    } catch (e) {
      showSnackBar("checkUserPurchasedItem ${e.toString()}");
      return;
    }
  }

  Future<void> getSkuDetailOfSubscriptionItem(String skuValueInput) async {
    if (!connected) {
      showSnackBar('Service: Not Connected');
      return;
    }

    try {
      List<SkuDetails>? response =
          await FlutterPoolakey.getSubscriptionSkuDetails([skuValueInput]);
      showSnackBar("Detail Of Subscription Item ${response.toString()}");
    } catch (e) {
      showSnackBar("getSkuDetailOfSubscriptionItem ${e.toString()}");
      return;
    }
  }

  Future<void> getSkuDetailOfInAppItem(String skuValueInput) async {
    if (!connected) {
      showSnackBar('Service: Not Connected');
      return;
    }

    try {
      List<SkuDetails>? response =
          await FlutterPoolakey.getInAppSkuDetails([skuValueInput]);
      showSnackBar("Detail Of InApp Item ${response.toString()}");
    } catch (e) {
      showSnackBar("getSkuDetailOfInAppItem ${e.toString()}");
      return;
    }
  }

  Future<void> checkTrialSubscription() async {
    if (!connected) {
      showSnackBar('Service: Not Connected');
      return;
    }

    try {
      Map response = await FlutterPoolakey.checkTrialSubscription();
      showSnackBar("isAvailable ${response["isAvailable"].toString()}");
    } catch (e) {
      showSnackBar("checkTrialSubscription ${e.toString()}");
      return;
    }
  }

  Future<void> consumePurchasedItem(String purchaseToken) async {
    if (!connected) {
      showSnackBar('Service: Not Connected');
      return;
    }

    try {
      bool? response = await FlutterPoolakey.consume(purchaseToken);
      showSnackBar("consumePurchasedItem success $response");
    } catch (e) {
      showSnackBar(e.toString());
      return;
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    dynamicPriceTokenController.dispose();
    productIdController.dispose();
    super.dispose();
  }
}
