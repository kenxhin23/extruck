import 'dart:async';
import 'dart:convert';
import 'package:extruck/db/db_helper.dart';
import 'package:extruck/dialogs/confirm_sync.dart';
import 'package:extruck/dialogs/confirmupload.dart';
// import 'package:extruck/home/spinkit.dart';
import 'package:extruck/providers/caption_provider.dart';
// import 'package:extruck/providers/sync_caption.dart';
// import 'package:extruck/providers/upload_count.dart';
import 'package:extruck/session/session_timer.dart';
import 'package:extruck/spinkit/load_spin.dart';
// import 'package:extruck/spinkit/upload_spin.dart';
import 'package:extruck/sync/sync_option.dart';
import 'package:extruck/values/colors.dart';
import 'package:extruck/values/userdata.dart';
import 'package:extruck/widgets/buttons.dart';
// import 'package:extruck/widgets/dialogs.dart';
import 'package:extruck/widgets/snackbar.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
// import 'package:provider/provider.dart';

class SyncPage extends StatefulWidget {
  const SyncPage({Key? key}) : super(key: key);

  @override
  State<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  List _list = [];
  List _updateLog = [];
  bool uploadPressed = true;
  bool viewSpinkit = false;
  bool uploading = false;

  bool upTrans = false;
  bool upItem = false;
  bool upCust = false;
  bool upSm = false;

  String transLastUp = '';
  String itemLastUp = '';
  String custLastUp = '';
  String smLastUp = '';

  String amount = "";

  List _toList = [];
  List _tranList = [];
  List _lineList = [];

  // List _upList = [];
  List _inv = [];
  List _cash = [];
  // List _tempList = [];

  List _loadldgloc = [];
  List _loadldglive = [];

  final db = DatabaseHelper();

  Timer? timer;

  final formatCurrencyAmt = NumberFormat.currency(locale: "en_US", symbol: "₱");

  final formatCurrencyTot =
      NumberFormat.currency(locale: "en_US", symbol: "Php ");

  @override
  void initState() {
    timer =
        Timer.periodic(const Duration(seconds: 1), (Timer t) => checkStatus());
    super.initState();
    checkStatus();
  }

  checkStatus() async {
    loadForUpload();

    // if (GlobalVariables.upload == true) {
    //   if (NetworkData.uploaded == false && uploading == false) {
    //     // showDialog(
    //     //     barrierDismissible: false,
    //     //     context: context,
    //     //     builder: (context) => UploadingSpinkit());
    //     showDialog(
    //         barrierDismissible: false,
    //         context: context,
    //         builder: (context) => const LoadingSpinkit());
    //     await upload();
    //     print('UPLOADING.........');
    //   }
    // }
  }

  loadForUpload() async {
    var getP = await db.getForUploadRemit(UserData.id);
    if (!mounted) return;
    setState(() {
      _list = json.decode(json.encode(getP));
      if (_list.isNotEmpty) {
        for (var element in _list) {
          String date = "";
          date = element['date'].toString();
          DateTime s = DateTime.parse(date);
          element['newdate'] =
              '${DateFormat("MMM dd, yyyy").format(s)} at ${DateFormat("hh:mm aaa").format(s)}';
        }
      }
      if (_list.isEmpty) {
        uploading = false;
      } else {
        GlobalVariables.uploaded = false;
        GlobalVariables.uploadLength = _toList.length.toString();
      }
    });
  }

