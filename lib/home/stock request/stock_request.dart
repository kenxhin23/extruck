import 'dart:convert';
import 'dart:io';

import 'package:extruck/db/db_helper.dart';
import 'package:extruck/home/stock%20request/item_list.dart';
import 'package:extruck/home/stock%20request/send_request.dart';
import 'package:extruck/providers/cart_items.dart';
import 'package:extruck/providers/cart_total.dart';
import 'package:extruck/session/session_timer.dart';
import 'package:extruck/values/assets.dart';
import 'package:extruck/values/colors.dart';
import 'package:extruck/values/userdata.dart';
import 'package:extruck/widgets/buttons.dart';
import 'package:extruck/widgets/snackbar.dart';
// import 'package:extruck/values/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

// import 'package:flutter/src/foundation/key.dart';
// import 'package:flutter/src/widgets/framework.dart';

class StockRequest extends StatefulWidget {
  const StockRequest({Key? key}) : super(key: key);

  @override
  State<StockRequest> createState() => _StockRequestState();
}

class _StockRequestState extends State<StockRequest> {
  List cartList = [];
  List convList = [];
  List convLine = [];
  String imgPath = "";
  bool emptyCart = true;
  bool noImage = true;

  final db = DatabaseHelper();

  final formatCurrencyAmt = NumberFormat.currency(locale: "en_US", symbol: "₱");
  final formatCurrencyTot =
      NumberFormat.currency(locale: "en_US", symbol: "Php ");

  @override
  void initState() {
    super.initState();
    loadCart();
    loadforUpload();
  }

  loadCart() async {
    var documentDirectory = await getApplicationDocumentsDirectory();
    var firstPath = '${documentDirectory.path}/';
    imgPath = firstPath;
    // emptyCart = true;
    CartData.itmNo = '0';
    CartData.totalAmount = "0.00";
    var rsp = await db.ofFetchCart(UserData.id);
    cartList = json.decode(json.encode(rsp));

    setState(() {
      if (cartList.isNotEmpty) {
        emptyCart = false;
      }
      computeTotal();
    });
    OrderData.setSign = false;
    OrderData.signature = '';
  }

  computeTotal() {
    setState(() {
      CartData.itmNo = '0';
      double sum = 0;
      if (cartList.isNotEmpty) {
        for (var element in cartList) {
          setState(() {
            sum = sum + double.parse(element['item_total']);
            CartData.totalAmount = sum.toStringAsFixed(2);
            CartData.itmNo =
                (int.parse(CartData.itmNo) + int.parse(element['item_qty']))
                    .toString();
          });
        }
      } else {
        setState(() {
          CartData.totalAmount = '0.00';
          CartData.itmNo = '0';
        });
      }
      CartData.itmLineNo = cartList.length.toString();
    });
    Provider.of<CartItemCounter>(context, listen: false)
        .setTotal(int.parse(CartData.itmNo));
    Provider.of<CartTotalCounter>(context, listen: false)
        .setTotal(double.parse(CartData.totalAmount));
  }

