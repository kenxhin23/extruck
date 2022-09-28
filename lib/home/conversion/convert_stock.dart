import 'dart:convert';
import 'dart:io';

import 'package:extruck/db/db_helper.dart';
import 'package:extruck/home/conversion/conv_list.dart';
import 'package:extruck/home/spinkit.dart';
import 'package:extruck/session/session_timer.dart';
import 'package:extruck/values/assets.dart';
import 'package:extruck/values/colors.dart';
import 'package:extruck/values/userdata.dart';
import 'package:extruck/widgets/buttons.dart';
import 'package:extruck/widgets/dialogs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:flutter/src/foundation/key.dart';
// import 'package:flutter/src/widgets/framework.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';

class StockConversion extends StatefulWidget {
  const StockConversion({Key? key}) : super(key: key);

  @override
  State<StockConversion> createState() => _StockConversionState();
}

class _StockConversionState extends State<StockConversion> {
  List _convList = [];
  List _convCount = [];
  bool noImage = true;
  bool outofStock = false;
  // bool emptyList = true;

  String imgPath = '';
  String tranNo = '';

  double totalAmt = 0.00;
  int itmQty = 0;
  int nitmQty = 0;

  final db = DatabaseHelper();

  final formatCurrencyAmt = NumberFormat.currency(locale: "en_US", symbol: "₱");

  @override
  void initState() {
    super.initState();
    // initPlatformState();
    loadConvert();
  }

  loadConvert() async {
    // var test = await db.ofFetchSample();
    // print(test);
    var documentDirectory = await getApplicationDocumentsDirectory();
    var firstPath = '${documentDirectory.path}/';
    imgPath = firstPath;
    var rsp = await db.getConversionList(UserData.id);
    if (!mounted) return;
    setState(() {
      _convList = json.decode(json.encode(rsp));
      // print(_convList);
      for (var element in _convList) {
        totalAmt = totalAmt +
            (double.parse(element['item_amt']) *
                int.parse(element['item_qty']));
        itmQty = itmQty + int.parse(element['item_qty']);
        nitmQty = nitmQty +
            (int.parse(element['conv_qty']) * int.parse(element['item_qty']));
      }
    });
  }

