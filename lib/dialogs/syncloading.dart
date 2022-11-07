import 'package:extruck/db/db_helper.dart';
import 'package:extruck/dialogs/syncsuccess.dart';
import 'package:extruck/providers/sync_caption.dart';
import 'package:extruck/values/userdata.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SyncLoadingSpinkit extends StatefulWidget {
  const SyncLoadingSpinkit({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
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

  String upType = '';

  final date = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    if (GlobalVariables.updateType == 'Transactions') {
      print(GlobalVariables.syncStartDate);
      print(GlobalVariables.syncEndDate);
      if (GlobalVariables.fullSync == true) {
        // print('NISUD SA FULL SYNC');
        upType = 'Full';
        updateTransactions();
      } else {
        upType = 'Selective';
        // print('NISUD SA SELECTIVE');
        updateTransactions();
        // updateSelectiveTransactions();
      }
    }
    if (GlobalVariables.updateType == 'Item Masterfile') {
      updateItemMasterfile();
    }
    if (GlobalVariables.updateType == 'Customer Masterfile') {
      updateCustomer();
    }
    if (GlobalVariables.updateType == 'Balance') {
      updateBalance();
    }
  }

  updateTransactions() async {
    //TRAN CHEQUE
    List list = [];
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Cheque Transactions...');
    print(UserData.id);
    print(upType);
    print(GlobalVariables.syncStartDate.toString());
    print(GlobalVariables.syncEndDate.toString());
    var rsp = await db.getTranCheque(
        context,
        UserData.id,
        upType,
        GlobalVariables.syncStartDate.toString(),
        GlobalVariables.syncEndDate.toString());
    if (rsp != null) {
      list = rsp;
      await db.deleteTable('xt_tran_cheque');
      await db.insertTable(list, 'xt_tran_cheque');
      await db.updateTable('xt_tran_cheque ', date.toString());
      await db.addUpdateTable(
          'xt_tran_cheque', 'TRANSACTIONS', date.toString());
      updateXtTranLine();
    } else {
      updateTransactions();
    }
  }

  updateXtTranLine() async {
    //TRAN LINE
    List list = [];
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Transaction Line...');
    var rsp = await db.getXtTranLine(
        context,
        UserData.id,
        upType,
        GlobalVariables.syncStartDate.toString(),
        GlobalVariables.syncEndDate.toString());
    if (rsp != null) {
      list = rsp;
      print('TRAN LINE: $list');
      await db.deleteTable('xt_tran_line');
      await db.insertTable(list, 'xt_tran_line');
      await db.updateTable('xt_tran_line ', date.toString());
      await db.addUpdateTable('xt_tran_line', 'TRANSACTIONS', date.toString());
      updateXtTranHead();
    } else {
      updateXtTranLine();
    }
  }

  updateXtTranHead() async {
    //TRAN HEAD
    List list = [];
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Transaction Head...');
    var rsp = await db.getXtTranHead(
        context,
        UserData.id,
        upType,
        GlobalVariables.syncStartDate.toString(),
        GlobalVariables.syncEndDate.toString());
    if (rsp != null) {
      list = rsp;
      print('TRAN HEAD: $list');
      await db.deleteTable('xt_tran_head');
      await db.insertTable(list, 'xt_tran_head');
      await db.updateTable('xt_tran_head ', date.toString());
      await db.addUpdateTable('xt_tran_head', 'TRANSACTIONS', date.toString());
      updateXtChequeData();
    } else {
      updateXtTranHead();
    }
  }

  updateXtChequeData() async {
    //CHEQUE DATA
    List list = [];
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Cheque Data...');
    var rsp = await db.getXtChequeData(
        context,
        UserData.id,
        upType,
        GlobalVariables.syncStartDate.toString(),
        GlobalVariables.syncEndDate.toString());
    if (rsp != null) {
      list = rsp;
      print('CHEQUE DATA: $list');
      await db.deleteTable('xt_cheque_data');
      await db.insertTable(list, 'xt_cheque_data');
      await db.updateTable('xt_cheque_data ', date.toString());
      await db.addUpdateTable(
          'xt_cheque_data', 'TRANSACTIONS', date.toString());
      updateRmtLine();
    } else {
      updateXtChequeData();
    }
  }

  updateRmtLine() async {
    //UPDATE REMITTANCE LINE
    List list = [];
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Remittance Line...');
    var rsp = await db.getRmtLine(
        context,
        UserData.id,
        upType,
        GlobalVariables.syncStartDate.toString(),
        GlobalVariables.syncEndDate.toString());
    if (rsp != null) {
      list = rsp;
      print('REMIT LINE: $list');
      await db.deleteTable('xt_rmt_line');
      await db.insertTable(list, 'xt_rmt_line');
      await db.updateTable('xt_rmt_line ', date.toString());
      await db.addUpdateTable('xt_rmt_line', 'TRANSACTIONS', date.toString());
      updateRmtHead();
    } else {
      updateRmtLine();
    }
  }

  updateRmtHead() async {
    //UPDATE REMITTANCE HEAD
    List list = [];
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Remittance Head...');
    var rsp = await db.getRmtHead(
        context,
        UserData.id,
        upType,
        GlobalVariables.syncStartDate.toString(),
        GlobalVariables.syncEndDate.toString());
    if (rsp != null) {
      list = rsp;
      print('REMIT HEAD: $list');
      await db.deleteTable('xt_rmt_head');
      await db.insertTable(list, 'xt_rmt_head');
      await db.updateTable('xt_rmt_head ', date.toString());
      await db.addUpdateTable('xt_rmt_head', 'TRANSACTIONS', date.toString());
      updateRemittance();
    } else {
      updateRmtHead();
    }
  }

  updateRemittance() async {
    //UPDATE REMITTANCE
    List list = [];
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Remittance...');
    var rsp = await db.getRemittance(
        context,
        UserData.id,
        upType,
        GlobalVariables.syncStartDate.toString(),
        GlobalVariables.syncEndDate.toString());
    if (rsp != null) {
      list = rsp;
      print('REMIT: $list');
      await db.deleteTable('xt_rmt');
      await db.insertTable(list, 'xt_rmt');
      await db.updateTable('xt_rmt ', date.toString());
      await db.addUpdateTable('xt_rmt', 'TRANSACTIONS', date.toString());
      await db.addUpdateTableLog(date.toString(), GlobalVariables.updateType,
          'Completed', GlobalVariables.updateBy);
      //print('Salesman List Created');
      Navigator.pop(context);
      GlobalVariables.updateSpinkit = false;

      print('SUCCESSFULLY UPDATED!');
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => UpdatedSuccessfully());
    } else {
      updateRmtHead();
    }
  }

  // updateTranUnserved() async {
  //   //RETURNED/UNSERVED LIST
  //   Provider.of<SyncCaption>(context, listen: false)
  //       .changeCap('Updating Unserved List...');
  //   var uslist = await db.getUnservedList(context);
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
  //           // print('Unserved/Returned List Updated');
  //           // updateTranCheque();
  //           updateTranLine();
  //         }
  //       }
  //     });
  //   } else {
  //     // print('EMPTY UNSERVED LIST');
  //     await db.deleteTable('tb_unserved_items');
  //     updateTranLine();
  //   }
  // }

  // updateTranLine() async {
  //   //LINE UPDATE
  //   Provider.of<SyncCaption>(context, listen: false)
  //       .changeCap('Updating Transaction Items...');
  //   var linersp = await db.getTranLine(context);
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
  //           // print('Transaction Line Created');
  //           updateTranHead();
  //         }
  //       }
  //     });
  //   } else {
  //     //print('EMPTY TRANSACTION LINE');
  //     await db.deleteTable('tb_tran_line');
  //     updateTranHead();
  //   }
  // }

  // updateTranHead() async {
  //   //TRAN UPDATE
  //   Provider.of<SyncCaption>(context, listen: false)
  //       .changeCap('Updating Transactions...');
  //   // print(UserData.position);
  //   if (UserData.position == 'Salesman') {
  //     var thead = await db.getTranHead(context, UserData.id.toString());
  //     tranHeadList = thead;
  //   } else {
  //     var thead = await db.getHepeTranHead(context);
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
    List list = [];
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Item Images...');
    var rsp = await db.getAllItemImgList(context);
    list = rsp;
    if (list.isNotEmpty) {
      await db.deleteTable('tbl_item_image');
      await db.insertItemImgList(list);
      await db.addUpdateTable('tbl_item_image   ', 'ITEM', date.toString());
      updateItemCateg();
    } else {
      updateItemMasterfile();
    }
    // var rsp = await db.getItemImgList(context);
    // itemImgList = rsp;
    // int x = 0;
    // itemImgList.forEach((element) async {
    //   if (x < itemImgList.length) {
    //     x++;
    //     if (x == itemImgList.length) {
    //       await db.insertItemImgList(itemImgList);
    //       await db.updateTable('tbl_item_image', date.toString());
    //       //print('Item Image List Updated');
    //       updateItemCateg();
    //     }
    //   }
    // });
  }

  updateItemCateg() async {
    List list = [];
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Categories...');
    var rsp = await db.getCategList(context);
    list = rsp;
    if (list.isNotEmpty) {
      await db.deleteTable('tbl_category_masterfile');
      await db.insertCategList(list);
      await db.addUpdateTable(
          'tbl_category_masterfile   ', 'ITEM', date.toString());
      updatePrincipalDiscount();
    } else {
      updateItemCateg();
    }
    // Provider.of<SyncCaption>(context, listen: false)
    //     .changeCap('Updating Categories...');
    // // //CATEGORY
    // var rsp1 = await db.getCategList(context);
    // categList = rsp1;
    // int y = 0;
    // categList.forEach((element) async {
    //   if (y < categList.length) {
    //     // print(element);
    //     // final imgBase64Str = await networkImageToBase64(
    //     //     UrlAddress.categImg + element['category_image']);
    //     // setState(() {
    //     // element['category_image'] = imgBase64Str;
    //     // });
    //     y++;
    //     if (y == categList.length) {
    //       await db.deleteTable('tbl_category_masterfile');
    //       await db.updateCategList(categList);
    //       await db.updateTable('tbl_category_masterfile', date.toString());
    //       //print('Categ List Updated');
    //       updateItemList();
    //     }
    //   }
    // });
  }

  updatePrincipalDiscount() async {
    List list = [];
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Discounts...');
    var rsp = await db.getDiscountList(context);
    list = rsp;
    if (list.isNotEmpty) {
      await db.deleteTable('tb_principal_discount');
      await db.insertDiscountList(list);
      await db.addUpdateTable(
          'tb_principal_discount   ', 'ITEM', date.toString());
      updateItemList();
    } else {
      updatePrincipalDiscount();
    }
  }

  updateItemList() async {
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Item List...');
    var rsp = await db.getItemList(context);
    itemList = rsp;
    if (itemList.isNotEmpty) {
      await db.deleteTable('item_masterfiles');
      await db.insertItemList(itemList);
      await db.addUpdateTable('item_masterfiles ', 'ITEM', date.toString());
      await db.addUpdateTableLog(date.toString(), GlobalVariables.updateType,
          'Completed', GlobalVariables.updateBy);
      // GlobalVariables.updateSpinkit = true;
      Navigator.pop(context);
      GlobalVariables.updateSpinkit = false;

      print('SUCCESSFULLY UPDATED!');
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => UpdatedSuccessfully());
    } else {
      updateItemList();
    }
  }

  updateCustomer() async {
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Bank List...');
    var resp = await db.getBankListonLine(context);
    bankList = resp;
    if (bankList.isNotEmpty) {
      await db.deleteTable('tb_bank_list');
      await db.insertBankList(bankList);
      await db.addUpdateTable('tb_bank_list', 'CUSTOMER', date.toString());
      // await db.addUpdateTableLog(date.toString(), GlobalVariables.updateType,
      //     'Completed', GlobalVariables.updateBy);
      // GlobalVariables.tableProcessing = 'Bank List Created';
      // setState(() {
      //   GlobalVariables.statusCaption = 'Bank List Created';
      // });
      updateCustomerList();
    } else {
      updateCustomer();
    }
    // loadOrderLimit();
    // loadItemMasterfile();
    // var rsp = await db.getDiscountList(context);
    // discountList = rsp;
    // int x = 1;
    // discountList.forEach((element) async {
    //   if (x < discountList.length) {
    //     x++;
    //     if (x == discountList.length) {
    //       await db.deleteTable('tbl_discounts');
    //       await db.insertTable(discountList, 'tbl_discounts');
    //       await db.updateTable('tbl_discounts ', date.toString());
    //       //print('Discount List Created');
    //       updateCustomerBank();
    //     }
    //   }
    // });
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
          //print('Bank List Created');
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
          //print('User Access Created');
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
    // print(customerList);
    if (customerList.isNotEmpty) {
      await db.deleteTable('customer_master_files');
      await db.insertTable(customerList, 'customer_master_files');
      await db.updateTable('customer_master_files ', date.toString());
      await db.addUpdateTableLog(date.toString(), GlobalVariables.updateType,
          'Completed', GlobalVariables.updateBy);
      //print('Customer List Created');
      // GlobalVariables.updateSpinkit = true;
      Navigator.pop(context);
      GlobalVariables.updateSpinkit = false;

      print('SUCCESSFULLY UPDATED!');
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => UpdatedSuccessfully());
    } else {
      updateCustomerList();
    }
    // var resp = await db.getCustomersList(context);
    // customerList = resp;
    // int z = 1;
    // customerList.forEach((element) async {
    //   if (z < customerList.length) {
    //     z++;
    //     if (z == customerList.length) {
    //       await db.deleteTable('customer_master_files');
    //       await db.insertTable(customerList, 'customer_master_files');
    //       await db.updateTable('customer_master_files ', date.toString());
    //       await db.addUpdateTableLog(
    //           date.toString(),
    //           GlobalVariables.updateType,
    //           'Completed',
    //           GlobalVariables.updateBy);
    //       //print('Customer List Created');
    //       GlobalVariables.updateSpinkit = true;
    //     }
    //   }
    // });
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
          //print('Salesman List Created');
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
          //print('Order Limit Created');
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
          //print('Hepe List Created');
          GlobalVariables.updateSpinkit = true;
        }
      }
    });
  }

  updateBalance() async {
    List list = [];
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Conversion Line...');
    var rsp = await db.getConversionLine(context, UserData.id);
    if (rsp != null) {
      list = rsp;
      await db.deleteTable('xt_conv_line');
      await db.insertTable(list, 'xt_conv_line');
      await db.updateTable('xt_conv_line ', date.toString());
      await db.addUpdateTable('xt_conv_line   ', 'BALANCE', date.toString());
      updateConversionHead();
    } else {
      updateBalance();
    }
  }

  updateConversionHead() async {
    List list = [];
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Conversion Head...');
    var rsp = await db.getConversionHead(context, UserData.id);
    if (rsp != null) {
      list = rsp;
      await db.deleteTable('xt_conv_head');
      await db.insertTable(list, 'xt_conv_head');
      await db.updateTable('xt_conv_head ', date.toString());
      updateLoadLedger();
    } else {
      updateConversionHead();
    }
  }

  updateLoadLedger() async {
    List list = [];
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Load Ledger...');
    var rsp = await db.getLoadLedger(context, UserData.id);
    if (rsp != null) {
      list = rsp;
      await db.deleteTable('xt_load_ldg');
      await db.insertTable(list, 'xt_load_ldg');
      await db.updateTable('xt_load_ldg ', date.toString());
      // updateRevolvingLedger();
      // updateRevolvingFund();
      updateCashLedger();
    } else {
      updateLoadLedger();
    }
  }

  // updateRevolvingLedger() async {
  //   List list = [];
  //   Provider.of<SyncCaption>(context, listen: false)
  //       .changeCap('Updating Revolving Ledger...');
  //   var rsp = await db.getRevolvingLedger(context, UserData.id);
  //   if (rsp != null) {
  //     list = rsp;
  //     await db.deleteTable('xt_rev_ldg');
  //     await db.insertTable(list, 'xt_rev_ldg');
  //     await db.updateTable('xt_rev_ldg ', date.toString());
  //     updateRevolvingFund();
  //   } else {
  //     updateRevolvingLedger();
  //   }
  // }

  // updateRevolvingFund() async {
  //   List list = [];
  //   Provider.of<SyncCaption>(context, listen: false)
  //       .changeCap('Updating Revolving Fund...');
  //   var rsp = await db.getRevolvingFund(context, UserData.id);
  //   if (rsp != null) {
  //     list = rsp;
  //     await db.deleteTable('xt_rev_fund');
  //     await db.insertTable(list, 'xt_rev_fund');
  //     await db.updateTable('xt_rev_fund ', date.toString());
  //     updateCashLedger();
  //   } else {
  //     updateRevolvingFund();
  //   }
  // }

  updateCashLedger() async {
    List list = [];
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Cash Ledger...');
    var rsp = await db.getCashLedgerOnline(context, UserData.id);
    if (rsp != null) {
      list = rsp;
      await db.deleteTable('xt_cash_ldg');
      await db.insertTable(list, 'xt_cash_ldg');
      await db.updateTable('xt_cash_ldg ', date.toString());
      updateSmLoad();
    } else {
      updateCashLedger();
    }
  }

  updateSmLoad() async {
    List list = [];
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Salesman Load...');
    var rsp = await db.getSmLoad(context, UserData.id);
    if (rsp != null) {
      list = rsp;
      await db.deleteTable('xt_sm_load');
      await db.insertTable(list, 'xt_sm_load');
      await db.updateTable('xt_sm_load ', date.toString());
      updateSmBalance();
    } else {
      updateSmLoad();
    }
  }

  updateSmBalance() async {
    List list = [];
    Provider.of<SyncCaption>(context, listen: false)
        .changeCap('Updating Salesman Balance...');
    var rsp = await db.getSmBalance(context, UserData.id);
    print(rsp);
    if (rsp != null) {
      list = rsp;
      await db.deleteTable('xt_sm_balance');
      await db.insertTable(list, 'xt_sm_balance');
      await db.updateTable('xt_sm_balance ', date.toString());
      await db.addUpdateTableLog(date.toString(), GlobalVariables.updateType,
          'Completed', GlobalVariables.updateBy);
      //print('Salesman List Created');
      Navigator.pop(context);
      GlobalVariables.updateSpinkit = false;

      print('SUCCESSFULLY UPDATED!');
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => UpdatedSuccessfully());
    } else {
      updateSmBalance();
    }
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
                Container(
                  padding: const EdgeInsets.all(10),
                  // color: Colors.white,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10),
                      // ignore: prefer_const_literals_to_create_immutables
                      boxShadow: [
                        const BoxShadow(
                          color: Colors.transparent,
                          // blurRadius: 10.0,
                          // offset: Offset(0.0, 10.0),
                        ),
                      ]),
                  child: Column(
                    children: [
                      Text(
                        context.watch<SyncCaption>().cap,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                      const LinearProgressIndicator(),
                      const SizedBox(height: 10),
                    ],
                  ),
                )
                // SpinKitCircle(
                //   controller: animationController,
                //   color: Colors.yellowAccent,
                // ),
              ],
            )),
      ],
    );
  }
}
