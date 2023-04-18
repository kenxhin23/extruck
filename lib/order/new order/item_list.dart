import 'dart:convert';
import 'dart:io';

import 'package:extruck/db/db_helper.dart';
import 'package:extruck/home/inventory/discount_details.dart';
import 'package:extruck/order/new%20order/add_dialog.dart';
// import 'package:extruck/home/add_dialog.dart';
import 'package:extruck/providers/cart_total.dart';
import 'package:extruck/session/session_timer.dart';
import 'package:extruck/values/assets.dart';
import 'package:extruck/values/colors.dart';
import 'package:extruck/values/userdata.dart';
import 'package:extruck/widgets/dialogs.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
// import 'package:flutter/src/foundation/key.dart';
// import 'package:flutter/src/widgets/framework.dart';

class ItemList extends StatefulWidget {
  const ItemList({Key? key}) : super(key: key);

  @override
  State<ItemList> createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  bool noImage = true;
  bool viewSpinkit = true;
  bool outofStock = false;
  List _itemlist = [];
  List _tmpitm = [];
  List _disc = [];

  String imgPath = '';
  String _searchController = "";

  final db = DatabaseHelper();

  final formatCurrencyAmt = NumberFormat.currency(locale: "en_US", symbol: "₱");
  final formatCurrencyTot = NumberFormat.currency(locale: "en_US", symbol: "Php ");

  @override
  void initState() {
    super.initState();
    // initPlatformState();
    getPrincipalDiscounts();
    loadProducts();
  }

  getPrincipalDiscounts() async {
    var disc = await db.checkPrincipal();
    _disc = json.decode(json.encode(disc));
  }

  loadProducts() async {
    // int x = 1;
    var documentDirectory = await getApplicationDocumentsDirectory();
    var firstPath = '${documentDirectory.path}/';
    // var filePathAndName = documentDirectory.path + '/images/pic.jpg';
    imgPath = firstPath;
    if (_itemlist.isEmpty) {
      var getO = await db.getInventory(UserData.id);
      if (!mounted) return;
      setState(() {
        _itemlist = json.decode(json.encode(getO));
        _itemlist.forEach((element) {
          _disc.forEach((a) {
            if (element['item_principal'] == a['principal']) {
              element['discounted'] = 1;
            }
          });
        });
        viewSpinkit = false;
        GlobalVariables.itemlist = _itemlist;
      });
    } else {
      // _itemlist = GlobalVariables.itemlist;
      var getO = await db.getInventory(UserData.id);
      setState(() {
        _itemlist = json.decode(json.encode(getO));
        _itemlist.forEach((element) {
          _disc.forEach((a) {
            if (element['item_principal'] == a['principal']) {
              element['discounted'] = 1;
            }
          });
        });
      });
    }

    GlobalVariables.outofStock = false;
  }

  searchItems() async {
    var getI = await db.searchInventory(UserData.id, _searchController);
    if (!mounted) return;
    setState(() {
      // _itemlist = getI;
      _itemlist = json.decode(json.encode(getI));
    });
  }

