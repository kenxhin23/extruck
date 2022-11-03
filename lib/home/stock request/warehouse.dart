import 'dart:convert';
import 'package:extruck/db/db_helper.dart';
import 'package:extruck/session/session_timer.dart';
import 'package:extruck/values/colors.dart';
import 'package:extruck/values/userdata.dart';
import 'package:extruck/widgets/buttons.dart';
import 'package:extruck/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum WarehouseName { none, cdc, udc, talibon, tubigon, jagna }

enum PMethodName { none, cash, cheque }

class WarehousePage extends StatefulWidget {
  const WarehousePage({Key? key}) : super(key: key);

  @override
  State<WarehousePage> createState() => _WarehousePageState();
}

class _WarehousePageState extends State<WarehousePage> {
  bool cheque = false;
  bool pMeth = false;
  bool satW = false;
  bool viewCheque = false;
  List _list = [];

  final db = DatabaseHelper();

  final formatCurrencyAmt = NumberFormat.currency(locale: "en_US", symbol: "₱");

  PMethodName? _pmeth = PMethodName.none;
  WarehouseName? _warehouse = WarehouseName.none;
  void handleUserInteraction([_]) {
    SessionTimer sessionTimer = SessionTimer();
    sessionTimer.initializeTimer(context);
  }

  getChequeDetails() async {
    var rsp = await db.getPendingCheque(UserData.id);
    setState(() {
      _list = json.decode(json.encode(rsp));
      // print(_list);
    });
  }

  @override
  Widget build(BuildContext context) {
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
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(
            color: Colors.black, //change your color here
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Select a warehouse',
                  style: TextStyle(fontSize: 14, color: ColorsTheme.mainColor),
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 15),
                    child: const Icon(
                      Icons.warehouse_rounded,
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Distribution Center',
                    style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            ListTile(
              title: const Text('Central DC (Cortes)'),
              leading: Radio<WarehouseName>(
                value: WarehouseName.cdc,
                groupValue: _warehouse,
                onChanged: (WarehouseName? value) {
                  setState(() {
                    _warehouse = value;
                    CartData.warehouse = 'Central DC (Cortes)';
                    CartData.pMeth = 'RF';
                    satW = false;
                    viewCheque = false;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Ubay DC'),
              leading: Radio<WarehouseName>(
                value: WarehouseName.udc,
                groupValue: _warehouse,
                onChanged: (WarehouseName? value) {
                  setState(() {
                    _warehouse = value;
                    CartData.warehouse = 'Ubay DC';
                    CartData.pMeth = 'RF';
                    satW = false;
                    viewCheque = false;
                  });
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 15),
                    child: const Icon(
                      Icons.cell_tower_rounded,
                      color: Colors.green,
                      size: 24,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Satellite Warehouses',
                    style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            ListTile(
              title: const Text('Tubigon'),
              leading: Radio<WarehouseName>(
                value: WarehouseName.tubigon,
                groupValue: _warehouse,
                onChanged: (WarehouseName? value) {
                  setState(() {
                    _warehouse = value;
                    CartData.warehouse = 'Tubigon';
                    if (CartData.pMeth == 'RF') {
                      CartData.pMeth = 'Cash';
                    }
                    satW = true;
                    viewCheque = false;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Talibon'),
              leading: Radio<WarehouseName>(
                value: WarehouseName.talibon,
                groupValue: _warehouse,
                onChanged: (WarehouseName? value) {
                  setState(() {
                    _warehouse = value;
                    CartData.warehouse = 'Talibon';
                    if (CartData.pMeth == 'RF') {
                      CartData.pMeth = 'Cash';
                    }
                    satW = true;
                    viewCheque = false;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Jagna'),
              leading: Radio<WarehouseName>(
                value: WarehouseName.jagna,
                groupValue: _warehouse,
                onChanged: (WarehouseName? value) {
                  setState(() {
                    _warehouse = value;
                    CartData.warehouse = 'Jagna';
                    if (CartData.pMeth == 'RF') {
                      CartData.pMeth = 'Cash';
                    }
                    print(CartData.pMeth);
                    satW = true;
                    viewCheque = false;
                  });
                },
              ),
            ),
            Visibility(
              visible: satW,
              child: Column(
                children: [
                  Text(
                    'Select Payment',
                    style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Container(
                        // color: Colors.grey[200],
                        width: MediaQuery.of(context).size.width / 2 - 15,
                        height: 40,
                        child: ListTile(
                          title: const Text('Cash only',
                              style: TextStyle(fontSize: 12)),
                          leading: Radio<PMethodName>(
                            value: PMethodName.cash,
                            groupValue: _pmeth,
                            onChanged: (PMethodName? value) {
                              setState(() {
                                _pmeth = value;
                                cheque = false;
                                pMeth = true;
                                CartData.pMeth = 'Cash';
                                viewCheque = false;
                              });
                            },
                          ),
                        ),
                      ),
                      Container(
                        // color: Colors.grey[200],
                        width: MediaQuery.of(context).size.width / 2 - 15,
                        height: 40,
                        child: ListTile(
                          title: const Text('Cheque & cash',
                              style: TextStyle(fontSize: 12)),
                          leading: Radio<PMethodName>(
                            value: PMethodName.cheque,
                            groupValue: _pmeth,
                            onChanged: (PMethodName? value) {
                              setState(() {
                                getChequeDetails();
                                _pmeth = value;
                                cheque = true;
                                pMeth = true;
                                CartData.pMeth = 'Cheque';
                                viewCheque = true;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: 5),
            Visibility(
              visible: viewCheque,
              child: Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                      itemCount: _list.length,
                      itemBuilder: (context, index) {
                        bool mark;
                        if (_list[index]['mark'] == 0) {
                          mark = false;
                        } else {
                          mark = true;
                        }
                        return Container(
                          margin: EdgeInsets.only(top: 5, left: 5, right: 5),
                          width: MediaQuery.of(context).size.width,
                          height: 70,
                          color: Colors.white,
                          child: Row(
                            children: [
                              Checkbox(
                                  checkColor: Colors.white,
                                  fillColor: MaterialStateProperty.resolveWith(
                                      getColor),
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
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_list[index]['cheque_no'],
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500)),
                                    Text(
                                      _list[index]['bank_name'],
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[700]),
                                    ),
                                    Text(
                                      _list[index]['account_name'],
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                formatCurrencyAmt.format(
                                    double.parse(_list[index]['amount'])),
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green[700]),
                              ),
                            ],
                          ),
                        );
                      }),
                  // color: Colors.green,
                  // child: ListView.builder(itemBuilder:),
                ),
              ),
            )
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
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                        padding: const EdgeInsets.all(10),
                        child: ElevatedButton(
                          style: raisedButtonStyleGreen,
                          onPressed: () {
                            setState(() {
                              if (CartData.pMeth == 'Cheque') {
                                for (var element in _list) {
                                  if (element['mark'] == 1) {
                                    GlobalVariables.chequeList.add(element);
                                  }
                                }
                                if (GlobalVariables.chequeList.isEmpty) {
                                  showGlobalSnackbar(
                                      'Information',
                                      'Please select cheque.',
                                      Colors.blue,
                                      Colors.white);
                                } else {
                                  Navigator.pop(context);
                                }
                              } else {
                                Navigator.pop(context);
                              }
                            });

                            // print(GlobalVariables.chequeList);
                          },
                          child: const Text(
                            'SAVE WAREHOUSE',
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
}
