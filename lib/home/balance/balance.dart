import 'dart:convert';

import 'package:extruck/db/db_helper.dart';
import 'package:extruck/home/balance/cash_ledger.dart';
import 'package:extruck/home/balance/view_bo.dart';
import 'package:extruck/home/balance/view_cheque.dart';
import 'package:extruck/home/balance/view_remit.dart';
import 'package:extruck/session/session_timer.dart';
import 'package:extruck/values/userdata.dart';
import 'package:extruck/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class BalancePage extends StatefulWidget {
  const BalancePage({Key? key}) : super(key: key);

  @override
  State<BalancePage> createState() => _BalancePageState();
}

class _BalancePageState extends State<BalancePage> {
  bool updated = true;
  String cash = '0.00';
  String cheque = '0.00';
  String discounts = '0.00';
  String badorder = '0.00';
  String pendingremit = '0.00';
  String loadbalance = '0.00';
  String revbalance = '0.00';
  String revfund = '0.00';

  final db = DatabaseHelper();

  final formatCurrencyAmt = NumberFormat.currency(locale: "en_US", symbol: "₱");
  final formatCurrencyTot =
      NumberFormat.currency(locale: "en_US", symbol: "Php ");

  @override
  void initState() {
    super.initState();
    checkBalance();
  }

