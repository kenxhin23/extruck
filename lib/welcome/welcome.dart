// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:extruck/providers/caption_provider.dart';
import 'package:extruck/values/assets.dart';
// import 'package:extruck/values/colors.dart';
import 'package:extruck/values/userdata.dart';
import 'package:extruck/welcome/login.dart';
import 'package:extruck/widgets/buttons.dart';
import 'package:extruck/widgets/custom_modals.dart';
import 'package:extruck/widgets/dialogs.dart';
// import 'package:extruck/widgets/size_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:retry/retry.dart';
import 'package:http/http.dart' as http;
import '../db/db_helper.dart';
import '../url/url.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  List rows = [];
  List salesmanList = [];
  List customerList = [];
  List discountList = [];
  List hepeList = [];
  List itemList = [];
  List itemImgList = [];
  List itemAllImgList = [];
  List itemwImgList = [];
  List categList = [];
  List salestypeList = [];
  List bankList = [];
  List orderLimitList = [];
  List accessList = [];

  String? imageData;

  bool dataLoaded = false;
  bool processing = false;

  final db = DatabaseHelper();

  bool loadSpinkit = true;
  bool imgLoad = true;

  String? _dir;
  List<String>? _images, _tempImages;
  final String _zipPath = '${UrlAddress.itemImg}img.zip';
  final String _localZipFileName = 'img.zip';

  // final date = DateTime.parse(DateFormat("y-M-d").format(new DateTime.now()));

  String date = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());

  Future createDatabase() async {
    await db.init();
    checkStatus();
    load();
    // print(date);
    // itemImage();
  }

  @override
  void initState() {
    super.initState();
    createDatabase();
    // _images = List();
    _images = [];
    // _tempImages = List();
    _tempImages = [];
    // _downloading = false;
    _initDir();
  }

  // viewSampleTable() async {
  //   var res = await db.ofFetchAll();
  //   rows = res;
  //   print(rows);
  // }

  _initDir() async {
    if (null == _dir) {
      _dir = (await getApplicationDocumentsDirectory()).path;
      if (kDebugMode) {
        print(_dir);
      }
    }
  }

  load() {
    // GlobalVariables.statusCaption = 'Creating/Updating Database...';
    // context.read().changeCap('Creating/Updating Database...');
    Provider.of<Caption>(context, listen: false)
        .changeCap('Creating/Updating Database...');
    GlobalVariables.spinProgress = 0;

    if (loadSpinkit == true) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => const LoadingSpinkit());
    }
    // GlobalVariables.viewPolicy = true;
  }

  unloadSpinkit() async {
    loadSpinkit = false;
    // print('Unload Spinkit');
    setState(() {
      GlobalVariables.tableProcessing = 'Unloading Spinkit . . .';
    });

    Navigator.pop(context);
    // viewSampleTable();
    // updateItemImage();
  }

  checkStatus() async {
    var stat = await db.checkStat();
    if (!mounted) return;
    setState(() {
      if (stat == 'Connected') {
        // print('CONNECTED!');
        NetworkData.connected = true;

        NetworkData.errorMsgShow = false;
        // upload();
        NetworkData.errorMsg = '';
        // print('Connected to Internet!');
      } else {
        if (stat == 'ERROR1') {
          NetworkData.connected = false;
          NetworkData.errorMsgShow = true;
          NetworkData.errorNo = '1';
          // print('Network Error...');
        }
        if (stat == 'ERROR2') {
          NetworkData.connected = false;
          NetworkData.errorMsgShow = true;
          NetworkData.errorNo = '2';
          // print('Connection to API Error...');
        }
        if (stat == 'ERROR3') {
          NetworkData.connected = false;
          NetworkData.errorMsgShow = true;
          NetworkData.errorNo = '3';
          // print('Cannot connect to the Server...');
        }
        if (stat == 'Updating') {
          NetworkData.connected = false;
          NetworkData.errorMsgShow = true;
          NetworkData.errorMsg = 'Updating Server';
          NetworkData.errorNo = '4';
          // print('Updating Server...');
        }
      }
      if (stat == '' || stat == null) {
        // print('Checking Status');
      } else {
        // itemImage(); // OLD PROCESS
        checkEmpty();
      }
    });
  }

  itemImage() async {
    processing = true;
    //ITEM IMAGE (ONLY WITH IMAGE)
    var itmImg = await db.ofFetchItemImgList();
    itemImgList = itmImg;
    if (itemImgList.isEmpty) {
      // ignore: use_build_context_synchronously
      var rsp = await db.getItemImgList(context);
      itemImgList = rsp;
      _downloadZip();
    } else {
      // print('Image Already downloaded in phone.');
      processing = false;
      checkEmpty();
    }
  }

  // Future<void> _downloadZip(String _zipPath, String _localZipFileName) async {
  Future<void> _downloadZip() async {
    setState(() {
      // _downloading = true;
      // print('Downloading Images');
      // GlobalVariables.statusCaption = 'Downloading Images...';
      // context.read().changeCap('Downloading Images...');
      Provider.of<Caption>(context, listen: false)
          .changeCap('Downloading Images...');
    });

    _images!.clear();
    _tempImages!.clear();

    var zippedFile = await _downloadFile(_zipPath, _localZipFileName);
    await unarchiveAndSave(zippedFile);

    setState(() {
      _images!.addAll(_tempImages!);
      // _downloading = false;
      // print('Download Completed!');
      GlobalVariables.statusCaption = 'Download Completed!';
      checkEmpty();
    });
  }

  Future<File> _downloadFile(String url, String fileName) async {
    var req = await retry(() => http.Client().get(Uri.parse(url)));
    var file = File('$_dir/$fileName');
    return file.writeAsBytes(req.bodyBytes);
  }

  unarchiveAndSave(var zippedFile) async {
    // print('NAHUMAN NAG DOWNLOAD');
    var bytes = zippedFile.readAsBytesSync();
    var archive = ZipDecoder().decodeBytes(bytes);
    for (var file in archive) {
      var fileName = '$_dir/${file.name}';
      if (file.isFile) {
        var outFile = File(fileName);
        //print('File:: ' + outFile.path);
        _tempImages!.add(outFile.path);
        outFile = await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content);
      }
    }
  }

  downloadSalesmanImage() async {
    Provider.of<Caption>(context, listen: false)
        .changeCap('Downloading Salesman Images...');
    int x = 1;
    for (var element in salesmanList) {
      try {
        var url = Uri.parse(UrlAddress.userImg + element['img']); // <-- 1
        var response = await get(url); // <--2
        if (response.statusCode == 200) {
          var documentDirectory = await getApplicationDocumentsDirectory();
          var firstPath = '${documentDirectory.path}/images/user/';
          var filePathAndName =
              '${documentDirectory.path}/images/user/${element['img']}';
          // print(filePathAndName);
          //comment out the next three lines to prevent the image from being saved
          //to the device to show that it's coming from the internet
          await Directory(firstPath).create(recursive: true); // <-- 1
          File file2 = File(filePathAndName); // <-- 2
          file2.writeAsBytesSync(response.bodyBytes);
          if (x == salesmanList.length) {
            processing = false;
            // print('Salesman Images Saved to File...');
            // loadHepe();
            loadCustomer();
          } else {
            x++;
          }
        } else if (response.statusCode >= 400 || response.statusCode <= 499) {
          // ignore: use_build_context_synchronously
          customModal(
              context,
              const Icon(CupertinoIcons.exclamationmark_circle,
                  size: 50, color: Colors.red),
              Text(
                  "Error: ${response.statusCode}. Your client has issued a malformed or illegal request.",
                  textAlign: TextAlign.center),
              true,
              const Icon(
                CupertinoIcons.checkmark_alt,
                size: 25,
                color: Colors.greenAccent,
              ),
              '',
              () {});
        } else if (response.statusCode >= 500 || response.statusCode <= 599) {
          // ignore: use_build_context_synchronously
          customModal(
              context,
              const Icon(CupertinoIcons.exclamationmark_circle,
                  size: 50, color: Colors.red),
              Text("Error: ${response.statusCode}. Internal server error.",
                  textAlign: TextAlign.center),
              true,
              const Icon(
                CupertinoIcons.checkmark_alt,
                size: 25,
                color: Colors.greenAccent,
              ),
              '',
              () {});
        }
      } on TimeoutException {
        customModal(
            context,
            const Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            const Text(
                "Connection timed out. Please check internet connection or proxy server configurations.",
                textAlign: TextAlign.center),
            true,
            const Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            'Okay',
            () {});
      } on SocketException {
        customModal(
            context,
            const Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            const Text(
                "Connection timed out. Please check internet connection or proxy server configurations.",
                textAlign: TextAlign.center),
            true,
            const Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            'Okay',
            () {});
      } on HttpException {
        customModal(
            context,
            const Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            const Text("An HTTP error eccured. Please try again later.",
                textAlign: TextAlign.center),
            true,
            const Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            'Okay',
            () {});
      } on FormatException {
        customModal(
            context,
            const Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            const Text(
                "Format exception error occured. Please try again later.",
                textAlign: TextAlign.center),
            true,
            const Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            'Okay',
            () {});
      }
    }
  }

  downloadHepeImage() async {
    Provider.of<Caption>(context, listen: false)
        .changeCap('Downloading Hepe Images...');
    int x = 1;
    for (var element in hepeList) {
      try {
        var url = Uri.parse(UrlAddress.userImg + element['img']); // <-- 1
        var response = await get(url); // <--2
        if (response.statusCode == 200) {
          var documentDirectory = await getApplicationDocumentsDirectory();
          var firstPath = '${documentDirectory.path}/images/user/';
          var filePathAndName =
              '${documentDirectory.path}/images/user/${element['img']}';
          // print(filePathAndName);
          //comment out the next three lines to prevent the image from being saved
          //to the device to show that it's coming from the internet
          await Directory(firstPath).create(recursive: true); // <-- 1
          File file2 = File(filePathAndName); // <-- 2
          file2.writeAsBytesSync(response.bodyBytes);
          if (x == hepeList.length) {
            processing = false;
            // print('Hepe Images Saved to File...');
            loadCustomer();
          } else {
            x++;
          }
        } else if (response.statusCode >= 400 || response.statusCode <= 499) {
          // ignore: use_build_context_synchronously
          customModal(
              context,
              const Icon(CupertinoIcons.exclamationmark_circle,
                  size: 50, color: Colors.red),
              Text(
                  "Error: ${response.statusCode}. Your client has issued a malformed or illegal request.",
                  textAlign: TextAlign.center),
              true,
              const Icon(
                CupertinoIcons.checkmark_alt,
                size: 25,
                color: Colors.greenAccent,
              ),
              '',
              () {});
        } else if (response.statusCode >= 500 || response.statusCode <= 599) {
          // ignore: use_build_context_synchronously
          customModal(
              context,
              const Icon(CupertinoIcons.exclamationmark_circle,
                  size: 50, color: Colors.red),
              Text("Error: ${response.statusCode}. Internal server error.",
                  textAlign: TextAlign.center),
              true,
              const Icon(
                CupertinoIcons.checkmark_alt,
                size: 25,
                color: Colors.greenAccent,
              ),
              '',
              () {});
        }
      } on TimeoutException {
        customModal(
            context,
            const Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            const Text(
                "Connection timed out. Please check internet connection or proxy server configurations.",
                textAlign: TextAlign.center),
            true,
            const Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            'Okay',
            () {});
      } on SocketException {
        customModal(
            context,
            const Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            const Text(
                "Connection timed out. Please check internet connection or proxy server configurations.",
                textAlign: TextAlign.center),
            true,
            const Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            'Okay',
            () {});
      } on HttpException {
        customModal(
            context,
            const Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            const Text("An HTTP error eccured. Please try again later.",
                textAlign: TextAlign.center),
            true,
            const Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            'Okay',
            () {});
      } on FormatException {
        customModal(
            context,
            const Icon(CupertinoIcons.exclamationmark_circle,
                size: 50, color: Colors.red),
            const Text(
                "Format exception error occured. Please try again later.",
                textAlign: TextAlign.center),
            true,
            const Icon(
              CupertinoIcons.checkmark_alt,
              size: 25,
              color: Colors.greenAccent,
            ),
            'Okay',
            () {});
      }
    }
  }

  checkEmpty() async {
    //SALESMAN
    var sm = await db.ofFetchSalesmanList();
    salesmanList = sm;
    if (salesmanList.isEmpty) {
      // context.read().changeCap('Creating Salesman List...');
      // ignore: use_build_context_synchronously
      Provider.of<Caption>(context, listen: false)
          .changeCap('Creating Salesman List...');
      // ignore: use_build_context_synchronously
      var rsp = await db.getSalesmanList(context);
      salesmanList = rsp;
      // print(salesmanList);
      await db.insertSalesmanList(salesmanList);
      await db.addUpdateTable('xt_sm_list ', 'SALESMAN', date.toString());
      // print('Salesman List Created');

      // setState(() {
      //   GlobalVariables.processList.add('Salesman List Created');
      //   GlobalVariables.statusCaption = 'SalesmanList Created';
      // });
      // loadHepe();
      loadCustomer();
    } else {
      // ignore: use_build_context_synchronously
      final action = await Dialogs.openDialog(
          context,
          'Confirmation',
          'Update data? It may take a while please secure a stable connection.',
          false,
          'No',
          'Yes');
      if (action == DialogAction.yes) {
        // context.read().changeCap('Updating Salesman List...');
        // ignore: use_build_context_synchronously
        Provider.of<Caption>(context, listen: false)
            .changeCap('Updating Order Limit...');
        // ignore: unused_local_variable
        String updateType = 'Salesman';
        if (NetworkData.connected == true) {
          // print('NISUD SA CONNECTED!!');
          // ignore: use_build_context_synchronously
          // var resp = await db.getOrderLimitonLine(context);
          // if (!mounted) return;
          // setState(() {
          //   orderLimitList = resp;
          //   // print(salesmanList);
          //   int y = 1;
          //   orderLimitList.forEach((element) async {
          //     if (y < orderLimitList.length) {
          //       // print(salesmanList.length);
          //       y++;
          //       if (y == orderLimitList.length) {
          //         await db.deleteTable('tbl_order_limit');
          //         await db.insertTable(orderLimitList, 'tbl_order_limit');
          //         await db.updateTable('tbl_order_limit ', date.toString());
          //         await db.addUpdateTableLog(date.toString(),
          //             'Salesman Masterfile', 'Completed', updateType);
          //         print('Oder Limit Updated');
          //         GlobalVariables.updateSpinkit = true;
          //         loadSalesman();
          //       }
          //     }
          //   });
          // });
          loadSalesman();
        } else {
          // print('NIDERETSO!!');
          // loadHepe();
          loadCustomer();
        }
      } else {
        // ignore: use_build_context_synchronously
        Provider.of<Caption>(context, listen: false)
            .changeCap('Updated Successfuly!');
        unloadSpinkit();
      }
    }
  }

  loadSalesman() async {
    Provider.of<Caption>(context, listen: false)
        .changeCap('Updating Salesman List...');
    String updateType = 'Salesman';
    var resp = await db.getSalesmanList(context);
    if (!mounted) return;
    setState(() {
      salesmanList = resp;
      // print(salesmanList);
      int y = 1;
      // ignore: avoid_function_literals_in_foreach_calls
      salesmanList.forEach((element) async {
        // print(salesmanList.length);
        // print(y);
        if (y < salesmanList.length) {
          // print(salesmanList.length);
          y++;
          if (y == salesmanList.length) {
            await db.deleteTable('xt_sm_list');
            await db.insertTable(salesmanList, 'xt_sm_list');
            await db.updateTable('xt_sm_list ', date.toString());
            await db.addUpdateTableLog(date.toString(), 'Salesman Masterfile',
                'Completed', updateType);
            // print('Salesman List Updated');
            GlobalVariables.updateSpinkit = true;
            downloadSalesmanImage();
          }
        }
      });
    });
  }

