import 'dart:convert';
import 'dart:io';
import 'package:extruck/db/db_helper.dart';
import 'package:extruck/order/new%20order/checkout.dart';
import 'package:extruck/order/new%20order/item_list.dart';
import 'package:extruck/providers/cart_items.dart';
import 'package:extruck/providers/cart_total.dart';
import 'package:extruck/session/session_timer.dart';
import 'package:extruck/values/assets.dart';
import 'package:extruck/values/colors.dart';
import 'package:extruck/values/userdata.dart';
import 'package:extruck/widgets/buttons.dart';
import 'package:extruck/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class MyCart extends StatefulWidget {
  const MyCart({Key? key}) : super(key: key);

  @override
  State<MyCart> createState() => _MyCartState();
}

class _MyCartState extends State<MyCart> {
  List cartList = [];
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
    // initPlatformState();
    loadCart();
    // loadTran();
  }

  loadCart() async {
    var documentDirectory = await getApplicationDocumentsDirectory();
    var firstPath = '${documentDirectory.path}/';
    imgPath = firstPath;
    // emptyCart = true;
    CartData.itmNo = '0';
    CartData.totalAmount = "0.00";
    CartData.siNum = '';
    var rsp =
        await db.ofFetchCustomerCart(UserData.id, CustomerData.accountCode);
    // var rsp = await getTemp(UserData.id, CustomerData.accountCode);
    if (!mounted) return null;
    cartList = json.decode(json.encode(rsp));
    CartData.list = cartList;
    setState(() {
      if (cartList.isNotEmpty) {
        emptyCart = false;
      }
      computeTotal();
      // loadMinOrder();
    });
    OrderData.setSign = false;
    OrderData.signature = '';
    // viewSpinkit = false;
  }

  computeTotal() {
    setState(() {
      // itmCat = "";
      // categ = false;
      CartData.itmNo = '0';
      CartData.totalAmount = '0.00';
      double sum = 0;
      if (cartList.isNotEmpty) {
        for (var element in cartList) {
          setState(() {
            sum = sum + double.parse(element['item_total']);
            // print(element['item_total']);
            CartData.totalAmount = sum.toStringAsFixed(2);
            // print(CartData.totalAmount);
            // CartData.itmNo = cartList.length.toString();
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

      // print('TOTAL AMOUNT:' + CartData.totalAmount);
      // print(CartData.itmNo);
      CartData.itmLineNo = cartList.length.toString();
    });
    Provider.of<CartItemCounter>(context, listen: false)
        .setTotal(int.parse(CartData.itmNo));
    Provider.of<CartTotalCounter>(context, listen: false)
        .setTotal(double.parse(CartData.totalAmount));
  }

  Future<void> refreshList() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      loadCart();
    });

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
      db.minusInventory(UserData.id, itmCode, itmDesc, itmUom, itmQty);
      refreshList();
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
          backgroundColor: Colors.white,
          foregroundColor: Colors.white,
          title: Text(
            "${CustomerData.accountName}'s Cart",
            style: TextStyle(
                fontSize: 12,
                color: Colors.grey[800],
                fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
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
              'Order No.',
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
                          child: const Checkout()));
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  const Text(
                    "Checkout Order",
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

  Container listViewCont(BuildContext context) {
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
    return Container(
      color: Colors.transparent,
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 5, right: 10, left: 10),
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
                  db.addInventory(
                      UserData.id,
                      cartList[index]['item_code'],
                      cartList[index]['item_desc'],
                      cartList[index]['item_uom'],
                      cartList[index]['item_qty']);
                  db.deleteItem(
                      UserData.id,
                      CustomerData.accountCode,
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                  : Image.file(
                                      File(imgPath + cartList[index]['image'])),
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
                                Text(
                                  cartList[index]['item_desc'],
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(
                                      cartList[index]['item_uom'],
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          color: Colors.deepOrange,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(width: 30),
                                    Text(
                                      formatCurrencyAmt.format(double.parse(
                                          cartList[index]['item_amt'])),
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )),
                          Center(
                            child: Container(
                              color: Colors.transparent,
                              width: 25,
                              child: Text(
                                cartList[index]['item_qty'].toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                          Center(
                            child: Container(
                              width: 70,
                              padding: const EdgeInsets.only(right: 5),
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
                          ),
                        ],
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
