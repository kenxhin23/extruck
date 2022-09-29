import 'package:extruck/home/stock%20request/pending_requests.dart';
import 'package:extruck/home/stock%20request/request_history.dart';
import 'package:extruck/home/stock%20request/stock_request.dart';
import 'package:extruck/order/history/order_history.dart';
import 'package:extruck/providers/pending_counter.dart';
// import 'package:extruck/order/new%20order/customer.dart';
// import 'package:extruck/order/pending%20order/pending_order.dart';
// import 'package:extruck/order/rmt_history/rmt_history.dart';
import 'package:extruck/session/session_timer.dart';
import 'package:extruck/values/userdata.dart';
import 'package:extruck/widgets/snackbar.dart';
// import 'package:extruck/values/colors.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class StockPage extends StatefulWidget {
  const StockPage({Key? key}) : super(key: key);

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
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
                  'Stocks',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              newRequestCont(context),
              const SizedBox(height: 10),
              pendingCont(context),
              const SizedBox(height: 10),
              requestHistory(context),
              const SizedBox(height: 10),
              transferCont(context),
              // const SizedBox(height: 20),
              // boReportCont(context),
              // const SizedBox(height: 10),
              // changePriceCont(context),
            ],
          ),
        ));
  }

  Container newRequestCont(BuildContext context) {
    // ignore: avoid_unnecessary_containers
    return Container(
      child: GestureDetector(
        onTap: () {
          print(NetworkData.connected);
          if (!NetworkData.connected) {
            showGlobalSnackbar('Connectivity', 'Please connect to internet.',
                Colors.black, Colors.white);
          } else {
            Navigator.push(
                context,
                PageTransition(
                    // duration: const Duration(milliseconds: 100),
                    type: PageTransitionType.rightToLeft,
                    child: const StockRequest()));
          }
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
                  Icons.playlist_add,
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
                      'Create new request',
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
                  child: const PendingRequests()));
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
                      'Pending Requests',
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
              (int.parse(Provider.of<PendingCounter>(context)
                          .reqNo
                          .toString()) ==
                      0)
                  ? const SizedBox()
                  : Container(
                      // margin: EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.only(top: 5),
                      width: 45,
                      height: 25,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.green),
                      child: Text(
                        Provider.of<PendingCounter>(context).reqNo.toString(),
                        // '2',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
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

  Container requestHistory(BuildContext context) {
    // ignore: avoid_unnecessary_containers
    return Container(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              PageTransition(
                  // duration: const Duration(milliseconds: 100),
                  type: PageTransitionType.rightToLeft,
                  child: const RequestHistory()));
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
                  Icons.history,
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
                      'Request History',
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

  Container transferCont(BuildContext context) {
    // ignore: avoid_unnecessary_containers
    return Container(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              PageTransition(
                  // duration: const Duration(milliseconds: 100),
                  type: PageTransitionType.rightToLeft,
                  child: const OrderHistory()));
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
                  Icons.send_to_mobile,
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
                      'Transfer',
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

  Container boReportCont(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 60,
      color: Colors.white,
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 15, right: 15),
            child: Icon(
              Icons.production_quantity_limits_rounded,
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
                  'View BO Reports',
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
    );
  }

  Container changePriceCont(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 60,
      color: Colors.white,
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 15, right: 15),
            child: Icon(
              Icons.published_with_changes_rounded,
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
                  'Change Price Reports',
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
    );
  }
}
