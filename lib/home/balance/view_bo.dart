import 'dart:convert';

import 'package:extruck/db/db_helper.dart';
import 'package:extruck/order/history/order_history_line.dart';
import 'package:extruck/session/session_timer.dart';
import 'package:extruck/values/userdata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class BoView extends StatefulWidget {
  const BoView({Key? key}) : super(key: key);

  @override
  State<BoView> createState() => _BoViewState();
}

class _BoViewState extends State<BoView> {
  String rmtNo = 'n/a';
  List _list = [];
  List pending = [];

  bool viewSpinkit = false;

  final db = DatabaseHelper();

  final formatCurrencyAmt = NumberFormat.currency(locale: "en_US", symbol: "₱");

  @override
  void initState() {
    super.initState();
    loadPending();
  }

  loadPending() async {
    var rsp = await db.loadPending(UserData.id);
    setState(() {
      pending = json.decode(json.encode(rsp));
      // print(pending);
      for (var element in pending) {
        String newDate = '';
        DateTime s = DateTime.parse(element['date'].toString());
        newDate = '${DateFormat("MMM dd, yyyy").format(s)} at ${DateFormat("hh:mm aaa").format(s)}';
        element['date'] = newDate.toString();
        if (element['tran_type'] == 'BO') {
          _list.add(element);
        }
        viewSpinkit = false;
        // print(_list);
      }
    });
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
          title: const Text('Pending BO Refund',
            style: TextStyle(fontSize: 16),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: buildListView(context),
            ),
          ],
        ),
      ),
    );
  }

  Container buildListView(BuildContext context) {
    if (viewSpinkit == true) {
      return Container(
        color: Colors.transparent,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              const SpinKitCircle(
                size: 36,
                color: Colors.deepOrange,
              )
            ],
          ),
        ),
      );
    } else {
      if (_list.isEmpty) {
        return Container(
          color: Colors.grey[100],
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.error_outline_outlined,
                size: 100,
                color: Colors.orange[500],
              ),
              Text(
                'No pending orders found.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[500],
                ),
              )
            ],
          ),
        );
      } else {
        return Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.transparent,
          child: ListView.builder(
              itemCount: _list.length,
              itemBuilder: ((context, index) {
                bool cash = false;
                if (_list[index]['pmeth_type'] == 'Cash') {
                  cash = true;
                } else {
                  cash = false;
                }

                return GestureDetector(
                  onTap: () {
                    if (_list[index]['rmt_no'] != null) {
                      rmtNo = _list[index]['rmt_no'];
                    }
                    //print(rmtNo);
                    setState(() {
                      CustomerData.accountCode = _list[index]['account_code'];
                      CustomerData.accountName = _list[index]['store_name'];
                      CartData.itmNo = _list[index]['item_count'];
                      CartData.totalAmount = _list[index]['tot_amt'];
                      CartData.discAmt = _list[index]['disc_amt'];
                      CartData.netAmount = _list[index]['net_amt'];
                      CartData.siNum = _list[index]['si_no'];
                    });
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: HistoryItems(
                              _list[index]['order_no'],
                              _list[index]['si_no'],
                              _list[index]['store_name'],
                              _list[index]['item_count'],
                              _list[index]['pmeth_type'],
                              _list[index]['tran_type'],
                              _list[index]['tot_amt'],
                              _list[index]['disc_amt'],
                              _list[index]['net_amt'],
                              rmtNo,
                            )));
                  },
                  child: Container(
                    color: Colors.white,
                    // height: 70,
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      // ignore: prefer_const_literals_to_create_immutables
                      children: [
                        Icon(
                          cash
                              ? Icons.money_rounded
                              : Icons.fact_check_outlined,
                          color: cash ? Colors.green : Colors.deepOrange,
                          size: 36,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _list[index]['order_no'],
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                _list[index]['store_name'],
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'SI #: ',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  Text(
                                    _list[index]['si_no'],
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.green),
                                  ),
                                ],
                              ),
                              Text(
                                _list[index]['date'],
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          // ignore: prefer_const_literals_to_create_immutables
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w400),
                            ),
                            Text(
                              formatCurrencyAmt.format(
                                  double.parse(_list[index]['tot_amt'])),
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              })),
        );
      }
    }
  }
}
