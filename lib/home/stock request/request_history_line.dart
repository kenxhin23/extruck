import 'dart:convert';
import 'dart:io';
import 'package:extruck/db/db_helper.dart';
// import 'package:extruck/providers/pending_counter.dart';
import 'package:extruck/session/session_timer.dart';
import 'package:extruck/values/assets.dart';
import 'package:extruck/values/userdata.dart';
// import 'package:extruck/widgets/dialogs.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:provider/provider.dart';

class RequestHistoryLine extends StatefulWidget {
  const RequestHistoryLine({Key? key}) : super(key: key);

  @override
  State<RequestHistoryLine> createState() => _RequestHistoryLineState();
}

class _RequestHistoryLineState extends State<RequestHistoryLine> {
  bool noImage = true;
  bool viewSpinkit = true;
  bool appTrue = false;
  String imgPath = '';
  List _line = [];

  final db = DatabaseHelper();

  final date = DateTime.parse(DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()));

  final formatCurrencyAmt = NumberFormat.currency(locale: "en_US", symbol: "₱");
  final formatCurrencyTot =
      NumberFormat.currency(locale: "en_US", symbol: "Php ");

  @override
  void initState() {
    super.initState();
    checkTranStat();
  }

  checkTranStat() async {
    var documentDirectory = await getApplicationDocumentsDirectory();
    var firstPath = '${documentDirectory.path}/';
    imgPath = firstPath;

    var line = await db.getRequestLine(RequestData.tranNo);
    setState(() {
      _line = json.decode(json.encode(line));
      appTrue = false;
    });
    viewSpinkit = false;
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
            RequestData.tranNo,
            style:
                TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
        ),
        backgroundColor: Colors.grey[100],
        body: Column(
          children: [
            Expanded(
              child: listViewCont(),
            ),
            buildTotalCont(),
            // buildLoadButton()
          ],
        ),
      ),
    );
  }

  Container buildTotalCont() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8),
      child: Row(
        // ignore: prefer_const_literals_to_create_immutables
        children: [
          const Text('Amount:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(formatCurrencyAmt.format(double.parse(RequestData.totAmt)),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.deepOrange,
              ),
            ),
          ),
          const Text('Req Total:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 5),
          Text(RequestData.reqQty,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.deepOrange,
            ),
          ),
          const SizedBox(width: 10),
          Row(
            children: [
              const Text('App Total:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 5),
              Text(RequestData.appQty,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.deepOrange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Container buildLoadButton() => Container(
  //     decoration: const BoxDecoration(
  //       color: Colors.white,
  //       border: Border(
  //         top: BorderSide(width: 0.2, color: Colors.black),
  //       ),
  //     ),
  //     width: MediaQuery.of(context).size.width,
  //     height: 80,
  //     padding: const EdgeInsets.symmetric(horizontal: 20),
  //     child: Row(
  //       children: [
  //         Expanded(
  //           child: Container(
  //               padding: const EdgeInsets.all(10),
  //               child: ElevatedButton(
  //                 style:
  //                     appTrue ? raisedButtonStyleGreen : raisedButtonStyleGrey,
  //                 onPressed: () async {
  //                   if (appTrue) {
  //                     final action = await Dialogs.openDialog(
  //                         context,
  //                         'Confirmation',
  //                         'Are you sure you want to add this items?',
  //                         false,
  //                         'No',
  //                         'Yes');
  //                     if (action == DialogAction.yes) {
  //                       Spinkit.label = 'Loading Items...';
  //                       showDialog(
  //                           barrierDismissible: false,
  //                           context: context,
  //                           builder: (context) => const LoadingSpinkit());
  //                       loadItems();
  //                     } else {}
  //                   } else {}
  //                 },
  //                 child: const Text(
  //                   'LOAD ITEMS',
  //                   style: TextStyle(color: Colors.white),
  //                 ),
  //               )),
  //         )
  //       ],
  //     ));

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
    } else {
      if (_line.isEmpty) {
        return Container(
          color: Colors.grey[100],
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.do_disturb_alt_outlined,
                size: 100,
                color: Colors.orange[500],
              ),
              Text(
                'No items found. Please contact administrator.',
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
          padding: const EdgeInsets.all(5),
          width: MediaQuery.of(context).size.width,
          child: ListView.builder(
              itemCount: _line.length,
              itemBuilder: ((context, index) {
                if (appTrue) {
                  if (_line[index]['item_path'] == '') {
                    noImage = true;
                  } else {
                    noImage = false;
                  }
                } else {
                  if (_line[index]['image'] == '') {
                    noImage = true;
                  } else {
                    noImage = false;
                  }
                }
                return Column(
                  children: [
                    Row(
                      children: [
                        if (GlobalVariables.viewImg)
                          Container(
                            // margin: const EdgeInsets.only(left: 3, top: 3),
                            width: 75,
                            height: 80,
                            color: Colors.white,
                            child: noImage
                                ? Image(image: AssetsValues.noImageImg)
                                : appTrue
                                    ? Image.file(File(imgPath +
                                        _line[index]['item_path'].toString()))
                                    : Image.file(File(imgPath +
                                        _line[index]['image'].toString())),
                          )
                        else if (!GlobalVariables.viewImg)
                          Container(
                            // margin: const EdgeInsets.only(left: 3, top: 3),
                            width: 75,
                            height: 80,
                            color: Colors.white,
                            child: Image(image: AssetsValues.noImageImg),
                          ),
                        Expanded(
                            child: Container(
                          padding: const EdgeInsets.only(left: 5),
                          color: Colors.white,
                          height: 80,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _line[index]['item_desc'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(_line[index]['uom']),
                                  const SizedBox(
                                    width: 30,
                                  ),
                                  Text(
                                    formatCurrencyAmt.format(
                                        double.parse(_line[index]['amt'])),
                                    style: const TextStyle(
                                        // fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.green),
                                  )
                                ],
                              )
                            ],
                          ),
                        )),
                        Container(
                          color: Colors.white,
                          width: 50,
                          height: 80,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Qty',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                appTrue
                                    ? _line[index]['app_qty']
                                    : _line[index]['req_qty'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10)
                  ],
                );
              })),
        );
      }
    }
  }
}
