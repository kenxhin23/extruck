import 'dart:convert';

import 'package:extruck/db/db_helper.dart';
import 'package:extruck/session/session_timer.dart';
import 'package:flutter/material.dart';

class ChequeDetails extends StatefulWidget {
  final String ordNo;

  // const PrintPreview({Key? key}) : super(key: key);
  // ignore: use_key_in_widget_constructors
  const ChequeDetails(this.ordNo);

  @override
  State<ChequeDetails> createState() => _ChequeDetailsState();
}

class _ChequeDetailsState extends State<ChequeDetails> {
  List list = [];
  String accountName = '';
  String accountNo = '';
  String bankName = '';
  String chequeNum = '';
  String chequeDate = '';
  String chequeType = '';

  final db = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    // getCashLedger();
    getChequeDetails();
  }

  getChequeDetails() async {
    var rsp = await db.getChequeDetails(widget.ordNo);
    setState(() {
      list = json.decode(json.encode(rsp));
      accountName = list[0]['account_name'];
      accountNo = list[0]['account_no'];
      bankName = list[0]['bank_name'];
      chequeNum = list[0]['cheque_no'];
      chequeDate = list[0]['cheque_date'];
      chequeType = list[0]['cheque_type'];
      // print(accountName);
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
          automaticallyImplyLeading: true,
          backgroundColor: Colors.white,
          title: Text(
            "#${widget.ordNo}",
            style: const TextStyle(color: Colors.black, fontSize: 12),
          ),
        ),
        body: Column(
          children: [
            chequeIcon(context),
            chequeDetailsCont(context),
          ],
        ),
      ),
    );
  }

  Container chequeIcon(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.transparent,
      height: 30,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 15),
            child: const Icon(
              Icons.fact_check_outlined,
              color: Colors.deepOrange,
              size: 24,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Text('Cheque Details',
            style: TextStyle(color: Colors.grey[800], fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Column chequeDetailsCont(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 15, right: 15),
          width: MediaQuery.of(context).size.width,
          height: 90,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Account Name',
                style: TextStyle(fontWeight: FontWeight.w400, color: Colors.grey[500]),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(accountName,
                style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.only(left: 15, right: 15),
          width: MediaQuery.of(context).size.width,
          height: 90,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Account No.',
                style: TextStyle(fontWeight: FontWeight.w400, color: Colors.grey[500]),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(accountNo,
                style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.only(left: 15, right: 15),
          width: MediaQuery.of(context).size.width,
          height: 80,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bank Name',
                style: TextStyle(fontWeight: FontWeight.w400, color: Colors.grey[500]),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(bankName,
                style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.only(left: 15, right: 15),
          width: MediaQuery.of(context).size.width,
          height: 90,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cheque No.',
                style: TextStyle(fontWeight: FontWeight.w400, color: Colors.grey[500]),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(chequeNum,
                style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.only(left: 15, right: 15),
          width: MediaQuery.of(context).size.width,
          height: 90,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cheque Date',
                style: TextStyle(fontWeight: FontWeight.w400, color: Colors.grey[500]),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(chequeDate,
                style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.only(left: 15, right: 15),
          width: MediaQuery.of(context).size.width,
          height: 80,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cheque Type',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.grey[500]),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(chequeType,
                style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
      ],
    );
  }
}
