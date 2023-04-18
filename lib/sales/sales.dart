import 'package:extruck/session/session_timer.dart';
import 'package:extruck/values/colors.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/src/foundation/key.dart';
// import 'package:flutter/src/widgets/framework.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({Key? key}) : super(key: key);

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  void handleUserInteraction([_]) {
    SessionTimer sessionTimer = SessionTimer();
    sessionTimer.initializeTimer(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        handleUserInteraction();
      },
      onPanDown: (details) {
        handleUserInteraction();
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 85,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Sales",
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: ColorsTheme.mainColor,
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: const [],
        ),
      ),
    );
  }
}