// //CATEGORY
//   loadCategory() async {
//     var ctg = await db.ofFetchCategList();
//     categList = ctg;
//     if (categList.isEmpty) {
//       var rsp = await db.getCategList();
//       categList = rsp;
//       int x = 1;
//       categList.forEach((element) async {
//         if (x < categList.length) {
//           final imgBase64Str = await networkImageToBase64(
//               UrlAddress.categImg + element['category_image']);
//           setState(() {
//             element['category_image'] = imgBase64Str;
//             // print('CONVERTING.....');
//           });
//           x++;
//           if (x == categList.length) {
//             // print(categList.length);
//             await db.insertCategList(categList);
//             await db.addUpdateTable(
//                 'tbl_category_masterfile', 'ITEM', date.toString());
//             await db.addUpdateTable(
//                 'tb_tran_head', 'TRANSACTIONS', date.toString());
//             await db.addUpdateTable(
//                 'tb_tran_line', 'TRANSACTIONS', date.toString());
//             await db.addUpdateTable(
//                 'tb_unserved_items', 'TRANSACTIONS', date.toString());
//             await db.addUpdateTable(
//                 'tb_returned_tran', 'TRANSACTIONS', date.toString());
//             print('Categ List Created');
//             GlobalVariables.tableProcessing = 'Categ List Created';
//             unloadSpinkit();
//           }
//         }
//       });
//     } else {
//       setState(() {
//         unloadSpinkit();
//       });
//     }
//   }

