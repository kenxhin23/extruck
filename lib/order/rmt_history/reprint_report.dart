import 'dart:typed_data';
import 'dart:convert';
import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:extruck/session/session_timer.dart';
import 'package:extruck/values/userdata.dart';
import 'package:extruck/widgets/buttons.dart';
import 'package:extruck/widgets/dialogs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'package:intl/intl.dart';

class ReprintReport extends StatefulWidget {
  final List data;

  final String rmtNo, boAmt, ordCount, totAmt, totDisc, satWh, totNet;

  // const PrintPreview({Key? key}) : super(key: key);
  // ignore: use_key_in_widget_constructors
  const ReprintReport(this.data, this.rmtNo, this.boAmt, this.ordCount,
      this.totAmt, this.totDisc, this.satWh, this.totNet);

  @override
  State<ReprintReport> createState() => _ReprintReportState();
}

class _ReprintReportState extends State<ReprintReport> {
  String? nDate;
  String vat = '';
  double netAmount = 0.00;
  double totalSales = 0.00;
  bool viewBo = false;

  final date = DateTime.parse(DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()));

  final formatCurrencyAmt = NumberFormat.currency(locale: "en_US", symbol: "");
  final formatCurrencyTot = NumberFormat.currency(locale: "en_US", symbol: "Php ");

  @override
  void initState() {
    super.initState();
    getVat();
  }

  getVat() async {
    totalSales = double.parse(CartData.totalAmount) / 1.12;
    vat = (totalSales * .12).toString();
    nDate = DateFormat("dd/MM/yyyy HH:mm:ss").format(date);
    netAmount = double.parse(widget.totNet) - double.parse(widget.boAmt);
  }

  Future<void> printTicket() async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      PrinterData.connected = true;
      // List<int> bytes = await getTicket();
      //
      // final result = await BluetoothThermalPrinter.writeBytes(bytes);

      String top =

        "~CT~~CD,~CC^~CT~"
        "^XA^LL110~TA000~JSN^LT0^MNN^MTD^POI^PMN^LH0,0^JMA^PR4,4~SD13^JUS^LRN^CI0^XZ"

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
        "^FO20,70^FDRemittance No. :^FS"
        "^FO200,70^FD${widget.rmtNo}^FS"
        "^FO20,90^FDSalesman         : ^FS"
        "^FO200,90^FD${UserData.firstname} ${UserData.lastname}^FS"
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
        if (widget.data[i]['tran_type'] == 'BO') {
          viewBo = true;
          print('BO TRUE');
          String items =

            "~CT~~CD,~CC^~CT~"
            "^XA^LL60~TA000~JSN^LT0^MNN^MTD^POI^PMN^LH0,0^JMA^PR4,4~SD13^JUS^LRN^CI0^XZ"

            "^XA"
            "^CFA,14"
            "^FO20,5^FB450,15,3,L^FDSI #${widget.data[i]['si_no']} - #${widget.data[i]['order_no']}^FS"
            "^FO20,25^FB450,15,3,L^FD${widget.data[i]['store_name']} (Bo Refund) @ ${widget.data[i]['item_count']}^FS"
            "^FO470,5^FD${widget.data[i]['net_amt']}^FS"

            "^XZ"
          ;

          await BluetoothThermalPrinter.writeText(items);
        } else {
          viewBo = false;
          print('BO FALSE');
          String items =

            "~CT~~CD,~CC^~CT~"
            "^XA^LL60~TA000~JSN^LT0^MNN^MTD^POI^PMN^LH0,0^JMA^PR4,4~SD13^JUS^LRN^CI0^XZ"

            "^XA"
            "^CFA,14"
            "^FO20,5^FB450,15,3,L^FDSI #${widget.data[i]['si_no']} - #${widget.data[i]['order_no']}^FS"
            "^FO20,25^FB450,15,3,L^FD${widget.data[i]['store_name']} (${widget.data[i]['pmeth_type']}) @ ${widget.data[i]['item_count']}^FS"
            "^FO470,5^FD${widget.data[i]['net_amt']}^FS"

            "^XZ"
          ;

          await BluetoothThermalPrinter.writeText(items);
        }
      }

      String bottom =

        "~CT~~CD,~CC^~CT~"
        "^XA^LL550~TA000~JSN^LT0^MNN^MTD^POI^PMN^LH0,0^JMA^PR4,4~SD13^JUS^LRN^CI0^XZ"

        "^XA"

        "^FO20,5^GB530,3,3^FS"
        "^CF0,20"
        "^FO20,25^FDOrder Amount Total :^FS"
        "^FO470,25^FD${formatCurrencyAmt.format(double.parse(widget.totAmt))}^FS"
        "^FO20,45^FDDiscount Total :^FS"
        "^FO470,45^FD${formatCurrencyAmt.format(double.parse(widget.totDisc))}^FS"
        "^FO20,65^FDBOAmount Total :^FS"
        "^FO470,65^FD${formatCurrencyAmt.format(double.parse(widget.boAmt))}^FS"
        "^FO20,85^FDSatellite Warehouse Request :^FS"
        "^FO470,85^FD${formatCurrencyAmt.format(double.parse(widget.satWh))}^FS"
        "^FO20,105^FDNo. of Orders :^FS"
        "^FO470,105^FD${widget.ordCount}^FS"
        "^FO20,125^FDTotal Sales Amount :^FS"
        "^FO470,125^FD${formatCurrencyAmt.format(netAmount)}^FS"
        "^FO20,150^GB530,3,3^FS"

        "^CF0,19"
        "^FO200,165^FDNO RETURNABLES/REFUND^FS"
        "^FO20,220^FDReceived by:^FS"
        "^FO150,235^GB350,2,2^FS"
        "^FO200,245^FD(Signature over Printed Name)^FS"
        "^FO210,245^BY4,2.0,60^BQN,2,7^FDQA,${widget.rmtNo}^FS"
        "^FO210,490^FD${widget.rmtNo}^FS"
        "^XZ"
      ;

      await BluetoothThermalPrinter.writeText(bottom);


      if (kDebugMode) {
        // print("Print $result");
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

    bytes += generator.image(image!);
    // bytes += generator.image(image!);
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
    bytes += generator.text('Remittance No : ${widget.rmtNo}',
      styles: const PosStyles(align: PosAlign.left),
    );
    bytes += generator.text('Salesman   : ${UserData.firstname} ${UserData.lastname}',
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
      if (widget.data[i]['tran_type'] == 'BO') {
        viewBo = true;
        print('BO TRUE');
      } else {
        viewBo = false;
        print('BO FALSE');
      }
      bytes += generator.text(
        'SI #${widget.data[i]['si_no']} - #${widget.data[i]['order_no']}',
        styles: const PosStyles(align: PosAlign.left),
      );
      bytes += generator.row([
        // PosColumn(text: ' ', width: 1),
        viewBo
      ? PosColumn(
          text: '${widget.data[i]['store_name']}',
          width: 4,
          styles: const PosStyles(
            align: PosAlign.left,
          ),
        )
      : PosColumn(
          text: '${widget.data[i]['store_name']}',
          width: 5,
          styles: const PosStyles(
            align: PosAlign.left,
          ),
        ),
        viewBo
      ? PosColumn(
          text: '(Bo Refund)',
          width: 3,
          styles: const PosStyles(
            align: PosAlign.center,
          ))
      : PosColumn(
          text: '(${widget.data[i]['pmeth_type']})',
          width: 2,
          styles: const PosStyles(
            align: PosAlign.center,
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
          text: '${widget.data[i]['item_count']}',
          width: 1,
          styles: const PosStyles(
            align: PosAlign.center,
          ),
        ),
        PosColumn(
          text: '${widget.data[i]['net_amt']}',
          width: 3,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }
    bytes += generator.hr(ch: ' ');
    bytes += generator.row([
      PosColumn(
        text: 'Order Amount Total',
        width: 6,
        styles: const PosStyles(
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: formatCurrencyAmt.format(double.parse(widget.totAmt)),
        width: 6,
        styles: const PosStyles(
          align: PosAlign.right,
        ),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Discount Total',
        width: 7,
        styles: const PosStyles(
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: formatCurrencyAmt.format(double.parse(widget.totDisc)),
        width: 5,
        styles: const PosStyles(
          align: PosAlign.right,
        ),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'BO Amount Total',
        width: 7,
        styles: const PosStyles(
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: formatCurrencyAmt.format(double.parse(widget.boAmt)),
        width: 5,
        styles: const PosStyles(
          align: PosAlign.right,
        ),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Satellite Warehouse Request',
        width: 8,
        styles: const PosStyles(
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: formatCurrencyAmt.format(double.parse(widget.satWh)),
        width: 4,
        styles: const PosStyles(
          align: PosAlign.right,
        ),
      ),
    ]);
    bytes += generator.text('  No. of Orders  :      ${widget.ordCount}',
      styles: const PosStyles(align: PosAlign.left));

    bytes += generator.row([
      PosColumn(
        text: 'Total Sales Amount',
        width: 5,
        styles: const PosStyles(
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: formatCurrencyAmt.format(netAmount),
        width: 7,
        styles: const PosStyles(
          align: PosAlign.right,
        ),
      ),
    ]);

    bytes += generator.hr(ch: ' ', linesAfter: 1);
    // ticket.feed(2);
    bytes += generator.qrcode(widget.rmtNo);

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


    print(widget.rmtNo);
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
                    const Text('CLOSE',
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
                    )
                  ],
                ),
              ),
            ],
          ),
          centerTitle: false,
        ),
        body: Column(
          children: [
            Expanded(child: bodyCont(context)),
            printCont(context)
          ],
        ),
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
                  const Text('Remittance No. :  '),
                  Text(widget.rmtNo,
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
                  child: Text('DESCRIPTION',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const Text('AMOUNT',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Expanded(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                itemCount: widget.data.length,
                itemBuilder: ((context, index) {
                  if (widget.data[index]['tran_type'] == 'BO') {
                    viewBo = true;
                  } else {
                    viewBo = false;
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('SI # ${widget.data[index]['si_no']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text('- ${widget.data[index]['order_no']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2,
                            child: Text(
                              '${widget.data[index]['store_name']}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10),
                          viewBo
                        ? const Text('(BO Refund)')
                        : Text('(${widget.data[index]['pmeth_type']})'),
                          const SizedBox(width: 10),
                          const Text('@'),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text('${widget.data[index]['item_count']}',
                              ),
                            ),
                          ),
                          Text('${widget.data[index]['net_amt']}'),
                        ],
                      )
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
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Order Amount Total',
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                ),
              ),
              Text(formatCurrencyAmt.format(double.parse(widget.totAmt)),
                style: const TextStyle(fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 15),
              const Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Discount Total',
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                ),
              ),
              Text(formatCurrencyAmt.format(double.parse(widget.totDisc)),
                style: const TextStyle(fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 15),
              const Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'BO Amount Total',
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                ),
              ),
              Text(formatCurrencyAmt.format(double.parse(widget.boAmt)),
                style: const TextStyle(fontWeight: FontWeight.w400,
                ),
              )
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 15),
              const Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Satellite Warehouse Request',
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                ),
              ),
              Text(formatCurrencyAmt.format(double.parse(widget.satWh)),
                style: const TextStyle(fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          // const SizedBox(height: 5),
          Row(
            children: [
              const SizedBox(width: 15),
              const Text('No. of Orders   :'),
              const SizedBox(
                width: 40,
              ),
              Text(widget.ordCount)
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 15),
              const Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Total Sales Amount',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Text(formatCurrencyAmt.format(netAmount),
                style: const TextStyle(fontWeight: FontWeight.bold,
                ),
              ),
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
                    const Text('REPRINT REPORT',
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
