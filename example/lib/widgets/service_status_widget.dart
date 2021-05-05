import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ServiceStatusWidget extends StatelessWidget {
  final Exception? error;

  const ServiceStatusWidget(this.error) : super();

  String _errorMessage() {
    if (error is PlatformException) {
      return (error as PlatformException).stacktrace!;
    }
    return error.toString();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (error != null) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: SingleChildScrollView(
                child: Text(_errorMessage()),
              ),
            ),
          );
        }
      },
      child: Text.rich(
        TextSpan(
          children: <InlineSpan>[
            TextSpan(text: 'Service is: '),
            error != null
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
