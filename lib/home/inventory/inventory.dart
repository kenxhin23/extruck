import 'dart:convert';
import 'dart:io';
import 'package:extruck/db/db_helper.dart';
import 'package:extruck/home/inventory/discount_details.dart';
import 'package:extruck/home/spinkit.dart';
import 'package:extruck/providers/caption_provider.dart';
import 'package:extruck/session/session_timer.dart';
import 'package:extruck/spinkit/load_spin.dart';
import 'package:extruck/values/assets.dart';
import 'package:extruck/values/userdata.dart';
import 'package:extruck/widgets/buttons.dart';
import 'package:extruck/widgets/dialogs.dart';
import 'package:extruck/widgets/snackbar.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

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
  String revBal = '0.00';
  List _inv = [];
  List _disc = [];
  List itemList = [];
  List itemAllImgList = [];
  List itemDiscList = [];
  List categList = [];
  List _rsp = [];
  String date = '';

  final db = DatabaseHelper();

  final formatCurrencyAmt = NumberFormat.currency(locale: "en_US", symbol: "₱");
  final formatCurrencyTot =
      NumberFormat.currency(locale: "en_US", symbol: "Php ");

  @override
  void initState() {
    super.initState();
    getPrincipalDiscounts();
    getLoadInventory();
  }

  getPrincipalDiscounts() async {
    var disc = await db.checkPrincipal();
    _disc = json.decode(json.encode(disc));
  }

  //LOAD INVENTORY ITEMS
  getLoadInventory() async {
    // var a = await db.ofFetchSample();
    // print(a);
    // db.setBal(UserData.id, '0.00');
    var documentDirectory = await getApplicationDocumentsDirectory();
    var firstPath = '${documentDirectory.path}/';
    imgPath = firstPath;
    totQty = '0';
    loadBal = '0.00';
    var rsp = await db.getInventory(UserData.id);
    setState(() {
      _inv = json.decode(json.encode(rsp));
      // print(_inv);
      for (var element in _inv) {
        //to set discounted in view
        _disc.forEach((a) {
          if (element['item_principal'] == a['principal']) {
            element['discounted'] = 1;
          }
        });
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

  //CHECKING PRICE CHANGE
  checkforPriceChange() async {
    var rsp = await db.checkPriceChange(_inv);
    _rsp = rsp;
    print(_rsp);
    if (_rsp.isEmpty) {
      Navigator.pop(context);
      showGlobalSnackbar(
          'Information', 'No price change found.', Colors.blue, Colors.white);
    } else {
      date = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
      Navigator.pop(context);
      final action = await Dialogs.openDialog(context, 'Confirmation',
          'Are you sure yo want to update prices?', false, 'No', 'Yes');
      if (action == DialogAction.yes) {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => const LoadingSpinkit());
        updateItemMasterfile();
      }
    }
  }

  updateItemMasterfile() async {
    Provider.of<Caption>(context, listen: false)
        .changeCap('Updating Item Masterfile...');

    var rsp = await db.getItemList(context);
    itemList = rsp;
    await db.deleteTable('item_masterfiles');
    await db.insertItemList(itemList);
    await db.addUpdateTable('item_masterfiles ', 'ITEM', date.toString());
    loadItemImgPath();
  }

  loadItemImgPath() async {
    Provider.of<Caption>(context, listen: false)
        .changeCap('Updating Image Path...');

    var rsp = await db.getAllItemImgList(context);
    itemAllImgList = rsp;
    await db.deleteTable('tbl_item_image');
    await db.insertItemImgList(itemAllImgList);
    await db.addUpdateTable('tbl_item_image   ', 'ITEM', date.toString());
    loadItemDiscounts();
  }

  loadItemDiscounts() async {
    Provider.of<Caption>(context, listen: false)
        .changeCap('Updating Discounts...');

    var rsp = await db.getDiscountList(context);
    itemDiscList = rsp;
    await db.deleteTable('tb_principal_discount');
    await db.insertDiscountList(itemDiscList);
    await db.addUpdateTable(
        'tb_principal_discount   ', 'ITEM', date.toString());
    loadCategory();
  }

  loadCategory() async {
    Provider.of<Caption>(context, listen: false)
        .changeCap('Updating Categories...');
    var rsp = await db.getCategList(context);
    categList = rsp;
    int x = 1;
    // ignore: unused_local_variable
    for (var element in categList) {
      if (x < categList.length) {
        x++;
        if (x == categList.length) {
          // print(categList.length);
          await db.deleteTable('tbl_category_masterfile');
          await db.insertCategList(categList);
          await db.addUpdateTable(
              'tbl_category_masterfile', 'ITEM', date.toString());
          // ignore: use_build_context_synchronously
          Provider.of<Caption>(context, listen: false)
              .changeCap('Item Masterfile Updated Successfully!');
          updateInventoryPrice();
        }
      }
    }
  }

  updateInventoryPrice() async {
    List _rsp = [];
    String adj = '';
    double totalAdj = 0.00;
    double variance = 0.00;
    String stockPrice = '0.00';
    String newPrice = '0.00';
    String cpNo = '0';
    final String date2 = DateFormat("MMddyy").format(DateTime.now());
    Provider.of<Caption>(context, listen: false)
        .changeCap('Updating Inventory Stock Prices...');
    // print(_inv);
    int x = 0;
    //INVENTORY ITEMS
    _inv.forEach((element) async {
      var rsp =
          await db.checkItemPrice(element['item_code'], element['item_uom']);
      _rsp = json.decode(json.encode(rsp));
      stockPrice = double.parse(element['item_amt']).toStringAsFixed(2);
      newPrice = double.parse(_rsp[0]['list_price_wtax']).toStringAsFixed(2);

      if (stockPrice != newPrice) {
        db.setItemPrice(
            UserData.id, element['item_code'], element['item_uom'], newPrice);
        variance = double.parse(stockPrice) - double.parse(newPrice);
        cpNo = '${element['item_code']}-${element['item_uom']}';
        adj = variance.toStringAsFixed(2);
        if (double.parse(adj) > 0) {
          //POSITIVE ADJ
          double amt = double.parse(adj) * double.parse(element['item_qty']);
          totalAdj = totalAdj - amt;
          var rsp = await db.updateRevolving(
              UserData.id, amt.toStringAsFixed(2), 'IN', cpNo);
          // print('RESPONSE${rsp}');
          if (rsp != null) {
            await db.setRevBal(UserData.id, rsp.toString());
          }
        } else {
          //NEGATIVE ADJ
          adj = (double.parse(adj) * -1).toString();
          double amt = double.parse(adj) * double.parse(element['item_qty']);
          totalAdj = totalAdj + amt;
          // print(totalAdj.toString());
          var rsp = await db.updateRevolving(
              UserData.id, amt.toStringAsFixed(2), 'OUT', cpNo);
          if (rsp != null) {
            await db.setRevBal(UserData.id, rsp.toString());
          }
        }
      }
      x++;
      if (x == _inv.length) {
        print('TOTAL ADJ:$totalAdj');
        if (totalAdj > 0) {
          db.addLoadBal(UserData.id, totalAdj.toString());
        } else {
          totalAdj = totalAdj * -1;
          print('NEG TOTAL ADJ:$totalAdj');
          db.minusLoadBal(UserData.id, totalAdj.toString());
        }
        Navigator.pop(context);
        String msg = 'Price Changes Successfully Updated.';
        // ignore: use_build_context_synchronously
        final action = await WarningDialogs.openDialog(
          context,
          'Information',
          msg,
          false,
          'OK',
        );
        if (action == DialogAction.yes) {
          setState(() {
            refreshList();
          });
        }
      }
    });
  }

  void handleUserInteraction([_]) {
    SessionTimer sessionTimer = SessionTimer();
    sessionTimer.initializeTimer(context);
  }

  Future<void> refreshList() async {
    await Future.delayed(const Duration(seconds: 1));
    getLoadInventory();
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
              // padding: EdgeInsets.all(5),
              width: MediaQuery.of(context).size.width,
              height: 40,
              color: Colors.white,
              child: Row(
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  Expanded(
                    child: !GlobalVariables.viewImg
                        ? Container(
                            padding: const EdgeInsets.all(5),
                            child: ElevatedButton(
                              style: raisedButtonStyleGrey,
                              onPressed: () async {
                                setState(() {
                                  GlobalVariables.viewImg = true;
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                // mainAxisSize: MainAxisSize.min,
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
                  Container(
                    padding: EdgeInsets.all(5),
                    // color: Colors.green,
                    child: ElevatedButton(
                      style: raisedButtonStyleGreen,
                      onPressed: () {
                        if (!NetworkData.connected) {
                          showGlobalSnackbar(
                              'Connectivity',
                              'Please connect to internet.',
                              Colors.black,
                              Colors.white);
                        } else {
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) =>
                                  const ProcessingBox('Checking for Updates'));
                        }
                        checkforPriceChange();
                      },
                      child: Text(
                        'Price Update',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  // const Text(
                  //   'Total Item(s):',
                  //   style: TextStyle(
                  //       fontWeight: FontWeight.w500, color: Colors.deepOrange),
                  // ),
                  // Text(
                  //   '  $totItm',
                  //   style: const TextStyle(
                  //       fontWeight: FontWeight.w500, fontSize: 16),
                  // ),
                  const SizedBox(
                    width: 5,
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
              bool discounted = false;
              if (_inv[index]['discounted'] == 1) {
                discounted = true;
              } else {
                discounted = false;
              }
              if (_inv[index]['image'] == '') {
                noImage = true;
              } else {
                noImage = false;
              }
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (discounted) {
                        showDialog(
                            context: context,
                            builder: (context) =>
                                DiscountDetails(_inv[index]['item_principal']));
                      }
                    },
                    child: Row(
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
                              Visibility(
                                visible: discounted,
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) => DiscountDetails(
                                            _inv[index]['item_principal']));
                                  },
                                  child: Container(
                                    width: 50,
                                    color: Colors.white,
                                    height: 15,
                                    child: Image(
                                      // color: ColorsTheme.mainColor,
                                      image: AssetsValues.discTag,
                                    ),
                                  ),
                                ),
                              ),
                              const Text(
                                'Qty',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                _inv[index]['item_qty'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10)
                ],
              );
            })),
      );
    }
  }
}
