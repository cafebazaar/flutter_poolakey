import 'package:flutter/material.dart';
import 'package:flutter_poolakey/flutter_poolakey.dart';

import 'data.dart';

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
  var _gasLevels = ["0", "1", "2", "3", "4", "_inf"];
  var _gasLevel = 4;
  var _vehicleState = "free";
  Map<String, ProductItem> _productsMap = {};

  String _logText = "";

  @override
  void initState() {
    _initShop();
    super.initState();
  }

  Future<void> _initShop() async {
    _productsMap["gas"] = ProductItem("buy_gas", true);
    _productsMap["premium"] = ProductItem("upgrade_app", false);
    _productsMap["infinite_gas_monthly"] =
        ProductItem("get_infinite_gas", false);

    var message = "";
    var rsaKey =
        "MIHNMA0GCSqGSIb3DQEBAQUAA4G7ADCBtwKBrwDbY/p0EgtJZHE6t9nVZ6QyzcR7e2O5RalVJx6Y+6Dc7n40FqdxAjHBYlptyZsdTg9r77JCS7UjEPXNuCHG5NCBLq/u7DWQQmh8otzMK6/P6nzsJUYvCqyNEu7cecaXmh5DgKlfRFpzNXBzBd4K3Xon8hBJjez/qdzvMtmHVFpdCSApUC0WTmT/kq1tDKLU1lDAEt10K83xZbi6lJWcAK20VUn+9KSVFxsr5WuXuWcCAwEAAQ==";
    bool connected = false;
    try {
      connected = await FlutterPoolakey.connect(rsaKey,
          onDisconnected: () => message = "Poolakey disconnected!");
    } on Exception catch (e) {
      setState(() {
        message = e.toString();
      });
    }
    if (!connected) {
      _log(message);
      return;
    }
    _reteriveProducts();
  }

  Future<void> _reteriveProducts() async {
    var purchases = await FlutterPoolakey.getAllPurchasedProducts();
    var subscribes = await FlutterPoolakey.getAllSubscribedProducts();
    var allPurchases = <PurchaseInfo>[];
    allPurchases.addAll(purchases);
    allPurchases.addAll(subscribes);
    for (var purchase in allPurchases) {
      _handlePurchase(purchase);
    }

    var skuDetailsList =
        await FlutterPoolakey.getInAppSkuDetails(_productsMap.keys.toList());

    for (var skuDetails in skuDetailsList) {
      _productsMap[skuDetails.sku]?.skuDetails = skuDetails;

      // inject purchaseInfo
      PurchaseInfo? purchaseInfo;
      for (var p in allPurchases) {
        if (p.productId == skuDetails.sku) purchaseInfo = p;
      }
      _productsMap[skuDetails.sku]?.purchaseInfo = purchaseInfo;
    }
    setState(() {});
  }

  Future<void> _handlePurchase(PurchaseInfo purchase) async {
    _log(purchase.originalJson);
    if (purchase.productId == "gas") {
      if (_gasLevel < 5) _gasLevel = (_gasLevel + 1).clamp(0, 4);
    } else if (purchase.productId == "infinite_gas_monthly") {
      _gasLevel = 5;
    } else if (purchase.productId == "premium") {
      _vehicleState = "premium";
    }

    if (_productsMap[purchase.productId]!.consumable) {
      var result = await FlutterPoolakey.consume(purchase.purchaseToken);
      if (!result) {
        _log("object");
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    final size = MediaQuery.of(context).size;
    final items = _productsMap.values.toList();
    final itemHeight = 100.0;
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build methodx, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Container(
          width: size.width,
          height: size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                  color: Colors.green.withAlpha(44),
                  height: 110,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset("assets/$_vehicleState.png", width: 110),
                          SizedBox(
                            height: 8,
                          ),
                          Image.asset("assets/gas${_gasLevels[_gasLevel]}.png",
                              width: 110)
                        ],
                      ),
                      SizedBox(
                        width: 128,
                        height: 56,
                        child: ElevatedButton(
                          child: Text("یه دوری بزن"),
                          onPressed: _drive,
                        ),
                      ),
                    ],
                  )),
              SizedBox(height: 6),
              SizedBox(
                  height: items.length * itemHeight,
                  child: ListView.builder(
                      itemExtent: itemHeight,
                      itemBuilder: (c, i) => _itemBuilder(items[i]),
                      itemCount: items.length)),
              SizedBox(height: 6),
              Expanded(
                  child: Stack(
                children: [
                  SingleChildScrollView(
//scrollable Text - > wrap in SingleChildScrollView -> wrap that in Expanded
                    child: Text(
                      _logText,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 4,
                    width: 36,
                    child: ElevatedButton(
                      onPressed: _clearLog,
                      child: Icon(Icons.delete),
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  )
                ],
              ))
            ],
          )),
    );
  }

  void _drive() {
    if (_gasLevel >= 5) return;
    _gasLevel = (_gasLevel - 1).clamp(0, 4);
    setState(() {});
  }

  Widget _itemBuilder(ProductItem item) {
    var title = item.skuDetails == null ? "Title" : item.skuDetails!.title;
    var description =
        item.skuDetails == null ? "Description" : item.skuDetails!.description;
    var price = item.skuDetails == null ? "Price" : item.skuDetails!.price;
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: Card(
            child: InkWell(
                onTap: () => _onItemTap(item),
                child: Container(
                    padding: EdgeInsets.all(8),
                    child: IgnorePointer(
                        ignoring: true,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset("assets/${item.icon}.png",
                                  width: 100),
                              Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(title, textAlign: TextAlign.right),
                                    Text(description,
                                        textAlign: TextAlign.right),
                                    Text(price, textAlign: TextAlign.right),
                                  ]),
                            ]))))));
  }

  Future<void> _onItemTap(ProductItem item) async {
    if (item.skuDetails == null) return;
    PurchaseInfo? purchaseInfo;
    try {
      purchaseInfo = await FlutterPoolakey.purchase(item.skuDetails!.sku);
    } catch (e) {
      _log(e.toString());
      return;
    }
    _handlePurchase(purchaseInfo);
  }

  void _log(String message) {
    _logText += message + "\n";
    setState(() {});
  }

  void _clearLog() {
    _logText = "";
    setState(() {});
  }

  @override
  void dispose() {
    // FlutterPoolakey.
    super.dispose();
  }
}
