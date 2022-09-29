import 'package:extruck/home/conversion/conv.dart';
// import 'package:extruck/home/conversion/convert_stock.dart';
import 'package:extruck/home/inventory/inventory.dart';
import 'package:extruck/home/stock%20request/pending_requests.dart';
import 'package:extruck/home/ledger/stock_ledger.dart';
import 'package:extruck/home/stock%20request/stocks.dart';
import 'package:extruck/providers/pending_counter.dart';
import 'package:extruck/session/session_timer.dart';
import 'package:extruck/values/colors.dart';
// import 'package:extruck/values/userdata.dart';
// import 'package:extruck/widgets/snackbar.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/src/foundation/key.dart';
// import 'package:flutter/src/widgets/framework.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
            toolbarHeight: 85,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Home",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color: ColorsTheme.mainColor,
                      fontSize: 50,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Row(
                children: [
                  inventoryCont(context),
                  stockPageCont(context),
                ],
              ),
              Row(
                children: [
                  // pendingRequestCont(context),
                  convertStockCont(context),
                  stockLedgerCont(context),
                ],
              ),
              // Row(
              //   children: [
              //     // pendingRequestCont(context),
              //     stockLedgerCont(context),
              //   ],
              // ),
            ],
          ),
        ));
  }

  Expanded stockLedgerCont(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              PageTransition(
                  // duration: const Duration(milliseconds: 100),
                  type: PageTransitionType.rightToLeft,
                  child: const StockLedger()));
        },
        child: Container(
          margin: const EdgeInsets.all(2),
          color: Colors.white,
          height: MediaQuery.of(context).size.height / 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              const Icon(
                Icons.swap_vert,
                color: Colors.deepOrange,
                size: 48,
              ),
              const Text(
                'Stock Ledger',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Expanded pendingRequestCont(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              PageTransition(
                  // duration: const Duration(milliseconds: 100),
                  type: PageTransitionType.rightToLeft,
                  child: const PendingRequests()));
        },
        child: Container(
          margin: const EdgeInsets.all(2),
          color: Colors.white,
          height: MediaQuery.of(context).size.height / 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              (int.parse(Provider.of<PendingCounter>(context)
                          .reqNo
                          .toString()) ==
                      0)
                  ? const Icon(
                      Icons.history,
                      color: Colors.deepOrange,
                      size: 48,
                    )
                  : Container(
                      width: 60,
                      // height: 50,
                      color: Colors.transparent,
                      child: Stack(
                        children: [
                          const Icon(Icons.history,
                              color: Colors.deepOrange, size: 48),
                          Padding(
                            padding: const EdgeInsets.only(left: 30),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                // margin: EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.only(top: 5),
                                width: 40,
                                height: 20,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green),
                                child: Text(
                                  Provider.of<PendingCounter>(context)
                                      .reqNo
                                      .toString(),
                                  // '2',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              const Text(
                'Pending Requests',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Expanded convertStockCont(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              PageTransition(
                  // duration: const Duration(milliseconds: 100),
                  type: PageTransitionType.rightToLeft,
                  child: const Conversion()));
        },
        child: Container(
          margin: const EdgeInsets.all(2),
          color: Colors.white,
          height: MediaQuery.of(context).size.height / 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              const Icon(
                Icons.cached_outlined,
                color: Colors.deepOrange,
                size: 48,
              ),
              const Text(
                'Stock Conversion',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Expanded stockPageCont(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              PageTransition(
                  // duration: const Duration(milliseconds: 100),
                  type: PageTransitionType.rightToLeft,
                  child: const StockPage()));
        },
        child: Container(
          margin: const EdgeInsets.all(2),
          color: Colors.white,
          height: MediaQuery.of(context).size.height / 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              const Icon(
                Icons.storage_outlined,
                color: Colors.deepOrange,
                size: 48,
              ),
              const Text(
                'Stocks',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Expanded inventoryCont(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              PageTransition(
                  // duration: const Duration(milliseconds: 100),
                  type: PageTransitionType.rightToLeft,
                  child: const StockInvetory()));
        },
        child: Container(
          margin: const EdgeInsets.all(2),
          color: Colors.white,
          height: MediaQuery.of(context).size.height / 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              const Icon(
                Icons.inventory_rounded,
                color: Colors.deepOrange,
                size: 48,
              ),
              const Text(
                'View Inventory',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