  loadforUpload() async {
    var rsp = await db.getPendingConversion(UserData.id);

    setState(() {
      convList = json.decode(json.encode(rsp));
    });
    if (convList.isNotEmpty) {
      for (var element in convList) {
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
        }
      }
    }
  }

  showSnackBar(context, itmCode, itmDesc, itmUom, itmAmt, itmQty, itmTotal,
      setCateg, itmImg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: const Text(
            '1 Item Deleted',
          ),
          action: SnackBarAction(
              label: "UNDO",
              onPressed: () {
                setState(() {
                  unDoDelete(itmCode, itmDesc, itmUom, itmAmt, itmQty, itmTotal,
                      setCateg, itmImg);
                });
              })),
    );
  }

  unDoDelete(
      itmCode, itmDesc, itmUom, itmAmt, itmQty, itmTotal, setCateg, itmImg) {
    setState(() {
      db.addItemtoCart(UserData.id, itmCode, itmDesc, itmUom, itmAmt, itmQty,
          itmTotal, setCateg, itmImg);
      refreshList();
    });
  }

  Future<void> refreshList() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      loadCart();
    });

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
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // ignore: prefer_const_literals_to_create_immutables
              children: [
                const Text(
                  'Stock Request',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.grey[100],
          body: Column(
            children: [Expanded(child: listViewCont())],
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
                              child: const ItemList()))
                      .then((value) {
                    refreshList();
                  });
                },
                backgroundColor: ColorsTheme.mainColor,
                child: const Icon(Icons.add),
              ),
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              height: 140,
              child: bottomAppBar(),
            ),
          ),
        ));
  }

  Container listViewCont() {
    if (emptyCart == true) {
      return Container(
        color: Colors.grey[100],
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.remove_shopping_cart,
              size: 100,
              color: Colors.orange[500],
            ),
            Text(
              'Cart is Empty. Press the add button below to add items.',
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
    // ignore: sized_box_for_whitespace
    return Container(
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 1),
        itemCount: cartList.length,
        itemBuilder: (context, index) {
          // String x = '';
          // if (itmCat != cartList[index]['item_cat']) {
          //   categ = false;
          //   itmCat = cartList[index]['item_cat'];
          // } else {
          //   categ = true;
          // }
          if (cartList[index]['image'] == '') {
            noImage = true;
          } else {
            noImage = false;
          }
          cartList[index]['item_total'] =
              (double.parse(cartList[index]['item_amt']) *
                      double.parse(cartList[index]['item_qty']))
                  .toStringAsFixed(2);
          final item = cartList[index].toString();
          return SingleChildScrollView(
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
              // key: UniqueKey(),
              onDismissed: (direction) {
                if (!mounted) return;
                setState(() {
                  var itmcode = cartList[index]['item_code'].toString();
                  var itmdesc = cartList[index]['item_desc'].toString();
                  var itmuom = cartList[index]['item_uom'].toString();
                  var itmamt = cartList[index]['item_amt'].toString();
                  var itmqty = cartList[index]['item_qty'].toString();
                  var itmtot = cartList[index]['item_total'].toString();
                  var itmcat = cartList[index]['item_cat'].toString();
                  var itmImg = cartList[index]['image'].toString();

                  db.deleteRequestItem(
                      UserData.id,
                      cartList[index]['item_code'].toString(),
                      cartList[index]['item_uom'].toString());
                  cartList.removeAt(index);
                  computeTotal();
                  // refreshList();

                  showSnackBar(context, itmcode, itmdesc, itmuom, itmamt,
                      itmqty, itmtot, itmcat, itmImg);

                  // print(cartList);
                });
              },
              child: Column(
                children: <Widget>[
                  Container(
                    // padding:
                    //     const EdgeInsets.only(left: 10, bottom: 5, right: 5),
                    margin: const EdgeInsets.only(bottom: 10),
                    height: 70,
                    width: MediaQuery.of(context).size.width,
                    // color: Colors.white,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                            width: 1.0, color: ColorsTheme.mainColor),
                      ),
                      color: Colors.white,
                    ),
                    child: Stack(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 5,
                              height: 80,
                              color: ColorsTheme.mainColor,
                            ),
                            if (GlobalVariables.viewImg)
                              Container(
                                margin: const EdgeInsets.only(left: 3, top: 3),
                                width: 75,
                                color: Colors.white,
                                child: noImage
                                    ? Image(image: AssetsValues.noImageImg)
                                    : Image.file(File(
                                        imgPath + cartList[index]['image'])),
                              )
                            else if (!GlobalVariables.viewImg)
                              Container(
                                margin: const EdgeInsets.only(left: 3, top: 3),
                                width: 75,
                                color: Colors.white,
                                child: Image(image: AssetsValues.noImageImg),
                              )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.only(left: 85),
                              margin: const EdgeInsets.only(left: 3),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width - 230,
                                    child: Text(
                                      cartList[index]['item_desc'],
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      SizedBox(
                                        width: 45,
                                        child: Text(
                                          cartList[index]['item_uom'],
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 2,
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                    6 -
                                                15,
                                        child: Text(
                                          formatCurrencyAmt.format(double.parse(
                                              cartList[index]['item_amt'])),
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                              color: Colors.green,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500),
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
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              margin: const EdgeInsets.only(right: 5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  const SizedBox(
                                    height: 40,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            if (int.parse(cartList[index]
                                                    ['item_qty']) ==
                                                1) {
                                              // itmCat = "";
                                              // categ = false;
                                              showGlobalSnackbar(
                                                  'Information',
                                                  'Swipe to remove item.',
                                                  Colors.blue,
                                                  Colors.white);
                                            } else {
                                              if (int.parse(cartList[index]
                                                      ['item_qty']) >
                                                  1) {
                                                setState(() {
                                                  var i = int.parse(
                                                          cartList[index]
                                                              ['item_qty']) -
                                                      1;
                                                  cartList[index]['item_qty'] =
                                                      i.toString();

                                                  cartList[index]
                                                      ['item_total'] = (double
                                                              .parse(cartList[
                                                                      index][
                                                                  'item_amt']) *
                                                          double.parse(
                                                              cartList[index]
                                                                  ['item_qty']))
                                                      .toStringAsFixed(2);

                                                  db.updateSmCart(
                                                      UserData.id,
                                                      cartList[index]
                                                          ['item_code'],
                                                      cartList[index]
                                                          ['item_uom'],
                                                      cartList[index]
                                                          ['item_qty'],
                                                      cartList[index]
                                                          ['item_total']);
                                                  computeTotal();
                                                });
                                              } else {
                                                setState(() {
                                                  db.deleteRequestItem(
                                                      UserData.id,
                                                      cartList[index]
                                                              ['item_code']
                                                          .toString(),
                                                      cartList[index]
                                                              ['item_uom']
                                                          .toString());

                                                  cartList.removeAt(index);
                                                  computeTotal();
                                                });
                                              }
                                            }
                                          });
                                        },
                                        child: Icon(
                                          Icons.indeterminate_check_box,
                                          color: ColorsTheme.mainColor,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 25,
                                        child: Text(
                                          cartList[index]['item_qty']
                                              .toString(),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            var i = int.parse(cartList[index]
                                                    ['item_qty']) +
                                                1;
                                            // print(i);
                                            cartList[index]['item_qty'] =
                                                i.toString();

                                            cartList[index]['item_total'] =
                                                (double.parse(cartList[index]
                                                            ['item_amt']) *
                                                        double.parse(
                                                            cartList[index]
                                                                ['item_qty']))
                                                    .toStringAsFixed(2);
                                            computeTotal();
                                            db.updateSmCart(
                                                UserData.id,
                                                cartList[index]['item_code'],
                                                cartList[index]['item_uom'],
                                                cartList[index]['item_qty'],
                                                cartList[index]['item_total']);
                                          });
                                        },
                                        child: Icon(
                                          Icons.add_box,
                                          color: ColorsTheme.mainColor,
                                        ),
                                      ),
                                      Container(
                                        width: 70,
                                        padding:
                                            const EdgeInsets.only(right: 5),
                                        child: Text(
                                          formatCurrencyAmt.format(double.parse(
                                              cartList[index]['item_total'])),
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                              color: Colors.green,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              fontStyle: FontStyle.italic),
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Column bottomAppBar() {
    return Column(
      children: [
        Row(
          children: const [
            Text(
              'Order Summary',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            )
          ],
        ),
        // const SizedBox(height: 5),
        Row(
          children: const [
            Expanded(
                child: Text(
              'Request No.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            )),
            Text(
              '0',
              style: TextStyle(fontSize: 12),
            )
          ],
        ),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Total Qty',
                style: TextStyle(fontSize: 12),
              ),
            ),
            Text(
              CartData.itmNo,
              style: const TextStyle(fontSize: 12),
            )
          ],
        ),
        Row(
          children: const [
            Expanded(
                child: Text(
              'Total Discount',
              style: TextStyle(fontSize: 12),
            )),
            Text(
              '0.00',
              style: TextStyle(fontSize: 12),
            )
          ],
        ),
        Row(
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            const Expanded(
              child: Text(
                'Total Amount',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
            Text(
              formatCurrencyTot.format(double.parse(CartData.totalAmount)),
              // formatCurrencyTot.format(double.parse(totalAmount)),
              // '',
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
        // const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              style: raisedButtonStyleGreen,
              onPressed: () async {
                if (cartList.isEmpty) {
                  showGlobalSnackbar('Information',
                      'Unable to send empty cart.', Colors.blue, Colors.white);
                } else {
                  CartData.list = cartList;
                  Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: const SendRequest()));
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  const Text(
                    "Send Request",
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
    );
  }

  Container viewPendingCont() {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      margin: const EdgeInsets.only(top: 2),
      color: Colors.white,
      height: 50,
      child: Row(
        // ignore: prefer_const_literals_to_create_immutables
        children: [
          const Icon(Icons.remove_red_eye_outlined, color: Colors.deepOrange),
          const SizedBox(width: 5),
          const Expanded(
            child: Text(
              'View Pending Requests',
              style: TextStyle(fontSize: 14),
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Colors.black,
          )
        ],
      ),
    );
  }

  Container newOrderCont() {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      margin: const EdgeInsets.only(top: 2),
      color: Colors.white,
      height: 50,
      child: Row(
        // ignore: prefer_const_literals_to_create_immutables
        children: [
          const Icon(Icons.add_circle_outline_outlined, color: Colors.green),
          const SizedBox(width: 5),
          const Expanded(
            child: Text(
              'Add New Request',
              style: TextStyle(fontSize: 14),
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Colors.black,
          )
        ],
      ),
    );
  }
}
