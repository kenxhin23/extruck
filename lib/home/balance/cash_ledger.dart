import 'dart:convert';

import 'package:extruck/db/db_helper.dart';
import 'package:extruck/values/userdata.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/src/foundation/key.dart';
// import 'package:flutter/src/widgets/framework.dart';

class CashLedger extends StatefulWidget {
  const CashLedger({Key? key}) : super(key: key);

  @override
  State<CashLedger> createState() => _CashLedgerState();
}

class _CashLedgerState extends State<CashLedger> {
  List list = [];

  final db = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    getCashLedger();
  }

  getCashLedger() async {
    var rsp = await db.getCashLedger(UserData.id);
    rsp = json.decode(json.encode(rsp));
    // print(rsp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Ledger'),
      ),
    );
  }
}
