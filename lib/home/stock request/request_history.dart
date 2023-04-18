import 'dart:convert';
import 'package:extruck/db/db_helper.dart';
// import 'package:extruck/home/stock%20request/load_items.dart';
import 'package:extruck/home/stock%20request/request_history_line.dart';
import 'package:extruck/session/session_timer.dart';
import 'package:extruck/values/userdata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class RequestHistory extends StatefulWidget {
  const RequestHistory({Key? key}) : super(key: key);

  @override
  State<RequestHistory> createState() => _RequestHistoryState();
}

class _RequestHistoryState extends State<RequestHistory> {
  // List _temp = [];
  List _list = [];
  List _rfList = [];
  bool loaded = false;
  bool revTrue = false;
  bool viewSpinkit = true;

  final date =
      DateTime.parse(DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()));

  final db = DatabaseHelper();

  final formatCurrencyAmt = NumberFormat.currency(locale: "en_US", symbol: "₱");
  final formatCurrencyTot =
      NumberFormat.currency(locale: "en_US", symbol: "Php ");

  @override
  void initState() {
    super.initState();
    getRequestHistory();
    // checkRevolving();
  }

  getRequestHistory() async {
    var getP = await db.getRequestsHistory(UserData.id);
    // _pending = getP;
    if (!mounted) return null;
    setState(() {
      _list = json.decode(json.encode(getP));
      // print(_list);
    });
    // int x = 0;
    if (_list.isNotEmpty) {
      viewSpinkit = false;
    } else {
      viewSpinkit = false;
    }

    // ignore: use_build_context_synchronously
  }

  checkRevolving() async {
    var rsp = await db.checkRevolvingFund(UserData.id);
    _rfList = rsp;
    if (!mounted) return;
    setState(() {
      _rfList = rsp;
      // print(ver);
    });
    if (_rfList.isNotEmpty) {
      setState(() {
        GlobalVariables.revBal = _rfList[0]['bal'];
        // print(GlobalVariables.revBal);
      });
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
              const Text('Requests History',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: listViewCont(),
            ),
            // bottomNoteCont(context)
          ],
        ),
      ),
    );
  }

  Container bottomNoteCont(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      height: 40,
      child: Column(
        children: [
          Row(
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              const SizedBox(width: 10),
              const Text('Note:',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Always connect to an internet connection to get updated of the latest status changes.',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ],
      ),
    );
  }

  Container listViewCont() {
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
    }
    if (_list.isEmpty) {
      return Container(
        color: Colors.grey[100],
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.history_outlined,
              size: 100,
              color: Colors.orange[500],
            ),
            Text('No request found.',
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
    } else {
      return Container(
        padding: const EdgeInsets.all(5),
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
          itemCount: _list.length,
          itemBuilder: ((context, index) {
            String newDate = "";
            String dateReq = "";
            if (_list[index]['tran_stat'] == 'Pending' ||
                _list[index]['tran_stat'] == 'Approved') {
              loaded = false;
            } else {
              loaded = true;
            }
            if (_list[index]['pmeth_type'] == 'RF') {
              revTrue = true;
            } else {
              revTrue = false;
            }
            dateReq = _list[index]['date_req'];
            // print(_pendList[index]['tran_stat']);
            DateTime s = DateTime.parse(dateReq);
            newDate =
                '${DateFormat("MMM dd, yyyy").format(s)} at ${DateFormat("hh:mm aaa").format(s)}';
            _list[index]['date_req'] = newDate;
            return GestureDetector(
              onTap: () {
                RequestData.reqQty = _list[index]['item_count'];
                RequestData.appQty = _list[index]['app_count'];
                RequestData.totAmt = _list[index]['tot_amt'];
                RequestData.tranNo = _list[index]['tran_no'];
                RequestData.status = _list[index]['tran_stat'];

                Navigator.push(
                  context,
                  PageTransition(
                    // duration: const Duration(milliseconds: 100),
                    type: PageTransitionType.rightToLeft,
                    child: const RequestHistoryLine(),
                  ),
                );
              },
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        height: 90,
                        width: 5,
                        color: Colors.deepOrange,
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(left: 5),
                          height: 90,
                          color: Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '#${_list[index]['tran_no']}',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    revTrue
                                      ? Icons.warehouse_rounded
                                      : Icons.cell_tower_rounded,
                                    color:
                                      revTrue ? Colors.blue : Colors.green,
                                    size: 21,
                                  ),
                                  Text(' - ${_list[index]['warehouse']}',
                                    style: const TextStyle(color: Colors.grey),
                                  )
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Text(loaded
                                    ? 'Qty: ${_list[index]['app_count']}'
                                    : 'Qty: ${_list[index]['item_count']}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(width: 40),
                                  const Text('Total: ',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  Text(formatCurrencyTot.format(double.parse(_list[index]['tot_amt'])),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(_list[index]['date_req'],
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 90,
                        color: Colors.white,
                        child: Center(
                          child: Text(_list[index]['tran_stat'],
                            style: TextStyle(
                              color: loaded ? Colors.green : Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 10,
                        height: 90,
                        color: Colors.white,
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                ],
              ),
            );
          }),
        ),
      );
    }
  }
}
