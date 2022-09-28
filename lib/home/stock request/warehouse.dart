import 'package:extruck/session/session_timer.dart';
import 'package:extruck/values/colors.dart';
import 'package:extruck/values/userdata.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/src/foundation/key.dart';
// import 'package:flutter/src/widgets/framework.dart';

enum WarehouseName { none, cdc, udc, talibon, tubigon, jagna }

class WarehousePage extends StatefulWidget {
  const WarehousePage({Key? key}) : super(key: key);

  @override
  State<WarehousePage> createState() => _WarehousePageState();
}

class _WarehousePageState extends State<WarehousePage> {
  WarehouseName? _warehouse = WarehouseName.none;
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
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(
            color: Colors.black, //change your color here
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Select a warehouse',
                  style: TextStyle(fontSize: 14, color: ColorsTheme.mainColor),
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 15),
                    child: const Icon(
                      Icons.warehouse_rounded,
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Distribution Center',
                    style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            ListTile(
              title: const Text('Central DC (Cortes)'),
              leading: Radio<WarehouseName>(
                value: WarehouseName.cdc,
                groupValue: _warehouse,
                onChanged: (WarehouseName? value) {
                  setState(() {
                    _warehouse = value;
                    CartData.warehouse = 'Central DC (Cortes)';
                    CartData.pMeth = 'RF';
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Ubay DC'),
              leading: Radio<WarehouseName>(
                value: WarehouseName.udc,
                groupValue: _warehouse,
                onChanged: (WarehouseName? value) {
                  setState(() {
                    _warehouse = value;
                    CartData.warehouse = 'Ubay DC';
                    CartData.pMeth = 'RF';
                  });
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 15),
                    child: const Icon(
                      Icons.cell_tower_rounded,
                      color: Colors.green,
                      size: 24,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Satellite Warehouses',
                    style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            ListTile(
              title: const Text('Tubigon'),
              leading: Radio<WarehouseName>(
                value: WarehouseName.tubigon,
                groupValue: _warehouse,
                onChanged: (WarehouseName? value) {
                  setState(() {
                    _warehouse = value;
                    CartData.warehouse = 'Tubigon';
                    CartData.pMeth = 'Cash';
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Talibon'),
              leading: Radio<WarehouseName>(
                value: WarehouseName.talibon,
                groupValue: _warehouse,
                onChanged: (WarehouseName? value) {
                  setState(() {
                    _warehouse = value;
                    CartData.warehouse = 'Talibon';
                    CartData.pMeth = 'Cash';
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Jagna'),
              leading: Radio<WarehouseName>(
                value: WarehouseName.jagna,
                groupValue: _warehouse,
                onChanged: (WarehouseName? value) {
                  setState(() {
                    _warehouse = value;
                    CartData.warehouse = 'Jagna';
                    CartData.pMeth = 'Cash';
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
