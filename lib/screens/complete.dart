import 'package:flutter/material.dart';
import 'package:flutter_application_1/constant/routes.dart';

class Complete extends StatelessWidget {
  const Complete({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AlertDialog(
        title: const Text("完成"),
        actions: [
          ElevatedButton(
              onPressed: () => Navigator.popUntil(
                    context,
                    ModalRoute.withName(Routes.dashboard),
                  ),
              child: const Text('回到主頁'))
        ],
      ),
    );
  }
}
