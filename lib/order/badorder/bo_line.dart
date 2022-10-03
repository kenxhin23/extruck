import 'dart:convert';
import 'dart:io';
import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:extruck/db/db_helper.dart';
import 'package:extruck/order/badorder/bo_cart.dart';
import 'package:extruck/session/session_timer.dart';
import 'package:extruck/values/assets.dart';
import 'package:extruck/values/userdata.dart';
import 'package:extruck/widgets/buttons.dart';
import 'package:extruck/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';

class BoOrderItems extends StatefulWidget {
  final String ordNo, siNo, storeName, itmCount, pmeth, type, totAmt, rmtNo;

  // ignore: use_key_in_widget_constructors
  const BoOrderItems(this.ordNo, this.siNo, this.storeName, this.itmCount,
      this.pmeth, this.type, this.totAmt, this.rmtNo);
  // const ConvertedItems({Key? key}) : super(key: key);

  @override
  State<BoOrderItems> createState() => _BoOrderItemsState();
}

class _BoOrderItemsState extends State<BoOrderItems> {
  bool noImage = false;
  bool noItms = true;
  List _list = [];

  String imgPath = '';

  final db = DatabaseHelper();

  final formatCurrencyAmt = NumberFormat.currency(locale: "en_US", symbol: "₱");
  final formatCurrencyTot =
      NumberFormat.currency(locale: "en_US", symbol: "Php ");

  @override
  void initState() {
    super.initState();
    // initPlatformState();
    loadHistoryLine();
    refreshConnection();
  }

  loadHistoryLine() async {
    var documentDirectory = await getApplicationDocumentsDirectory();
    var firstPath = '${documentDirectory.path}/';
    imgPath = firstPath;

    var rsp = await db.loadHistoryItems(widget.ordNo);
    setState(() {
      _list = json.decode(json.encode(rsp));
      CartData.itmLineNo = _list.length.toString();
      // print(_list);
    });
  }

  Future<void> refreshConnection() async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      setState(() {
        PrinterData.connected = true;
        // print('PRINTER CONNECTED');
      });
    } else {
      setState(() {
        PrinterData.connected = false;
        // print('PRINTER NOT CONNECTED');
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
          iconTheme: const IconThemeData(
            color: Colors.black, //change your color here
          ),
          automaticallyImplyLeading: true,
          backgroundColor: Colors.white,
          title: Text(
            "${widget.storeName}'s Cart",
            style: const TextStyle(color: Colors.black, fontSize: 12),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: listViewCont(context),
            ),
            buildSummaryCont(),
          ],
        ),
      ),
    );
  }

  Container listViewCont(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(5),
      width: MediaQuery.of(context).size.width,
      color: Colors.transparent,
      child: ListView.builder(
          itemCount: _list.length,
          itemBuilder: (context, index) {
            bool mark;
            if (_list[index]['mark'] == 0) {
              mark = false;
            } else {
              mark = true;
            }
            if (_list[index]['image'] == '') {
              noImage = true;
            } else {
              noImage = false;
            }
            // ignore: unused_local_variable
            final item = _list[index].toString();
            return Container(
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10),
                  // ignore: prefer_const_literals_to_create_immutables
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade100,
                    ),
                  ]),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 5),
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    height: 70,
                    child: Row(
                      children: [
                        Checkbox(
                            checkColor: Colors.white,
                            fillColor:
                                MaterialStateProperty.resolveWith(getColor),
                            value: mark,
                            onChanged: (bool? value) {
                              setState(() {
                                mark = value!;
                                if (mark) {
                                  _list[index]['mark'] = 1;
                                } else {
                                  _list[index]['mark'] = 0;
                                }
                              });
                            }),
                        if (GlobalVariables.viewImg)
                          Container(
                            width: 75,
                            color: Colors.white,
                            child: noImage
                                ? Image(image: AssetsValues.noImageImg)
                                : Image.file(
                                    File(imgPath + _list[index]['image'])),
                          )
                        else if (!GlobalVariables.viewImg)
                          Container(
                              margin: const EdgeInsets.only(left: 3, top: 3),
                              width: 75,
                              color: Colors.white,
                              child: Image(image: AssetsValues.noImageImg)),
                        Expanded(
                            child: Container(
                          margin: const EdgeInsets.only(left: 5),
                          // color: Colors.grey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _list[index]['item_desc'],
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              Row(
                                children: [
                                  Text(
                                    _list[index]['uom'],
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                        color: Colors.deepOrange,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    formatCurrencyAmt.format(
                                        double.parse(_list[index]['amt'])),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),
                        const SizedBox(width: 10),
                        Text(
                          _list[index]['qty'],
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 20),
                        Container(
                          color: Colors.transparent,
                          // width: 80,
                          // color: Colors.grey,
                          child: Row(
                            // ignore: prefer_const_literals_to_create_immutables
                            children: [
                              Text(
                                formatCurrencyAmt.format(
                                    double.parse(_list[index]['tot_amt'])),
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            );
          }),
    );
  }

  Container buildSummaryCont() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(15, 5, 15, 15),
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
          Text('${_list.length} lines, ${widget.itmCount} items'),
          Row(
            children: [
              const Expanded(child: Text('Goods')),
              Text(
                formatCurrencyAmt.format(double.parse(widget.totAmt)),
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
                formatCurrencyTot.format(double.parse(widget.totAmt)),
                style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 20,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                style: raisedButtonStyleGreen,
                onPressed: () async {
                  bool empty = true;
                  setState(() {
                    for (var element in _list) {
                      if (element['mark'] == 1) {
                        empty = false;
                      } else {}
                    }
                    if (!empty) {
                      RefundData.tmplist.clear();
                      Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: BoCart(
                                _list,
                                widget.ordNo,
                              ))).then((value) {
                        if (RefundData.tmplist.isNotEmpty) {
                          // print('NOT EMPTY');

                          for (var element in RefundData.tmplist) {
                            if (element['rf_itmcode'] == '' ||
                                element['rf_itmcode'] == ' ') {
                              // noItms = true;
                            } else {
                              noItms = false;
                              db.addInventory(
                                  UserData.id,
                                  element['rf_itmcode'],
                                  element['rf_itemdesc'],
                                  element['rf_uom'],
                                  element['rf_qty']);
                            }
                          }

                          // db.deleteAllConvItem(UserData.id);
                          if (!noItms) {
                            showGlobalSnackbar(
                                'Information',
                                'Items returned to inventory.',
                                Colors.blue,
                                Colors.white);
                          }
                        }
                      });
                    } else {
                      showGlobalSnackbar(
                          'Information',
                          'Please select items to refund.',
                          Colors.blue,
                          Colors.white);
                    }
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    const Text(
                      "Continue to refund",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
