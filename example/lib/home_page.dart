import 'package:flutter/material.dart';
import 'package:flutter_poolakey/flutter_poolakey.dart';
import 'package:flutter_poolakey_example/home_content.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _inAppBillingKey =
      'MIHNMA0GCSqGSIb3DQEBAQUAA4G7ADCBtwKBrwCfriLwKr3lCxr0ru81gNWsODfWV8kHGZrMuf3DsV68l/Np89AuRersNcmfqjTpAuDlWkK4X3k4hFTqBJXJr0pjHwRe+OyIKZlXUHCy0MaO+IvJFXosMd8dfFpylPTHBWNN6lV7aTEGz5JCYLcpefalvZ3XoEnTJ/+GF/dcGOPd+JpdJxCLX4e6FrYg/e3LDGEoQIxHbLMkVVqjzUJLsS9q97I4p+uHXpeVJYCV/esCAwEAAQ==';

  late bool _isLoading;

  Exception? _exception;

  @override
  void initState() {
    initFlutterPoolakey();
    super.initState();
  }

  void initFlutterPoolakey() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await FlutterPoolakey.init(_inAppBillingKey,
          onDisconnected: _onDisconnect);
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
    print(
        'Connection to cafebazaar has just disconnected, you may need to call FlutterPoolakey.init() again');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Poolakey Sample App')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : HomeContent(exception: _exception),
    );
  }
}
