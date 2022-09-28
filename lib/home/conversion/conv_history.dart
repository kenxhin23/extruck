import 'dart:convert';

import 'package:extruck/db/db_helper.dart';
import 'package:extruck/home/conversion/conv_history_line.dart';
// import 'package:extruck/home/conversion/convert_stock.dart';
// import 'package:extruck/home/conversion/convert_stock.dart';
import 'package:extruck/session/session_timer.dart';
import 'package:extruck/values/colors.dart';
import 'package:extruck/values/userdata.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class ConversionHistory extends StatefulWidget {
  const ConversionHistory({Key? key}) : super(key: key);

  @override
  State<ConversionHistory> createState() => _ConversionHistoryState();
}

class _ConversionHistoryState extends State<ConversionHistory> {
  List _convlist = [];

  final db = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    getHistory();
  }

  getHistory() async {
    var rsp = await db.getConversionHistory(UserData.id);
    setState(() {
      _convlist = json.decode(json.encode(rsp));
      // print(_convlist);
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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              const Text(
                'Stock Conversion History',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(child: buildListView(context)),
          ],
        ),
      ),
    );
  }

  Container buildListView(BuildContext context) {
    if (_convlist.isEmpty) {
      return Container(
        color: Colors.grey[100],
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.pending_actions_rounded,
              size: 100,
              color: Colors.orange[500],
            ),
            Text(
              'No conversions found.',
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
            itemCount: _convlist.length,
            itemBuilder: ((context, index) {
              String newDate = "";
              String date = "";
              date = _convlist[index]['conv_date'].toString();
              DateTime s = DateTime.parse(date);
              newDate =
                  '${DateFormat("MMM dd, yyyy").format(s)} at ${DateFormat("hh:mm aaa").format(s)}';
              _convlist[index]['conv_date'] = newDate.toString();
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: ConvertedItems(
                              _convlist[index]['conv_no'],
                              _convlist[index]['totAmt'],
                              _convlist[index]['nitem_qty'])));
                },
                child: Container(
                  margin: const EdgeInsets.all(8),
                  height: 80,
                  color: Colors.white,
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Icon(Icons.sync_outlined,
                          size: 36, color: ColorsTheme.mainColor),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Column(
                          // ignore: prefer_const_literals_to_create_immutables
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _convlist[index]['conv_no'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              _convlist[index]['conv_date'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 12),
                            ),
                            Row(
                              children: [
                                const Text('Items Converted: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12)),
                                Text(
                                  _convlist[index]['itmno'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: Colors.deepOrange),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: 30,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Qty',
                                style: TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 12)),
                            Text(_convlist[index]['item_qty'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: 10,
                        child: const Text(
                          'to',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: 30,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Qty',
                                style: TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 12)),
                            Text(_convlist[index]['nitem_qty'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: Colors.green)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            })),
      );
    }
  }
}