  uploadButtonclicked() async {
    getInventoryLoad();
    if (NetworkData.connected == true) {
      // if (NetworkData.uploaded == false) {
      showDialog(
          context: context,
          builder: (context) => const ConfirmUpload(
                // iconn: 59137,
                title: 'Confirmation!',
                description1: 'Are you sure you want to upload transactions?',
                description2: 'Please secure stable internet connection.',
              )).then((value) async {
        if (GlobalVariables.upload) {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => const LoadingSpinkit());
          await updatingLoadItemsOnline();
        }
      });
      // }
      // final action = await Dialogs.openDialog(context, 'Confirmation',
      //     'Are you sure you want to upload transactions?', false, 'No', 'Yes');
      // if (action == DialogAction.yes) {
      //   await upload();
      // }
    } else {
      showGlobalSnackbar('Connectivity', 'Please connect to internet.',
          Colors.red.shade900, Colors.white);
    }
  }

  upload() async {
    // int x = 0;
    // Provider.of<UploadCount>(context, listen: false).setTotal(x);
    // if (NetworkData.errorMsgShow == false &&
    //     uploading == false &&
    //     !GlobalVariables.uploaded) {
    //   NetworkData.uploaded = true;
    //   uploading = true;

    //   await updatingLoadItemsOnline();

    //updateconversion
    //updatecashledger
    //updatestockledger
    //chequedata
    //updatesmbalance
    // saveRemittance();
    // }
    await updatingLoadItemsOnline();
    // await saveRemittance();
  }

  updatingLoadItemsOnline() async {
    Provider.of<Caption>(context, listen: false)
        .changeCap('Updating Salesman Load...');
    var rsp = await db.saveitemLoad(UserData.id, _inv);
    print(rsp);
    if (rsp != '' || rsp != null) {
      print('NI UPDATE');
      await updateStockLedger();
    } else {
      await updatingLoadItemsOnline();
    }
  }

  updateStockLedger() async {
    List _ldgListloc = [];
    List _ldgListlive = [];
    var checkLedgerLocal = await db.checkLoadLedgerLocal(UserData.id);
    _ldgListloc = json.decode(json.encode(checkLedgerLocal));
    if (_ldgListloc.isNotEmpty) {
      var checkLedgerOnline = await db.checkLoadLedger(UserData.id);
      _ldgListlive = checkLedgerOnline;
      if (_ldgListlive.length == _ldgListloc.length) {
        print('EQUAL');
        await updateCashLedger();
      } else {
        Provider.of<Caption>(context, listen: false)
            .changeCap('Updating Stock Ledger...');
        var rsp = await db.updateLoadLedger(UserData.id, _ldgListloc);
        if (rsp != null) {
          await updateCashLedger();
        } else {
          await updateStockLedger();
        }
      }
    }
  }

  updateCashLedger() async {
    List _ldgListloc = [];
    List _ldgListlive = [];
    var checkLedgerLocal = await db.checkCashLedgerLocal(UserData.id);
    _ldgListloc = json.decode(json.encode(checkLedgerLocal));
    if (_ldgListloc.isNotEmpty) {
      var checkLedgerOnline = await db.checkCashLedger(UserData.id);
      _ldgListlive = checkLedgerOnline;
      if (_ldgListlive.length >= _ldgListloc.length) {
        await updateChequeData();
        // Navigator.pop(context);
      } else {
        Provider.of<Caption>(context, listen: false)
            .changeCap('Updating Cash Ledger...');
        var rsp = await db.updateCashLedger(UserData.id, _ldgListloc);
        if (rsp != null) {
          await updateChequeData();
          // print('NIUPDATE');
          // Navigator.pop(context);
        } else {
          await updateCashLedger();
        }
      }
    }
  }

  updateChequeData() async {
    List _list = [];
    List res = [];
    Provider.of<Caption>(context, listen: false)
        .changeCap('Updating Cheque Data...');
    var resp = await db.getPendingCheque(UserData.id);
    _list = json.decode(json.encode(resp));
    if (_list.isNotEmpty) {
      var rsp = await db.uploadChequeData(UserData.id, _list);
      if (rsp != null) {
        for (var element in _list) {
          db.updateChequeStat(
              element['sm_code'], element['order_no'], element['cheque_no']);
        }
        await updateConversion();
      } else {
        await updateChequeData();
      }
    } else {
      await updateConversion();
    }
    // var rsp = await db.updatingChequeData();
    // if (rsp != null) {
    //   await updateConversion();
    // } else {
    //   await updateChequeData();
    // }
  }

  updateConversion() async {
    List _list = [];
    Provider.of<Caption>(context, listen: false)
        .changeCap('Updating Conversion Records...');
    var rsp = await db.getPendingConversion(UserData.id);

    setState(() {
      _list = json.decode(json.encode(rsp));
      // print('CONVERSION LIST: ${_list}');
    });
    if (_list.isNotEmpty) {
      for (var element in _list) {
        var conLine = await db.loadConvertedItems(element['conv_no']);
        // convLine = json.decode(json.encode(conLine));
        var upConv = await db.uploadConversion(
            element['sm_code'],
            element['conv_no'],
            element['conv_date'],
            element['itmno'],
            element['totAmt'],
            element['item_qty'],
            element['nitem_qty'],
            conLine);
        if (upConv != null || upConv != '') {
          db.changeConvStat(upConv, 'Uploaded');
        } else {
          await updateConversion();
        }
      }
      await updateSalesmanBalance();
    } else {
      await updateSalesmanBalance();
    }
  }

  updateSalesmanBalance() async {
    List _list = [];
    Provider.of<Caption>(context, listen: false)
        .changeCap('Updating Salesman Balance...');

    var rsp = await db.checkSmBalance(UserData.id);
    // setState(() {
    _list = json.decode(json.encode(rsp));
    print(_list);
    for (var element in _list) {
      await db.uploadSmBalance(
          element['sm_code'],
          element['rev_fund'],
          element['rev_bal'],
          element['load_bal'],
          element['cash_onhand'],
          element['cheque_amt'],
          element['disc_amt'],
          element['bo_amt'],
          element['rmt_amt']);
    }
    // });
    await saveRemittance();
  }

  getInventoryLoad() async {
    var rsp = await db.getInventory(UserData.id);
    setState(() {
      _inv = json.decode(json.encode(rsp));
      // print(_inv);
    });
  }

  getCashLedger() async {
    var rsp = await db.getCashLedger(UserData.id);
    if (!mounted) return;
    setState(() {
      _cash = json.decode(json.encode(rsp));
      // print(_cash);
    });
  }

  // updateLoadLedger() async {
  //   var checkLedgerLocal = await db.checkLedgerLocal(UserData.id);
  //   _loadldgloc = json.decode(json.encode(checkLedgerLocal));
  //   if (_loadldgloc.isNotEmpty) {
  //     var checkLedgerOnline = await db.checkLedger(UserData.id);
  //     _loadldglive = checkLedgerOnline;
  //     if (_loadldglive.length == _loadldgloc.length) {
  //       if (kDebugMode) {
  //         print('EQUAL');
  //       }
  //     } else {
  //       if (kDebugMode) {
  //         print('NOT EQUAL');
  //       }
  //       var rsp = await db.updateLedger(UserData.id, _loadldgloc);
  //       if (kDebugMode) {
  //         print(rsp);
  //       }
  //     }
  //   }
  // }

  saveRemittance() async {
    Provider.of<Caption>(context, listen: false)
        .changeCap('Saving Remittance Reports...');
    int x = 0;
    for (var element in _list) {
      await getRmtTranDetails(element['rmt_no']);
      await getRmtLineDetails();
      x++;
      if (_tranList.isNotEmpty && x <= _list.length) {
        var rsp = await db.saveRemittance(
            UserData.id,
            element['rmt_no'],
            element['date'],
            element['order_count'],
            element['rev_bal'],
            element['load_bal'],
            element['bo_amt'],
            element['tot_amt'],
            element['tot_cash'],
            element['tot_cheque'],
            element['tot_disc'],
            element['tot_satwh'],
            element['tot_net'],
            element['repl_amt'],
            'Posted',
            '1',
            _tranList,
            _lineList);
        if (rsp != null) {
          print(rsp);
          _lineList.clear();
          var res =
              await db.changeRemittanceFlag(UserData.id, rsp, 'Posted', '1');
          if (res != null && _list.isEmpty) {
            setState(() {
              Navigator.pop(context);
            });
          }
        }
      }
    }
  }

  getRmtTranDetails(ordNo) async {
    var tranH = await db.loadRmtHistoryHead(ordNo);
    if (!mounted) return;
    _tranList = json.decode(json.encode(tranH));
  }

  getRmtLineDetails() async {
    List tmp = [];
    for (var element in _tranList) {
      var tranL = await db.loadRemitItems(element['order_no']);
      tmp = json.decode(json.encode(tranL));
      _lineList.addAll(tmp);
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
            toolbarHeight: 130,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sync",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color: ColorsTheme.mainColor,
                      fontSize: 50,
                      fontWeight: FontWeight.bold),
                ),
                Visibility(
                    visible: NetworkData.errorMsgShow,
                    child: buildStatusCont()),
                buildOrderOption(),
              ],
            ),
          ),
          body: uploadPressed ? buildUploadCont() : buildDownloadCont(),
          floatingActionButton: Visibility(
            visible: uploadPressed,
            child: Container(
              padding: const EdgeInsets.only(left: 30),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FloatingActionButton(
                  onPressed: () {
                    if (_list.isNotEmpty) {
                      uploadButtonclicked();
                    }
                    // setState(() {
                    //   loadRemittance();
                    // });
                  },
                  tooltip: 'Upload',
                  child: const Icon(Icons.file_upload),
                ),
              ),
            ),
          ),
          // body: Column(
          //   children: const [],
          // ),
        ));
  }

  Container buildStatusCont() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 20,
      color: Colors.red,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                NetworkData.errorMsg!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                width: 10,
              ),
              const SpinKitFadingCircle(
                color: Colors.white,
                size: 15,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Container buildOrderOption() {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width - 40,
      margin: const EdgeInsets.only(top: 0, bottom: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: (MediaQuery.of(context).size.width - 45) / 2,
            height: 35,
            child: ElevatedButton(
              style: raisedButtonStyleWhite,
              onPressed: () {
                setState(() {
                  viewSpinkit = true;
                  // loadProcessed();
                  OrderData.visible = true;
                  uploadPressed = true;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    text: TextSpan(
                      text: "Upload Data",
                      // recognizer: _tapGestureRecognizer,
                      style: TextStyle(
                        // fontSize: 15,
                        fontSize: ScreenData.scrWidth * .038,
                        fontWeight:
                            uploadPressed ? FontWeight.bold : FontWeight.normal,
                        decoration: TextDecoration.underline,
                        color:
                            uploadPressed ? ColorsTheme.mainColor : Colors.grey,
                      ),
                    ),
                  ),
                  // ignore: avoid_unnecessary_containers
                  Container(
                    // padding: EdgeInsets.all(5),
                    child: Icon(
                      Icons.file_upload,
                      color: Colors.green,
                      size: ScreenData.scrWidth * .06,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 2,
          ),
          SizedBox(
            width: (MediaQuery.of(context).size.width - 45) / 2,
            height: 35,
            child: ElevatedButton(
              style: raisedButtonStyleWhite,
              onPressed: () {
                setState(() {
                  viewSpinkit = true;
                  // loadPending();
                  // loadConsolidated();
                  // dispose();
                  OrderData.visible = false;
                  uploadPressed = false;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                      text: TextSpan(
                    text: "Download Data",
                    // recognizer: _tapGestureRecognizer,
                    style: TextStyle(
                      // fontSize: 15,
                      fontSize: ScreenData.scrWidth * .038,
                      fontWeight:
                          uploadPressed ? FontWeight.normal : FontWeight.bold,
                      decoration: TextDecoration.underline,
                      color:
                          uploadPressed ? Colors.grey : ColorsTheme.mainColor,
                    ),
                  )),
                  Icon(
                    Icons.file_download,
                    color: Colors.yellowAccent,
                    // size: 24,
                    size: ScreenData.scrWidth * .06,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container buildUploadCont() {
    if (_list.isEmpty) {
      return Container(
        padding: const EdgeInsets.only(left: 15, right: 15),
        width: MediaQuery.of(context).size.width,
        // color: ColorsTheme.mainColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.file_upload,
              size: 100,
              color: Colors.grey[500],
            ),
            Text(
              'You have no remittance report for upload.',
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
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: ListView.builder(
        padding: const EdgeInsets.all(0),
        itemCount: _list.length,
        itemBuilder: (context, index) {
          bool uploaded = false;
          if (_list[index]['flag'] == '0') {
            uploaded = false;
          } else {
            uploaded = true;
          }
          amount = _list[index]['tot_amt'];
          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  color: Colors.white,
                  // height: 70,
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    // ignore: prefer_const_literals_to_create_immutables
                    children: [
                      const Icon(
                        Icons.assignment_outlined,
                        color: Colors.deepOrange,
                        size: 36,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _list[index]['rmt_no'],
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              'No. of Orders: ${_list[index]['order_count']}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey),
                            ),
                            Text(
                              _list[index]['newdate'],
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      !uploading
                          ? Column(
                              // ignore: prefer_const_literals_to_create_immutables
                              children: [
                                const Text(
                                  'Total Amount',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  formatCurrencyAmt.format(
                                      double.parse(_list[index]['tot_amt'])),
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.green),
                                ),
                                Text(
                                  uploaded ? 'Uploaded' : 'Ready to Upload',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      color: uploaded
                                          ? Colors.green
                                          : ColorsTheme.mainColor,
                                      fontSize: !uploaded ? 12 : 12,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            )
                          : Column(
                              children: const <Widget>[
                                Text(
                                  'Uploading...',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                                SpinKitFadingCircle(
                                  color: Colors.green,
                                  size: 25,
                                ),
                              ],
                            ),
                      // Icon(
                      //   Icons.file_upload,
                      //   color: uploaded ? Colors.green : Colors.grey,
                      //   size: ScreenData.scrWidth * .06,
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Container buildDownloadCont() {
    // ignore: avoid_unnecessary_containers
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              // height: 250,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 40,
                          // color: Colors.grey,
                          child: Stack(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  InkWell(
                                    onTap: () {
                                      if (!NetworkData.errorMsgShow) {
                                        if (_list.isNotEmpty) {
                                          showGlobalSnackbar(
                                              'Download Error',
                                              'Please upload your orders before downloading.',
                                              Colors.grey.shade900,
                                              Colors.white);
                                        } else {
                                          // print(UserData.id);
                                          // print('TRANSACTIONS CLICKED!');

                                          GlobalVariables.updateType =
                                              'Transactions';
                                          // print('TRANSACTIONS CLICKED!');
                                          GlobalVariables.updateType =
                                              'Transactions';
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  const SyncOption());
                                          // showDialog(
                                          //     context: context,
                                          //     builder: (context) =>
                                          //         ConfirmDialog(
                                          //           title: 'Confirmation',
                                          //           description:
                                          //               'Are you sure you want to update transactions?',
                                          //           buttonText: 'Confirm',
                                          //         ));
                                        }
                                      } else {
                                        showGlobalSnackbar(
                                            'Connectivity',
                                            'Please connect to internet.',
                                            Colors.red.shade900,
                                            Colors.white);
                                      }
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 5),
                                      height: 100,
                                      width: MediaQuery.of(context).size.width /
                                              2 -
                                          30,
                                      decoration: BoxDecoration(
                                          color: Colors.orange[300],
                                          border: Border.all(
                                              color: Colors.transparent),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Stack(
                                        children: <Widget>[
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5, top: 5),
                                                child: !upTrans
                                                    // ignore: avoid_unnecessary_containers
                                                    ? Container(
                                                        child: const Text(
                                                          'Click to Update',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                      )
                                                    : SizedBox(
                                                        width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                2 -
                                                            30,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: const <
                                                              Widget>[
                                                            Icon(
                                                              Icons
                                                                  .check_circle,
                                                              size: 25,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    left: 5, right: 5),
                                                width: MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        2 -
                                                    30,
                                                // color: Colors.grey,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: const <Widget>[
                                                    Icon(
                                                      Icons.shopping_cart,
                                                      size: 50,
                                                      color: Colors.white,
                                                    ),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      'Transaction',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5, top: 5),
                                                child: Row(
                                                  children: <Widget>[
                                                    const Text(
                                                      'Last Updated: ',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                    Text(
                                                      transLastUp,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  InkWell(
                                    onTap: () {
                                      if (!NetworkData.errorMsgShow) {
                                        //print('ITEM MASTERFILE CLICKED');
                                        GlobalVariables.updateType =
                                            'Item Masterfile';
                                        showDialog(
                                            context: context,
                                            builder: (context) =>
                                                const ConfirmDialog(
                                                  title: 'Confirmation',
                                                  description:
                                                      'Are you sure you want to update item masterfile?',
                                                  buttonText: 'Confirm',
                                                ));
                                      } else {
                                        showGlobalSnackbar(
                                            'Connectivity',
                                            'Please connect to internet.',
                                            Colors.red.shade900,
                                            Colors.white);
                                      }
                                    },
                                    child: Container(
                                      height: 100,
                                      width: MediaQuery.of(context).size.width /
                                              2 -
                                          30,
                                      decoration: BoxDecoration(
                                          color: Colors.blue[300],
                                          border: Border.all(
                                              color: Colors.transparent),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Stack(
                                        children: <Widget>[
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5, top: 5),
                                                child: !upItem
                                                    // ignore: avoid_unnecessary_containers
                                                    ? Container(
                                                        child: const Text(
                                                          'Click to Update',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                      )
                                                    : SizedBox(
                                                        width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                2 -
                                                            30,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: const <
                                                              Widget>[
                                                            Icon(
                                                              Icons
                                                                  .check_circle,
                                                              size: 25,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                width: MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        2 -
                                                    30,
                                                margin: const EdgeInsets.only(
                                                    left: 5, right: 5),
                                                // color: Colors.grey,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: const <Widget>[
                                                    Icon(
                                                      Icons.local_offer,
                                                      size: 50,
                                                      color: Colors.white,
                                                    ),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      'Item',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5, top: 5),
                                                child: Row(
                                                  children: <Widget>[
                                                    const Text(
                                                      'Last Updated: ',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                    Text(
                                                      itemLastUp,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: <Widget>[
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 40,
                          // color: Colors.grey,
                          child: Stack(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  InkWell(
                                    onTap: () {
                                      if (!NetworkData.errorMsgShow) {
                                        //print('CUSTOMER MASTERFILE CLICKED!');
                                        GlobalVariables.updateType =
                                            'Customer Masterfile';
                                        showDialog(
                                            context: context,
                                            builder: (context) =>
                                                const ConfirmDialog(
                                                  title: 'Confirmation',
                                                  description:
                                                      'Are you sure you want to update customer masterfile?',
                                                  buttonText: 'Confirm',
                                                ));
                                      } else {
                                        showGlobalSnackbar(
                                            'Connectivity',
                                            'Please connect to internet.',
                                            Colors.red.shade900,
                                            Colors.white);
                                      }
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 5),
                                      height: 100,
                                      width: MediaQuery.of(context).size.width /
                                              2 -
                                          30,
                                      decoration: BoxDecoration(
                                          color: Colors.green[300],
                                          border: Border.all(
                                              color: Colors.transparent),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Stack(
                                        children: <Widget>[
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5, top: 5),
                                                child: !upCust
                                                    // ignore: avoid_unnecessary_containers
                                                    ? Container(
                                                        child: const Text(
                                                          'Click to Update',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                      )
                                                    : SizedBox(
                                                        width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                2 -
                                                            30,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: const <
                                                              Widget>[
                                                            Icon(
                                                              Icons
                                                                  .check_circle,
                                                              size: 25,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                width: MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        2 -
                                                    30,
                                                margin: const EdgeInsets.only(
                                                    left: 5, right: 5),
                                                // color: Colors.grey,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: const <Widget>[
                                                    Icon(
                                                      Icons.account_circle,
                                                      size: 50,
                                                      color: Colors.white,
                                                    ),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      'Customer',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5, top: 5),
                                                child: Row(
                                                  children: <Widget>[
                                                    const Text(
                                                      'Last Updated: ',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                    Text(
                                                      custLastUp,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  InkWell(
                                    onTap: () {
                                      if (!NetworkData.errorMsgShow) {
                                        //print('SALESMAN MASTERFILE CLICKED!');
                                        GlobalVariables.updateType =
                                            'Salesman Masterfile';
                                        showDialog(
                                            context: context,
                                            builder: (context) =>
                                                const ConfirmDialog(
                                                  title: 'Confirmation',
                                                  description:
                                                      'Are you sure you want to update salesman masterfile?',
                                                  buttonText: 'Confirm',
                                                ));
                                      } else {
                                        showGlobalSnackbar(
                                            'Connectivity',
                                            'Please connect to internet.',
                                            Colors.red.shade900,
                                            Colors.white);
                                      }
                                    },
                                    child: Container(
                                      height: 100,
                                      width: MediaQuery.of(context).size.width /
                                              2 -
                                          30,
                                      decoration: BoxDecoration(
                                          color: Colors.purple[300],
                                          border: Border.all(
                                              color: Colors.transparent),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Stack(
                                        children: <Widget>[
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5, top: 5),
                                                child: !upSm
                                                    // ignore: avoid_unnecessary_containers
                                                    ? Container(
                                                        child: const Text(
                                                          'Click to Update',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                      )
                                                    : SizedBox(
                                                        width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                2 -
                                                            30,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: const <
                                                              Widget>[
                                                            Icon(
                                                              Icons
                                                                  .check_circle,
                                                              size: 25,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                width: MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        2 -
                                                    30,
                                                margin: const EdgeInsets.only(
                                                    left: 5, right: 5),
                                                // color: Colors.grey,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: const <Widget>[
                                                    Icon(
                                                      Icons.local_shipping,
                                                      size: 50,
                                                      color: Colors.white,
                                                    ),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      'Salesman',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5, top: 5),
                                                child: Row(
                                                  children: <Widget>[
                                                    const Text(
                                                      'Last Updated: ',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                    Text(
                                                      smLastUp,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            // height: 220,
            // height: 380,
            padding: const EdgeInsets.only(left: 15, right: 15),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Colors.deepOrange[50],
                border: Border.all(color: Colors.deepOrange.shade50),
                borderRadius: BorderRadius.circular(0)),
            child: SingleChildScrollView(
              child: Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            // margin: EdgeInsets.only(left: 10, right: 10),
                            width: MediaQuery.of(context).size.width - 35,
                            height: 20,
                            color: ColorsTheme.mainColor,
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  height: 50,
                                  margin: const EdgeInsets.only(left: 10),
                                  // color: ColorsTheme.mainColor,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const <Widget>[
                                      Text(
                                        'Download Log',
                                        style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontSize: 10,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            // margin: EdgeInsets.only(left: 10, right: 10),
                            width: MediaQuery.of(context).size.width - 35,
                            height: 30,
                            color: Colors.transparent,
                            child: Stack(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      height: 50,
                                      margin: const EdgeInsets.only(left: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const <Widget>[
                                          Text(
                                            'Date',
                                            style: TextStyle(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      height: 50,
                                      margin: const EdgeInsets.only(right: 10),
                                      // color: Colors.grey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const <Widget>[
                                          Text(
                                            'Type',
                                            style: TextStyle(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Container(
                                      height: 50,
                                      margin: const EdgeInsets.only(right: 10),
                                      // color: Colors.grey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const <Widget>[
                                          Text(
                                            'Status',
                                            style: TextStyle(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width - 35,
                            // height: 120,

                            height:
                                MediaQuery.of(context).size.height / 2 - 100,
                            color: Colors.transparent,
                            child: ListView.builder(
                                padding: const EdgeInsets.only(top: 1),
                                itemCount: _updateLog.length,
                                itemBuilder: (context, index) {
                                  Color contColor = Colors.white;
                                  Color fontColor = Colors.white;
                                  String conDate = '';
                                  DateTime x = DateTime.parse(
                                      _updateLog[index]['date'].toString());
                                  // conDate = DateFormat("MMM. d, y ").format(x);
                                  conDate =
                                      DateFormat.yMMMd().add_jm().format(x);
                                  if (_updateLog[index]['tb_categ'] ==
                                      'Transactions') {
                                    // contColor = Colors.orange[300];
                                    fontColor = Colors.orange.shade300;
                                  }
                                  if (_updateLog[index]['tb_categ'] ==
                                      'Item Masterfile') {
                                    // contColor = Colors.blue[300];
                                    fontColor = Colors.blue.shade300;
                                  }
                                  if (_updateLog[index]['tb_categ'] ==
                                      'Customer Masterfile') {
                                    // contColor = Colors.green[300];
                                    fontColor = Colors.green.shade300;
                                  }
                                  if (_updateLog[index]['tb_categ'] ==
                                      'Salesman Masterfile') {
                                    // contColor = Colors.purple[300];
                                    fontColor = Colors.purple.shade300;
                                  }
                                  // ignore: avoid_unnecessary_containers
                                  return Container(
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 5),
                                          padding: const EdgeInsets.all(10),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              35,
                                          // height: 50,
                                          color: contColor,
                                          child: Stack(
                                            children: <Widget>[
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width -
                                                            150,
                                                    child: Text(
                                                      conDate,
                                                      style: TextStyle(
                                                        color: fontColor,
                                                        fontSize: 11,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      ),
                                                      // overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        left: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                3 +
                                                            20),
                                                    child: Text(
                                                      _updateLog[index]
                                                          ['tb_categ'],
                                                      style: TextStyle(
                                                        color: fontColor,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: <Widget>[
                                                  Text(
                                                    _updateLog[index]['status'],
                                                    style: TextStyle(
                                                      color: fontColor,
                                                      fontSize: 12,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
