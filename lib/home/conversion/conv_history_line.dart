import 'dart:convert';
import 'dart:io';

import 'package:extruck/db/db_helper.dart';
import 'package:extruck/session/session_timer.dart';
import 'package:extruck/values/assets.dart';
import 'package:extruck/values/colors.dart';
import 'package:extruck/values/userdata.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class ConvertedItems extends StatefulWidget {
  final String convNo, totAmt, totQty;

  // ignore: use_key_in_widget_constructors
  const ConvertedItems(this.convNo, this.totAmt, this.totQty);
  // const ConvertedItems({Key? key}) : super(key: key);

  @override
  State<ConvertedItems> createState() => _ConvertedItemsState();
}

class _ConvertedItemsState extends State<ConvertedItems> {
  bool noImage = false;
  List _convList = [];

  String imgPath = '';

  final db = DatabaseHelper();

  final formatCurrencyAmt = NumberFormat.currency(locale: "en_US", symbol: "₱");

  @override
  void initState() {
    super.initState();
    // initPlatformState();
    loadConverted();
  }

  loadConverted() async {
    var documentDirectory = await getApplicationDocumentsDirectory();
    var firstPath = '${documentDirectory.path}/';
    imgPath = firstPath;

    var rsp = await db.loadConvertedItems(widget.convNo);
    setState(() {
      _convList = json.decode(json.encode(rsp));
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
          automaticallyImplyLeading: true,
          backgroundColor: Colors.white,
          title: Text(
            widget.convNo,
            style: const TextStyle(color: Colors.black),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: listViewCont(context),
            ),
          ],
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
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  const Text(
                    'Total Amount:',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      formatCurrencyAmt.format(double.parse(widget.totAmt)),
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  const Text(
                    'Total Qty:',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    widget.totQty,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  Container listViewCont(BuildContext context) {
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
            // ignore: unused_local_variable
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
                                : Image.file(
                                    File(imgPath + _convList[index]['image'])),
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
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
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
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
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
            );
          }),
    );
  }
}
