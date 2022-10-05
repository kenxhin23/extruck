import 'package:extruck/db/db_helper.dart';
import 'package:extruck/providers/sync_caption.dart';
import 'package:extruck/values/userdata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SyncLoadingSpinkit extends StatefulWidget {
  @override
  _SyncLoadingSpinkitState createState() => _SyncLoadingSpinkitState();
}

class _SyncLoadingSpinkitState extends State<SyncLoadingSpinkit>
    with SingleTickerProviderStateMixin {
  AnimationController? animationController;

  final db = DatabaseHelper();

  bool loadSpinkit = false;
  List itemList = [];
  List categList = [];
  List itemImgList = [];
  List customerList = [];
  List discountList = [];
  List bankList = [];
  List accessList = [];
  List salesmanList = [];
  List orderLimitList = [];
  List tranHeadList = [];
  List returnList = [];
  List unsrvlist = [];
  List chequeList = [];
  List linelist = [];
  List hepeList = [];

  final date = DateFormat("yyyy-MM-dd HH:mm:ss").format(new DateTime.now());

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    if (GlobalVariables.updateType == 'Transactions') {
      if (GlobalVariables.fullSync == true) {
        print('NISUD SA FULL SYNC');
        updateTransactions();
      } else {
        print('NISUD SA SELECTIVE');
        // updateSelectiveTransactions();
      }
    }
    if (GlobalVariables.updateType == 'Item Masterfile') {
      updateItemMasterfile();
    }
    if (GlobalVariables.updateType == 'Customer Masterfile') {
      updateCustomer();
    }
    if (GlobalVariables.updateType == 'Salesman Masterfile') {
      updateSalesman();
    }
  }

  updateTransactions() async {
    //RETURNED TRAN LIST
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Returned List...');
    var retlist = await db.getReturnedTranList(context);
    returnList = retlist;
    if (returnList.isNotEmpty) {
      int v = 0;
      returnList.forEach((element) async {
        if (v < returnList.length) {
          v++;
          if (v == returnList.length) {
            await db.deleteTable('tb_returned_tran');
            await db.insertTable(returnList, 'tb_returned_tran');
            await db.updateTable('tb_returned_tran', date.toString());
            print('RETURNED TRAN Updated');
            updateTranUnserved();
          }
        }
      });
    } else {
      print('EMPTY RETURN LIST');
      await db.deleteTable('tb_returned_tran');
      updateTranUnserved();
    }
  }

  updateTranUnserved() async {
    //RETURNED/UNSERVED LIST
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Unserved List...');
    var uslist = await db.getUnservedList(context);
    unsrvlist = uslist;
    if (unsrvlist.isNotEmpty) {
      int w = 0;
      unsrvlist.forEach((element) async {
        if (w < unsrvlist.length) {
          w++;
          if (w == unsrvlist.length) {
            await db.deleteTable('tb_unserved_items');
            await db.insertTable(unsrvlist, 'tb_unserved_items');
            await db.updateTable('tb_unserved_items', date.toString());
            print('Unserved/Returned List Updated');
            // updateTranCheque();
            updateTranLine();
          }
        }
      });
    } else {
      // print('EMPTY UNSERVED LIST');
      await db.deleteTable('tb_unserved_items');
      updateTranLine();
    }
  }

  updateTranLine() async {
    //LINE UPDATE
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Transaction Items...');
    var linersp = await db.getTranLine(context);
    linelist = linersp;
    if (linelist.isNotEmpty) {
      int y = 1;
      linelist.forEach((element) async {
        if (y < linelist.length) {
          y++;
          if (y == linelist.length) {
            await db.deleteTable('tb_tran_line');
            await db.insertTable(linelist, 'tb_tran_line');
            await db.updateTable('tb_tran_line', date.toString());
            print('Transaction Line Created');
            updateTranHead();
          }
        }
      });
    } else {
      print('EMPTY TRANSACTION LINE');
      await db.deleteTable('tb_tran_line');
      updateTranHead();
    }
  }

  updateTranHead() async {
    //TRAN UPDATE
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Transactions...');
    print(UserData.position);
    if (UserData.position == 'Salesman') {
      var thead = await db.getTranHead(context, UserData.id.toString());
      tranHeadList = thead;
    } else {
      var thead = await db.getHepeTranHead(context);
      tranHeadList = thead;
    }

    if (tranHeadList.isNotEmpty) {
      int z = 0;
      tranHeadList.forEach((element) async {
        if (z < tranHeadList.length) {
          z++;
          // print(tranHeadList.length);
          if (z == tranHeadList.length) {
            await db.deleteTable('tb_tran_head');
            await db.insertTable(tranHeadList, 'tb_tran_head');
            await db.updateTable('tb_tran_head ', date.toString());
            await db.addUpdateTableLog(
                date.toString(),
                GlobalVariables.updateType,
                'Completed',
                GlobalVariables.updateBy);
            print('Transaction Head Created');
            GlobalVariables.updateSpinkit = true;
          }
        }
      });
    } else {
      print('EMPTY TRANSACTION HEAD');
      await db.deleteTable('tb_tran_head');
      GlobalVariables.updateSpinkit = true;
    }
  }

  /////////////////////////SELECTIVE UPDATE TRANSACTIONS
  ///
  // updateSelectiveTransactions() async {
  //   //RETURNED TRAN LIST

  //   print('Updating Selective Transactions');
  //   print(GlobalVariables.syncStartDate);
  //   print(GlobalVariables.syncEndDate);
  //   Provider.of<SyncCaption>(context, listen: false)
  //       .changeCap('Updating Returned List...');
  //   var retlist = await db.getReturnedTranListSelective(
  //       context,
  //       GlobalVariables.syncStartDate.toString(),
  //       GlobalVariables.syncEndDate.toString());
  //   returnList = retlist;
  //   if (returnList.isNotEmpty) {
  //     int v = 0;
  //     returnList.forEach((element) async {
  //       if (v < returnList.length) {
  //         v++;
  //         if (v == returnList.length) {
  //           await db.deleteTable('tb_returned_tran');
  //           await db.insertTable(returnList, 'tb_returned_tran');
  //           await db.updateTable('tb_returned_tran', date.toString());
  //           print('RETURNED TRAN Updated');
  //           updateTranUnservedSelective();
  //         }
  //       }
  //     });
  //   } else {
  //     print('EMPTY RETURN LIST');
  //     await db.deleteTable('tb_returned_tran');
  //     updateTranUnservedSelective();
  //   }
  // }

  // updateTranUnservedSelective() async {
  //   //RETURNED/UNSERVED LIST
  //   Provider.of<SyncCaption>(context, listen: false)
  //       .changeCap('Updating Unserved List...');
  //   var uslist = await db.getUnservedListSelective(
  //       context,
  //       GlobalVariables.syncStartDate.toString(),
  //       GlobalVariables.syncEndDate.toString());
  //   unsrvlist = uslist;
  //   if (unsrvlist.isNotEmpty) {
  //     int w = 0;
  //     unsrvlist.forEach((element) async {
  //       if (w < unsrvlist.length) {
  //         w++;
  //         if (w == unsrvlist.length) {
  //           await db.deleteTable('tb_unserved_items');
  //           await db.insertTable(unsrvlist, 'tb_unserved_items');
  //           await db.updateTable('tb_unserved_items', date.toString());
  //           print('Unserved/Returned List Updated');
  //           // updateTranCheque();
  //           updateTranLineSelective();
  //         }
  //       }
  //     });
  //   } else {
  //     print('EMPTY UNSERVED LIST');
  //     await db.deleteTable('tb_unserved_items');
  //     updateTranLineSelective();
  //   }
  // }

  // updateTranLineSelective() async {
  //   //LINE UPDATE
  //   Provider.of<SyncCaption>(context, listen: false)
  //       .changeCap('Updating Transaction Items...');
  //   var linersp = await db.getTranLineSelective(
  //       context,
  //       GlobalVariables.syncStartDate.toString(),
  //       GlobalVariables.syncEndDate.toString());
  //   linelist = linersp;
  //   if (linelist.isNotEmpty) {
  //     int y = 1;
  //     linelist.forEach((element) async {
  //       if (y < linelist.length) {
  //         y++;
  //         if (y == linelist.length) {
  //           await db.deleteTable('tb_tran_line');
  //           await db.insertTable(linelist, 'tb_tran_line');
  //           await db.updateTable('tb_tran_line', date.toString());
  //           print('Transaction Line Created');
  //           updateTranHeadSelective();
  //         }
  //       }
  //     });
  //   } else {
  //     print('EMPTY TRANSACTION LINE');
  //     await db.deleteTable('tb_tran_line');
  //     updateTranHeadSelective();
  //   }
  // }

  // updateTranHeadSelective() async {
  //   //TRAN UPDATE
  //   Provider.of<SyncCaption>(context, listen: false)
  //       .changeCap('Updating Transactions...');
  //   print(UserData.position);
  //   if (UserData.position == 'Salesman') {
  //     var thead = await db.getTranHeadSelective(
  //         context,
  //         UserData.id.toString(),
  //         GlobalVariables.syncStartDate.toString(),
  //         GlobalVariables.syncEndDate.toString());
  //     tranHeadList = thead;
  //   } else {
  //     var thead = await db.getHepeTranHeadSelective(
  //         context,
  //         UserData.division.toString(),
  //         GlobalVariables.syncStartDate.toString(),
  //         GlobalVariables.syncEndDate.toString());
  //     tranHeadList = thead;
  //   }

  //   if (tranHeadList.isNotEmpty) {
  //     int z = 0;
  //     tranHeadList.forEach((element) async {
  //       if (z < tranHeadList.length) {
  //         z++;
  //         // print(tranHeadList.length);
  //         if (z == tranHeadList.length) {
  //           await db.deleteTable('tb_tran_head');
  //           await db.insertTable(tranHeadList, 'tb_tran_head');
  //           await db.updateTable('tb_tran_head ', date.toString());
  //           await db.addUpdateTableLog(
  //               date.toString(),
  //               GlobalVariables.updateType,
  //               'Completed',
  //               GlobalVariables.updateBy);
  //           // print('Transaction Head Created');
  //           GlobalVariables.updateSpinkit = true;
  //         }
  //       }
  //     });
  //   } else {
  //     // print('EMPTY TRANSACTION HEAD');
  //     await db.deleteTable('tb_tran_head');
  //     GlobalVariables.updateSpinkit = true;
  //   }
  // }

