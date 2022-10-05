import 'dart:convert';
import 'package:extruck/db/db_helper.dart';
import 'package:extruck/order/history/order_history_line.dart';
import 'package:extruck/session/session_timer.dart';
import 'package:extruck/values/userdata.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class BoHistory extends StatefulWidget {
  const BoHistory({Key? key}) : super(key: key);

  @override
  State<BoHistory> createState() => _BoHistoryState();
}

class _BoHistoryState extends State<BoHistory> {
  String rmtNo = 'n/a';
  String _searchController = "";
  List _list = [];

  final db = DatabaseHelper();

  final formatCurrencyAmt = NumberFormat.currency(locale: "en_US", symbol: "₱");

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  loadHistory() async {
    var rsp = await db.loadBoHistory(UserData.id);
    setState(() {
      _list = json.decode(json.encode(rsp));
      print(_list);
    });
  }

  searchOrder() async {
    var rsp = await db.searchBO(_searchController, UserData.id);
    setState(() {
      _list = json.decode(json.encode(rsp));
      // print(_list);
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
          title: Row(
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              const Expanded(
                child: Text(
                  'Order History',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigator.push(
                  //     context,
                  //     PageTransition(
                  //         type: PageTransitionType.rightToLeft,
                  //         child: const QRViewExample()));
                },
                child: Row(
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    const Text(
                      'Scan',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const Icon(
                      Icons.qr_code_scanner_outlined,
                      color: Colors.white,
                      size: 36,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            searchCont(context),
            Expanded(
              child: buildListView(context),
            ),
          ],
        ),
      ),
    );
  }

  Container searchCont(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      color: Colors.white,
      child: Form(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    // width: MediaQuery.of(context).size.width - 130,
                    width: MediaQuery.of(context).size.width,
                    height: 40,
                    child: TextFormField(
                      // controller: searchController,
                      onChanged: (String str) {
                        setState(() {
                          _searchController = str;
                          searchOrder();
                        });
                      },
                      decoration: const InputDecoration(
                          contentPadding:
                              EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black87),
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                          hintText: 'Search Order #'),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container buildListView(BuildContext context) {
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
              'No order found.',
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
              // String newDate = "";
              // String date = "";
              // date = _list[index]['date'].toString();
              // DateTime s = DateTime.parse(date);
              // newDate =
              //     '${DateFormat("MMM dd, yyyy").format(s)} at ${DateFormat("hh:mm aaa").format(s)}';
              // _list[index]['date'] = newDate.toString();
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
                  print(rmtNo);
                  setState(() {
                    CustomerData.accountCode = _list[index]['account_code'];
                    CustomerData.accountName = _list[index]['store_name'];
                    CartData.itmNo = _list[index]['item_count'];
                    CartData.totalAmount = _list[index]['tot_amt'];
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
                            rmtNo,
                          )));
                },
                child: Container(
                  // width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  // height: 80,
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    // ignore: prefer_const_literals_to_create_immutables
                    children: [
                      Icon(
                        cash ? Icons.money_rounded : Icons.fact_check_outlined,
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
                            formatCurrencyAmt
                                .format(double.parse(_list[index]['tot_amt'])),
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