  Future<void> refreshList() async {
    await Future.delayed(const Duration(seconds: 1));
    loadProducts();
    // return null;
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
          title: headerCont(),
        ),
        body: Column(
          children: [
            Expanded(
              child: listViewCont(context),
            ),
            bottomAppBarCont(context)
          ],
        ),
      ),
    );
  }

  Container listViewCont(BuildContext context) {
    if (viewSpinkit == true) {
      return Container(
        // height: MediaQuery.of(context).size.height - 100,
        // width: MediaQuery.of(context).size.width,
        // color: Colors.white10,
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 150,
                // color: Colors.white,
                height: 150,
                child: Image(
                  color: ColorsTheme.mainColor,
                  image: AssetsValues.cartImage,
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (_itemlist.isEmpty) {
      return Container(
        color: Colors.grey[100],
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.search_off_outlined,
              size: 100,
              color: Colors.orange[500],
            ),
            Text('No items found.',
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
        color: Colors.transparent,
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 1),
          itemCount: _itemlist.length,
          itemBuilder: (context, index) {
            bool lowStock = false;
            bool discounted = false;
            if (_itemlist[index]['discounted'] == 1) {
              discounted = true;
            } else {
              discounted = false;
            }
            if (_itemlist[index]['image'] == '') {
              noImage = true;
            } else {
              noImage = false;
            }
            if (int.parse(_itemlist[index]['item_qty']) < 5) {
              lowStock = true;
            } else {
              lowStock = false;
            }
            // if (_itemlist[index]['status'] == '0') {
            //   outofStock = true;
            // } else {
            //   outofStock = false;
            // }
            return SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      var tmp = await db.searchCustomerCart(
                        UserData.id,
                        CustomerData.accountCode,
                        _itemlist[index]['item_code'],
                        _itemlist[index]['item_uom'],
                      );
                      _tmpitm = tmp;
                      setState(() {
                        CartData.itmCode      = _itemlist[index]['item_code'];
                        CartData.itmDesc      = _itemlist[index]['item_desc'];
                        CartData.itmUom       = _itemlist[index]['item_uom'];
                        CartData.itmAmt       = _itemlist[index]['item_amt'];
                        CartData.itmQty       = '1';
                        CartData.principal    = _itemlist[index]['item_principal'];
                        CartData.imgpath      = _itemlist[index]['image'];
                        CartData.itmTotal     = (double.parse(_itemlist[index]['item_amt']) * double.parse(CartData.itmQty)).toString();
                        CartData.availableQty = _itemlist[index]['item_qty'];
                        // CartData.setCateg = _itemlist[index]['item_cat'];

                        // print(CartData.imgpath);
                        // if (_itemlist[index]['status'] == '0') {
                        //   GlobalVariables.outofStock = true;
                        // } else {
                        //   GlobalVariables.outofStock = false;
                        // }
                      });
                      if (_tmpitm.isNotEmpty) {
                        String msg = "${_tmpitm[0]['item_desc']} is already added with ${_tmpitm[0]['item_qty']} quantity. Add anyway?";
                        // ignore: use_build_context_synchronously
                        final action = await Dialogs.openDialog(context,
                          'Confirmation', msg, false, 'No', 'Yes',
                        );
                        if (action == DialogAction.yes) {
                          showDialog(
                            context: context,
                            builder: (context) => const AddDialog()).then((value) {
                            setState(() {
                              refreshList();
                              // loadProducts();
                            });
                          });
                        } else {}
                      } else {
                        showDialog(
                          // barrierDismissible: false,
                          context: context,
                          builder: (context) => const AddDialog()).then((value) {
                          setState(() {
                            refreshList();
                            // print('REFRESH!');
                          });
                        });
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
                      height: 70,
                      // color: Colors.white,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: Row(
                        children: [
                          Container(
                            width: 5,
                            height: 80,
                            color: ColorsTheme.mainColor,
                          ),
                          if (GlobalVariables.viewImg)
                            Container(
                              // margin: const EdgeInsets.only(
                              //     left: 3, top: 3),
                              width: 75,
                              color: Colors.white,
                              child: noImage
                                ? Image(image: AssetsValues.noImageImg)
                                // ? const Icon(
                                //     Icons.no_photography_outlined,
                                //     color: Colors.grey,
                                //     size: 36,
                                //   )
                                // ? Image.file(File(
                                //     "/data/data/com.example.salesman/app_flutter/images/906782_PCS.jpg"))
                                : Image.file(File(
                                    imgPath + _itemlist[index]['image'])),
                              // child: Image(image: AssetsValues.noImageImg),
                            )
                          else if (!GlobalVariables.viewImg)
                            Container(
                              margin: const EdgeInsets.only(left: 3, top: 3),
                              width: 75,
                              color: Colors.white,
                              child: Image(image: AssetsValues.noImageImg),
                            ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(left: 5),
                              // color: Colors.grey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_itemlist[index]['item_desc'],
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: outofStock
                                      ? Colors.grey
                                      : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    _itemlist[index]['item_uom'],
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      color: Colors.deepOrange,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.transparent,
                            width: 90,
                            // color: Colors.grey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Visibility(
                                  visible: discounted,
                                  child: GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => DiscountDetails(_itemlist[index]
                                          ['item_principal'],
                                        ),
                                      );
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
                                Text(formatCurrencyAmt.format(double.parse(_itemlist[index]['item_amt'])),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // const SizedBox(
                                //   height: 20,
                                // ),
                                Text('${_itemlist[index]['item_qty']} item(s) available',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w500,
                                    color: lowStock
                                    ? Colors.red[800]
                                    : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      );
    }
  }

  Container bottomAppBarCont(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      width: MediaQuery.of(context).size.width,
      height: 50,
      color: Colors.white,
      child: Column(
        children: [
          Row(
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              const Expanded(
                child: Text('Total',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              const Text('Qty', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 60),
              const Text('Amount', style: TextStyle(fontSize: 12)),
            ],
          ),
          Row(
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              const Expanded(
                child: Text(' '),
              ),
              Container(
                width: 50,
                color: Colors.white,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    CartData.itmNo,
                    style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                width: 100,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(formatCurrencyAmt.format(double.parse(Provider.of<CartTotalCounter>(context).totalAmt.toString())),
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Row headerCont() {
    return Row(
      children: <Widget>[
        Expanded(
          child: SizedBox(
            height: 40,
            child: TextFormField(
              onChanged: (String str) {
                setState(() {
                  _searchController = str;
                  searchItems();
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search Product',
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepOrange),
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.redAccent),
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ),
          ),
        ),
        // const SizedBox(
        //   width: 10,
        // ),
      ],
    );
  }
}
