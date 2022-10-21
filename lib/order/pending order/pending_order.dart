import 'dart:convert';

import 'package:extruck/db/db_helper.dart';
import 'package:extruck/home/spinkit.dart';
import 'package:extruck/order/pending%20order/connect_printer.dart';
import 'package:extruck/order/pending%20order/print_report.dart';
// import 'package:extruck/home/spinkit.dart';
import 'package:extruck/session/session_timer.dart';
import 'package:extruck/values/userdata.dart';
import 'package:extruck/widgets/buttons.dart';
import 'package:extruck/widgets/dialogs.dart';
import 'package:extruck/widgets/snackbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class PendingOrders extends StatefulWidget {
  const PendingOrders({Key? key}) : super(key: key);

  @override
  State<PendingOrders> createState() => _PendingOrdersState();
}

class _PendingOrdersState extends State<PendingOrders> {
  double totAmount = 0.00;
  double totDiscount = 0.00;
  double totNet = 0.00;
  double ordAmt = 0.00;
  double boAmt = 0.00;

  double cashChequeBal = 0.00;

  String cash = '0.00';
  String cheque = '0.00';
  String discount = '0.00';
  String bo = '0.00';
  String satWh = '0.00';

  List _list = [];
  List _ord = [];
  List _bo = [];
  List _rmtNo = [];
  List _bal = [];

  bool viewSpinkit = true;
  bool boRef = false;
  bool showSatWh = false;

  String rmtNo = '';
  String loadBal = '';
  String loadQty = '';

  final db = DatabaseHelper();

  final formatCurrencyAmt = NumberFormat.currency(locale: "en_US", symbol: "₱");

  @override
  void initState() {
    super.initState();
    getBalance();
    loadPending();
    gettingLoadBalance();
    getSatWarehouseRequests();
  }

  // update() async {
  //   await db.changeSatWhStat(UserData.id, 'Loaded');
  // }

  getSatWarehouseRequests() async {
    List satwh = [];
    var rsp = await db.getSatWarehouseRequestTotal(UserData.id);
    // print(rsp[0]['total']);
    if (rsp[0]['total'] != null) {
      satwh = json.decode(json.encode(rsp));
      if (satwh.isNotEmpty) {
        setState(() {
          satWh = satwh[0]['total'].toString();
          showSatWh = true;
        });
      } else {
        showSatWh = false;
      }
    }
  }

  getBalance() async {
    List bal = [];
    var rsp = await db.checkSmBalance(UserData.id);
    bal = json.decode(json.encode(rsp));
    setState(() {
      bal = json.decode(json.encode(rsp));
      cash = bal[0]['cash_onhand'];
      cheque = bal[0]['cheque_amt'];
      discount = bal[0]['disc_amt'];
      bo = bal[0]['bo_amt'];
      cashChequeBal = double.parse(cash) + double.parse(cheque);
      // print(cashChequeBal.toStringAsFixed(2));
    });
  }

  loadPending() async {
    var rsp = await db.loadPending(UserData.id);
    setState(() {
      _list = json.decode(json.encode(rsp));
      // print(_list);
      for (var element in _list) {
        String newDate = '';
        totAmount = totAmount + double.parse(element['tot_amt']);
        totDiscount = totDiscount + double.parse(element['disc_amt']);
        totNet = totNet + double.parse(element['net_amt']);
        DateTime s = DateTime.parse(element['date'].toString());
        newDate =
            '${DateFormat("MMM dd, yyyy").format(s)} at ${DateFormat("hh:mm aaa").format(s)}';
        element['date'] = newDate.toString();
      }
    });
    loadPendingOrders();
    loadPendingBo();
  }

  loadPendingOrders() async {
    var rsp = await db.loadPendingOrders(UserData.id);
    setState(() {
      _ord = json.decode(json.encode(rsp));
      // print(_list);
      for (var element in _ord) {
        ordAmt = ordAmt + double.parse(element['net_amt'].toString());
      }
    });
  }

