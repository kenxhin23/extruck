import 'dart:convert';

import 'package:extruck/db/db_helper.dart';
import 'package:extruck/order/new%20order/cart.dart';
import 'package:extruck/session/session_timer.dart';
import 'package:extruck/values/userdata.dart';
import 'package:extruck/widgets/snackbar.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
// import 'package:flutter/src/foundation/key.dart';
// import 'package:flutter/src/widgets/framework.dart';

class SelectCustomer extends StatefulWidget {
  const SelectCustomer({Key? key}) : super(key: key);

  @override
  State<SelectCustomer> createState() => _SelectCustomerState();
}

class _SelectCustomerState extends State<SelectCustomer> {
  String _searchController = "";
  List _list = [];

  final db = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    // loadUserAccess();
    loadCustomers();
    // _getColor();
  }

  loadCustomers() async {
    var getC = await db.viewAllCustomers();
    if (!mounted) return null;
    setState(() {
      _list = json.decode(json.encode(getC));
    });
  }

  searchCustomers() async {
    var getC = await db.customerSearch(_searchController);
    setState(() {
      _list = json.decode(json.encode(getC));
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
              const Text(
                'Select Customer',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            searchCont(context),
            Expanded(
              child: listViewCont(context),
            ),
          ],
        ),
      ),
    );
  }

  Container listViewCont(BuildContext context) {
    if (_list.isEmpty) {
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
            Text(
              'No customer found.',
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
          padding: const EdgeInsets.only(left: 10, right: 10),
          width: MediaQuery.of(context).size.width,
          color: Colors.transparent,
          child: ListView.builder(
              itemCount: _list.length,
              itemBuilder: ((context, index) {
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        CustomerData.accountName =
                            _list[index]['location_name'];
                        CustomerData.accountCode = _list[index]['account_code'];
                        CustomerData.city = _list[index]['address3'];
                        CustomerData.province = _list[index]['address1'];

                        Navigator.push(
                                context,
                                PageTransition(
                                    // duration: const Duration(milliseconds: 100),
                                    type: PageTransitionType.rightToLeft,
                                    child: const MyCart()))
                            .then((value) {
                          if (CartData.list.isNotEmpty) {
                            // print('DELETING CART');
                            for (var element in CartData.list) {
                              db.addInventory(
                                  UserData.id,
                                  element['item_code'],
                                  element['item_desc'],
                                  element['item_uom'],
                                  element['item_qty']);
                              db.deleteItem(
                                  UserData.id,
                                  CustomerData.accountCode,
                                  element['item_code'].toString(),
                                  element['item_uom'].toString());
                            }
                            showGlobalSnackbar(
                                'Information',
                                'Items returned to inventory.',
                                Colors.blue,
                                Colors.white);
                          } else {
                            // print('EMPTY CART');
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        width: MediaQuery.of(context).size.width,
                        height: 80,
                        color: Colors.white,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _list[index]['location_name'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 14),
                            ),
                            Text(
                              '${_list[index]['address3']}, ${_list[index]['address1']}',
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    )
                  ],
                );
              })));
    }
  }

  Container searchCont(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      color: Colors.white,
      child: Form(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    // width: MediaQuery.of(context).size.width - 130,
                    width: MediaQuery.of(context).size.width,
                    height: 40,
                    child: TextFormField(
                      // controller: searchController,
                      onChanged: (String str) {
                        setState(() {
                          _searchController = str;
                          searchCustomers();
                        });
                      },
                      decoration: const InputDecoration(
                          contentPadding:
                              EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black87),
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                          hintText: 'Search Customer'),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
