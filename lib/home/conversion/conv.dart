import 'package:extruck/db/db_helper.dart';
import 'package:extruck/home/conversion/conv_history.dart';
import 'package:extruck/home/conversion/convert_stock.dart';
import 'package:extruck/session/session_timer.dart';
import 'package:extruck/values/userdata.dart';
import 'package:extruck/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class Conversion extends StatefulWidget {
  const Conversion({Key? key}) : super(key: key);

  @override
  State<Conversion> createState() => _ConversionState();
}

class _ConversionState extends State<Conversion> {
  final db = DatabaseHelper();
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
              const Text('Stock Conversion',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            newOrderCont(context),
            const SizedBox(height: 10),
            pendingCont(context),
          ],
        ),
      ),
    );
  }

  Container newOrderCont(BuildContext context) {
    // ignore: avoid_unnecessary_containers
    return Container(
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft,
            child: const StockConversion())).then((value) {
            if (ConversionData.list.isNotEmpty) {
              for (var element in ConversionData.list) {
                db.addInventory(
                  UserData.id,
                  element['item_code'],
                  element['item_desc'],
                  element['item_uom'],
                  element['item_qty'],
                );
              }
              db.deleteAllConvItem(UserData.id);
              showGlobalSnackbar('Information', 'Items returned to inventory.',
                Colors.blue, Colors.white);
            }
          });
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 60,
          color: Colors.white,
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 15, right: 15),
                child: Icon(
                  Icons.add_shopping_cart_rounded,
                  color: Colors.grey,
                  size: 24,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    Text('Convert new stocks',
                      style: TextStyle(color: Colors.grey[700], fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              )
            ],
          ),
        ),
      ),
    );
  }

  Container pendingCont(BuildContext context) {
    // ignore: avoid_unnecessary_containers
    return Container(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              PageTransition(
                  // duration: const Duration(milliseconds: 100),
                  type: PageTransitionType.rightToLeft,
                  child: const ConversionHistory()));
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 60,
          color: Colors.white,
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 15, right: 15),
                child: Icon(
                  Icons.pending_actions_outlined,
                  color: Colors.grey,
                  size: 24,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    Text(
                      'View Conversion History',
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              )
            ],
          ),
        ),
      ),
    );
  }
}
