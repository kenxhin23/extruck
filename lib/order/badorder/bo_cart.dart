import 'dart:convert';
import 'dart:io';
import 'package:extruck/db/db_helper.dart';
import 'package:extruck/home/spinkit.dart';
import 'package:extruck/order/badorder/item_list.dart';
import 'package:extruck/session/session_timer.dart';
import 'package:extruck/values/assets.dart';
import 'package:extruck/values/colors.dart';
import 'package:extruck/values/userdata.dart';
import 'package:extruck/widgets/buttons.dart';
import 'package:extruck/widgets/dialogs.dart';
import 'package:extruck/widgets/snackbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';

class BoCart extends StatefulWidget {
  final List data;
  final String ordNo;

  // ignore: use_key_in_widget_constructors
  const BoCart(this.data, this.ordNo);
  // const BoCart({Key? key}) : super(key: key);

  @override
  State<BoCart> createState() => _BoCartState();
}

class _BoCartState extends State<BoCart> {
  List _list = [];
  List _boCount = [];
  bool noImage = true;
  bool noItem = true;
  // bool emptyList = true;

  String imgPath = '';
  String tranNo = '';

  double totalAmt = 0.00;
  int itmNo = 0;

  int itmQty = 0;
  int nitmQty = 0;

  final db = DatabaseHelper();

  final formatCurrencyAmt = NumberFormat.currency(locale: "en_US", symbol: "₱");

  @override
  void initState() {
    super.initState();
    // initPlatformState();
    loadforRefund();
    clearValue();
  }

  loadforRefund() async {
    CartData.totalAmount = '0.00';
    CartData.itmNo = '0';
    // var test = await db.ofFetchSample();
    // print(test);
    var documentDirectory = await getApplicationDocumentsDirectory();
    var firstPath = '${documentDirectory.path}/';
    imgPath = firstPath;
    for (var element in widget.data) {
      int x;
      x = int.parse(element['mark'].toString());
      if (x == 1) {
        var rsp = await db.getRefundLines(
            element['order_no'], element['item_code'], element['uom']);
        if (!mounted) return;
        setState(() {
          _list.addAll(json.decode(json.encode(rsp)));
        });
      } else {}
    }
  }

  clearValue() {
    setState(() {
      CartData.itmCode = '';
      CartData.itmCode = '';
      CartData.itmDesc = '';
      CartData.itmUom = '';
      CartData.itmAmt = '';
      CartData.itmQty = '1';
      CartData.imgpath = '';
      CartData.itmTotal = '';
      CartData.availableQty = '';
    });
  }

