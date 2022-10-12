import 'package:extruck/db/db_helper.dart';
import 'package:extruck/session/session_timer.dart';
import 'package:flutter/material.dart';

class RemitView extends StatefulWidget {
  const RemitView({Key? key}) : super(key: key);

  @override
  State<RemitView> createState() => _RemitViewState();
}

class _RemitViewState extends State<RemitView> {
  List list = [];

  final db = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    // getCashLedger();
  }

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
          title: const Text('Pending Remittance'),
        ),
      ),
    );
  }
}
