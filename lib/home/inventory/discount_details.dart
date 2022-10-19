import 'dart:convert';

import 'package:extruck/db/db_helper.dart';
import 'package:extruck/values/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DiscountDetails extends StatefulWidget {
  final String principal;
  // ignore: use_key_in_widget_constructors
  const DiscountDetails(this.principal);
  // const DiscountDetails({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DiscountDetailsState createState() => _DiscountDetailsState();
}

class _DiscountDetailsState extends State<DiscountDetails> {
  List _list = [];

  final db = DatabaseHelper();

  final formatCurrencyAmt = NumberFormat.currency(locale: "en_US", symbol: "₱");

  @override
  void initState() {
    super.initState();
    getDiscountDetails();
  }

  getDiscountDetails() async {
    var rsp = await db.getDiscountDetails(widget.principal);
    setState(() {
      _list = json.decode(json.encode(rsp));
      _list.forEach((element) {
        double disc = 0;
        // double amt1 = 0;
        // double amt2 = 0;
        disc = double.parse(element['discount']) * 100;
        element['discount'] = disc.toStringAsFixed(0);
        // amt1 = double.parse(element['range_from']);
        // element['range_from'] = amt1.toStringAsFixed(0);
        // amt2 = double.parse(element['range_to']);
        // element['range_to'] = amt2.toStringAsFixed(0);
      });
      print(_list);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 15, bottom: 10),
      // color: Colors.white,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.principal,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.w500, color: ColorsTheme.mainColor),
          ),
          listViewCont()
        ],
      ),
    );
  }

  Container listViewCont() {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      width: MediaQuery.of(context).size.width,
      height: 100,
      child: ListView.builder(
          itemCount: _list.length,
          itemBuilder: ((context, index) {
            double abAmt = 99999.00;
            bool above = false;

            if (double.parse(_list[index]['range_to']) >= abAmt) {
              above = true;
            } else {
              above = false;
            }

            return Column(
              children: [
                Container(
                  // color: Colors.grey,
                  // height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        'Buy worth ',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w400),
                      ),
                      Text(
                        formatCurrencyAmt
                            .format(double.parse(_list[index]['range_from'])),
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                            color: Colors.grey[700]),
                      ),
                      Text(' - '),
                      above
                          ? Text(
                              'above',
                              style: TextStyle(fontSize: 12),
                            )
                          : Text(
                              formatCurrencyAmt.format(
                                  double.parse(_list[index]['range_to'])),
                              style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12,
                                  color: Colors.grey[700]),
                            ),
                      Text(
                        ' enjoy ',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w400),
                      ),
                      Text(
                        '${_list[index]['discount']}%',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: ColorsTheme.mainColor),
                      ),
                      Text(
                        ' discount.',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10)
              ],
            );
          })),
    );
  }
}