//CATEGORY
  loadCategory() async {
    var ctg = await db.ofFetchCategList();
    categList = ctg;
    if (categList.isEmpty) {
      // context.read().changeCap('Creating Category...');
      // ignore: use_build_context_synchronously
      Provider.of<Caption>(context, listen: false)
          .changeCap('Creating Categories...');
      // ignore: use_build_context_synchronously
      var rsp = await db.getCategList(context);
      categList = rsp;
      int x = 1;
      // ignore: unused_local_variable
      for (var element in categList) {
        if (x < categList.length) {
          x++;
          if (x == categList.length) {
            // print(categList.length);
            await db.insertCategList(categList);
            await db.addUpdateTable(
                'tbl_category_masterfile', 'ITEM', date.toString());
            await db.addUpdateTable(
                'tb_tran_head', 'TRANSACTIONS', date.toString());
            await db.addUpdateTable(
                'tb_tran_line', 'TRANSACTIONS', date.toString());
            await db.addUpdateTable(
                'tb_unserved_items', 'TRANSACTIONS', date.toString());
            await db.addUpdateTable(
                'tb_returned_tran', 'TRANSACTIONS', date.toString());
            // print('Categ List Created');
            setState(() {
              GlobalVariables.statusCaption = 'Category List Created';
            });
            // ignore: use_build_context_synchronously
            Provider.of<Caption>(context, listen: false)
                .changeCap('All Database Created Successfuly!');
            unloadSpinkit();
          }
        }
      }
    } else {
      // ignore: use_build_context_synchronously
      Provider.of<Caption>(context, listen: false)
          .changeCap('All Database Created Successfuly!');
      setState(() {
        unloadSpinkit();
      });
    }
  }

  //ITEM IMAGE (ALL IMAGE PATH)
  loadItemImgPath() async {
    // context.read().changeCap('Creating Image Path...');
    Provider.of<Caption>(context, listen: false)
        .changeCap('Creating Image Path...');
    var itmImg = await db.ofFetchItemImgList();
    itemAllImgList = itmImg;
    if (itemAllImgList.isEmpty) {
      // ignore: use_build_context_synchronously
      var rsp = await db.getAllItemImgList(context);
      itemAllImgList = rsp;
      await db.insertItemImgList(itemAllImgList);
      await db.addUpdateTable('tbl_item_image   ', 'ITEM', date.toString());
      // print('All Item Image List Created');
      GlobalVariables.tableProcessing = 'All Item Image List Created';
      setState(() {
        GlobalVariables.statusCaption = 'All Item Image List Created!';
      });
      loadCategory();
    } else {
      loadCategory();
    }
  }