  savingBoRefund() async {
    final String date1 =
        DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
    final String date2 = DateFormat("MMddyy").format(DateTime.now());

    var count = await db.checkCount(UserData.id, CustomerData.accountCode);
    _boCount = json.decode(json.encode(count));
    int cnt = _boCount.length + 1;
    tranNo = '$date2${cnt}BO${CustomerData.accountCode}';
    if (kDebugMode) {
      print(tranNo);
    }

    for (var element in _list) {
      totalAmt = totalAmt + double.parse(element['rf_totamt']);
      itmNo = itmNo + int.parse(element['rf_qty']);
    }
    CartData.totalAmount = totalAmt.toString();
    CartData.itmNo = itmNo.toString();

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
        'BO',
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

    for (var element in _list) {
      // print(element);
      db.addTransactionLine(
          tranNo,
          CartData.siNum,
          element['rf_itmcode'],
          element['rf_itemdesc'],
          element['rf_qty'],
          element['rf_uom'],
          element['rf_amount'],
          '0.00',
          element['rf_totamt'],
          '0.00',
          element['item_cat'],
          'Served',
          'F',
          UserData.id,
          element['rf_image']);
    }
    // if (CartData.pMeth == 'Cheque') {
    //   db.addChequeData(
    //       date,
    //       tranNo,
    //       UserData.id,
    //       CustomerData.accountCode,
    //       ChequeData.bankName,
    //       ChequeData.accName,
    //       ChequeData.accNum,
    //       ChequeData.chequeNum,
    //       ChequeData.chequeDate,
    //       ChequeData.type,
    //       CartData.totalAmount,
    //       'Pending');
    //   // print('Cheque Data Saved!');
    // }

    ///ADD LOG TO LEDGER
    db.minustoLoadLedger(
        UserData.id, date.toString(), CartData.itmNo, 'STOCK OUT', tranNo);

    ///CLEAN CUSTOMER CART
    // db.cleanCustomerCart(UserData.id, CustomerData.accountCode);

    Navigator.pop(context);

    String msg =
        'Your BO Refund #$tranNo has been saved successfully. Continue to print receipt';
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
      // Navigator.push(
      //     context,
      //     PageTransition(
      //         type: PageTransitionType.rightToLeft,
      //         child: PrintReceipt(CartData.list, tranNo)));
    } else {}
  }

  deletetoRefundList(code) {
    for (var element in RefundData.tmplist) {
      if (element['item_code'] == code) {
        element['rf_itmcode'] = '';
        element['rf_itemdesc'] = '';
        element['rf_qty'] = '';
        element['rf_uom'] = '';
        element['rf_amount'] = '';
        element['rf_totamt'] = '';
        element['rf_image'] = '';
      }
    }
  }

  Future<void> refreshList() async {
    await Future.delayed(const Duration(seconds: 1));
    // loadforRefund();
    setState(() {
      _list = RefundData.tmplist;
    });
    // _list.clear();

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
              Text(
                '#${widget.ordNo}',
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
        // floatingActionButton: Container(
        //   padding: const EdgeInsets.only(left: 20),
        //   child: Align(
        //     alignment: Alignment.bottomCenter,
        //     child: FloatingActionButton(
        //       onPressed: () {
        //         //PADUNG SA ITEM LIST
        //         Navigator.push(
        //                 context,
        //                 PageTransition(
        //                     // duration: const Duration(milliseconds: 100),
        //                     type: PageTransitionType.rightToLeft,
        //                     child: const ConversionList()))
        //             .then((value) {
        //           setState(() {
        //             refreshList();
        //           });
        //         }).then((value) {});
        //       },
        //       backgroundColor: ColorsTheme.mainColor,
        //       child: const Icon(Icons.add),
        //     ),
        //   ),
        // ),
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
                          style: _list.isEmpty
                              ? raisedButtonStyleGrey
                              : raisedButtonStyleGreen,
                          onPressed: () async {
                            bool emptyLine = true;
                            for (var element in _list) {
                              if (element['rf_itmcode'] == '' ||
                                  element['rf_itmcode'] == ' ') {
                                emptyLine = true;
                              } else {
                                emptyLine = false;
                              }
                            }
                            if (emptyLine == true) {
                              showGlobalSnackbar(
                                  'Information',
                                  'Please supply empty item.',
                                  Colors.grey,
                                  Colors.white);
                            } else {
                              final action = await Dialogs.openDialog(
                                  context,
                                  'Confirmation',
                                  'You cannot cancel or modify after this. Are you sure you want to refund items?',
                                  false,
                                  'No',
                                  'Yes');
                              if (action == DialogAction.yes) {
                                showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (context) => const ProcessingBox(
                                        'Processing Items'));
                                savingBoRefund();
                              }
                            }
                          },
                          child: const Text(
                            'REFUND ITEMS',
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
    if (_list.isEmpty == true) {
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
          itemCount: _list.length,
          itemBuilder: (context, index) {
            if (_list[index]['image'] == '') {
              noImage = true;
            } else {
              noImage = false;
            }
            if (_list[index]['rf_itmcode'] == '' ||
                _list[index]['rf_itmcode'] == ' ') {
              noItem = true;
            } else {
              noItem = false;
            }
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
                                    _list[index]['uom'].toString(),
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                        color: Colors.deepOrange,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    formatCurrencyAmt.format(double.parse(
                                        _list[index]['amt'].toString())),
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
                                _list[index]['qty'].toString(),
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
                  noItem
                      ? GestureDetector(
                          onTap: () {
                            clearValue();
                            Navigator.push(
                                    context,
                                    PageTransition(
                                        // duration: const Duration(milliseconds: 100),
                                        type: PageTransitionType.rightToLeft,
                                        child: RefundList(
                                            _list,
                                            _list[index]['item_code'],
                                            _list[index]['qty'])))
                                .then((value) {
                              setState(() {
                                if (RefundData.tmplist.isNotEmpty) {
                                  _list = RefundData.tmplist;
                                  //print(_list);
                                }
                              });
                              // print(_list);

                              // refreshList();
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 15),
                            width: MediaQuery.of(context).size.width,
                            color: Colors.white,
                            height: 70,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              // ignore: prefer_const_literals_to_create_immutables
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_circle_outlined,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Click to Add Item',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey.shade400,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      : Dismissible(
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
                              var itmcode =
                                  _list[index]['rf_itmcode'].toString();
                              var itmdesc =
                                  _list[index]['rf_itemdesc'].toString();
                              var itmuom = _list[index]['rf_uom'].toString();
                              var itmamt = _list[index]['rf_amount'].toString();
                              var itmqty = _list[index]['rf_qty'].toString();
                              var itmtot = _list[index]['rf_totamt'].toString();
                              var itmcat = '';
                              var itmImg = _list[index]['rf_image'].toString();
                              db.addInventory(
                                  UserData.id,
                                  _list[index]['rf_itmcode'],
                                  _list[index]['rf_itemdesc'],
                                  _list[index]['rf_uom'],
                                  _list[index]['rf_qty']);

                              deletetoRefundList(_list[index]['item_code']);

                              // _list.removeAt(index);

                              refreshList();
                              // if (_list.isEmpty) {
                              //   setState(() {
                              //     // print('TRUE');
                              //     refreshList();
                              //   });
                              // }

                              showSnackBar(context, itmcode, itmdesc, itmuom,
                                  itmamt, itmqty, itmtot, itmcat, itmImg);

                              // print(cartList);
                            });
                          },
                          child: Container(
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
                                if (GlobalVariables.viewImg)
                                  Container(
                                    width: 45,
                                    color: Colors.white,
                                    child: noImage
                                        ? Image(image: AssetsValues.noImageImg)
                                        : Image.file(File(imgPath +
                                            _list[index]['rf_image'])),
                                  )
                                else if (!GlobalVariables.viewImg)
                                  Container(
                                      margin: const EdgeInsets.only(
                                          left: 3, top: 3),
                                      width: 45,
                                      color: Colors.white,
                                      child: Image(
                                          image: AssetsValues.noImageImg)),
                                Expanded(
                                    child: Container(
                                  margin: const EdgeInsets.only(left: 5),
                                  // color: Colors.grey,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _list[index]['rf_itemdesc'],
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            _list[index]['rf_uom'],
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                                color: Colors.deepOrange,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            formatCurrencyAmt.format(
                                                double.parse(
                                                    _list[index]['rf_amount'])),
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
                                        _list[index]['rf_qty'],
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
                        ),
                  // Container(
                  //   margin: const EdgeInsets.only(left: 15),
                  //   width: MediaQuery.of(context).size.width,
                  //   color: Colors.white,
                  //   height: 70,
                  //   child: Row(
                  //     children: [
                  //       const Icon(
                  //         Icons.subdirectory_arrow_right_outlined,
                  //         color: Colors.grey,
                  //         size: 36,
                  //       ),
                  //       Container(
                  //           margin: const EdgeInsets.only(left: 3, top: 3),
                  //           // width: 75,
                  //           color: Colors.white,
                  //           child: Icon(
                  //             Icons.image_not_supported_outlined,
                  //             color: ColorsTheme.mainColor,
                  //             size: 36,
                  //           )),
                  //       Expanded(
                  //           child: Container(
                  //         margin: const EdgeInsets.only(left: 5),
                  //         // color: Colors.grey,
                  //         child: Column(
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             Text(
                  //               _list[index]['rf_itemdesc'],
                  //               textAlign: TextAlign.left,
                  //               style: TextStyle(
                  //                   fontSize: 12,
                  //                   fontWeight: FontWeight.bold,
                  //                   color: outofStock
                  //                       ? Colors.grey
                  //                       : Colors.black),
                  //             ),
                  //             Row(
                  //               children: [
                  //                 Text(
                  //                   _list[index]['rf_uom'],
                  //                   textAlign: TextAlign.left,
                  //                   style: const TextStyle(
                  //                       color: Colors.deepOrange,
                  //                       fontSize: 11,
                  //                       fontWeight: FontWeight.w500),
                  //                 ),
                  //                 const SizedBox(width: 10),
                  //                 Text(
                  //                   formatCurrencyAmt.format(double.parse(
                  //                       _list[index]['rf_amount'])),
                  //                   textAlign: TextAlign.right,
                  //                   style: const TextStyle(
                  //                       color: Colors.green,
                  //                       fontSize: 12,
                  //                       fontWeight: FontWeight.bold),
                  //                 ),
                  //               ],
                  //             ),
                  //           ],
                  //         ),
                  //       )),
                  //       Container(
                  //         color: Colors.transparent,
                  //         width: 80,
                  //         // color: Colors.grey,
                  //         child: Column(
                  //           // ignore: prefer_const_literals_to_create_immutables
                  //           children: [
                  //             const Expanded(
                  //                 child: SizedBox(
                  //               width: 50,
                  //             )),
                  //             Text(
                  //               _list[index]['rf_qty'],
                  //               textAlign: TextAlign.right,
                  //               style: const TextStyle(
                  //                   color: Colors.green,
                  //                   fontSize: 12,
                  //                   fontWeight: FontWeight.bold),
                  //             ),
                  //             const SizedBox(
                  //               height: 20,
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          }),
    );
  }
}