  loadPendingBo() async {
    var rsp = await db.loadPendingBo(UserData.id);
    setState(() {
      _bo = json.decode(json.encode(rsp));
      // print(_list);
      for (var element in _bo) {
        boAmt = boAmt + double.parse(element['net_amt']);
      }
    });
    CartData.boAmt = formatCurrencyAmt.format(boAmt);
  }

  generateReport() async {
    final String date1 =
        DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
    final String date2 = DateFormat("MMddyy").format(DateTime.now());

    var count = await db.checkRMTCount(UserData.id);
    _rmtNo = json.decode(json.encode(count));
    int cnt = _rmtNo.length + 1;
    rmtNo = '$date2${cnt}RMT${UserData.id}';
    if (kDebugMode) {
      print(rmtNo);
    }
    int x = 0;
    for (var element in _list) {
      x++;
      await db.changeOrderStat(element['order_no'], rmtNo, 'Approved');

      if (element['tran_type'] == 'BO') {
        db.minusBoBal(UserData.id, element['net_amt']);
      } else {
        if (element['pmeth_type'] == 'Cash') {
          db.minusCashBal(UserData.id, element['net_amt']);
          db.minustoCashLog(UserData.id, date1, element['net_amt'], 'CASH OUT',
              'REMIT', rmtNo);
        } else {
          db.minusChequeBal(UserData.id, element['net_amt']);
        }
        if (double.parse(element['disc_amt']) > 0) {
          db.minusDiscBal(UserData.id, element['disc_amt']);
        }
      }
    }
    if (x == _list.length) {
      await db.changeSatWhStat(UserData.id, 'Loaded');
      await db.addRemitBal(UserData.id, totAmount.toString());
      var rsp = await db.saveRemittanceReport(
          rmtNo,
          date1,
          UserData.id,
          _list.length.toString(),
          GlobalVariables.revBal,
          loadBal,
          '0.00',
          totAmount,
          cheque,
          totDiscount,
          satWh,
          totNet);
      if (rsp != null) {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);

        String msg =
            'Your Remittance #$rmtNo has been saved successfully. Continue to print report';
        // ignore: use_build_context_synchronously
        final action = await WarningDialogs.openDialog(
          context,
          'Information',
          msg,
          false,
          'OK',
        );
        if (action == DialogAction.yes) {
          // ignore: use_build_context_synchronously
          if (!PrinterData.connected) {
            // ignore: use_build_context_synchronously
            Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: ConnectPrinter(
                        _list,
                        _ord,
                        _bo,
                        ordAmt.toString(),
                        boAmt.toString(),
                        rmtNo,
                        _list.length.toString(),
                        totAmount.toString(),
                        totDiscount.toString(),
                        totNet.toString())));
          } else {
            // ignore: use_build_context_synchronously
            Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: PrintReport(
                        _list,
                        _ord,
                        _bo,
                        ordAmt.toString(),
                        boAmt.toString(),
                        rmtNo,
                        _list.length.toString(),
                        totAmount.toString(),
                        totDiscount.toString(),
                        totNet.toString())));
          }
        } else {}
      }
    }
  }

  gettingLoadBalance() async {
    loadBal = '0';
    loadQty = '0';
    var rsp = await db.getInventory(UserData.id);
    setState(() {
      _bal = json.decode(json.encode(rsp));
      // print(_bal);
      for (var element in _bal) {
        double amt = 0.00;
        amt =
            double.parse(element['item_amt']) * int.parse(element['item_qty']);
        loadBal = (double.parse(loadBal) + amt).toString();
        loadQty =
            (int.parse(loadQty) + int.parse(element['item_qty'])).toString();
      }
      viewSpinkit = false;
    });
    if (kDebugMode) {
      // print(loadBal);
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
          title: const Text(
            'Pending Orders',
            style: TextStyle(fontSize: 16),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: buildListView(context),
            ),
            Visibility(visible: showSatWh, child: buildSatWCont(context)),
            buildTotalCont(context),
            buildCheckoutButton(context),
          ],
        ),
      ),
    );
  }

  Container buildSatWCont(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(width: 0.1, color: Colors.grey),
        ),
      ),
      width: MediaQuery.of(context).size.width,
      // height: 40,
      padding: const EdgeInsets.all(5),
      child: Row(
        // ignore: prefer_const_literals_to_create_immutables
        children: [
          const Text('Satellite Warehouse: ', style: TextStyle(fontSize: 12)),
          Expanded(
            child: Text(formatCurrencyAmt.format(double.parse(satWh)),
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                    fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Container buildTotalCont(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(width: 0.1, color: Colors.grey),
        ),
      ),
      width: MediaQuery.of(context).size.width,
      // height: 40,
      padding: const EdgeInsets.all(5),
      child: Column(
        children: [
          Row(
            // mainAxisAlignment: MainAxisAlignment.center,
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              const Text('Discount: ', style: TextStyle(fontSize: 12)),
              Text(formatCurrencyAmt.format(double.parse(discount)),
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                      fontSize: 12)),
              SizedBox(width: 5),
              const Text('Cheque: ', style: TextStyle(fontSize: 12)),
              Expanded(
                child: Text(formatCurrencyAmt.format(double.parse(cheque)),
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                        fontSize: 12)),
              ),
              const Text('Cash: ', style: TextStyle(fontSize: 12)),
              Expanded(
                child: Text(formatCurrencyAmt.format(double.parse(cash)),
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                        fontSize: 12)),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              const Text('BO: ', style: TextStyle(fontSize: 12)),
              Text(formatCurrencyAmt.format(double.parse(bo)),
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                      fontSize: 12)),
              SizedBox(
                width: 5,
              ),
              const Text('Order No: ', style: TextStyle(fontSize: 12)),
              Expanded(
                  child: Text(_list.length.toString(),
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.deepOrange,
                          fontSize: 12))),
              const Text('Total Amount: ', style: TextStyle(fontSize: 12)),
              Expanded(
                  child: Text(formatCurrencyAmt.format(totNet),
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.deepOrange,
                          fontSize: 12))),
            ],
          ),
        ],
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
                if (_list[index]['tran_type'] == 'BO') {
                  boRef = true;
                } else {
                  boRef = false;
                }

                return Container(
                  // width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  // height: 70,
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
                          Visibility(
                            visible: boRef,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              color: Colors.grey,
                              child: const Text(
                                'BO REFUND',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                          const Text(
                            'Total Amount',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w400),
                          ),
                          Text(
                            formatCurrencyAmt
                                .format(double.parse(_list[index]['net_amt'])),
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.green),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              })),
        );
      }
    }
  }

  Container buildCheckoutButton(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(width: 0.2, color: Colors.black),
        ),
      ),
      width: MediaQuery.of(context).size.width,
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                  style: _list.isEmpty
                      ? raisedButtonStyleGrey
                      : raisedButtonStyleGreen,
                  onPressed: () async {
                    // print('ORDER TOTAL:${ordAmt}');
                    // print('BO TOTAL:${boAmt}');
                    // print('GRAND TOTAL:${totAmount}');
                    if (_list.isEmpty) {
                    } else {
                      // if (cashChequeBal < ordAmt) {
                      //   showGlobalSnackbar(
                      //       'Information',
                      //       'Insufficient cash/cheque balance.',
                      //       Colors.grey,
                      //       Colors.white);
                      // } else {
                      final action = await Dialogs.openDialog(
                          context,
                          'Confirmation',
                          'You cannot cancel or modify after this. Are you sure you want to generate report?',
                          false,
                          'No',
                          'Yes');
                      if (action == DialogAction.yes) {
                        // update();
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) =>
                                const ProcessingBox('Generating Report'));
                        generateReport();
                      } else {}
                      // }
                    }
                  },
                  child: const Text(
                    'GENERATE REPORT',
                    style: TextStyle(color: Colors.white),
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