//ITEM MASTERFILE
  loadItemMasterfile() async {
    // context.read().changeCap('Creating Item Masterfile...');
    Provider.of<Caption>(context, listen: false)
        .changeCap('Creating Item Masterfile...');
    var itm = await db.ofFetchItemList();
    itemList = itm;
    if (itemList.isEmpty) {
      // ignore: use_build_context_synchronously
      var rsp = await db.getItemList(context);
      itemList = rsp;
      await db.insertItemList(itemList);
      await db.addUpdateTable('item_masterfiles ', 'ITEM', date.toString());
      // print('Item Masterfile Created');
      GlobalVariables.tableProcessing = 'Item Masterfile Created';
      setState(() {
        GlobalVariables.statusCaption = 'Item Masterfile Created!';
      });
      loadItemImgPath();
    } else {
      loadItemImgPath();
    }
  }

//LOAD BCOM ITEM MASTERFILE
  // loadBcomMasterfile() async {
  //   // context.read().changeCap('Creating Item Masterfile...');
  //   Provider.of<Caption>(context, listen: false)
  //       .changeCap('Creating BCOM Item Masterfile...');
  //   var itm = await db.ofFetchItemList();
  //   itemList = itm;
  //   if (itemList.isEmpty) {
  //     // ignore: use_build_context_synchronously
  //     var rsp = await db.getBcomItemList(context);
  //     itemList = rsp;
  //     await db.insertItemList(itemList);
  //     await db.addUpdateTable('item_masterfiles ', 'ITEM', date.toString());
  //     print('BCOM Item Masterfile Created');
  //     GlobalVariables.tableProcessing = 'Item Masterfile Created';
  //     setState(() {
  //       GlobalVariables.statusCaption = 'Item Masterfile Created!';
  //     });
  //     // loadItemImgPath();
  //     loadBulkMasterfile();
  //   } else {
  //     // loadItemImgPath();
  //     loadBulkMasterfile();
  //   }
  // }

  // loadBulkMasterfile() async {
  //   // context.read().changeCap('Creating Item Masterfile...');
  //   Provider.of<Caption>(context, listen: false)
  //       .changeCap('Creating BULK Item Masterfile...');
  //   // var itm = await db.ofFetchItemList();
  //   // itemList = itm;
  //   // if (itemList.isEmpty) {
  //   // ignore: use_build_context_synchronously
  //   var rsp = await db.getBulkItemList(context);
  //   itemList = rsp;
  //   await db.insertItemList(itemList);
  //   await db.addUpdateTable('item_masterfiles ', 'ITEM', date.toString());
  //   print('BULK Item Masterfile Created');
  //   GlobalVariables.tableProcessing = 'Item Masterfile Created';
  //   setState(() {
  //     GlobalVariables.statusCaption = 'Item Masterfile Created!';
  //   });
  //   loadItemImgPath();
  //   // } else {
  //   //   loadItemImgPath();
  //   // }
  // }

