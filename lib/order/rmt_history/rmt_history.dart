import 'dart:convert';

import 'package:extruck/db/db_helper.dart';
import 'package:extruck/order/rmt_history/rmt_history_line.dart';
import 'package:extruck/values/userdata.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class ReportsHistory extends StatefulWidget {
  const ReportsHistory({Key? key}) : super(key: key);

  @override
  State<ReportsHistory> createState() => _ReportsHistoryState();
}

class _ReportsHistoryState extends State<ReportsHistory> {
  List _list = [];

  final db = DatabaseHelper();

  final formatCurrencyAmt = NumberFormat.currency(locale: "en_US", symbol: "₱");

  @override
  void initState() {
    super.initState();
    loadRemittanceHistory();
  }

  loadRemittanceHistory() async {
    var rsp = await db.loadRmtHistory(UserData.id);
    setState(() {
      _list = json.decode(json.encode(rsp));
      for (var element in _list) {
        String newDate = "";
        DateTime s = DateTime.parse(element['date']);
        newDate = '${DateFormat("MMM dd, yyyy").format(s)} at ${DateFormat("hh:mm aaa").format(s)}';
        element['date'] = newDate.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remittance Reports',
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
            Text('No remittance reports found.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.transparent,
      child: ListView.builder(
        itemCount: _list.length,
        itemBuilder: ((context, index) {
          bool uploaded = false;
          // String newDate = "";
          // String date = "";
          // date = _list[index]['date'].toString();
          // DateTime s = DateTime.parse(date);
          // newDate =
          //     '${DateFormat("MMM dd, yyyy").format(s)} at ${DateFormat("hh:mm aaa").format(s)}';
          // _list[index]['date'] = newDate.toString();
          if (_list[index]['order_count'] == null ||
              _list[index]['order_count'] == 'null') {
            _list[index]['order_count'] = '0';
          }
          if (_list[index]['flag'] == '0') {
            uploaded = false;
          } else {
            uploaded = true;
          }
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageTransition(
                  // duration: const Duration(milliseconds: 100),
                  type: PageTransitionType.rightToLeft,
                  child: ReportsHistoryLine(
                    _list[index]['rmt_no'],
                    _list[index]['order_count'],
                    _list[index]['tot_amt'],
                  ),
                ),
              );
            },
            child: Container(
              color: Colors.white,
              // height: 70,
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              child: Row(
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  const Icon(
                    Icons.assignment_outlined,
                    color: Colors.deepOrange,
                    size: 36,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_list[index]['rmt_no'],
                          style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text('No. of Orders: ${_list[index]['order_count']}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        Text(_list[index]['date'],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    // ignore: prefer_const_literals_to_create_immutables
                    children: [
                      const Text('Total Amount',
                        style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(formatCurrencyAmt.format(double.parse(_list[index]['tot_amt'])),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.file_upload,
                    color: uploaded ? Colors.green : Colors.grey,
                    size: ScreenData.scrWidth * .06,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
