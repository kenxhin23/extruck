import 'dart:convert';
import 'dart:io';
import 'package:extruck/db/db_helper.dart';
import 'package:extruck/session/session_timer.dart';
import 'package:extruck/values/assets.dart';
import 'package:extruck/values/userdata.dart';
import 'package:extruck/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class StockInvetory extends StatefulWidget {
  const StockInvetory({Key? key}) : super(key: key);

  @override
  State<StockInvetory> createState() => _StockInvetoryState();
}

class _StockInvetoryState extends State<StockInvetory> {
  bool noImage = true;
  String imgPath = '';
  String totQty = '0';
  String totItm = '0';
  String loadBal = '0.00';
  List _inv = [];

  final db = DatabaseHelper();

  final formatCurrencyAmt = NumberFormat.currency(locale: "en_US", symbol: "₱");
  final formatCurrencyTot =
      NumberFormat.currency(locale: "en_US", symbol: "Php ");

  @override
  void initState() {
    super.initState();
    getLoadInventory();
  }

  getLoadInventory() async {
    var documentDirectory = await getApplicationDocumentsDirectory();
    var firstPath = '${documentDirectory.path}/';
    imgPath = firstPath;
    totQty = '0';
    var rsp = await db.getInventory(UserData.id);
    setState(() {
      _inv = json.decode(json.encode(rsp));
      // print(_inv);
      for (var element in _inv) {
        totQty =
            (int.parse(totQty) + int.parse(element['item_qty'])).toString();
        loadBal = (double.parse(loadBal) +
                (int.parse(element['item_qty']) *
                    double.parse(element['item_amt'])))
            .toString();
      }
      totItm = _inv.length.toString();
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
              Row(
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  const Text(
                    'Stock Inventory',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '(${formatCurrencyAmt.format(double.parse(loadBal))})',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.yellow[400]),
                  ),
                ],
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: listViewCont(),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 40,
              color: Colors.white,
              child: Row(
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  Expanded(
                    child: !GlobalVariables.viewImg
                        ? Container(
                            padding: const EdgeInsets.all(10),
                            child: ElevatedButton(
                              style: raisedButtonStyleOrange,
                              onPressed: () async {
                                setState(() {
                                  GlobalVariables.viewImg = true;
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                // ignore: prefer_const_literals_to_create_immutables
                                children: [
                                  const Text(
                                    "View Images",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const Text(''),
                  ),
                  const Text(
                    'Total Item(s):',
                    style: TextStyle(
                        fontWeight: FontWeight.w500, color: Colors.deepOrange),
                  ),
                  Text(
                    '  $totItm',
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  const Text(
                    'Total Qty:',
                    style: TextStyle(
                        fontWeight: FontWeight.w500, color: Colors.deepOrange),
                  ),
                  Text(
                    '  $totQty',
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Container listViewCont() {
    if (_inv.isEmpty) {
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
              'Inventory is empty. Please request for stocks.',
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
            itemCount: _inv.length,
            itemBuilder: ((context, index) {
              if (_inv[index]['image'] == '') {
                noImage = true;
              } else {
                noImage = false;
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
                              : Image.file(
                                  File(imgPath + _inv[index]['image'])),
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
                              _inv[index]['item_desc'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Row(
                              children: [
                                Text(_inv[index]['item_uom']),
                                const SizedBox(
                                  width: 30,
                                ),
                                Text(
                                  formatCurrencyAmt.format(
                                      double.parse(_inv[index]['item_amt'])),
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
                              _inv[index]['item_qty'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
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
