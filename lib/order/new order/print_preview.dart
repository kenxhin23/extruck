import 'dart:typed_data';

import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:extruck/session/session_timer.dart';
// import 'package:extruck/values/assets.dart';
import 'package:extruck/values/userdata.dart';
import 'package:extruck/widgets/buttons.dart';
import 'package:extruck/widgets/dialogs.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'package:intl/intl.dart';
// import 'package:flutter/src/foundation/key.dart';
// import 'package:flutter/src/widgets/framework.dart';

class PrintPreview extends StatefulWidget {
  final List data;
  final String ordNo;

  // const PrintPreview({Key? key}) : super(key: key);
  // ignore: use_key_in_widget_constructors
  const PrintPreview(this.data, this.ordNo);

  @override
  State<PrintPreview> createState() => _PrintPreviewState();
}

class _PrintPreviewState extends State<PrintPreview> {
  String? nDate;
  String vat = '';
  double totalSales = 0.00;

  final date = DateTime.parse(DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()));

  final formatCurrencyAmt = NumberFormat.currency(locale: "en_US", symbol: "");
  final formatCurrencyTot = NumberFormat.currency(locale: "en_US", symbol: "Php ");

  @override
  void initState() {
    super.initState();
    getVat();
  }

  getVat() async {
    // print(CartData.totalAmount);

    totalSales = double.parse(CartData.netAmount) / 1.12;
    vat = (totalSales * .12).toString();
    // print('TOTAL SALES: ${totalSales}');
    // print('VAT: ${vat}');

    nDate = DateFormat("dd/MM/yyyy HH:mm:ss").format(date);
  }

  Future<void> printTicket() async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      PrinterData.connected = true;
      // List<int> bytes = await getTicket();
      // ignore: unused_local_variable
      // final result = await BluetoothThermalPrinter.writeBytes(bytes);
      // print("Print $result");

      String top =

        "~CT~~CD,~CC^~CT~"
        "^XA^LL130~TA000~JSN^LT0^MNN^MTD^POI^PMN^LH0,0^JMA^PR4,4~SD13^JUS^LRN^CI0^XZ"

        "^XA"
        "^DFE:TEMPLATE.ZPL^FS"
        "^CF0,23"
        "^FO20,50^FDDATE : ^FS"
        "^FO110,50^FN1^FS"
        "^XZ"

        "^XA"
        "^XFE:TEMPLATE.ZPL^FS"
        "^FN1^FD${nDate.toString()}^FS"
        "^PQ1"
        "^FO20,70^FDAccount Code :^FS"
        "^FO200,70^FD${CustomerData.accountCode}^FS"
        "^FO20,90^FDAccount Name : ^FS"
        "^FO200,90^FD${CustomerData.accountName}^FS"
        "^FO20,110^FDSalesman : ^FS"
        "^FO200,110^FD${UserData.firstname} ${UserData.lastname}^FS"
        "^XZ"
      ;
      await BluetoothThermalPrinter.writeText(top);

      String desc =

        "~CT~~CD,~CC^~CT~"
        "^XA^LL50~TA000~JSN^LT0^MNN^MTD^POI^PMN^LH0,0^JMA^PR4,4~SD13^JUS^LRN^CI0^XZ"

        "^XA"
        "^FO20,5^GB530,3,3^FS"
        "^CF0,24"
        "^FO20,15^FDDESCRIPTION^FS"
        "^FO460,15^FDAMOUNT^FS"
        "^FO20,40^GB530,3,3^FS"
        "^XZ"
      ;

      await BluetoothThermalPrinter.writeText(desc);

      for (var i = 0; i < widget.data.length; i++){
          String items =

            "~CT~~CD,~CC^~CT~"
            "^XA^LL60~TA000~JSN^LT0^MNN^MTD^POI^PMN^LH0,0^JMA^PR4,4~SD13^JUS^LRN^CI0^XZ"

            "^XA"
            "^CFA,14"
            "^FO20,5^FB450,15,3,L^FD${widget.data[i]['item_desc']}^FS"
            "^FO20,25^FB450,15,3,L^FD${widget.data[i]['item_qty']} ${widget.data[i]['item_uom']} @ ${widget.data[i]['item_amt']}^FS"
            "^FO470,5^FD${widget.data[i]['item_total']}^FS"

            "^XZ"
          ;

          await BluetoothThermalPrinter.writeText(items);
      }

      String bottom =

        "~CT~~CD,~CC^~CT~"
        "^XA^LL550~TA000~JSN^LT0^MNN^MTD^POI^PMN^LH0,0^JMA^PR4,4~SD13^JUS^LRN^CI0^XZ"

        "^XA"

        "^FO20,5^GB530,3,3^FS"
        "^CF0,20"
        "^FO20,25^FDTotal :^FS"
        "^FO470,25^FD${formatCurrencyAmt.format(double.parse(CartData.totalAmount))}^FS"
        "^FO20,45^FDNo. of Items :^FS"
        "^FO470,45^FD${CartData.itmNo}^FS"
        "^FO20,65^FDNo. of Lines :^FS"
        "^FO470,65^FD${CartData.itmLineNo}^FS"
        "^FO20,85^FDVat Amount :^FS"
        "^FO470,85^FD${formatCurrencyAmt.format(double.parse(vat))}^FS"
        "^FO20,105^FDTotal Sales :^FS"
        "^FO470,105^FD${formatCurrencyAmt.format(totalSales)}^FS"
        "^FO20,125^FDTotal Discounted Amount :^FS"
        "^FO470,125^FD${formatCurrencyAmt.format(double.parse(CartData.discAmt))}^FS"
        "^FO20,145^FDTotal Amount Due :^FS"
        "^FO470,145^FD${formatCurrencyAmt.format(double.parse(CartData.netAmount))}^FS"
        "^FO20,165^FDSales Invoice # :^FS"
        "^FO470,165^FD${ CartData.siNum}^FS"


        "^FO20,185^GB530,3,3^FS"

        "^CF0,19"
        "^FO200,195^FDNO RETURNABLES/REFUND^FS"
        "^FO20,240^FDReceived by:^FS"
        "^FO150,255^GB350,2,2^FS"
        "^FO200,260^FD(Signature over Printed Name)^FS"
        "^FO210,245^BY4,2.0,60^BQN,2,7^FDQA,${widget.ordNo}^FS"
        "^FO210,490^FD${widget.ordNo}^FS"
        "^XZ"
      ;

      await BluetoothThermalPrinter.writeText(bottom);

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
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
      PosColumn(
        text: 'DATE:',
        width: 2,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
      PosColumn(
        text: nDate.toString(),
        width: 5,
        styles: const PosStyles(
          align: PosAlign.right,
        ),
      ),
    ]);

    bytes += generator.hr(ch: ' ');
    bytes += generator.text('Account Code : ${CustomerData.accountCode}',
      styles: const PosStyles(align: PosAlign.left),
    );
    bytes += generator.text('Account Name : ${CustomerData.accountName}',
      styles: const PosStyles(align: PosAlign.left),
    );
    bytes += generator.text(
      'Salesman   : ${UserData.firstname} ${UserData.lastname}',
      styles: const PosStyles(align: PosAlign.left),
    );
    bytes += generator.hr(ch: ' ');
    bytes += generator.row([
      PosColumn(
        text: '',
        width: 1,
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ),
      PosColumn(
        text: 'DESCRIPTION',
        width: 7,
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ),
      PosColumn(
        text: '',
        width: 1,
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ),
      PosColumn(
        text: 'AMOUNT',
        width: 3,
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ),
    ]);

    for (var i = 0; i < widget.data.length; i++) {
      bytes += generator.text('${widget.data[i]['item_desc']}',
        styles: const PosStyles(align: PosAlign.left),
      );
      bytes += generator.row([
        // PosColumn(text: ' ', width: 1),
        PosColumn(
          text: '${widget.data[i]['item_qty']}',
          width: 1,
          styles: const PosStyles(
            align: PosAlign.left,
          ),
        ),
        PosColumn(
          text: '${widget.data[i]['item_uom']}',
          width: 2,
          styles: const PosStyles(
            align: PosAlign.left,
          ),
        ),
        PosColumn(
          text: '@',
          width: 1,
          styles: const PosStyles(
            align: PosAlign.center,
          ),
        ),
        PosColumn(
          text: '${widget.data[i]['item_amt']}',
          width: 2,
          styles: const PosStyles(
            align: PosAlign.center,
          ),
        ),
        PosColumn(
          text: ' ',
          width: 3,
          styles: const PosStyles(align: PosAlign.center),
        ),
        PosColumn(
          text: '${widget.data[i]['item_total']}',
          width: 3,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }
    bytes += generator.hr(ch: ' ');
    bytes += generator.row([
      PosColumn(
        text: 'TOTAL',
        width: 3,
        styles: const PosStyles(
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: formatCurrencyAmt.format(double.parse(CartData.totalAmount)),
        width: 9,
        styles: const PosStyles(
          align: PosAlign.right,
        ),
      ),
    ]);
    bytes += generator.hr(ch: ' ');
    bytes += generator.text('  No. of Items   :      ${CartData.itmNo}',
      styles: const PosStyles(align: PosAlign.left),
    );
    bytes += generator.text('  No. of Lines   :      ${CartData.itmLineNo}',
      styles: const PosStyles(align: PosAlign.left),
    );
    bytes += generator.row([
      PosColumn(
        text: 'Vat Amount',
        width: 3,
        styles: const PosStyles(
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: formatCurrencyAmt.format(double.parse(vat)),
        width: 9,
        styles: const PosStyles(
          align: PosAlign.right,
        ),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Total Sales',
        width: 3,
        styles: const PosStyles(
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: formatCurrencyAmt.format(totalSales),
        width: 9,
        styles: const PosStyles(
          align: PosAlign.right,
        ),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Total Discounted Amount',
        width: 7,
        styles: const PosStyles(
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: formatCurrencyAmt.format(double.parse(CartData.discAmt)),
        width: 5,
        styles: const PosStyles(
          align: PosAlign.right,
        ),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Total Amount Due',
        width: 5,
        styles: const PosStyles(
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: formatCurrencyAmt.format(double.parse(CartData.netAmount)),
        width: 7,
        styles: const PosStyles(
          align: PosAlign.right,
        ),
      ),
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
        ),
      ),
      PosColumn(
        text: CartData.siNum,
        width: 7,
        styles: const PosStyles(
          align: PosAlign.right,
        ),
      ),
    ]);
    bytes += generator.hr(ch: ' ', linesAfter: 1);
    bytes += generator.text('NO RETURNABLES/REFUND',
      styles: const PosStyles(align: PosAlign.center, bold: true),
      linesAfter: 1,
    );
    bytes += generator.hr(ch: ' ');
    bytes += generator.row([
      PosColumn(
        text: 'Received by: ',
        width: 4,
        styles: const PosStyles(
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: '_______________________________',
        width: 8,
        styles: const PosStyles(
          align: PosAlign.right,
        ),
      ),
    ]);
    bytes += generator.text('(Signature over Printed Name)',
      styles: const PosStyles(align: PosAlign.right),
    );
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
          title: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Print Preview',
                    style: TextStyle(
                      color: Colors.grey[800], fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  String msg = 'Are you sure you want to close?';
                  // ignore: use_build_context_synchronously
                  final action = await WarningDialogs.openDialog(
                    context,
                    'Information',
                    msg,
                    false,
                    'OK',
                  );
                  if (action == DialogAction.yes) {
                    GlobalVariables.menuKey = 1;
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        '/menu', (Route<dynamic> route) => false);
                  } else {}
                },
                child: Row(
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    const Text(
                      'CLOSE',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    ),
                    const Icon(
                      Icons.cancel_presentation_rounded,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ],
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
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              const Text('DATE :',
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
                  ),
                ],
              ),
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
                  ),
                ],
              ),
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
                  ),
                ],
              ),
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
                  child: Text('DESCRIPTION',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const Text('AMOUNT',
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
                          Text('${widget.data[index]['item_qty']}'),
                          const SizedBox(width: 10),
                          Text('${widget.data[index]['item_uom']}'),
                          const SizedBox(width: 10),
                          const Text('@'),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text('${widget.data[index]['item_amt']}'),
                            ),
                          ),
                          Text('${widget.data[index]['item_total']}'),
                        ],
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          Row(
            children: [
              const SizedBox(width: 15),
              const Expanded(
                child: Align(
                  alignment: Alignment.centerLeft, child: Text('TOTAL'),
                ),
              ),
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
                  child: Text('Vat Amount'),
                ),
              ),
              Text(formatCurrencyAmt.format(double.parse(vat)))
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 15),
              const Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Total Sales'),
                ),
              ),
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
                  child: Text('Total Discounted Amount'),
                ),
              ),
              Text(formatCurrencyAmt.format(double.parse(CartData.discAmt)))
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 15),
              const Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Net Amount'),
                ),
              ),
              Text(formatCurrencyAmt.format(double.parse(CartData.netAmount)))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            // ignore: prefer_const_constructors
            children: const [Icon(Icons.qr_code)],
          ),
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
                    const Text('PRINT',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
