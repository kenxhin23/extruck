// import 'package:bluetooth_print/bluetooth_print.dart';
// import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
// import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:extruck/order/new%20order/print_preview.dart';
import 'package:extruck/values/colors.dart';
import 'package:extruck/values/userdata.dart';
import 'package:extruck/widgets/buttons.dart';
import 'package:extruck/widgets/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class PrintReceipt extends StatefulWidget {
  final List data;
  final String ordNo;

  // ignore: use_key_in_widget_constructors
  const PrintReceipt(this.data, this.ordNo);

  @override
  State<PrintReceipt> createState() => _PrintReceiptState();
}

class _PrintReceiptState extends State<PrintReceipt> {
  // BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  // List<BluetoothDevice> _devices = [];
  final formatCurrencyAmt = NumberFormat.currency(locale: "en_US", symbol: "₱");
  final formatCurrencyTot =
      NumberFormat.currency(locale: "en_US", symbol: "Php ");

  @override
  void initState() {
    super.initState();
    getBluetooth();
    // checkConnected();
    // WidgetsBinding.instance.addPostFrameCallback((_) => {initPrinter()});
  }

  // checkConnected() async {
  //   String? isConnected = await BluetoothThermalPrinter.connectionStatus;
  //   if (isConnected == "true") {
  //     setState(() {
  //       connected = true;
  //     });
  //   }
  // }

  // bool connected = false;
  List availableBluetoothDevices = [];

  Future<void> getBluetooth() async {
    final List? bluetooths = await BluetoothThermalPrinter.getBluetooths;
    // print("Print $bluetooths");
    setState(() {
      availableBluetoothDevices = bluetooths!;
    });
  }

  Future<void> setConnect(String mac) async {
    refreshConnection();
    // final String? rsp = await BluetoothThermalPrinter.connectionStatus;
    final String? result = await BluetoothThermalPrinter.connect(mac);
    // print("state connected $result");
    if (result == "true") {
      setState(() {
        // connected = true;
        PrinterData.connected = true;
        PrinterData.mac = mac;
      });
    } else {
      setState(() {
        refreshConnection();
        PrinterData.connected = false;
        PrinterData.mac = '';
      });
    }
  }

  // Future<void> printGraphics() async {
  //   String? isConnected = await BluetoothThermalPrinter.connectionStatus;
  //   if (isConnected == "true") {
  //     List<int> bytes = await getGraphicsTicket();
  //     final result = await BluetoothThermalPrinter.writeBytes(bytes);
  //     print("Print $result");
  //   } else {
  //     //Hadnle Not Connected Senario
  //   }
  // }

  // Future<List<int>> getGraphicsTicket() async {
  //   List<int> bytes = [];

  //   CapabilityProfile profile = await CapabilityProfile.load();
  //   final generator = Generator(PaperSize.mm80, profile);

  //   // Print QR Code using native function
  //   bytes += generator.qrcode('example.com');

  //   bytes += generator.hr();

  //   // Print Barcode using native function
  //   final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
  //   bytes += generator.barcode(Barcode.upcA(barData));

  //   bytes += generator.cut();

  //   return bytes;
  // }

  Future<void> refreshConnection() async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      setState(() {
        PrinterData.connected = true;
      });
    } else {
      setState(() {
        PrinterData.connected = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              const Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select Printer',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  String msg =
                      'Are you sure you want to skip printing receipt?';
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
                      'SKIP',
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    ),
                    const Icon(
                      Icons.skip_next,
                      color: Colors.white,
                    )
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: ColorsTheme.mainColor,
        ),
        body: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (PrinterData.connected)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    const Text(
                      'Connected',
                      style: TextStyle(
                          fontWeight: FontWeight.w500, color: Colors.green),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.check_circle_outline_outlined,
                      color: Colors.green,
                    )
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    const Text(
                      'No Printer Connected',
                      style: TextStyle(
                          fontWeight: FontWeight.w500, color: Colors.red),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.highlight_off_rounded,
                      color: Colors.red,
                    )
                  ],
                ),
              Expanded(
                child: SizedBox(
                  // height: 200,
                  child: RefreshIndicator(
                    onRefresh: getBluetooth,
                    child: ListView.builder(
                      itemCount: availableBluetoothDevices.isNotEmpty
                          ? availableBluetoothDevices.length
                          : 0,
                      itemBuilder: (context, index) {
                        bool con = false;
                        if (PrinterData.mac == '') {}
                        return ListTile(
                          onTap: () {
                            // print(connected);
                            // print(availableBluetoothDevices[index]);
                            String select = availableBluetoothDevices[index];
                            List list = select.split("#");
                            // String name = list[0];
                            String mac = list[1];
                            // print(mac);
                            setConnect(mac);
                          },
                          leading: const Icon(Icons.print),
                          title: Text('${availableBluetoothDevices[index]}'),
                          subtitle: !con
                              ? const Text('Click to connect')
                          // ignore: dead_code
                              : const Text(
                            'Connected',
                            style: TextStyle(color: Colors.green),
                          ),
                        );
                      },
                    ),
                  ),

                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: ElevatedButton(
                        style: PrinterData.connected
                            ? raisedButtonStyleOrange
                            : raisedButtonStyleGrey,
                        onPressed: () async {
                          if (PrinterData.connected) {
                            Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.rightToLeft,
                                    child: PrintPreview(
                                        CartData.list, widget.ordNo)));
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          // ignore: prefer_const_literals_to_create_immutables
                          children: [
                            const Text(
                              "CONTINUE TO PREVIEW",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