//////////////////////////////////////////
/////////////////////
  updateItemMasterfile() async {
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Item Images...');
    var rsp = await db.getItemImgList(context);
    itemImgList = rsp;
    int x = 0;
    itemImgList.forEach((element) async {
      if (x < itemImgList.length) {
        x++;
        if (x == itemImgList.length) {
          await db.insertItemImgList(itemImgList);
          await db.updateTable('tbl_item_image', date.toString());
          print('Item Image List Updated');
          updateItemCateg();
        }
      }
    });
  }

  updateItemCateg() async {
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Categories...');
    // //CATEGORY
    var rsp1 = await db.getCategList(context);
    categList = rsp1;
    int y = 0;
    categList.forEach((element) async {
      if (y < categList.length) {
        // print(element);
        // final imgBase64Str = await networkImageToBase64(
        //     UrlAddress.categImg + element['category_image']);
        // setState(() {
        // element['category_image'] = imgBase64Str;
        // });
        y++;
        if (y == categList.length) {
          await db.deleteTable('tbl_category_masterfile');
          await db.updateCategList(categList);
          await db.updateTable('tbl_category_masterfile', date.toString());
          print('Categ List Updated');
          updateItemList();
        }
      }
    });
  }

  updateItemList() async {
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Item List...');
    var resp = await db.getItemList(context);
    itemList = resp;
    int z = 0;
    itemList.forEach((element) async {
      if (z < itemList.length) {
        z++;
        if (z == itemList.length) {
          await db.deleteTable('item_masterfiles');
          await db.insertItemList(itemList);
          await db.updateTable('item_masterfiles', date.toString());
          await db.addUpdateTableLog(
              date.toString(),
              GlobalVariables.updateType,
              'Completed',
              GlobalVariables.updateBy);
          print('Item Masterfile Updated');
          GlobalVariables.updateSpinkit = true;
        }
      }
    });
  }

  updateCustomer() async {
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Discount List...');
    var rsp = await db.getDiscountList(context);
    discountList = rsp;
    int x = 1;
    discountList.forEach((element) async {
      if (x < discountList.length) {
        x++;
        if (x == discountList.length) {
          await db.deleteTable('tbl_discounts');
          await db.insertTable(discountList, 'tbl_discounts');
          await db.updateTable('tbl_discounts ', date.toString());
          print('Discount List Created');
          updateCustomerBank();
        }
      }
    });
  }

  updateCustomerBank() async {
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Bank List...');
    var rsp1 = await db.getBankListonLine(context);
    bankList = rsp1;
    int y = 1;
    bankList.forEach((element) async {
      if (y < bankList.length) {
        y++;
        if (y == bankList.length) {
          await db.deleteTable('tb_bank_list');
          await db.insertTable(bankList, 'tb_bank_list');
          await db.updateTable('tb_bank_list', date.toString());
          print('Bank List Created');
          // updateUserAccess();
          updateCustomerList();
        }
      }
    });
  }

  updateUserAccess() async {
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating User Access...');
    var rsp1 = await db.getUserAccessonLine(context);
    accessList = rsp1;
    int y = 1;
    accessList.forEach((element) async {
      if (y < accessList.length) {
        y++;
        if (y == accessList.length) {
          await db.deleteTable('user_access');
          await db.insertTable(accessList, 'user_access');
          await db.updateTable('tb_bank_list', date.toString());
          print('User Access Created');
          updateCustomerList();
        }
      }
    });
  }

  updateCustomerList() async {
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Customer List...');
    var resp = await db.getCustomersList(context);
    customerList = resp;
    int z = 1;
    customerList.forEach((element) async {
      if (z < customerList.length) {
        z++;
        if (z == customerList.length) {
          await db.deleteTable('customer_master_files');
          await db.insertTable(customerList, 'customer_master_files');
          await db.updateTable('customer_master_files ', date.toString());
          await db.addUpdateTableLog(
              date.toString(),
              GlobalVariables.updateType,
              'Completed',
              GlobalVariables.updateBy);
          print('Customer List Created');
          GlobalVariables.updateSpinkit = true;
        }
      }
    });
  }

  updateSalesman() async {
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Salesman List...');
    var resp = await db.getSalesmanList(context);
    salesmanList = resp;
    int y = 1;
    salesmanList.forEach((element) async {
      if (y < salesmanList.length) {
        y++;
        if (y == salesmanList.length) {
          await db.deleteTable('salesman_lists');
          await db.insertTable(salesmanList, 'salesman_lists');
          await db.updateTable('salesman_lists ', date.toString());
          await db.addUpdateTableLog(
              date.toString(),
              GlobalVariables.updateType,
              'Completed',
              GlobalVariables.updateBy);
          print('Salesman List Created');
          updateOrderLimit();
        }
      }
    });
  }

  updateOrderLimit() async {
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Order Limit List...');
    var resp = await db.getOrderLimitonLine(context);
    orderLimitList = resp;
    int y = 1;
    orderLimitList.forEach((element) async {
      if (y < orderLimitList.length) {
        y++;
        if (y == orderLimitList.length) {
          await db.deleteTable('tbl_order_limit');
          await db.insertTable(orderLimitList, 'tbl_order_limit');
          await db.updateTable('tbl_order_limit ', date.toString());
          await db.addUpdateTableLog(
              date.toString(),
              GlobalVariables.updateType,
              'Completed',
              GlobalVariables.updateBy);
          print('Order Limit Created');
          updateJefe();
        }
      }
    });
  }

  updateJefe() async {
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Jefe de Viaje List...');
    var rsp = await db.getHepeList(context);
    hepeList = rsp;
    int x = 1;
    hepeList.forEach((element) async {
      if (x < hepeList.length) {
        x++;
        if (x == hepeList.length) {
          await db.deleteTable('tbl_hepe_de_viaje');
          await db.insertTable(hepeList, 'tbl_hepe_de_viaje');
          await db.updateTable('tbl_hepe_de_viaje', date.toString());
          print('Hepe List Created');
          GlobalVariables.updateSpinkit = true;
        }
      }
    });
  }

  Future<String> networkImageToBase64(String imageUrl) async {
    var imgUri = Uri.parse(imageUrl);
    http.Response response = await http.get(imgUri);
    final bytes = response.bodyBytes;
    // return (bytes != null ? base64Encode(bytes) : null);
    return (base64Encode(bytes));
  }

  @override
  Widget build(BuildContext context) {
    // onWillPop: () => Future.value(false),
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      // child: confirmContent(context),
      child: loadingContent(context),
    );
  }

  loadingContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
            // width: MediaQuery.of(context).size.width,
            padding:
                const EdgeInsets.only(top: 50, bottom: 16, right: 5, left: 5),
            margin: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(20),
                // ignore: prefer_const_literals_to_create_immutables
                boxShadow: [
                  const BoxShadow(
                    color: Colors.transparent,
                    // blurRadius: 10.0,
                    // offset: Offset(0.0, 10.0),
                  ),
                ]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  context.watch<SyncCaption>().cap,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
                SpinKitCircle(
                  controller: animationController,
                  color: Colors.yellowAccent,
                ),
              ],
            )),
      ],
    );
  }
}
