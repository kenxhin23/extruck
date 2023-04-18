import 'dart:convert';
import 'package:extruck/db/db_helper.dart';
import 'package:extruck/session/session_timer.dart';
import 'package:extruck/values/userdata.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CashLedger extends StatefulWidget {
  const CashLedger({Key? key}) : super(key: key);

  @override
  State<CashLedger> createState() => _CashLedgerState();
}

class _CashLedgerState extends State<CashLedger> {
  List _entry = [];
  // ignore: prefer_final_fields
  List _ledger = [];
  Color varColor = Colors.black;
  List list = [];

  final db = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    getCashLedger();
  }

  getCashLedger() async {
    var rsp = await db.getCashLedger(UserData.id);
    if (!mounted) return;
    setState(() {
      _entry = json.decode(json.encode(rsp));
      print(rsp);
    });
    for (var element in _entry) {
      _ledger.add(element);
    }

    for (var element in _ledger) {
      String newDate = "";
      DateTime s = DateTime.parse(element['date'].toString());
      newDate = DateFormat("dd-MM-yy").format(s);
      // print(newDate);
      element['date'] = newDate;
    }
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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              const Text('Cash Ledger',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            headerCont(context),
            Expanded(child: listViewCont(context)),
            legendCont(context)
          ],
        ),
      ),
    );
  }

  Container headerCont(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      height: 40,
      child: Row(
        // ignore: prefer_const_literals_to_create_immutables
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
            // color: Colors.white,
            width: 50,
            decoration:
                BoxDecoration(border: Border.all(width: 1, color: Colors.grey)),
            child: const Center(
              child: Text('Date',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
              // color: Colors.white,
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.grey)),
              child: const Center(
                child: Text('Ref. #',
                  style: TextStyle(fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(5),
            // color: Colors.white,
            width: 80,
            decoration:
                BoxDecoration(border: Border.all(width: 1, color: Colors.grey)),
            child: const Center(
              child: Text('Description',
                style: TextStyle(fontSize: 12,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
            // color: Colors.white,
            width: 55,
            decoration:
                BoxDecoration(border: Border.all(width: 1, color: Colors.grey)),
            child: const Center(
              child: Text('IN',
                style: TextStyle(fontSize: 12,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
            // color: Colors.white,
            width: 55,
            decoration:
                BoxDecoration(border: Border.all(width: 1, color: Colors.grey)),
            child: const Center(
              child: Text('OUT',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
            // color: Colors.white,
            width: 55,
            decoration:
                BoxDecoration(border: Border.all(width: 1, color: Colors.grey)),
            child: const Center(
              child: Text('BAL',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container listViewCont(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      width: MediaQuery.of(context).size.width,
      color: Colors.transparent,
      child: ListView.builder(
        itemCount: _ledger.length,
        itemBuilder: ((context, index) {
          if (_ledger[index]['type'] == 'CASH IN') {
            varColor = Colors.green;
          }
          if (_ledger[index]['type'] == 'CASH OUT' &&
              _ledger[index]['details'] == 'REMIT') {
            varColor = Colors.grey.shade600;
          }
          if (_ledger[index]['type'] == 'CASH OUT' &&
              _ledger[index]['details'] == 'STOCK IN') {
            varColor = Colors.orange.shade900;
          }
          return Column(
            children: [
              Container(
                // padding: const EdgeInsets.only(top: 10),
                height: 50,
                color: varColor,
                child: Row(
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    Text(_ledger[index]['date'],
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                    const Divider(
                      color: Colors.white,
                      height: 50,
                      // thickness: 10,
                      indent: 10,
                    ),
                    Expanded(
                      child: Text(_ledger[index]['ref_no'],
                        style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      color: varColor,
                      width: 80,
                      child: Center(
                        child: Text(_ledger[index]['type'],
                          style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    Container(
                      color: varColor,
                      width: 55,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(_ledger[index]['qty_in'],
                          style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 1,
                    ),
                    Container(
                      color: varColor,
                      width: 55,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(_ledger[index]['qty_out'],
                          style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 1,
                    ),
                    Container(
                      color: varColor,
                      width: 55,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(_ledger[index]['bal'],
                          style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          );
        }),
      ),
    );
  }

  Container legendCont(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      height: 30,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 10, height: 10, color: Colors.green),
          const SizedBox(width: 5),
          const Text('Cash in(Order)',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 10),
          Container(width: 10, height: 10, color: Colors.grey[600]),
          const SizedBox(width: 5),
          const Text('Cash out(Remittance)',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 10),
          Container(width: 10, height: 10, color: Colors.deepOrange[600]),
          const SizedBox(width: 5),
          const Text('Cash out(Stock Request)',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