//BANK LIST
  loadBankList() async {
    // context.read().changeCap('Creating Bank List...');
    Provider.of<Caption>(context, listen: false)
        .changeCap('Creating Bank List...');
    var blist = await db.ofFetchBankList();
    bankList = blist;
    // print(bankList);
    if (bankList.isEmpty) {
      // ignore: use_build_context_synchronously
      var resp = await db.getBankListonLine(context);
      bankList = resp;
      int x = 1;
      // ignore: unused_local_variable
      for (var element in bankList) {
        if (x < bankList.length) {
          x++;
          if (x == bankList.length) {
            await db.insertBankList(bankList);
            await db.addUpdateTable(
                'tb_bank_list', 'CUSTOMER', date.toString());
            // print('Bank List Created');
            GlobalVariables.tableProcessing = 'Bank List Created';
            setState(() {
              GlobalVariables.statusCaption = 'Bank List Created';
            });
            // loadOrderLimit();
            loadItemMasterfile();
            // loadItemImgPath();
            // loadBcomMasterfile();
          }
        }
      }
    } else {
      // loadOrderLimit();
      loadItemMasterfile();
      // loadItemImgPath();
      // loadBcomMasterfile();
    }
  }

  //BANK LIST
  // loadOrderLimit() async {
  //   // context.read().changeCap('Creating Bank List...');
  //   Provider.of<Caption>(context, listen: false)
  //       .changeCap('Creating Oder Limit...');
  //   var ollist = await db.ofFetchOrderLimit();
  //   orderLimitList = ollist;
  //   // print(bankList);
  //   if (orderLimitList.isEmpty) {
  //     // ignore: use_build_context_synchronously
  //     var resp = await db.getOrderLimitonLine(context);
  //     orderLimitList = resp;
  //     int x = 1;
  //     orderLimitList.forEach((element) async {
  //       if (x < orderLimitList.length) {
  //         x++;
  //         if (x == orderLimitList.length) {
  //           await db.insertOrderLimitList(orderLimitList);
  //           await db.addUpdateTable(
  //               'tbl_order_limit', 'SALESMAN', date.toString());
  //           print('Order Limit Created');
  //           GlobalVariables.tableProcessing = 'Order Limit Created';
  //           setState(() {
  //             GlobalVariables.statusCaption = 'Order Limit Created';
  //           });
  //           // loadUserAccess();
  //           loadItemMasterfile();
  //         }
  //       }
  //     });
  //   } else {
  //     loadItemMasterfile();
  //     // loadUserAccess();
  //   }
  // }

  loadUserAccess() async {
    // context.read().changeCap('Creating Bank List...');
    Provider.of<Caption>(context, listen: false)
        .changeCap('Creating User Access...');
    var ulist = await db.ofFetchUserAccess();
    accessList = ulist;
    // print(bankList);
    if (accessList.isEmpty) {
      // ignore: use_build_context_synchronously
      var resp = await db.getUserAccessonLine(context);
      accessList = resp;
      int x = 1;
      // ignore: unused_local_variable
      for (var element in accessList) {
        if (x < accessList.length) {
          x++;
          if (x == accessList.length) {
            await db.insertAccessList(accessList);
            await db.addUpdateTable('user_access', 'CUSTOMER', date.toString());
            // print('User Access Created');
            GlobalVariables.tableProcessing = 'User Access Created';
            setState(() {
              GlobalVariables.statusCaption = 'User Access Created';
            });
            // loadItemMasterfile();
            loadItemImgPath();
          }
        }
      }
    } else {
      // loadItemMasterfile();
      loadItemImgPath();
    }
  }

  //SALES TYPE LIST
  loadSalesType() async {
    // context.read().changeCap('Creating Sales Type...');
    Provider.of<Caption>(context, listen: false)
        .changeCap('Creating Sales Type...');
    var stlist = await db.ofSalesTypeList();
    salestypeList = stlist;
    if (salestypeList.isEmpty) {
      // ignore: use_build_context_synchronously
      var resp = await db.getSalesTypeListonLine(context);
      salestypeList = resp;
      int x = 1;
      // ignore: unused_local_variable
      for (var element in salestypeList) {
        if (x < salestypeList.length) {
          x++;
          if (x == salestypeList.length) {
            await db.insertSalesTypeList(salestypeList);
            await db.addUpdateTable(
                'tb_sales_type', 'CUSTOMER', date.toString());
            // print('Sales Type List Created');
            GlobalVariables.tableProcessing = 'Sales Type List Created';
            setState(() {
              GlobalVariables.statusCaption = 'Sales Type List Created!';
            });
            loadBankList();
          }
        }
      }
    } else {
      loadBankList();
    }
  }

  //CUSTOMER_DISCOUNT
  loadCustomerDiscount() async {
    // context.read().changeCap('Creating Customer Discount...');
    Provider.of<Caption>(context, listen: false)
        .changeCap('Creating Customer Discount...');
    var disc = await db.ofFetchDiscountList();
    discountList = disc;
    if (discountList.isEmpty) {
      // ignore: use_build_context_synchronously
      var resp = await db.getDiscountList(context);
      discountList = resp;
      int x = 1;
      // ignore: unused_local_variable
      for (var element in discountList) {
        if (x < discountList.length) {
          x++;
          if (x == discountList.length) {
            await db.insertDiscountList(discountList);
            await db.addUpdateTable(
                'tbl_discounts', 'CUSTOMER', date.toString());
            // print('Discount List Created');
            GlobalVariables.tableProcessing = 'Discount List Created';
            setState(() {
              GlobalVariables.statusCaption = 'Discount List Created';
            });
            loadSalesType();
          }
        }
      }
    } else {
      loadSalesType();
    }
  }

  //CUSTOMER
  loadCustomer() async {
    // context.read().changeCap('Creating Customer List...');
    Provider.of<Caption>(context, listen: false)
        .changeCap('Creating Customer List...');
    var cust = await db.ofFetchCustomerList();
    customerList = cust;
    if (customerList.isEmpty) {
      // ignore: use_build_context_synchronously
      var resp = await db.getCustomersList(context);
      customerList = resp;
      int x = 1;
      // ignore: unused_local_variable
      for (var element in customerList) {
        if (x < customerList.length) {
          x++;
          if (x == customerList.length) {
            await db.insertCustomersList(customerList);
            await db.addUpdateTable(
                'customer_master_files ', 'CUSTOMER', date.toString());
            // print('Customer List Created');
            GlobalVariables.tableProcessing = 'Customer List Created';
            setState(() {
              GlobalVariables.statusCaption = 'Customer List Created!';
            });
            loadCustomerDiscount();
          }
        }
      }
    } else {
      loadCustomerDiscount();
    }
  }

  // loadHepe() async {
  //   var hepe = await db.ofFetchHepeList();
  //   hepeList = hepe;
  //   if (hepeList.isEmpty) {
  //     // context.read().changeCap('Creating Hepe List...');
  //     // ignore: use_build_context_synchronously
  //     Provider.of<Caption>(context, listen: false)
  //         .changeCap('Creating Hepe List...');
  //     // ignore: use_build_context_synchronously
  //     var rsp = await db.getHepeList(context);
  //     hepeList = rsp;
  //     int x = 1;
  //     hepeList.forEach((element) async {
  //       if (x < hepeList.length) {
  //         x++;
  //         if (x == hepeList.length) {
  //           await db.insertHepeList(hepeList);
  //           await db.addUpdateTable(
  //               'tbl_hepe_de_viaje', 'SALESMAN', date.toString());
  //           print('Hepe List Created.');
  //           setState(() {
  //             GlobalVariables.processList.add('Salesman List Created');
  //             GlobalVariables.statusCaption = 'Hepe List Created';
  //           });
  //           GlobalVariables.tableProcessing = 'Hepe List Created';
  //           loadCustomer();
  //         }
  //       }
  //     });
  //   } else {
  //     // String updateType = 'Jefe';
  //     if (NetworkData.connected) {
  //       // context.read().changeCap('Updating Hepe List...');
  //       // ignore: use_build_context_synchronously
  //       Provider.of<Caption>(context, listen: false)
  //           .changeCap('Updating Hepe List...');
  //       // ignore: use_build_context_synchronously
  //       var rsp = await db.getHepeList(context);
  //       hepeList = rsp;
  //       int x = 1;
  //       hepeList.forEach((element) async {
  //         if (x < hepeList.length) {
  //           x++;
  //           if (x == hepeList.length) {
  //             await db.deleteTable('tbl_hepe_de_viaje');
  //             await db.insertTable(hepeList, 'tbl_hepe_de_viaje');
  //             await db.updateTable('tbl_hepe_de_viaje', date.toString());
  //             // print('Hepe List Updated');
  //             downloadHepeImage();
  //           }
  //         }
  //       });
  //     } else {
  //       loadCustomer();
  //     }
  //     // loadCustomer();
  //   }
  // }

  Future<String> networkImageToBase64(String imageUrl) async {
    var imgUri = Uri.parse(imageUrl);
    http.Response response = await http.get(imgUri);
    final bytes = response.bodyBytes;
    // return (bytes != null ? base64Encode(bytes) : null);
    return (base64Encode(bytes));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    ScreenData.scrWidth = screenWidth;
    ScreenData.scrHeight = screenHeight;
    // print(screenWidth);
    // print(screenHeight);
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
          body: Stack(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetsValues.wallImg,
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Welcome!',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 1.5,
                      height: MediaQuery.of(context).size.height / 2,
                      child: Column(
                        children: [
                          Image(
                            image: AssetsValues.appImg,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    ElevatedButton(
                      style: raisedButtonLoginStyle,
                      onPressed: () async {
                        Navigator.push(
                            context,
                            PageTransition(
                                // duration: const Duration(milliseconds: 100),
                                type: PageTransitionType.rightToLeft,
                                child: const SalesmanLoginPage()));
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        // ignore: prefer_const_literals_to_create_immutables
                        children: [
                          const Text(
                            "Get Started",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: ScreenData.scrHeight * .070,
                    ),
                    // Text(message),
                  ],
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              // height: 30,
              // color: Colors.grey,
              child: Text(
                AppData.appName + AppData.appYear,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      )),
    );
  }
}

class LoadingSpinkit extends StatefulWidget {
  const LoadingSpinkit({Key? key}) : super(key: key);

  @override
  _LoadingSpinkitState createState() => _LoadingSpinkitState();
}

class _LoadingSpinkitState extends State<LoadingSpinkit> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        // child: confirmContent(context),
        child: loadingContent(context),
      ),
    );
  }

  loadingContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
            width: MediaQuery.of(context).size.width,
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
                        // Provider.of<Caption>(context).cap,
                        context.watch<Caption>().cap,
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
                ),
              ],
            )),
      ],
    );
  }
}
