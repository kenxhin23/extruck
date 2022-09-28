import 'dart:typed_data';

import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:extruck/session/session_timer.dart';
import 'package:extruck/values/userdata.dart';
import 'package:extruck/widgets/buttons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'package:intl/intl.dart';

class ReprintReceipt extends StatefulWidget {
  final List data;
  final String ordNo;

  // const PrintPreview({Key? key}) : super(key: key);
  // ignore: use_key_in_widget_constructors
  const ReprintReceipt(this.data, this.ordNo);

  @override
  State<ReprintReceipt> createState() => _ReprintReceiptState();
}

class _ReprintReceiptState extends State<ReprintReceipt> {
  String? nDate;
  String vat = '';
  double totalSales = 0.00;

  final date =
      DateTime.parse(DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()));

  final formatCurrencyAmt = NumberFormat.currency(locale: "en_US", symbol: "");
  final formatCurrencyTot =
      NumberFormat.currency(locale: "en_US", symbol: "Php ");

  @override
  void initState() {
    super.initState();
    getVat();
  }

  getVat() async {
    totalSales = double.parse(CartData.totalAmount) / 1.12;
    vat = (totalSales * .12).toString();
    nDate = DateFormat("dd/MM/yyyy HH:mm:ss").format(date);
  }

  Future<void> printTicket() async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      PrinterData.connected = true;
      List<int> bytes = await getTicket();
      final result = await BluetoothThermalPrinter.writeBytes(bytes);
      if (kDebugMode) {
        print("Print $result");
      }
    } else {
      //Hadnle Not Connected Senario
      setState(() {
        PrinterData.connected = false;
      });
    }
  }

  Future<List<int>> getTicket() async {
    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    final ByteData data = await rootBundle.load('assets/images/icon_.png');
    final Uint8List byt = data.buffer.asUint8List();
    final Image? image = decodeImage(byt);

    // bytes += generator.image(image!);
    bytes += generator.image(image!);
    // bytes += generator.text('DATE: $date',
    //     styles: const PosStyles(align: PosAlign.right));
    bytes += generator.row([
      PosColumn(
          text: '',
          width: 5,
          styles: const PosStyles(align: PosAlign.right, bold: true)),
      PosColumn(
          text: 'DATE:',
          width: 2,
          styles: const PosStyles(align: PosAlign.right, bold: true)),
      PosColumn(
          text: nDate.toString(),
          width: 5,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);

    bytes += generator.hr(ch: ' ');
    bytes += generator.text('Account Code : ${CustomerData.accountCode}',
        styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text('Account Name : ${CustomerData.accountName}',
        styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text(
        'Salesman   : ${UserData.firstname} ${UserData.lastname}',
        styles: const PosStyles(align: PosAlign.left));
    bytes += generator.hr(ch: ' ');
    bytes += generator.row([
      PosColumn(
          text: '',
          width: 1,
          styles: const PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(
          text: 'DESCRIPTION',
          width: 7,
          styles: const PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(
          text: '',
          width: 1,
          styles: const PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(
          text: 'AMOUNT',
          width: 3,
          styles: const PosStyles(align: PosAlign.center, bold: true)),
    ]);

    for (var i = 0; i < widget.data.length; i++) {
      bytes += generator.text('${widget.data[i]['item_desc']}',
          styles: const PosStyles(align: PosAlign.left));
      bytes += generator.row([
        // PosColumn(text: ' ', width: 1),
        PosColumn(
            text: '${widget.data[i]['qty']}',
            width: 1,
            styles: const PosStyles(
              align: PosAlign.left,
            )),
        PosColumn(
            text: '${widget.data[i]['uom']}',
            width: 2,
            styles: const PosStyles(
              align: PosAlign.left,
            )),
        PosColumn(
            text: '@',
            width: 1,
            styles: const PosStyles(
              align: PosAlign.center,
            )),
        PosColumn(
            text: '${widget.data[i]['amt']}',
            width: 2,
            styles: const PosStyles(
              align: PosAlign.center,
            )),
        PosColumn(
            text: ' ',
            width: 3,
            styles: const PosStyles(align: PosAlign.center)),
        PosColumn(
            text: '${widget.data[i]['tot_amt']}',
            width: 3,
            styles: const PosStyles(align: PosAlign.right)),
      ]);
    }
    bytes += generator.hr(ch: ' ');
    bytes += generator.row([
      PosColumn(
          text: 'TOTAL',
          width: 3,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: formatCurrencyAmt.format(double.parse(CartData.totalAmount)),
          width: 9,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.hr(ch: ' ');
    bytes += generator.text('  No. of Items   :      ${CartData.itmNo}',
        styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text('  No. of Lines   :      ${widget.data.length}',
        styles: const PosStyles(align: PosAlign.left));
    bytes += generator.row([
      PosColumn(
          text: 'Vat Amount',
          width: 3,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: formatCurrencyAmt.format(double.parse(vat)),
          width: 9,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Total Sales',
          width: 3,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: formatCurrencyAmt.format(totalSales),
          width: 9,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Total Discounted Amount',
          width: 7,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: '-',
          width: 5,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Total Amount Due',
          width: 5,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: formatCurrencyAmt.format(double.parse(CartData.totalAmount)),
          width: 7,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);

    bytes += generator.hr(ch: ' ', linesAfter: 1);
    // ticket.feed(2);
    bytes += generator.qrcode(widget.ordNo);

    bytes += generator.row([
      PosColumn(
          text: 'Sales Invoice #',
          width: 5,
          styles: const PosStyles(
            align: PosAlign.center,
          )),
      PosColumn(
          text: CartData.siNum,
          width: 7,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.hr(ch: ' ', linesAfter: 1);
    bytes += generator.text('NO RETURNABLES/REFUND',
        styles: const PosStyles(align: PosAlign.center, bold: true),
        linesAfter: 1);
    bytes += generator.hr(ch: ' ');
    bytes += generator.row([
      PosColumn(
          text: 'Received by: ',
          width: 4,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: '_______________________________',
          width: 8,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.text('(Signature over Printed Name)',
        styles: const PosStyles(align: PosAlign.right));
    bytes += generator.hr(ch: ' ', linesAfter: 1);
    bytes += generator.cut();
    return bytes;
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
            'Print Preview',
            style:
                TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
        ),
        body: Column(
            children: [Expanded(child: bodyCont(context)), printCont(context)]),
      ),
    );
  }

  Container bodyCont(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width,
              child: const Icon(
                Icons.local_grocery_store_outlined,
                color: Colors.black,
                size: 60,
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              const Text(
                'DATE :',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(nDate.toString())
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Column(
            children: [
              Row(
                children: [
                  const Text('Account Code  :  '),
                  Text(
                    CustomerData.accountCode.toString(),
                  )
                ],
              )
            ],
          ),
          Column(
            children: [
              Row(
                children: [
                  const Text('Account Name :  '),
                  Expanded(
                    child: Text(
                      CustomerData.accountName.toString(),
                    ),
                  )
                ],
              )
            ],
          ),
          Column(
            children: [
              Row(
                children: [
                  const Text('Salesman           :  '),
                  Expanded(
                    child: Text(
                      '${UserData.firstname} ${UserData.lastname}',
                    ),
                  )
                ],
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              const Expanded(
                child: Center(
                  child: Text(
                    'DESCRIPTION',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const Text(
                'AMOUNT',
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
          Expanded(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                  itemCount: widget.data.length,
                  itemBuilder: ((context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${widget.data[index]['item_desc']}'),
                        Row(
                          children: [
                            const SizedBox(width: 10),
                            Text('${widget.data[index]['qty']}'),
                            const SizedBox(width: 10),
                            Text('${widget.data[index]['uom']}'),
                            const SizedBox(width: 10),
                            const Text('@'),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child:
                                        Text('${widget.data[index]['amt']}'))),
                            Text('${widget.data[index]['tot_amt']}'),
                          ],
                        )
                      ],
                    );
                  })),
            ),
          ),
          Row(
            children: [
              const SizedBox(width: 15),
              const Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft, child: Text('TOTAL'))),
              Text(formatCurrencyAmt.format(double.parse(CartData.totalAmount)))
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const SizedBox(width: 15),
              const Text('No. of Items   :'),
              const SizedBox(
                width: 40,
              ),
              Text(CartData.itmNo)
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 15),
              const Text('No. of Lines   :'),
              const SizedBox(
                width: 40,
              ),
              Text(CartData.itmLineNo!)
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 15),
              const Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Vat Amount'))),
              Text(formatCurrencyAmt.format(double.parse(vat)))
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 15),
              const Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Total Sales'))),
              Text(formatCurrencyAmt.format(totalSales))
            ],
          ),
          Row(
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              const SizedBox(width: 15),
              const Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Total Discounted Amount'))),
              const Text('-')
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 15),
              const Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Total Amount Due'))),
              Text(formatCurrencyAmt.format(double.parse(CartData.totalAmount)))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            // ignore: prefer_const_constructors
            children: const [Icon(Icons.qr_code)],
          )
        ],
      ),
    );
  }

  Container printCont(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(width: 0.2, color: Colors.black),
        ),
      ),
      width: MediaQuery.of(context).size.width,
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                  style: raisedButtonStyleGreen,
                  onPressed: () async {
                    printTicket();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // ignore: prefer_const_literals_to_create_immutables
                    children: [
                      const Icon(
                        Icons.print,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'PRINT',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
