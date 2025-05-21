import 'package:flutter/material.dart';
import 'package:flutter_poolakey/flutter_poolakey.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trivial Example for Flutter-Poolakey',
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.dark,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

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
    super.initState();
    _initShop();
  }

  Future<void> _initShop() async {
    var rsaKey =
        "MIHNMA0GCSqGSIb3DQEBAQUAA4G7ADCBtwKBrwDbkRScfggn+JSs+DzcZK20ZbxKPKv060aekC4dxqapamlgf9PncC5/4sqhUU4SdeKE770H1s7dJhmV5QEnzLawJTgiTzD3RFcadl2H4dduro/KxVyAe5nNKE/Xg+uRalLU/Hw9Or44m2xDyWESWj8sqweaGDUnsoHWJFsyVwwIj15fx3cDX6kjObC0gYns1o79x+COWCqyIlDwE2Pf7Xum55FASKFH8lqlYpEzR38CAwEAAQ== ";
    try {
      await FlutterPoolakey.connect(
        rsaKey,
        onSucceed: () {
          connected = true;
          _updateState("Connected");
        },
        onFailed: () {
          connected = false;
          _updateState("Not Connected");
        },
        onDisconnected: () {
          connected = false;
          _updateState("Not Connected");
        },
      );
    } on Exception catch (e) {
      showSnackBar(e.toString());
      _updateState("Failed to Connect");
    }
  }

  void _updateState(String message) {
    setState(() {
      status = message;
    });
    showSnackBar(message);
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
              Text('Service: $status'),
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
                    },
                  ),
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
                child: Text('Purchase'),
              ),
              FilledButton(
                onPressed: () {
                  subscribeProduct(
                    productIdController.text,
                    "subscribePayload",
                    dynamicPriceTokenController.text,
                  );
                },
                child: Text('Subscribe'),
              ),
              FilledButton(
                onPressed: checkUserPurchasedItem,
                child: Text('Check if user purchased this item'),
              ),
              FilledButton(
                onPressed: checkUserSubscribedItem,
                child: Text('Check if user subscribed this item'),
              ),
              FilledButton(
                onPressed: () {
                  getSkuDetailOfInAppItem(productIdController.text);
                },
                child: Text('Get Sku detail of in-app item'),
              ),
              FilledButton(
                onPressed: () {
                  getSkuDetailOfSubscriptionItem(productIdController.text);
                },
                child: Text('Get Sku detail of subscription item'),
              ),
              FilledButton(
                onPressed: checkTrialSubscription,
                child: Text('Check Trial subscription'),
              ),
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
      PurchaseInfo? response = await FlutterPoolakey.subscribe(
        productId,
        payload: payload,
        dynamicPriceToken: dynamicPriceToken ?? "",
      );

      showSnackBar("subscribeProduct $response");
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
      PurchaseInfo? response = await FlutterPoolakey.purchase(
        productId,
        payload: payload,
        dynamicPriceToken: dynamicPriceToken ?? "",
      );
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
      bool result = response.any(
        (element) => element.productId == productIdController.text,
      );
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
      bool result = response.any(
        (element) => element.productId == productIdController.text,
      );
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
      List<SkuDetails>? response = await FlutterPoolakey.getInAppSkuDetails([
        skuValueInput,
      ]);
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    dynamicPriceTokenController.dispose();
    productIdController.dispose();
    super.dispose();
  }
}
