import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:extruck/order/rmt_history/reprint_report.dart';
import 'package:extruck/session/session_timer.dart';
import 'package:extruck/values/colors.dart';
import 'package:extruck/values/userdata.dart';
import 'package:extruck/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class ConnectPrinter extends StatefulWidget {
  final List data;
  final String rmtNo, ordCount, totAmt;

  // ignore: use_key_in_widget_constructors
  const ConnectPrinter(this.data, this.rmtNo, this.ordCount, this.totAmt);

  @override
  State<ConnectPrinter> createState() => _ConnectPrinterState();
}

class _ConnectPrinterState extends State<ConnectPrinter> {
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
      if (!mounted) return;
      setState(() {
        refreshConnection();
        PrinterData.connected = false;
        PrinterData.mac = '';
      });
    }
  }

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
          automaticallyImplyLeading: true,
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
                  child: ListView.builder(
                    itemCount: availableBluetoothDevices.isNotEmpty
                        ? availableBluetoothDevices.length
                        : 0,
                    itemBuilder: (context, index) {
                      bool con = false;
                      if (PrinterData.mac == '') {}
                      return ListTile(
                        onTap: () {
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
                                    child: ReprintReport(
                                        widget.data,
                                        widget.rmtNo,
                                        widget.ordCount,
                                        widget.totAmt)));
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
