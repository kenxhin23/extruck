import 'dart:convert';

import 'package:extruck/db/db_helper.dart';
import 'package:extruck/home/spinkit.dart';
import 'package:extruck/order/new%20order/add_si.dart';
import 'package:extruck/order/new%20order/pmethod.dart';
import 'package:extruck/order/new%20order/print_receipt.dart';
import 'package:extruck/session/session_timer.dart';
import 'package:extruck/values/userdata.dart';
import 'package:extruck/widgets/buttons.dart';
import 'package:extruck/widgets/dialogs.dart';
import 'package:extruck/widgets/snackbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
// import 'package:flutter/src/foundation/key.dart';
// import 'package:flutter/src/widgets/framework.dart';

class Checkout extends StatefulWidget {
  const Checkout({Key? key}) : super(key: key);

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  List _ordCount = [];
  String pmeth = '';
  String siNum = '';
  String tranNo = '';
  final db = DatabaseHelper();

  final date =
      DateTime.parse(DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()));

  final formatCurrencyAmt = NumberFormat.currency(locale: "en_US", symbol: "₱");
  final formatCurrencyTot =
      NumberFormat.currency(locale: "en_US", symbol: "Php ");

  @override
  void initState() {
    super.initState();
  }

  addOrder() async {
    final String date1 =
        DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
    final String date2 = DateFormat("MMddyy").format(DateTime.now());

    var count = await db.checkCount(UserData.id, CustomerData.accountCode);
    _ordCount = json.decode(json.encode(count));
    int cnt = _ordCount.length + 1;
    tranNo = '$date2${cnt}XT${CustomerData.accountCode}';
    if (kDebugMode) {
      print(tranNo);
    }

    ///ADD ORDER TRAN
    ///
    var headRsp = await db.addTransactionHead(
        tranNo,
        CartData.siNum,
        date1,
        CustomerData.accountCode,
        CustomerData.accountName,
        CartData.itmNo,
        CartData.totalAmount,
        CartData.pMeth,
        'ORDER',
        UserData.id);
    if (headRsp != null) {
      // print(tranNo);
      addingTransactionLine();
    } else {}
  }

  addingTransactionLine() async {
    ///ADD ORDER LINE
    final String date =
        DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());

    for (var element in CartData.list) {
      // print(element);
      db.addTransactionLine(
          tranNo,
          CartData.siNum,
          element['item_code'],
          element['item_desc'],
          element['item_qty'],
          element['item_uom'],
          element['item_amt'],
          '0.00',
          element['item_total'],
          '0.00',
          element['item_cat'],
          'Served',
          'F',
          UserData.id,
          element['image']);
    }
    if (CartData.pMeth == 'Cheque') {
      db.addChequeData(
          date,
          tranNo,
          UserData.id,
          CustomerData.accountCode,
          ChequeData.bankName,
          ChequeData.accName,
          ChequeData.accNum,
          ChequeData.chequeNum,
          ChequeData.chequeDate,
          ChequeData.type,
          CartData.totalAmount,
          'Pending');
      // print('Cheque Data Saved!');
    }

    ///ADD LOG TO LEDGER
    db.minustoLoadLedger(
        UserData.id, date.toString(), CartData.itmNo, 'STOCK OUT', tranNo);

    ///CLEAN CUSTOMER CART
    db.cleanCustomerCart(UserData.id, CustomerData.accountCode);

    Navigator.pop(context);

    String msg =
        'Your Order #$tranNo has been saved successfully. Continue to print receipt';
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
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.rightToLeft,
              child: PrintReceipt(CartData.list, tranNo)));
    } else {}
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
            'Review Order',
            style:
                TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
        ),
        backgroundColor: Colors.grey[100],
        body: Column(
          children: [
            Expanded(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    deliveryIcon(context),
                    deliveryCont(context),
                    const SizedBox(height: 10),
                    buildPaymentCont(),
                    const SizedBox(
                      height: 30,
                    ),
                    buildSummaryCont(),
                    const SizedBox(
                      height: 30,
                    ),
                    buildSiCont(),
                    // const SizedBox(height: 10),
                    // buildAudienceCont()
                  ],
                ),
              ),
            ),
            buildCheckoutButton(context),
          ],
        ),
      ),
    );
  }

  Container deliveryIcon(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.transparent,
      height: 30,
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
            'Delivery',
            style: TextStyle(
                color: Colors.grey[800],
                fontSize: 16,
                fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  Container deliveryCont(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      // height: 70,
      color: Colors.white,
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
                  CustomerData.accountName.toString(),
                  style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                // const SizedBox(height: 15),
                Text(
                  '${CustomerData.city}, ${CustomerData.province}',
                  style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
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

  Container buildPaymentCont() {
    // ignore: avoid_unnecessary_containers
    return Container(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
                  context,
                  PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: const PaymentMethod()))
              .then((value) {
            setState(() {
              pmeth = CartData.pMeth;
            });
          });
        },
        child: Container(
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
              if (pmeth == '')
                const Text(
                  'Select',
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                )
              else if (pmeth == 'Cash')
                Text(
                  CartData.pMeth,
                  style: const TextStyle(
                      color: Colors.green,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                )
              else if (pmeth == 'Cheque')
                Text(
                  CartData.pMeth,
                  style: const TextStyle(
                      color: Colors.deepOrange,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
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

  Container buildSiCont() {
    // ignore: avoid_unnecessary_containers
    return Container(
      child: GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              builder: (context) => const AddSalesInvoice()).then((value) {
            setState(() {
              siNum = CartData.siNum;
              // loadProducts();
            });
          });
        },
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Sales Invoice #',
                  style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
              if (CartData.siNum == '')
                const Text(
                  'Click to Add',
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                )
              else if (CartData.siNum != '')
                Text(
                  CartData.siNum,
                  style: const TextStyle(
                      color: Colors.green,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
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
    );
  }

  Container buildAudienceCont() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Audience Name',
              style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            'Cash',
            style: TextStyle(
                color: Colors.grey[800],
                fontSize: 16,
                fontWeight: FontWeight.w500),
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
    );
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
                  style: raisedButtonStyleGreen,
                  onPressed: () async {
                    //print(pmeth);
                    if (pmeth == "Select" || pmeth == '') {
                      {
                        showGlobalSnackbar(
                            'Information',
                            'Please select a payment method.',
                            Colors.blue,
                            Colors.white);
                      }
                    } else {
                      if (CartData.siNum == '') {
                        showGlobalSnackbar(
                            'Information',
                            'Please input sales invoice #.',
                            Colors.grey,
                            Colors.white);
                      } else {
                        final action = await Dialogs.openDialog(
                            context,
                            'Confirmation',
                            'You cannot cancel or modify after this. Are you sure you want to place this order?',
                            false,
                            'No',
                            'Yes');
                        if (action == DialogAction.yes) {
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) =>
                                  const ProcessingBox('Processing order'));
                          addOrder();
                        } else {}
                      }
                    }
                  },
                  child: const Text(
                    'CHECKOUT ORDER',
                    style: TextStyle(color: Colors.white),
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