  savingConversion() async {
    final String date =
        DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
    final String date2 = DateFormat("MMddyy").format(DateTime.now());

    var count = await db.checkConversionCount(UserData.id);
    _convCount = json.decode(json.encode(count));
    int cnt = _convCount.length + 1;
    tranNo = '$date2${cnt}CNV${UserData.id}';
    if (kDebugMode) {
      print(tranNo);
      print(totalAmt);
      print(itmQty);
      print(nitmQty);
    }

    ///SAVING TRAN
    ///

    ///SAVING LINE
    ///

    ///SAVING IN LEDGER
    ///

    ///DELETING IN CONV CART
    // int x = 0;
    for (var element in _convList) {
      var qty = int.parse(element['item_qty']) * int.parse(element['conv_qty']);
      await db.saveConvertedLine(
          UserData.id,
          tranNo,
          element['item_code'],
          element['item_desc'],
          element['item_qty'],
          element['item_uom'],
          element['item_amt'],
          element['conv_qty'],
          element['conv_uom'],
          element['conv_amt'],
          element['image']);
      var a = await db.loadItemtoInventory(
          UserData.id,
          element['item_code'],
          element['item_desc'],
          element['conv_uom'],
          element['conv_amt'],
          qty.toString(),
          '1',
          element['conv_uom'],
          element['image']);
      if (kDebugMode) {
        print('*************************LOAD INNVETORY RSP: $a');
      }
    }

    var headrsp = await db.saveConvertedHead(
        UserData.id, tranNo, date, _convList.length, totalAmt, itmQty, nitmQty);

    var minLedger = await db.minustoLoadLedger(
        UserData.id, date, itmQty.toString(), 'CONVERSION', tranNo);

    var addLedger = await db.addtoLoadLedger(
        UserData.id, date, nitmQty.toString(), 'CONVERSION', tranNo);

    // db.removeItems();
    if (headrsp != null && minLedger != null && addLedger != null) {
      db.deleteAllConvItem(UserData.id);
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      String msg = 'Items successfully converted.';
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
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/menu', (Route<dynamic> route) => false);
      } else {}
    }
  }

  Future<void> refreshList() async {
    await Future.delayed(const Duration(seconds: 1));
    loadConvert();
    // return null;
  }

  showSnackBar(context, itmCode, itmDesc, itmUom, itmAmt, itmQty, itmTotal,
      setCateg, itmImg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: const Text(
            '1 Item Deleted',
          ),
          action: SnackBarAction(
              label: "",
              onPressed: () {
                // setState(() {
                //   unDoDelete(itmCode, itmDesc, itmUom, itmAmt, itmQty, itmTotal,
                //       setCateg, itmImg);
                // });
              })),
    );
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
                'Stock Conversion',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: listViewCont(context),
            ),
          ],
        ),
        floatingActionButton: Container(
          padding: const EdgeInsets.only(left: 20),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FloatingActionButton(
              onPressed: () {
                //PADUNG SA ITEM LIST
                Navigator.push(
                        context,
                        PageTransition(
                            // duration: const Duration(milliseconds: 100),
                            type: PageTransitionType.rightToLeft,
                            child: const ConversionList()))
                    .then((value) {
                  setState(() {
                    refreshList();
                  });
                }).then((value) {});
              },
              backgroundColor: ColorsTheme.mainColor,
              child: const Icon(Icons.add),
            ),
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
                          style: _convList.isEmpty
                              ? raisedButtonStyleGrey
                              : raisedButtonStyleGreen,
                          onPressed: () async {
                            final action = await Dialogs.openDialog(
                                context,
                                'Confirmation',
                                'You cannot cancel or modify after this. Are you sure you want to convert items?',
                                false,
                                'No',
                                'Yes');
                            if (action == DialogAction.yes) {
                              showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (context) =>
                                      const ProcessingBox('Converting Items'));
                              savingConversion();
                            } else {}
                          },
                          child: const Text(
                            'CONVERT ITEMS',
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

  Container listViewCont(BuildContext context) {
    if (_convList.isEmpty == true) {
      return Container(
        color: Colors.grey[100],
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.error_outline_rounded,
              size: 100,
              color: Colors.orange[500],
            ),
            Text(
              'List is Empty. Press the add button below to add items.',
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
    }
    return Container(
      padding: const EdgeInsets.all(5),
      width: MediaQuery.of(context).size.width,
      color: Colors.transparent,
      child: ListView.builder(
          itemCount: _convList.length,
          itemBuilder: (context, index) {
            int convQty = 0;
            if (_convList[index]['image'] == '') {
              noImage = true;
            } else {
              noImage = false;
            }
            convQty = int.parse(_convList[index]['item_qty']) *
                int.parse(_convList[index]['conv_qty']);
            final item = _convList[index].toString();
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
              child: Dismissible(
                background: Container(
                  alignment: AlignmentDirectional.centerEnd,
                  color: ColorsTheme.mainColor,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                direction: DismissDirection.endToStart,
                key: Key(item),
                onDismissed: (direction) {
                  if (!mounted) return;
                  setState(() {
                    var itmcode = _convList[index]['item_code'].toString();
                    var itmdesc = _convList[index]['item_desc'].toString();
                    var itmuom = _convList[index]['item_uom'].toString();
                    var itmamt = _convList[index]['item_amt'].toString();
                    var itmqty = _convList[index]['item_qty'].toString();
                    var itmtot = _convList[index]['item_total'].toString();
                    var itmcat = _convList[index]['item_cat'].toString();
                    var itmImg = _convList[index]['image'].toString();
                    db.addInventory(
                        UserData.id,
                        _convList[index]['item_code'],
                        _convList[index]['item_desc'],
                        _convList[index]['item_uom'],
                        _convList[index]['item_qty']);
                    db.deleteConvItem(
                        UserData.id,
                        _convList[index]['item_code'].toString(),
                        _convList[index]['item_uom'].toString());
                    _convList.removeAt(index);

                    // refreshList();
                    if (_convList.isEmpty) {
                      setState(() {
                        // print('TRUE');
                        refreshList();
                      });
                    }

                    showSnackBar(context, itmcode, itmdesc, itmuom, itmamt,
                        itmqty, itmtot, itmcat, itmImg);

                    // print(cartList);
                  });
                },
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 5),
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      height: 70,
                      child: Row(
                        children: [
                          Container(
                            width: 5,
                            height: 70,
                            color: ColorsTheme.mainColor,
                          ),
                          if (GlobalVariables.viewImg)
                            Container(
                              width: 75,
                              color: Colors.white,
                              child: noImage
                                  ? Image(image: AssetsValues.noImageImg)
                                  : Image.file(File(
                                      imgPath + _convList[index]['image'])),
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
                                  _convList[index]['item_desc'],
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: outofStock
                                          ? Colors.grey
                                          : Colors.black),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      _convList[index]['item_uom'],
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          color: Colors.deepOrange,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      formatCurrencyAmt.format(double.parse(
                                          _convList[index]['item_amt'])),
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
                          Container(
                            color: Colors.transparent,
                            width: 80,
                            // color: Colors.grey,
                            child: Column(
                              // ignore: prefer_const_literals_to_create_immutables
                              children: [
                                const Expanded(
                                    child: SizedBox(
                                  width: 50,
                                )),
                                Text(
                                  _convList[index]['item_qty'],
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
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
                    //////CONVERT CONTAINER
                    Container(
                      margin: const EdgeInsets.only(left: 15),
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      height: 70,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.subdirectory_arrow_right_outlined,
                            color: Colors.grey,
                            size: 36,
                          ),
                          Container(
                              margin: const EdgeInsets.only(left: 3, top: 3),
                              // width: 75,
                              color: Colors.white,
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: ColorsTheme.mainColor,
                                size: 36,
                              )),
                          Expanded(
                              child: Container(
                            margin: const EdgeInsets.only(left: 5),
                            // color: Colors.grey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _convList[index]['item_desc'],
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: outofStock
                                          ? Colors.grey
                                          : Colors.black),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      _convList[index]['conv_uom'],
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          color: Colors.deepOrange,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      formatCurrencyAmt.format(double.parse(
                                          _convList[index]['conv_amt'])),
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
                          Container(
                            color: Colors.transparent,
                            width: 80,
                            // color: Colors.grey,
                            child: Column(
                              // ignore: prefer_const_literals_to_create_immutables
                              children: [
                                const Expanded(
                                    child: SizedBox(
                                  width: 50,
                                )),
                                Text(
                                  convQty.toString(),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
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
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