  checkBalance() async {
    List tmp = [];
    var rsp = await db.checkSmBalance(UserData.id);
    setState(() {
      tmp = json.decode(json.encode(rsp));
      print(tmp);
      cash = tmp[0]['cash_onhand'];
      cheque = tmp[0]['cheque_amt'];
      discounts = tmp[0]['disc_amt'];
      badorder = tmp[0]['bo_amt'];
      pendingremit = tmp[0]['rmt_amt'];
      loadbalance = tmp[0]['load_bal'];
      revbalance = tmp[0]['rev_bal'];
      revfund = tmp[0]['rev_fund'];
      if (tmp[0]['stat'] == '1') {
        updated = false;
      } else {
        updated = true;
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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              const Text(
                'Your Balance',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              cashCont(),
              chequeCont(),
              discountCont(),
              boCont(),
              remitCont(),
              loadCont(),
              revbalCont(),
              revfundCont(),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Container(
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
                          style: updated
                              ? raisedButtonStyleGrey
                              : raisedButtonStyleGreen,
                          onPressed: () async {
                            // final action = await Dialogs.openDialog(
                            //     context,
                            //     'Confirmation',
                            //     'You cannot cancel or modify after this. Are you sure you want to convert items?',
                            //     false,
                            //     'No',
                            //     'Yes');
                            // if (action == DialogAction.yes) {
                            //   showDialog(
                            //       barrierDismissible: false,
                            //       context: context,
                            //       builder: (context) =>
                            //           const ProcessingBox('Converting Items'));
                            //   savingConversion();
                            // } else {}
                          },
                          child: const Text(
                            'SYNC DATA',
                            style: TextStyle(color: Colors.white),
                          ),
                        )),
                  )
                ],
              )),
        ),
      ),
    );
  }

  Container cashCont() {
    // ignore: avoid_unnecessary_containers
    return Container(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              PageTransition(
                  // duration: const Duration(milliseconds: 100),
                  type: PageTransitionType.rightToLeft,
                  child: const CashLedger()));
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          height: 100,
          // width: MediaQuery.of(context).size.width / 2 - 30,
          decoration: BoxDecoration(
              color: Colors.green[300],
              border: Border.all(color: Colors.transparent),
              borderRadius: BorderRadius.circular(10)),
          child: Stack(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 5, right: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: const <Widget>[
                          // SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Cash',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 36,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(left: 15),
                          child: const Text(
                            'Click to view ledger',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        formatCurrencyAmt.format(double.parse(cash)).toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 36,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container chequeCont() {
    // ignore: avoid_unnecessary_containers
    return Container(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              PageTransition(
                  // duration: const Duration(milliseconds: 100),
                  type: PageTransitionType.rightToLeft,
                  child: const ChequeView()));
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          height: 80,
          // width: MediaQuery.of(context).size.width / 2 - 30,
          decoration: BoxDecoration(
              color: Colors.yellow[600],
              border: Border.all(color: Colors.transparent),
              borderRadius: BorderRadius.circular(10)),
          child: Stack(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 5, right: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: const <Widget>[
                          // SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Cheque',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(left: 15),
                          child: const Text(
                            'Click to view cheque details',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        formatCurrencyAmt
                            .format(double.parse(cheque))
                            .toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 36,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container discountCont() {
    // ignore: avoid_unnecessary_containers
    return Container(
      child: GestureDetector(
        onTap: () {
          // Navigator.push(
          //     context,
          //     PageTransition(
          //         // duration: const Duration(milliseconds: 100),
          //         type: PageTransitionType.rightToLeft,
          //         child: const BoView()));
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          height: 80,
          // width: MediaQuery.of(context).size.width / 2 - 30,
          decoration: BoxDecoration(
              color: Colors.deepOrange,
              border: Border.all(color: Colors.transparent),
              borderRadius: BorderRadius.circular(10)),
          child: Stack(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 5, right: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: const <Widget>[
                          // SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Discounts',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(left: 15),
                          child: const Text(
                            '',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        formatCurrencyAmt
                            .format(double.parse(discounts))
                            .toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 36,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container boCont() {
    // ignore: avoid_unnecessary_containers
    return Container(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              PageTransition(
                  // duration: const Duration(milliseconds: 100),
                  type: PageTransitionType.rightToLeft,
                  child: const BoView()));
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          height: 80,
          // width: MediaQuery.of(context).size.width / 2 - 30,
          decoration: BoxDecoration(
              color: Colors.grey[600],
              border: Border.all(color: Colors.transparent),
              borderRadius: BorderRadius.circular(10)),
          child: Stack(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 5, right: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: const <Widget>[
                          // SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Bad Order',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(left: 15),
                          child: const Text(
                            'Click to view transactions',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        formatCurrencyAmt
                            .format(double.parse(badorder))
                            .toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 36,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container remitCont() {
    // ignore: avoid_unnecessary_containers
    return Container(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              PageTransition(
                  // duration: const Duration(milliseconds: 100),
                  type: PageTransitionType.rightToLeft,
                  child: const RemitView()));
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          height: 100,
          // width: MediaQuery.of(context).size.width / 2 - 30,
          decoration: BoxDecoration(
              color: Colors.blue[300],
              border: Border.all(color: Colors.transparent),
              borderRadius: BorderRadius.circular(10)),
          child: Stack(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 5, right: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: const <Widget>[
                          // SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Pending Remittance',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(left: 15),
                          child: const Text(
                            'Click to view transactions',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        formatCurrencyAmt
                            .format(double.parse(pendingremit))
                            .toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 36,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container loadCont() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      height: 100,
      // width: MediaQuery.of(context).size.width / 2 - 30,
      decoration: BoxDecoration(
          color: Colors.orange[300],
          border: Border.all(color: Colors.transparent),
          borderRadius: BorderRadius.circular(10)),
      child: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 5, right: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const <Widget>[
                      // SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Load Balance',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 15),
                      child: const Text(
                        '',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    formatCurrencyAmt
                        .format(double.parse(loadbalance))
                        .toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 36,
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Container revbalCont() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      height: 100,
      // width: MediaQuery.of(context).size.width / 2 - 30,
      decoration: BoxDecoration(
          color: Colors.purple[300],
          border: Border.all(color: Colors.transparent),
          borderRadius: BorderRadius.circular(10)),
      child: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 5, right: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const <Widget>[
                      // SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Revolving Balance',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 15),
                      child: const Text(
                        '',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    formatCurrencyAmt
                        .format(double.parse(revbalance))
                        .toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 36,
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Container revfundCont() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      height: 100,
      // width: MediaQuery.of(context).size.width / 2 - 30,
      decoration: BoxDecoration(
          color: Colors.grey[300],
          border: Border.all(color: Colors.transparent),
          borderRadius: BorderRadius.circular(10)),
      child: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 5, right: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const <Widget>[
                      // SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Revolving Fund',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 15),
                      child: const Text(
                        '',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    formatCurrencyAmt.format(double.parse(revfund)).toString(),
                    style: TextStyle(
                      color: Colors.grey[850],
                      fontWeight: FontWeight.w500,
                      fontSize: 36,
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
