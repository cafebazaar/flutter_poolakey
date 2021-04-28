
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ServiceStatusWidget extends StatelessWidget {
  final AsyncSnapshot<bool> snapshot;

  const ServiceStatusWidget(this.snapshot) : super();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (snapshot.hasError) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: SingleChildScrollView(
                child: Text((snapshot.error as PlatformException).stacktrace),
              ),
            ),
          );
        }
      },
      child: Text.rich(
        TextSpan(
          children: <InlineSpan>[
            TextSpan(text: 'Service is: '),
            snapshot.hasError
                ? TextSpan(
              text: 'Disconnected(click to see error)',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            )
                : TextSpan(
              text: 'Connected',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
