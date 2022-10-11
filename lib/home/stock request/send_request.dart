import 'dart:convert';
import 'package:extruck/db/db_helper.dart';
import 'package:extruck/home/spinkit.dart';
import 'package:extruck/home/stock%20request/note.dart';
import 'package:extruck/home/stock%20request/sign.dart';
import 'package:extruck/home/stock%20request/sign_view.dart';
import 'package:extruck/home/stock%20request/warehouse.dart';
import 'package:extruck/providers/pending_counter.dart';
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
import 'package:provider/provider.dart';

class SendRequest extends StatefulWidget {
  const SendRequest({Key? key}) : super(key: key);

  @override
  State<SendRequest> createState() => _SendRequestState();
}

class _SendRequestState extends State<SendRequest> {
  String warehouse = "Select Warehouse";
  String pmethod = 'None';
  String revFund = '0.00';
  String cashonHand = '0.00';
  List rfList = [];
  List cashList = [];
  bool viewRevFund = false;
  bool viewCash = false;
  bool checking = false;
  bool fundShort = false;
  bool cashShort = false;

  double revolvingFund = 0.00;

  final db = DatabaseHelper();

  final date =
      DateTime.parse(DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()));

  final formatCurrencyAmt = NumberFormat.currency(locale: "en_US", symbol: "₱");
  final formatCurrencyTot =
      NumberFormat.currency(locale: "en_US", symbol: "Php ");

  @override
  void initState() {
    super.initState();
    // initPlatformState();
    // getCart();
    // print(date);
    // print(CartData.list);
    checkBalance();
  }

  checkBalance() async {
    List tmp = [];
    var rsp = await db.checkSmBalance(UserData.id);
    setState(() {
      tmp = json.decode(json.encode(rsp));
      print(tmp);
      revolvingFund = double.parse(tmp[0]['rev_fund']);
    });
  }

  // getCart()async{
  //   var cart = await db.ofFetchCart(UserData.id);
  // }
  uploadingRequest() async {
    var cart = await db.ofFetchCart(UserData.id);

    // ignore: use_build_context_synchronously
    var rsp = await db.uploadRequest(
        context,
        CartData.warehouse,
        UserData.id!,
        CartData.pMeth,
        CartData.itmNo,
        CartData.totalAmount,
        'Pending',
        OrderData.signature!,
        cart);
    if (rsp != null || rsp != '') {
      if (kDebugMode) {
        print(rsp);
      }
      GlobalVariables.tranNo = rsp;
      var getTranHead = await db.addRequestHead(
          GlobalVariables.tranNo,
          date.toString(),
          UserData.id,
          CartData.itmNo,
          CartData.totalAmount,
          CartData.warehouse,
          CartData.pMeth,
          'Pending',
          OrderData.signature,
          '1');
      // print('ADD RSP:${getTranHead}');
      if (getTranHead != '' || getTranHead != null) {
        if (kDebugMode) {}
        addRequestLine();

        // await db.updateRevBal(UserData.id,)

        db.cleanCart(UserData.id);

        Navigator.pop(context);

        Provider.of<PendingCounter>(context, listen: false).addTotal(1);

        String msg =
            'Your Request #${GlobalVariables.tranNo!} is being processed right now.View Pending Requests to check status.';
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
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/menu', (Route<dynamic> route) => false);
        } else {}
      } else {
        if (kDebugMode) {
          print('ERROR IN TRAN REQUEST SAVING');
        }
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      }
    }
  }

  addRequestLine() async {
    if (!mounted) return;
    setState(() {
      for (var element in CartData.list) {
        // double totamt = double.parse(element['item_amt']) *
        //     double.parse(element['item_qty']);
        db.addRequestLine(
            GlobalVariables.tranNo,
            element['item_code'],
            element['item_desc'],
            element['item_qty'],
            element['item_uom'],
            element['item_amt'],
            element['item_total'],
            UserData.id,
            date.toString(),
            element['image']);
      }
    });
  }

  checkRevolving() async {
    var rsp = await db.checkRevolvingFund(UserData.id);
    rfList = rsp;
    if (!mounted) return;
    setState(() {
      rfList = rsp;
      // print(ver);
    });
    if (rfList.isNotEmpty) {
      setState(() {
        revFund = rfList[0]['bal'];
        GlobalVariables.revBal = rfList[0]['bal'];
        GlobalVariables.revFund = rfList[0]['fund'];
        if (double.parse(revFund) < double.parse(CartData.totalAmount)) {
          fundShort = true;
        } else {
          fundShort = false;
        }
        checking = false;
        //kung e update ang revolving fund sa salesman ani sya mo trigger og change sa fund sa local
        if (double.parse(GlobalVariables.revFund) != revolvingFund) {
          db.setRevolvingFund(
              UserData.id, GlobalVariables.revFund, GlobalVariables.revBal);
        }
      });
    }
  }

  checkCashonhand() async {
    var rsp = await db.checkSmBalance(UserData.id);
    if (!mounted) return;
    setState(() {
      cashList = json.decode(json.encode(rsp));
      // print(ver);
      cashonHand = cashList[0]['cash_onhand'];
      if (double.parse(cashonHand) < double.parse(CartData.totalAmount)) {
        cashShort = true;
      } else {
        cashShort = false;
      }
      checking = false;
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
          iconTheme: const IconThemeData(
            color: Colors.black, //change your color here
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.white,
          title: Text(
            'Review Request',
            style:
                TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
        ),
        backgroundColor: Colors.grey[100],
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  color: Colors.grey[100],
                  child: Column(
                    children: [
                      Visibility(
                        visible: !NetworkData.connected,
                        child: noInternetCont(context),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      buildWarehouseCont(context),
                      const SizedBox(
                        height: 20,
                      ),
                      buildPaymentCont(),
                      const SizedBox(
                        height: 5,
                      ),
                      Visibility(visible: viewCash, child: buildCashCont()),
                      Visibility(
                          visible: viewRevFund, child: buildRevolvingCont()),
                      const SizedBox(
                        height: 30,
                      ),
                      buildSummaryCont(),
                      const SizedBox(
                        height: 30,
                      ),
                      buildSignatureCont(),
                      const SizedBox(
                        height: 30,
                      ),
                      buildNoteCont()
                    ],
                  ),
                ),
              ),
            ),
            buildSendButton(context)
          ],
        ),
      ),
    );
  }

  Container noInternetCont(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 20,
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        // ignore: prefer_const_literals_to_create_immutables
        children: [
          const Text(
            'No Internet Connection. Please connect to a network.',
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Container buildWarehouseCont(BuildContext context) {
    // ignore: avoid_unnecessary_containers
    return Container(
      child: Column(
        children: [
          // ignore: avoid_unnecessary_containers
          Container(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 15),
                  child: const Icon(
                    Icons.local_shipping,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  'Warehouse',
                  style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                          context,
                          PageTransition(
                              // duration: const Duration(milliseconds: 100),
                              type: PageTransitionType.rightToLeft,
                              child: const WarehousePage()))
                      .then((value) {
                    setState(() {
                      warehouse = CartData.warehouse;
                      pmethod = CartData.pMeth;
                      if (CartData.pMeth != 'Cash') {
                        cashShort = false;
                        checkRevolving();
                        setState(() {
                          checking = true;
                          viewRevFund = true;
                          viewCash = false;
                        });
                      } else {
                        fundShort = false;
                        checkCashonhand();
                        setState(() {
                          checking = true;
                          viewRevFund = false;
                          viewCash = true;
                        });
                      }
                    });
                  });
                },
                child: Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width,
                  // height: MediaQuery.of(context).size.height / 8,
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 15, right: 15),
                        child: Icon(
                          Icons.room,
                          color: Colors.red,
                          size: 24,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 15),
                            Text(
                              warehouse,
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 15),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Container buildPaymentCont() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Payment Method',
              style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            pmethod,
            style: TextStyle(
                color: Colors.grey[800],
                fontSize: 16,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(
            width: 5,
          ),
          // const Icon(
          //   Icons.chevron_right,
          //   color: Colors.grey,
          // )
        ],
      ),
    );
  }

  Container buildCashCont() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Cash Available',
              style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
          ),
          // ignore: prefer_const_constructors
          checking
              ? const SpinKitCircle(
                  // controller: animationController,
                  size: 24,
                  color: Colors.green,
                )
              : Text(
                  formatCurrencyAmt.format(double.parse(cashonHand)),
                  style: TextStyle(
                      color: fundShort ? Colors.red : Colors.green,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
          const SizedBox(
            width: 5,
          ),
          // const Icon(
          //   Icons.chevron_right,
          //   color: Colors.grey,
          // )
        ],
      ),
    );
  }

  Container buildRevolvingCont() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Revolving Fund Balance',
              style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
          ),
          // ignore: prefer_const_constructors
          checking
              ? const SpinKitCircle(
                  // controller: animationController,
                  size: 24,
                  color: Colors.green,
                )
              : Text(
                  formatCurrencyAmt.format(double.parse(revFund)),
                  style: TextStyle(
                      color: fundShort ? Colors.red : Colors.green,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
          const SizedBox(
            width: 5,
          ),
          // const Icon(
          //   Icons.chevron_right,
          //   color: Colors.grey,
          // )
        ],
      ),
    );
  }

  Container buildSummaryCont() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: TextStyle(
                color: Colors.grey[800],
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          Text('${CartData.itmLineNo!} lines, ${CartData.itmNo} items'),
          Row(
            children: [
              const Expanded(child: Text('Goods')),
              Text(
                formatCurrencyAmt.format(double.parse(CartData.totalAmount)),
              ),
            ],
          ),
          Row(
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              const Expanded(child: Text('Delivery Fee')),
              const Text('0.00'),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total',
                  style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 20,
                      fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                formatCurrencyTot.format(double.parse(CartData.totalAmount)),
                style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 20,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Container buildSignatureCont() {
    // ignore: avoid_unnecessary_containers
    return Container(
      child: GestureDetector(
        onTap: () {
          if (!OrderData.setSign) {
            Navigator.push(
                context,
                PageTransition(
                    // duration: const Duration(milliseconds: 100),
                    type: PageTransitionType.rightToLeft,
                    child: const MyApp()));
          } else {
            Navigator.push(
                context,
                PageTransition(
                    // duration: const Duration(milliseconds: 100),
                    type: PageTransitionType.rightToLeft,
                    child: const ViewSignature()));
          }
        },
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(15),
          // ignore: avoid_unnecessary_containers
          child: Container(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Signature',
                    style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container buildNoteCont() {
    // ignore: avoid_unnecessary_containers
    return Container(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              PageTransition(
                  // duration: const Duration(milliseconds: 100),
                  type: PageTransitionType.rightToLeft,
                  child: const SpecialNote()));
        },
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add a note',
                      style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    OrderData.note
                        ? Text(OrderData.specialInstruction)
                        : const Text(
                            'Place any special instruction here',
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              )
            ],
          ),
        ),
      ),
    );
  }

  Container buildSendButton(BuildContext context) {
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
                  style: raisedButtonStyleGreen,
                  onPressed: () async {
                    if (!NetworkData.connected) {
                      showGlobalSnackbar(
                          'Connectivity',
                          'Please connect to internet.',
                          Colors.black,
                          Colors.white);
                    } else {
                      if (pmethod == "None") {
                        {
                          showGlobalSnackbar(
                              'Information',
                              'Please select a warehouse',
                              Colors.blue,
                              Colors.white);
                        }
                      } else {
                        if (fundShort || cashShort) {
                          showGlobalSnackbar(
                              'Information',
                              'Balance is not enough.',
                              Colors.red,
                              Colors.white);
                        } else {
                          if (OrderData.signature == "") {
                            {
                              showGlobalSnackbar(
                                  'Information',
                                  'Please input signature',
                                  Colors.blue,
                                  Colors.white);
                            }
                          } else {
                            final action = await Dialogs.openDialog(
                                context,
                                'Confirmation',
                                'You cannot cancel or modify after this. Are you sure you want to place this order?',
                                false,
                                'No',
                                'Yes');
                            if (action == DialogAction.yes) {
                              print(CartData.totalAmount);
                              showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (context) => const ProcessingBox(
                                      'Processing Request'));

                              uploadingRequest();
                            } else {}
                          }
                        }
                      }
                    }
                  },
                  child: const Text(
                    'SEND REQUEST',
                    style: TextStyle(color: Colors.white),
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
