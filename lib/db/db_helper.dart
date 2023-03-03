import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:extruck/widgets/custom_modals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:retry/retry.dart';
import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';
import '../encrypt/enc.dart';
import '../url/url.dart';
// import 'package:package_info_plus/package_info_plus.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  static Database? _database;
  //TEST VERSION
  static const _dbName = 'EXTRUCK_TEST1.3.db';
  //LIVE VERSION
  // static const _dbName = 'EXTRUCK1.0.db';
  static const _dbVersion = 1;

  String globaldate = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());

  DatabaseHelper._();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get db async {
    if (_database != null) return _database!;

    _database = await init();
    return _database!;
  }

  Future<Database> init() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String dbPath = join(directory.path, _dbName);
    var database =
        openDatabase(dbPath, version: _dbVersion, onCreate: _onCreate);

    return database;
  }

  void _onCreate(Database db, int version) {
    db.execute('''
      CREATE TABLE myTable( 
        id INTEGER PRIMARY KEY,
        name TEXT)
       ''');

    ///CUSTOMER_MASTER_FILES
    db.execute('''
      CREATE TABLE customer_master_files(
        doc_no INTEGER PRIMARY KEY,
        customer_id TEXT,
        location_name TEXT,
        address1 TEXT,
        address2 TEXT,
        address3 TEXT,
        postal_address TEXT,
        account_group_code TEXT,
        account_group_name TEXT,
        account_code TEXT,
        account_name TEXT,
        account_description TEXT,
        account_credit_limit TEXT,
        account_classification_id TEXT,
        payment_type TEXT,
        salesman_code TEXT,
        status TEXT,
        cus_mobile_number TEXT,
        cus_password TEXT)''');

    ///ITEM MASTERFILE
    db.execute('''
      CREATE TABLE item_masterfiles(
        doc_no INTEGER PRIMARY KEY,
        item_masterfiles_id TEXT,
        product_name TEXT,
        company_code TEXT,
        itemcode TEXT,
        principal TEXT,
        product_family TEXT,
        uom TEXT,
        list_price_wtax TEXT,
        conversion_qty TEXT,
        isPromo TEXT,
        image TEXT,
        status TEXT)''');

    //ITEM IMAGE MASTERFILE
    db.execute('''
      CREATE TABLE tbl_item_image(
        doc_no INTEGER PRIMARY KEY,
        id TEXT,
        item_code TEXT,
        item_uom TEXT,
        item_path TEXT,
        image TEXT,
        created_at TEXT,
        updated_at TEXT)''');
    //or CLOB

    //ITEM CATEGORY MASTERFILE
    db.execute('''
      CREATE TABLE tbl_category_masterfile(
        doc_no INTEGER PRIMARY KEY,
        id TEXT,
        category_name TEXT,
        category_image TEXT)''');

    ///SALESMAN_LISTS
    db.execute('''
      CREATE TABLE xt_sm_list(
        doc_no INTEGER PRIMARY KEY,
        id TEXT,
        sm_code TEXT,
        username TEXT,
        password TEXT,
        firstname TEXT,
        lastname TEXT,
        department TEXT,
        division TEXT,
        area TEXT,
        title TEXT,
        address TEXT,
        mobile TEXT,
        status TEXT,
        password_date TEXT,
        img TEXT)''');

    ///SALESMAN-HEPE
    // db.execute('''
    //   CREATE TABLE tbl_hepe_salesman(
    //     doc_no INTEGER PRIMARY KEY,
    //     id TEXT,
    //     salesman_code TEXT,
    //     hepe_code TEXT,
    //     status TEXT)''');

    ///RETURNED TABLE
    db.execute('''
      CREATE TABLE tb_returned_tran(
        doc_no INTEGER PRIMARY KEY,
        tran_no TEXT,
        date TEXT,
        account_code TEXT,
        store_name TEXT,
        itm_count TEXT,
        tot_amt TEXT,
        hepe_code TEXT,
        reason TEXT,
        flag TEXT,
        signature TEXT,
        uploaded TEXT)''');

    ///SALESMAN TEMPORARY CART
    db.execute('''
      CREATE TABLE tb_salesman_cart(
        doc_no INTEGER PRIMARY KEY,
        salesman_code TEXT,
        account_code TEXT,
        item_code TEXT,
        item_desc TEXT,
        item_uom TEXT,
        item_amt TEXT,
        item_qty TEXT,
        item_total TEXT,
        item_cat TEXT,
        item_principal TEXT,
        image TEXT)''');

    ///SALES TYPE
    db.execute('''
      CREATE TABLE tb_sales_type(
        doc_no INTEGER PRIMARY KEY,
        id TEXT,
        type TEXT,
        categ TEXT)''');

    ///TRANSACTION HEAD
    db.execute('''
      CREATE TABLE tb_tran_head(
        doc_no INTEGER PRIMARY KEY,
        id TEXT,
        tran_no TEXT,
        nav_invoice_no TEXT,
        date_req TEXT,
        date_app TEXT,
        date_transit TEXT,
        date_del TEXT,
        account_code TEXT,
        store_name TEXT,
        p_meth TEXT,
        itm_count TEXT,
        itm_del_count TEXT,
        tot_amt TEXT,
        tot_del_amt TEXT,
        pmeth_type TEXT,
        tran_stat TEXT,
        sm_code TEXT,
        hepe_code TEXT,
        order_by TEXT,
        flag TEXT,
        signature TEXT,
        auth_signature TEXT,
        isExported TEXT,
        export_date TEXT,
        rate_status TEXT,
        sm_upload TEXT,
        hepe_upload TEXT)''');

    ///TRANSACTION LINE
    db.execute('''
      CREATE TABLE tb_tran_line(
        doc_no INTEGER PRIMARY KEY,
        tran_no TEXT,
        nav_invoice_no TEXT,
        itm_code TEXT,
        item_desc TEXT,
        req_qty TEXT,
        del_qty TEXT,
        uom TEXT,
        amt TEXT,
        discount TEXT,
        tot_amt TEXT,
        discounted_amount TEXT,
        itm_cat TEXT,
        itm_stat TEXT,
        flag TEXT,
        account_code TEXT,
        date_req TEXT,
        date_del TEXT,
        lrate TEXT,
        rated TEXT,
        manually_included TEXT,
        image TEXT)''');

    ///UNSERVED ITEMS
    db.execute('''
      CREATE TABLE tb_unserved_items(
        doc_no INTEGER PRIMARY KEY,
        tran_no TEXT,
        date TEXT,
        itm_code TEXT,
        item_desc TEXT,
        qty TEXT,
        uom TEXT,
        amt TEXT,
        tot_amt TEXT,
        itm_cat TEXT,
        itm_stat TEXT,
        flag TEXT,
        image TEXT)''');

    ///UPDATE TABLES
    db.execute('''
      CREATE TABLE tb_tables_update(
        doc_no INTEGER PRIMARY KEY,
        tb_name TEXT,
        tb_categ TEXT,
        date TEXT,
        flag TEXT)''');

    ///UPDATE TABLES LOG
    db.execute('''
      CREATE TABLE tb_updates_log(
        doc_no INTEGER PRIMARY KEY,
        date TEXT,
        tb_categ TEXT,
        status TEXT,
        type TEXT)''');

    ///DISCOUNTS TABLE
    db.execute('''
      CREATE TABLE tbl_discounts(
        doc_no INTEGER PRIMARY KEY,
        id TEXT,
        cus_id TEXT,
        principal_id TEXT,
        discount TEXT,
        created_at TEXT,
        updated_at TEXT)''');

    ///BANK LIST FOR CHEQUE TABLE
    db.execute('''
      CREATE TABLE tb_bank_list (
        doc_no INTEGER PRIMARY KEY,
        bank_name TEXT)''');

    ///FAVORITES TABLE
    db.execute('''
      CREATE TABLE tb_favorites (
        doc_no INTEGER PRIMARY KEY,
        account_code TEXT,
        item_code TEXT,
        item_uom TEXT)''');

    ///CHEQUE DATA
    db.execute('''
      CREATE TABLE tb_cheque_data  (
        doc_no INTEGER PRIMARY KEY,
        tran_no TEXT,
        account_code TEXT,
        sm_code TEXT,
        hepe_code TEXT,
        datetime TEXT,
        payee_name TEXT,
        payor_name TEXT,
        bank_name TEXT,
        cheque_no TEXT,
        branch_code TEXT,
        account_no TEXT,
        cheque_date TEXT,
        amount TEXT,
        status TEXT,
        image TEXT)''');

    ///XTRUCK CHEQUE DATA
    db.execute('''
      CREATE TABLE xt_cheque_data(
        doc_no INTEGER PRIMARY KEY,
        dtm TEXT,
        order_no TEXT,
        account_code TEXT,
        sm_code TEXT,
        bank_name TEXT,
        account_name TEXT,
        account_no TEXT,
        cheque_no TEXT,
        cheque_date TEXT,
        cheque_type TEXT,
        amount TEXT,
        status TEXT,
        image TEXT)''');

    ///XTRUCK CHEQUE DATA
    db.execute('''
      CREATE TABLE xt_tran_cheque(
        doc_no INTEGER PRIMARY KEY,
        sm_code TEXT,
        date TEXT,
        tran_no TEXT,
        cheque_no TEXT,
        amount TEXT,
        status TEXT)''');

    ///XTRUCK TRANSACTION HEAD
    db.execute('''
      CREATE TABLE xt_tran_head(
        doc_no INTEGER PRIMARY KEY,
        id TEXT,
        tran_no TEXT,
        ref_no TEXT,
        date_req TEXT,
        date_exp TEXT,
        date_app TEXT,
        date_load TEXT,
        sm_code TEXT,
        item_count TEXT,
        app_count TEXT,
        tot_amt TEXT,
        warehouse TEXT,
        pmeth_type TEXT,
        tran_stat TEXT,
        auth_signature TEXT,
        isExported TEXT,
        export_date TEXT,
        flag TEXT)''');

    ///XTRUCK TRANSACTION LINE
    db.execute('''
      CREATE TABLE xt_tran_line(
        doc_no INTEGER PRIMARY KEY,
        tran_no TEXT,
        ref_no TEXT,
        item_code TEXT,
        item_desc TEXT,
        req_qty TEXT,
        app_qty TEXT,
        uom TEXT,
        amt TEXT,
        discount TEXT,
        tot_amt TEXT,
        discounted_amount TEXT,
        item_cat TEXT,
        item_principal TEXT,
        item_stat TEXT,
        sm_code TEXT,
        date_req TEXT,
        date_app TEXT,
        image TEXT)''');

    ///XTRUCK SALESMAN LOAD
    db.execute('''
      CREATE TABLE xt_sm_load(
        doc_no INTEGER PRIMARY KEY,
        sm_code TEXT,
        item_code TEXT,
        item_desc TEXT,
        item_cat TEXT,
        item_principal TEXT,
        item_uom TEXT,
        item_amt TEXT,
        item_qty TEXT,
        item_total TEXT,
        conv_qty TEXT,
        conv_uom TEXT,
        image TEXT)''');

    ///XTRUCK SALESMAN LOAD
    db.execute('''
      CREATE TABLE xt_load_ldg(
        doc_no INTEGER PRIMARY KEY,
        sm_code TEXT,
        date TEXT,
        qty_in TEXT,
        qty_out TEXT,
        bal TEXT,
        type TEXT,
        details TEXT,
        ref_no TEXT)''');

    ///XTRUCK SALESMAN CASH LEDGER
    db.execute('''
      CREATE TABLE xt_cash_ldg(
        doc_no INTEGER PRIMARY KEY,
        sm_code TEXT,
        date TEXT,
        qty_in TEXT,
        qty_out TEXT,
        bal TEXT,
        type TEXT,
        details TEXT,
        ref_no TEXT)''');

    ///XTRUCK SALESMAN BALANCE
    db.execute('''
      CREATE TABLE xt_sm_balance(
        doc_no INTEGER PRIMARY KEY,
        sm_code TEXT,
        rev_fund TEXT,
        rev_bal TEXT,
        load_bal TEXT,
        cash_onhand TEXT,
        cheque_amt TEXT,
        disc_amt TEXT,
        bo_amt TEXT,
        rmt_amt TEXT,
        stat TEXT)''');

    ///XTRUCK REMITTANCE HEAD
    db.execute('''
      CREATE TABLE xt_rmt_head(
        doc_no INTEGER PRIMARY KEY,
        order_no TEXT,
        si_no TEXT,
        date TEXT,
        account_code TEXT,
        store_name TEXT,
        item_count TEXT,
        tot_amt TEXT,
        disc_amt TEXT,
        net_amt TEXT,
        pmeth_type TEXT,
        tran_type TEXT,
        sm_code TEXT,
        stat TEXT,
        rmt_no TEXT)''');

    ///XTRUCK REMITTANCE LINE
    db.execute('''
      CREATE TABLE xt_rmt_line(
        doc_no INTEGER PRIMARY KEY,
        order_no TEXT,
        si_no TEXT,
        item_code TEXT,
        item_desc TEXT,
        qty TEXT,
        uom TEXT,
        amt TEXT,
        discount TEXT,
        tot_amt TEXT,
        disc_amt TEXT,
        item_cat TEXT,
        item_principal TEXT,
        item_stat TEXT,
        disc_flag TEXT,
        sm_code TEXT,
        date TEXT,
        image TEXT)''');

    ///XTRUCK REMITTANCE REPORT
    db.execute('''
      CREATE TABLE xt_rmt(
        doc_no INTEGER PRIMARY KEY,
        rmt_no TEXT,
        date TEXT,
        date_app TEXT,
        app_by TEXT,
        sm_code TEXT,
        order_count TEXT,
        rev_bal TEXT,
        load_bal TEXT,
        bo_amt TEXT,
        tot_amt TEXT,
        tot_cash TEXT,
        tot_cheque TEXT,
        tot_disc TEXT,
        tot_satwh TEXT,
        tot_net TEXT,
        repl_amt TEXT,
        status TEXT,
        flag TEXT)''');

    ///XTRUCK CONVERSION CART
    db.execute('''
      CREATE TABLE xt_conv_cart(
        doc_no INTEGER PRIMARY KEY,
        sm_code TEXT,
        item_code TEXT,
        item_desc TEXT,
        item_principal TEXT,
        item_qty TEXT,
        avail_qty TEXT,
        item_uom TEXT,
        item_amt TEXT,
        conv_qty TEXT,
        conv_uom TEXT,
        conv_amt TEXT,
        image TEXT)''');

    ///XTRUCK CONVERSION HEAD
    db.execute('''
      CREATE TABLE xt_conv_head(
        doc_no INTEGER PRIMARY KEY,
        sm_code TEXT,
        conv_no TEXT,
        conv_date TEXT,
        itmno TEXT,
        totAmt TEXT,
        item_qty TEXT,
        nitem_qty TEXT,
        stat TEXT)''');

    ///XTRUCK CONVERSION LINE
    db.execute('''
      CREATE TABLE xt_conv_line(
        doc_no INTEGER PRIMARY KEY,
        sm_code TEXT,
        conv_no TEXT,
        item_code TEXT,
        item_desc TEXT,
        item_qty TEXT,
        item_uom TEXT,
        item_amt TEXT,
        conv_qty TEXT,
        conv_uom TEXT,
        conv_amt TEXT,
        image TEXT)''');

    db.execute('''
      CREATE TABLE xt_price_change_log(
        doc_no INTEGER PRIMARY KEY,
        sm_code TEXT,
        date TEXT,
        pc_no TEXT,
        item_code TEXT,
        item_desc TEXT,
        item_uom TEXT,
        item_amt TEXT,
        new_amt TEXT,
        var_amt TEXT,
        stock_qty TEXT,
        adj_total TEXT,
        image TEXT)''');

    ///DISCOUNTS TABLE
    db.execute('''
      CREATE TABLE tb_principal_discount(
        doc_no INTEGER PRIMARY KEY,
        id TEXT,
        principal TEXT,
        range_from TEXT,
        range_to TEXT,
        discount TEXT,
        created_at TEXT,
        updated_at TEXT,
        status TEXT)''');

    ///BANNER IMAGES TABLE
    // db.execute('''
    //   CREATE TABLE tbl_banner_image (
    //     doc_no INTEGER PRIMARY KEY,
    //     banner_details TEXT,
    //     banner_img TEXT,
    //     img_path TEXT)''');

    ///ORDER LIMIT
    // db.execute('''
    //   CREATE TABLE tbl_order_limit (
    //     doc_no INTEGER PRIMARY KEY,
    //     id TEXT,
    //     code TEXT,
    //     min_order_amt TEXT)''');

    ///BANNER USER ACCESS
    // db.execute('''
    //   CREATE TABLE user_access (
    //     doc_no INTEGER PRIMARY KEY,
    //     ua_userid TEXT,
    //     ua_code TEXT,
    //     ua_action TEXT,
    //     ua_cust TEXT,
    //     ua_add_date TEXT,
    //     ua_update_date TEXT)''');

    if (kDebugMode) {
      print("Database was created!");
    }
  }

  Future insertSalesmanList(salesman) async {
    var client = await db;
    Batch batch = client.batch();
    for (var i = 0; i < salesman.length; i++) {
      batch.insert('xt_sm_list', salesman[i]);
    }
    await batch.commit(noResult: true);
  }

  Future insertHepeList(hepe) async {
    var client = await db;
    Batch batch = client.batch();
    for (var i = 0; i < hepe.length; i++) {
      batch.insert('tbl_hepe_de_viaje', hepe[i]);
    }
    await batch.commit(noResult: true);
  }

  Future insertCustomersList(customer) async {
    var client = await db;
    Batch batch = client.batch();
    for (var i = 0; i < customer.length; i++) {
      batch.insert('customer_master_files', customer[i]);
    }
    await batch.commit(noResult: true);
  }

  Future insertDiscountList(discount) async {
    var client = await db;
    Batch batch = client.batch();
    for (var i = 0; i < discount.length; i++) {
      batch.insert('tb_principal_discount', discount[i]);
    }
    await batch.commit(noResult: true);
  }

  Future insertBankList(bank) async {
    var client = await db;
    Batch batch = client.batch();
    for (var i = 0; i < bank.length; i++) {
      batch.insert('tb_bank_list', bank[i]);
    }
    await batch.commit(noResult: true);
  }

  Future insertOrderLimitList(orderLimit) async {
    var client = await db;
    Batch batch = client.batch();
    for (var i = 0; i < orderLimit.length; i++) {
      batch.insert('tbl_order_limit', orderLimit[i]);
    }
    await batch.commit(noResult: true);
  }

  Future insertAccessList(access) async {
    var client = await db;
    Batch batch = client.batch();
    for (var i = 0; i < access.length; i++) {
      batch.insert('user_access', access[i]);
    }
    await batch.commit(noResult: true);
  }

  Future insertSalesTypeList(type) async {
    var client = await db;
    Batch batch = client.batch();
    for (var i = 0; i < type.length; i++) {
      batch.insert('tb_sales_type', type[i]);
    }
    await batch.commit(noResult: true);
  }

  Future insertItemList(items) async {
    var client = await db;
    Batch batch = client.batch();
    for (var i = 0; i < items.length; i++) {
      batch.insert('item_masterfiles', items[i]);
    }
    await batch.commit(noResult: true);
  }

  Future insertTable(list, tbName) async {
    var client = await db;
    Batch batch = client.batch();
    for (var i = 0; i < list.length; i++) {
      batch.insert('$tbName', list[i]);
    }
    await batch.commit(noResult: true);
  }

  // Future insertItemList(items, img) async {
  //   var client = await db;
  //   Batch batch = client.batch();
  //   for (var i = 0; i < items.length; i++) {
  //     batch.insert('item_masterfiles', items[i]);
  //     batch.update('item_masterfiles', {'image': img['image_path']},
  //         where: 'itemcode = ? AND uom = ?', whereArgs: []);
  //   }
  //   await batch.commit(noResult: true);
  // }

  Future insertItemImgList(img) async {
    var client = await db;
    Batch batch = client.batch();
    for (var i = 0; i < img.length; i++) {
      batch.insert('tbl_item_image', img[i]);
    }
    await batch.commit(noResult: true);
  }

  // Future updateItemImg(img) async {
  //   var client = await db;
  //   Batch batch = client.batch();
  //   for (var i = 0; i < img.length; i++) {
  //     batch.update('tbl_item_image', {'image': img[i]['image']},
  //         where: 'item_code = ? AND item_uom = ?',
  //         whereArgs: [img[i]['item_code'], img[i]['item_uom']]);
  //   }
  //   await batch.commit(noResult: true);
  // }
  Future updateItemImg(img) async {
    var client = await db;
    Batch batch = client.batch();
    for (var i = 0; i < img.length; i++) {
      batch.update('item_masterfiles', {'image': img[i]['item_path']},
          where: 'itemcode = ? AND uom = ?',
          whereArgs: [img[i]['item_code'], img[i]['item_uom']]);
    }
    await batch.commit(noResult: true);
  }

  Future insertCategList(categ) async {
    var client = await db;
    Batch batch = client.batch();
    for (var i = 0; i < categ.length; i++) {
      batch.insert('tbl_category_masterfile', categ[i]);
    }
    await batch.commit(noResult: true);
  }

  Future updateCategList(categ) async {
    var client = await db;
    Batch batch = client.batch();

    for (var i = 0; i < categ.length; i++) {
      batch.insert('tbl_category_masterfile', categ[i]);
      // batch.update('tbl_category_masterfile', categ[i],
      //     where: 'doc_no = ?', whereArgs: [categ[i]['doc_no']]);
    }
    await batch.commit(noResult: true);
  }

  Future deleteCateg() async {
    var client = await db;
    return client.rawQuery(
        'DELETE FROM tbl_category_masterfile WHERE category_name != " "', null);
  }

  Future deleteCustomer() async {
    var client = await db;
    return client.rawQuery(
        'DELETE FROM customer_master_files WHERE customer_id != " "', null);
  }

  Future deleteTable(tbNname) async {
    var client = await db;
    return client.rawQuery('DELETE FROM $tbNname WHERE doc_no !=" "', null);
  }

  Future addItemtoCart(salesmanCode, itemCode, itemDesc, itemUom, itemAmt, qty,
      total, itemCat, itemPrincipal, itemImage) async {
    int fqty = 0;
    double ftotal = 0.00;
    var client = await db;

    List<Map> res = await client.rawQuery(
        'SELECT item_qty, item_total FROM tb_salesman_cart WHERE salesman_code = "$salesmanCode" AND  item_code = "$itemCode" AND item_uom = "$itemUom"',
        null);
    // final result = count;
    // return res;
    if (res.isEmpty) {
      return client.insert('tb_salesman_cart', {
        'salesman_code': salesmanCode,
        'item_code': itemCode,
        'item_desc': itemDesc,
        'item_uom': itemUom,
        'item_amt': itemAmt,
        'item_qty': qty,
        'item_total': total,
        'item_cat': itemCat,
        'item_principal': itemPrincipal,
        'image': itemImage,
      });
    } else {
      for (var element in res) {
        fqty = int.parse(element['item_qty']);
        ftotal = double.parse(element['item_total']);
      }
      return client.update(
          'tb_salesman_cart',
          {
            'item_qty': (fqty + int.parse(qty)).toString(),
            'item_total': (ftotal + double.parse(total)).toString()
          },
          where: 'salesman_code = ? AND item_code = ? AND item_uom = ?',
          whereArgs: [salesmanCode, itemCode, itemUom]);
    }
  }

  // Future addOrdertoCart(salesmanCode, custCode, itemCode, itemDesc, itemUom,
  //     itemAmt, qty, total, itemCat, itemImage) async {
  //   int fqty = 0;
  //   double ftotal = 0.00;
  //   var client = await db;

  //   List<Map> res = await client.rawQuery(
  //       'SELECT item_qty, item_total FROM tb_salesman_cart WHERE salesman_code = "$salesmanCode" AND account_code = "$custCode" AND  item_code = "$itemCode" AND item_uom = "$itemUom"',
  //       null);
  //   // final result = count;
  //   // return res;
  //   if (res.isEmpty) {
  //     return client.insert('tb_salesman_cart', {
  //       'salesman_code': salesmanCode,
  //       'item_code': itemCode,
  //       'item_desc': itemDesc,
  //       'item_uom': itemUom,
  //       'item_amt': itemAmt,
  //       'item_qty': qty,
  //       'item_total': total,
  //       'item_cat': itemCat,
  //       'image': itemImage,
  //     });
  //   } else {
  //     res.forEach((element) {
  //       fqty = int.parse(element['item_qty']);
  //       ftotal = double.parse(element['item_total']);
  //     });
  //     return client.update(
  //         'tb_salesman_cart',
  //         {
  //           'item_qty': (fqty + int.parse(qty)).toString(),
  //           'item_total': (ftotal + double.parse(total)).toString()
  //         },
  //         where: 'salesman_code = ? AND item_code = ? AND item_uom = ?',
  //         whereArgs: [salesmanCode, itemCode, itemUom]);
  //   }
  // }

  Future addOrdertoCart(salesmanCode, custCode, itemCode, itemDesc, itemUom,
      itemAmt, qty, total, itemCat, itemPrincipal, itemImage) async {
    int fqty = 0;
    double ftotal = 0.00;
    var client = await db;

    List<Map> res = await client.rawQuery(
        'SELECT item_qty, item_total FROM tb_salesman_cart WHERE salesman_code = "$salesmanCode" AND account_code = "$custCode" AND item_code = "$itemCode" AND item_uom = "$itemUom"',
        null);
    // final result = count;
    // return res;
    if (res.isEmpty) {
      return client.insert('tb_salesman_cart', {
        'salesman_code': salesmanCode,
        'account_code': custCode,
        'item_code': itemCode,
        'item_desc': itemDesc,
        'item_uom': itemUom,
        'item_amt': itemAmt,
        'item_qty': qty,
        'item_total': total,
        'item_cat': itemCat,
        'item_principal': itemPrincipal,
        'image': itemImage,
      });
    } else {
      for (var element in res) {
        fqty = int.parse(element['item_qty']);
        ftotal = double.parse(element['item_total']);
      }
      return client.update(
          'tb_salesman_cart',
          {
            'item_qty': (fqty + int.parse(qty)).toString(),
            'item_total': (ftotal + double.parse(total)).toString()
          },
          where:
              'salesman_code = ? AND account_code = ? AND item_code = ? AND item_uom = ?',
          whereArgs: [salesmanCode, custCode, itemCode, itemUom]);
    }
  }

  Future addRequestHead(tranNo, dateReq, code, itmcount, totAmt, warehouse,
      pmeth, stat, signature, flag) async {
    double totalAmt = 0.00;
    int iCount = 0;
    var client = await db;

    List<Map> res = await client.rawQuery(
        'SELECT * FROM xt_tran_head WHERE tran_no ="$tranNo"', null);
    if (res.isEmpty) {
      return client.insert('xt_tran_head', {
        'tran_no': tranNo,
        'date_req': dateReq,
        'sm_code': code,
        'item_count': itmcount,
        'tot_amt': totAmt,
        'warehouse': warehouse,
        'pmeth_type': pmeth,
        'tran_stat': stat,
        'auth_signature': signature,
        'flag': flag,
      });
    } else {
      for (var element in res) {
        totalAmt = double.parse(element['tot_amt']);
        iCount = int.parse(element['item_count']);
      }
      return client.update(
          'xt_tran_head',
          {
            'item_count': (iCount + int.parse(itmcount)),
            'tot_amt': (totalAmt + double.parse(totAmt)),
          },
          where: 'tran_no = ?',
          whereArgs: [tranNo]);
    }
  }

  Future addRequestLine(tranNo, itemCode, itemDesc, itemQty, itemUom, itemAmt,
      totAmt, principal, code, date, image) async {
    int fqty = 0;
    double ftotal = 0.00;
    var client = await db;

    List<Map> res = await client.rawQuery(
        'SELECT req_qty, tot_amt FROM xt_tran_line WHERE tran_no ="$tranNo" AND sm_code ="$code" AND  item_code = "$itemCode" AND uom = "$itemUom"',
        null);
    // final result = count;
    // return res;
    if (res.isEmpty) {
      return client.insert('xt_tran_line', {
        'tran_no': tranNo,
        'item_code': itemCode,
        'item_desc': itemDesc,
        'req_qty': itemQty,
        'app_qty': '0',
        'uom': itemUom,
        'amt': itemAmt,
        'discount': '0',
        'tot_amt': totAmt,
        'discounted_amount': '0.00',
        'item_principal': principal,
        'sm_code': code,
        'item_stat': 'Pending',
        'date_req': date,
        'image': image,
      });
    } else {
      for (var element in res) {
        fqty = int.parse(element['req_qty']);
        ftotal = double.parse(element['tot_amt']);
      }
      return client.update(
          'xt_tran_line',
          {
            'req_qty': (fqty + int.parse(itemQty)).toString(),
            'tot_amt': (ftotal + double.parse(totAmt)).toString()
          },
          where: 'tran_no = ? AND sm_code = ? AND item_code = ? AND uom = ?',
          whereArgs: [tranNo, code, itemCode, itemUom]);
    }
  }

  Future addUpdateTable(tbName, tbCateg, date) async {
    var client = await db;
    return client.insert('tb_tables_update', {
      'tb_name': tbName,
      'tb_categ': tbCateg,
      'date': date,
    });
  }

  Future updateTable(tbName, date) async {
    var client = await db;
    return client.update('tb_tables_update', {'tb_name': tbName, 'date': date},
        where: 'tb_name = ?', whereArgs: [tbName]);
  }

  Future updateSalesmanPassword(code, pass) async {
    var client = await db;
    return client.update('xt_sm_list', {'password': pass},
        where: 'sm_code = ?', whereArgs: [code]);
  }

  Future updateHepePassword(code, pass) async {
    var client = await db;
    return client.update('tbl_hepe_de_viaje', {'password': pass},
        where: 'user_code = ?', whereArgs: [code]);
  }

  Future addUpdateTableLog(date, tbCateg, stat, type) async {
    var client = await db;
    return client.insert('tb_updates_log', {
      'date': date,
      'tb_categ': tbCateg,
      'status': stat,
      'type': type,
    });
  }

  Future updateSmCart(code, itemCode, itemUom, itemQty, itemTotal) async {
    var client = await db;
    return client.update(
        'tb_salesman_cart', {'item_qty': itemQty, 'item_total': itemTotal},
        where: 'salesman_code = ? AND item_code = ? AND item_uom = ?',
        whereArgs: [code, itemCode, itemUom]);

    // return 'UPDATED';
  }

  Future updateCustCart(
      smcode, custcode, itemCode, itemUom, itemQty, itemTotal) async {
    var client = await db;
    return client.update(
        'tb_salesman_cart', {'item_qty': itemQty, 'item_total': itemTotal},
        where:
            'salesman_code = ? AND account_code = ? AND item_code = ? AND item_uom = ?',
        whereArgs: [smcode, custcode, itemCode, itemUom]);

    // return 'UPDATED';
  }

  Future ofUpdateItemImg(image, itemcode, uom) async {
    var client = await db;
    return client.update('item_masterfiles', {'image': image},
        where: 'itemcode = ? AND uom = ?', whereArgs: [itemcode, uom]);
  }

  Future updateTranUploadStatSM(tmpTranNo, tranNo) async {
    String stat = 'TRUE';
    var client = await db;
    return client.update('tb_tran_head', {'tran_no': tranNo, 'sm_upload': stat},
        where: 'tran_no = ?', whereArgs: [tmpTranNo]);
  }

  Future updateTranUploadStatHEPE(tranNo) async {
    String stat = 'TRUE';
    var client = await db;
    return client.update('tb_tran_head', {'hepe_upload': stat},
        where: 'tran_no = ?', whereArgs: [tranNo]);
  }

  Future updateLineUploadStat(tmpTranNo, tranNo) async {
    var client = await db;
    return client.update('tb_tran_line', {'tran_no': tranNo},
        where: 'tran_no = ?', whereArgs: [tmpTranNo]);
  }

  // Future sampleUpdateItemImg(image, itemcode, uom) async {
  //   var client = await db;
  //   return client.update('tbl_item_image', {'item_path': image},
  //       where: 'item_code = ? AND item_uom = ?', whereArgs: [itemcode, uom]);
  // }

  Future fetchTest() async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM xt_tran_line ORDER BY doc_no DESC', null);
  }

  Future ofFetchUpdatesTables() async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM tb_tables_update ORDER BY date ASC', null);
  }

  Future ofFetchAll() async {
    var client = await db;
    return client.rawQuery('SELECT * FROM tb_bank_list ', null);
  }

  Future ofFetchSalesmanList() async {
    var client = await db;
    return client.rawQuery('SELECT * FROM xt_sm_list', null);
  }

  Future ofFetchHepeList() async {
    var client = await db;
    return client.rawQuery('SELECT * FROM tbl_hepe_de_viaje', null);
  }

  Future ofFetchCustomerList() async {
    var client = await db;
    return client.rawQuery('SELECT * FROM customer_master_files', null);
  }

  Future ofFetchDiscountList() async {
    var client = await db;
    return client.rawQuery('SELECT * FROM tb_principal_discount', null);
  }

  Future ofFetchBankList() async {
    var client = await db;
    return client.rawQuery('SELECT * FROM tb_bank_list', null);
  }

  Future ofFetchOrderLimit() async {
    var client = await db;
    return client.rawQuery('SELECT * FROM tbl_order_limit', null);
  }

  Future ofFetchUserAccess() async {
    var client = await db;
    return client.rawQuery('SELECT * FROM user_access', null);
  }

  Future ofSalesTypeList() async {
    var client = await db;
    return client.rawQuery('SELECT * FROM tb_sales_type', null);
  }

  Future ofFetchItemList() async {
    var client = await db;
    return client.rawQuery('SELECT * FROM item_masterfiles', null);
  }

  Future ofFetchItemImgList() async {
    var client = await db;
    return client.rawQuery('SELECT * FROM tbl_item_image', null);
  }

  Future ofFetchCategList() async {
    var client = await db;
    return client.rawQuery('SELECT * FROM tbl_category_masterfile', null);
  }

  Future getReturnedList() async {
    var client = await db;
    return client.rawQuery('SELECT * FROM tb_returned_tran', null);
  }

  Future getReturnedStatus() async {
    // String stat = 'Returned';
    var client = await db;
    return client.rawQuery(
        'SELECT store_name, hepe_code,tran_stat FROM tb_tran_head', null);
  }

  Future getUnserveditems() async {
    var client = await db;
    return client.rawQuery('SELECT * FROM tb_unserved_items ', null);
  }

  // Future ofFetchCart(custcode) async {
  //   var client = await db;

  //   return client.rawQuery(
  //       'SELECT * FROM tb_salesman_cart WHERE account_code ="$custcode" ORDER BY doc_no ASC',
  //       null);
  // }

  Future ofFetchCart(id) async {
    var client = await db;

    return client.rawQuery(
        'SELECT * FROM tb_salesman_cart WHERE salesman_code ="$id" ORDER BY doc_no ASC',
        null);
  }

  Future ofFetchCustomerCart(id, code) async {
    var client = await db;

    return client.rawQuery(
        'SELECT * FROM tb_salesman_cart WHERE salesman_code ="$id" AND account_code ="$code" ORDER BY doc_no ASC',
        null);
  }

  Future searchCart(code, itmcode, uom) async {
    var client = await db;

    return client.rawQuery(
        'SELECT * FROM tb_salesman_cart WHERE salesman_code ="$code" AND item_code ="$itmcode" AND item_uom ="$uom"',
        null);
  }

  Future searchCustomerCart(smcode, custcode, itmcode, uom) async {
    var client = await db;

    return client.rawQuery(
        'SELECT * FROM tb_salesman_cart WHERE salesman_code ="$smcode" AND account_code ="$custcode" AND item_code ="$itmcode" AND item_uom ="$uom"',
        null);
  }

  Future ofFetchSalesmanHistory(code) async {
    var client = await db;
    return client.rawQuery(
        "SELECT *,''as newdate FROM tb_tran_head WHERE sm_code ='$code' ORDER BY date_req ASC",
        null);
  }

  Future ofFetchSalesmanOngoingHistory(code) async {
    // String status = 'Delivered';
    var client = await db;
    // return client.rawQuery(
    //     "SELECT *,''as newdate FROM tb_tran_head WHERE sm_code ='$code' AND tran_stat='On-Process' OR sm_code ='$code' AND tran_stat='Approved'  ORDER BY date_req ASC",
    //     null);
    return client.rawQuery(
        "SELECT *,''as newdate FROM tb_tran_head WHERE sm_code ='$code' AND tran_stat ='Pending' OR sm_code ='$code' AND tran_stat ='On-Process' OR sm_code ='$code' AND tran_stat ='Approved' ORDER BY date_app DESC",
        null);
  }

  Future ofFetchSalesmanCompletedHistory(code) async {
    String status = 'Delivered';
    var client = await db;
    return client.rawQuery(
        "SELECT *,''as newdate FROM tb_tran_head WHERE sm_code ='$code' AND tran_stat ='$status' ORDER BY date_del DESC",
        null);
  }

  Future ofFetchSalesmanCancelHistory(code) async {
    // String status = 'Delivered';
    var client = await db;
    return client.rawQuery(
        "SELECT *,''as newdate FROM tb_tran_head WHERE sm_code ='$code' AND tran_stat ='Cancelled' OR sm_code ='$code' AND tran_stat ='Returned' ORDER BY date_del DESC",
        null);
  }

  Future ofFetchHepeHistory(code) async {
    var client = await db;
    return client.rawQuery(
        "SELECT *,'' as newdate FROM tb_tran_head WHERE hepe_code ='$code' ORDER BY date_req ASC",
        null);
  }

  Future ofFetchHepeOngoingHistory(code) async {
    var client = await db;
    return client.rawQuery(
        "SELECT *,'' as newdate FROM tb_tran_head WHERE hepe_code ='$code' AND tran_stat ='Pending' OR hepe_code ='$code' AND tran_stat ='On-Process' OR tran_stat ='Approved' ORDER BY date_app DESC",
        null);
  }

  Future ofFetchHepeCompletedHistory(code) async {
    String status = 'Delivered';
    var client = await db;
    return client.rawQuery(
        "SELECT *,'' as newdate FROM tb_tran_head WHERE hepe_code ='$code' AND tran_stat ='$status'  ORDER BY date_del DESC",
        null);
  }

  Future ofFetchHepeCancelHistory(code) async {
    var client = await db;
    return client.rawQuery(
        "SELECT *,'' as newdate FROM tb_tran_head WHERE hepe_code ='$code' AND tran_stat ='Cancelled' OR hepe_code ='$code' AND tran_stat ='Returned' ORDER BY date_del DESC",
        null);
  }

  Future ofFetchCustomerHistory(code) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM tb_tran_head WHERE account_code ="$code" ORDER BY date_req ASC',
        null);
  }

  Future ofFetchForUploadSalesmanSample(code) async {
    var client = await db;
    return client.rawQuery(
        'SELECT store_name FROM tb_tran_head WHERE sm_code ="$code" AND tran_stat ="Pending" AND sm_upload !="TRUE" ORDER BY account_code ASC',
        null);
  }

  Future ofFetchForUploadSalesman(code) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM tb_tran_head WHERE sm_code ="$code" AND tran_stat ="Pending" AND sm_upload !="TRUE" ORDER BY date_req ASC',
        null);
  }

  Future ofFetchForUploadHepe(code) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM tb_tran_head WHERE (tran_stat ="Delivered" OR tran_stat ="Returned") AND hepe_upload !="TRUE" ORDER BY date_del ASC',
        null);
  }

  Future ofFetchForUploadCustomer(code) async {
    var client = await db;
    return client.rawQuery(
        'SELECT tran_no FROM tb_tran_head WHERE account_code ="$code" AND tran_stat ="Pending" AND sm_upload !="TRUE" ORDER BY date_req ASC',
        null);
  }

  Future ofFetchUpdateLog(type) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM tb_updates_log WHERE type ="$type" ORDER BY doc_no DESC',
        null);
  }

  Future ofFetchUpdateLogAll() async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM tb_updates_log ORDER BY doc_no DESC', null);
  }

  // Future getAllProducts() async {
  //   var client = await db;
  //   return client.query('item_masterfiles',
  //       where: 'conversion_qty = ?', whereArgs: ['1']);
  // }

  // Future getProducts(categ) async {
  //   var client = await db;
  //   return client.rawQuery(
  //       'SELECT * FROM item_masterfiles WHERE product_family ="$categ" AND conversion_qty ="1"',
  //       null);
  // }

  Future getAllProducts() async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM item_masterfiles WHERE conversion_qty !="1" ORDER BY product_name ASC LIMIT 100',
        null);
  }

  Future getAvailableStocks(code) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM item_masterfiles ORDER BY product_name ASC LIMIT 100',
        null);
  }

  Future getUom(itmcode) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM item_masterfiles WHERE itemcode ="$itmcode" AND status="1"',
        null);
  }

  // Future getOrderedItems(tranNo) async {
  //   var client = await db;
  //   return client.rawQuery(
  //       'SELECT * FROM tb_tran_line WHERE tran_no ="$tranNo" ORDER BY item_desc ASC',
  //       null);
  // }

  Future getAllLine() async {
    var client = await db;
    return client.rawQuery(
        'SELECT doc_no,tran_no FROM tb_tran_line ORDER BY doc_no DESC', null);
  }

  Future getTransactionLine(tranNo) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM tb_tran_line WHERE tran_no ="$tranNo" ORDER BY item_desc ASC',
        null);
  }

  Future getReturnedTran(tranNo) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM tb_returned_tran WHERE tran_no ="$tranNo"', null);
  }

  Future getReturnedLine(tranNo) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM tb_unserved_items WHERE tran_no ="$tranNo" AND itm_stat="Returned" ',
        null);
  }

  Future getItemImg(itmcode, uom) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM item_masterfiles WHERE itemcode ="$itmcode" AND uom="$uom"',
        null);
  }

  Future getItemImginTable(itmcode, uom) async {
    var client = await db;
    return client.rawQuery(
        'SELECT item_path FROM tbl_item_image WHERE item_code ="$itmcode" AND item_uom="$uom"',
        null);
  }

  Future getItemImgListloc(path) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM tbl_item_image WHERE item_path ="$path"', null);
  }

  Future getItemwithImg() async {
    String noImg = 'no_image_item.jpg';
    String caseImg = 'CASEE.png';
    String boxImg = 'BOXX.jpg';
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM tbl_item_image WHERE item_path !="" AND item_path !="$noImg" AND item_path !="$caseImg" AND item_path !="$boxImg" LIMIT 3',
        null);
  }

  Future ofFetchItemPath(itmcode, uom) async {
    var client = await db;
    return client.rawQuery(
        'SELECT item_path FROM tbl_item_image WHERE item_code ="$itmcode" AND item_uom="$uom"',
        null);
  }

  Future setUom(itmcode, uom) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM item_masterfiles WHERE itemcode ="$itmcode" AND uom ="$uom"',
        null);
  }

  Future deleteRequestItem(smcode, itmcode, uom) async {
    var client = await db;
    return client.rawQuery(
        'DELETE FROM tb_salesman_cart WHERE salesman_code ="$smcode" AND item_code ="$itmcode" AND item_uom ="$uom"',
        null);
  }

  Future deleteOrderItem(smcode, custcode, itmcode, uom) async {
    var client = await db;
    return client.rawQuery(
        'DELETE FROM tb_salesman_cart WHERE salesman_code ="$smcode" AND account_code ="$custcode" AND item_code ="$itmcode" AND item_uom ="$uom"',
        null);
  }

  Future deleteItem(smcode, custcode, itmcode, uom) async {
    var client = await db;
    return client.rawQuery(
        'DELETE FROM tb_salesman_cart WHERE salesman_code ="$smcode" AND account_code ="$custcode" AND item_code ="$itmcode" AND item_uom ="$uom"',
        null);
  }

  Future deleteConvItem(smcode, itmcode, uom) async {
    var client = await db;
    return client.rawQuery(
        'DELETE FROM xt_conv_cart WHERE sm_code ="$smcode" AND item_code ="$itmcode" AND item_uom ="$uom"',
        null);
  }

  Future deleteCart(code) async {
    var client = await db;
    return client.rawQuery(
        'DELETE FROM tb_salesman_cart WHERE account_code ="$code"', null);
  }

  Future cleanCart(code) async {
    var client = await db;
    return client.rawQuery(
        'DELETE FROM tb_salesman_cart WHERE salesman_code ="$code"', null);
  }

  Future cleanCustomerCart(smCOde, accCode) async {
    var client = await db;
    return client.rawQuery(
        'DELETE FROM tb_salesman_cart WHERE salesman_code ="$smCOde" AND account_code ="$accCode"',
        null);
  }

  // Future searchAllItems(text) async {
  //   var client = await db;
  //   return client.rawQuery(
  //       "SELECT * FROM item_masterfiles WHERE product_name LIKE '%$text%' AND conversion_qty ='1' ",
  //       null);
  // }

  Future searchAllItems(text) async {
    var client = await db;
    return client.rawQuery(
        "SELECT * FROM item_masterfiles WHERE conversion_qty !='1' AND product_name LIKE '%$text%'",
        null);
  }

  Future searchItems(categ, text) async {
    var client = await db;
    return client.rawQuery(
        "SELECT * FROM item_masterfiles WHERE product_family ='$categ' AND product_name LIKE '%$text%' AND conversion_qty ='1'",
        null);
  }

  Future customerSearch(text) async {
    var client = await db;
    return client.rawQuery(
        "SELECT * FROM customer_master_files WHERE location_name LIKE '%$text%' AND status ='1'",
        null);
  }

  Future salesmanHistorySearch(text) async {
    var client = await db;
    return client.rawQuery(
        "SELECT * FROM tb_tran_head WHERE store_name LIKE '%$text%'", null);
  }

  Future categSearch(text) async {
    var client = await db;
    return client.rawQuery(
        "SELECT * FROM tbl_category_masterfile WHERE category_name LIKE '%$text%'",
        null);
  }

  Future storeSearch(text) async {
    var client = await db;
    return client.rawQuery(
        "SELECT * FROM tb_tran_head WHERE store_name LIKE '%$text%' AND tran_stat ='Approved' AND hepe_upload = 'FALSE'  ORDER BY store_name ASC",
        null);
  }

  //OLD LOGIN CODE WITHOUT ACCOUNT LOCKED
  // Future salesmanLogin(username, password) async {
  //   var client = await db;
  //   var passwordF = md5.convert(utf8.encode(password));
  //   var res = client.rawQuery(
  //       "SELECT * FROM salesman_lists WHERE username = '$username' AND password = '$passwordF'",
  //       null);
  //   return res;
  // }
  Future salesmanLogin(username, password) async {
    var client = await db;
    var emp = '';
    var passwordF = md5.convert(utf8.encode(password));
    List<Map> res = await client.rawQuery(
        'SELECT username, (1) as attempt,(0) as success FROM xt_sm_list WHERE username = "$username"',
        null);
    if (res.isEmpty) {
      return emp;
    } else {
      var rsp = await client.rawQuery(
          'SELECT *,(1) as success FROM xt_sm_list WHERE username = "$username" AND password = "$passwordF" ',
          null);
      if (rsp.isEmpty) {
        return res;
      } else {
        return rsp;
      }
    }
  }

  //OLD LOGIN CODE WITHOUT ACCOUNT LOCKED
  // Future hepeLogin(username, password) async {
  //   var client = await db;
  //   var passwordF = md5.convert(utf8.encode(password));
  //   var res = client.rawQuery(
  //       "SELECT * FROM tbl_hepe_de_viaje WHERE username = '$username' AND password = '$passwordF'",
  //       null);
  //   return res;
  // }

  Future hepeLogin(username, password) async {
    var client = await db;
    var emp = '';
    var passwordF = md5.convert(utf8.encode(password));
    List<Map> res = await client.rawQuery(
        'SELECT username, (1) as attempt,(0) as success FROM tbl_hepe_de_viaje WHERE username = "$username"',
        null);
    if (res.isEmpty) {
      return emp;
    } else {
      var rsp = await client.rawQuery(
          'SELECT *,(1) as success FROM tbl_hepe_de_viaje WHERE username = "$username" AND password = "$passwordF" ',
          null);
      if (rsp.isEmpty) {
        return res;
      } else {
        return rsp;
      }
    }
  }

  Future getAllTran() async {
    var client = await db;
    return client.rawQuery('SELECT * FROM tb_tran_head ORDER BY id ASC', null);
  }

  Future getTodayBooked(id) async {
    String orderby = "Salesman";
    String date = DateFormat("yyyy-MM-dd").format(DateTime.now());
    var client = await db;
    return client.rawQuery(
        'SELECT tran_no,tot_amt FROM tb_tran_head WHERE sm_code ="$id" AND order_by="$orderby" AND (strftime("%Y-%m-%d", date_req)="$date") AND sm_upload ="TRUE" ORDER BY tran_no ASC',
        null);
  }

  Future getWeeklyBooked(id, d1, d2) async {
    String weekstart = DateFormat("yyyy-MM-dd").format(d1);
    String weekend = DateFormat("yyyy-MM-dd").format(d2);

    String orderby = 'Salesman';
    var client = await db;
    return client.rawQuery(
        'SELECT tran_no,tot_amt FROM tb_tran_head WHERE sm_code ="$id" AND order_by="$orderby" AND (strftime("%Y-%m-%d", date_req)>="$weekstart") AND (strftime("%Y-%m-%d", date_req)<="$weekend") AND sm_upload ="TRUE"',
        null);
  }

  Future getMonthlyBooked(id) async {
    String date = DateFormat("yyyy-MM").format(DateTime.now());
    String orderby = 'Salesman';
    var client = await db;
    return client.rawQuery(
        'SELECT tran_no,tot_amt FROM tb_tran_head WHERE sm_code ="$id" AND order_by="$orderby"  AND (strftime("%Y-%m", date_req)="$date") AND sm_upload ="TRUE"',
        null);
  }

  Future getYearlyBooked(id) async {
    String date = DateFormat("yyyy").format(DateTime.now());
    String orderby = 'Salesman';
    var client = await db;
    return client.rawQuery(
        'SELECT tran_no,tot_amt FROM tb_tran_head WHERE sm_code ="$id" AND order_by="$orderby"  AND (strftime("%Y", date_req)="$date") AND sm_upload ="TRUE"',
        null);
  }

  ///
  ///
  ///
  ///
  ///
  /// MYSQL CODE
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  Future checkSMusername(String username) async {
    var url = Uri.parse('${UrlAddress.url}/checksm');

    final response = await http.post(url,
        headers: {"Accept": "Application/json"},
        body: {'username': encrypt(username)});
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future checkHEPEusername(String username) async {
    var url = Uri.parse('${UrlAddress.url}/checkhepe');
    final response = await http.post(url,
        headers: {"Accept": "Application/json"},
        body: {'username': encrypt(username)});
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future viewCustomersList(String code) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM customer_master_files WHERE salesman_code = "$code" ORDER BY doc_no ASC LIMIT 100',
        null);
  }

  Future viewAllCustomers() async {
    var client = await db;
    return client.rawQuery(
        "SELECT * FROM customer_master_files WHERE status ='1' ORDER BY doc_no ASC LIMIT 100",
        null);
  }

  Future viewMultiCustomersList(String code) async {
    var client = await db;
    return client.rawQuery(
        "SELECT * FROM customer_master_files WHERE account_code = '$code' AND status='1' ORDER BY doc_no ASC LIMIT 100",
        null);
  }

  Future getSalesmanList(BuildContext context) async {
    // String url = UrlAddress.url + '/getsalesmanlist';
    try {
      var url = Uri.parse('${UrlAddress.url}/getXTsalesmanlist');
      final response = await retry(() =>
          http.post(url, headers: {"Accept": "Application/json"}, body: {}));
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(response.body);
        return convertedDatatoJson;
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
      // getSalesmanList(context);
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
          const Text("Format exception error occured. Please try again later.",
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

  Future getHepeList(BuildContext context) async {
    try {
      var url = Uri.parse('${UrlAddress.url}/gethepelist');
      final response = await retry(() =>
          http.post(url, headers: {"Accept": "Application/json"}, body: {}));
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(response.body);
        return convertedDatatoJson;
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
          const Text("Format exception error occured. Please try again later.",
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

  Future getCustomersList(BuildContext context) async {
    try {
      var url = Uri.parse('${UrlAddress.url}/getcustomerslist');
      final response = await retry(() =>
          http.post(url, headers: {"Accept": "Application/json"}, body: {}));
      // var convertedDatatoJson = jsonDecode(decrypt(response.body));
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(response.body);
        return convertedDatatoJson;
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
          const Text("Format exception error occured. Please try again later.",
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

  Future getDiscountList(BuildContext context) async {
    try {
      var url = Uri.parse('${UrlAddress.url}/getprincipaldiscount');
      final response = await retry(() =>
          http.post(url, headers: {"Accept": "Application/json"}, body: {}));
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(response.body);
        return convertedDatatoJson;
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
          const Text("Format exception error occured. Please try again later.",
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

  Future getBankListonLine(BuildContext context) async {
    try {
      var url = Uri.parse('${UrlAddress.url}/getbanklist');
      final response = await retry(() =>
          http.post(url, headers: {"Accept": "Application/json"}, body: {}));
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(response.body);
        return convertedDatatoJson;
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
          const Text("Format exception error occured. Please try again later.",
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

  Future getOrderLimitonLine(BuildContext context) async {
    try {
      var url = Uri.parse('${UrlAddress.url}/getsmorderlimit');
      final response = await retry(() =>
          http.post(url, headers: {"Accept": "Application/json"}, body: {}));
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(response.body);
        return convertedDatatoJson;
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
          const Text("Format exception error occured. Please try again later.",
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

  Future getUserAccessonLine(BuildContext context) async {
    try {
      var url = Uri.parse('${UrlAddress.url}/getuseraccesslist');
      final response = await retry(() =>
          http.post(url, headers: {"Accept": "Application/json"}, body: {}));
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(response.body);
        return convertedDatatoJson;
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
          const Text("Format exception error occured. Please try again later.",
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

  Future getSalesTypeListonLine(BuildContext context) async {
    try {
      var url = Uri.parse('${UrlAddress.url}/getallsalestype');
      final response = await retry(() =>
          http.post(url, headers: {"Accept": "Application/json"}, body: {}));
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(response.body);
        return convertedDatatoJson;
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
          const Text("Format exception error occured. Please try again later.",
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

  // Future getChequeList() async {
  //   // String url = UrlAddress.url + '/getchequedata';
  //   var url = Uri.parse(UrlAddress.url + '/getchequedata');
  //   final response = await retry(() =>
  //       http.post(url, headers: {"Accept": "Application/json"}, body: {}));
  //   var convertedDatatoJson = jsonDecode(decrypt(response.body));
  //   return convertedDatatoJson;
  // }

  Future getItemList(BuildContext context) async {
    try {
      var url = Uri.parse('${UrlAddress.url}/getitemlist');
      final response = await retry(() =>
          http.post(url, headers: {"Accept": "Application/json"}, body: {}));
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(response.body);
        return convertedDatatoJson;
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
          const Text("Format exception error occured. Please try again later.",
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

  Future getBcomItemList(BuildContext context) async {
    try {
      var url = Uri.parse('${UrlAddress.url}/getbcomitemlist');
      final response = await retry(() =>
          http.post(url, headers: {"Accept": "Application/json"}, body: {}));
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(response.body);
        return convertedDatatoJson;
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
          const Text("Format exception error occured. Please try again later.",
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

  Future getBulkItemList(BuildContext context) async {
    try {
      var url = Uri.parse('${UrlAddress.url}/getbulkitemlist');
      final response = await retry(() =>
          http.post(url, headers: {"Accept": "Application/json"}, body: {}));
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(response.body);
        return convertedDatatoJson;
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
          const Text("Format exception error occured. Please try again later.",
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

  Future getItemImgList(BuildContext context) async {
    try {
      var url = Uri.parse('${UrlAddress.url}/getitemimglist');
      final response = await retry(() =>
          http.post(url, headers: {"Accept": "Application/json"}, body: {}));
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(response.body);
        return convertedDatatoJson;
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
          const Text("Format exception error occured. Please try again later.",
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

  Future getAllItemImgList(BuildContext context) async {
    try {
      var url = Uri.parse('${UrlAddress.url}/getallitemimglist');
      final response = await retry(() =>
          http.post(url, headers: {"Accept": "Application/json"}, body: {}));
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(response.body);
        return convertedDatatoJson;
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
          const Text("Format exception error occured. Please try again later.",
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

  Future getCategList(BuildContext context) async {
    try {
      var url = Uri.parse('${UrlAddress.url}/getcateglist');
      final response = await retry(() =>
          http.post(url, headers: {"Accept": "Application/json"}, body: {}));
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(response.body);
        return convertedDatatoJson;
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
          const Text("Format exception error occured. Please try again later.",
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

  Future getTranHead(BuildContext context, String code) async {
    try {
      var url = Uri.parse('${UrlAddress.url}/getalltranhead');
      final response = await retry(() => http.post(url,
          headers: {"Accept": "Application/json"},
          body: {'sm_code': encrypt(code)}));
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(decrypt(response.body));
        return convertedDatatoJson;
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
          const Text("Format exception error occured. Please try again later.",
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

  Future getHepeTranHead(BuildContext context) async {
    try {
      var url = Uri.parse('${UrlAddress.url}/gethepetranhead');
      final response = await retry(() =>
          http.post(url, headers: {"Accept": "Application/json"}, body: {}));
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(decrypt(response.body));
        return convertedDatatoJson;
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
          const Text("Format exception error occured. Please try again later.",
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

  Future getTranLine(BuildContext context) async {
    try {
      var url = Uri.parse('${UrlAddress.url}/getalltranline');
      final response = await retry(() =>
          http.post(url, headers: {"Accept": "Application/json"}, body: {}));
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(decrypt(response.body));
        return convertedDatatoJson;
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
          const Text("Format exception error occured. Please try again later.",
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

  Future getUnservedList(BuildContext context) async {
    try {
      var url = Uri.parse('${UrlAddress.url}/getunservedlist');
      final response = await retry(() =>
          http.post(url, headers: {"Accept": "Application/json"}, body: {}));
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(decrypt(response.body));
        return convertedDatatoJson;
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
          const Text("Format exception error occured. Please try again later.",
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

  Future getReturnedTranList(BuildContext context) async {
    try {
      var url = Uri.parse('${UrlAddress.url}/getreturnedlist');
      final response = await retry(() =>
          http.post(url, headers: {"Accept": "Application/json"}, body: {}));
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(decrypt(response.body));
        return convertedDatatoJson;
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
          const Text("Format exception error occured. Please try again later.",
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

  Future saveTransactions(
      BuildContext context,
      String userId,
      String date,
      String custId,
      String storeName,
      String payment,
      String itmcount,
      String totamt,
      String stat,
      String signature,
      String smStat,
      String hepeStat,
      List line) async {
    try {
      var url = Uri.parse('${UrlAddress.url}/addtransactions');
      final response = await retry(() => http.post(url, headers: {
            "Accept": "Application/json"
          }, body: {
            'sm_code': encrypt(userId),
            'date_req': encrypt(date),
            'account_code': encrypt(custId),
            'store_name': encrypt(storeName),
            'p_meth': encrypt(payment),
            'itm_count': encrypt(itmcount),
            'tot_amt': encrypt(totamt),
            'tran_stat': encrypt(stat),
            'auth_signature': encrypt(signature),
            'sm_upload': encrypt(smStat),
            'hepe_upload': encrypt(hepeStat),
            'line': jsonEncode(line),
          }));
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(response.body);
        return convertedDatatoJson;
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
          const Text("Format exception error occured. Please try again later.",
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

  // Future saveTransactionHead(
  //     String userId,
  //     String date,
  //     String custId,
  //     String storeName,
  //     String payment,
  //     String itmcount,
  //     String totamt,
  //     String stat,
  //     String signature,
  //     String smStat,
  //     String hepeStat) async {
  //   // String url = UrlAddress.url + '/addtranhead';
  //   var url = Uri.parse(UrlAddress.url + '/addtranhead');
  //   final response = await retry(() => http.post(url, headers: {
  //         "Accept": "Application/json"
  //       }, body: {
  //         'sm_code': encrypt(userId),
  //         'date_req': encrypt(date),
  //         'account_code': encrypt(custId),
  //         'store_name': encrypt(storeName),
  //         'p_meth': encrypt(payment),
  //         'itm_count': encrypt(itmcount),
  //         'tot_amt': encrypt(totamt),
  //         'tran_stat': encrypt(stat),
  //         'auth_signature': encrypt(signature),
  //         'sm_upload': encrypt(smStat),
  //         'hepe_upload': encrypt(hepeStat),
  //       }));
  //   var convertedDatatoJson = jsonDecode(response.body);
  //   return convertedDatatoJson;
  // }

  // Future saveTransactionLine(
  //     String tranNo,
  //     String itmcode,
  //     String desc,
  //     String qty,
  //     String uom,
  //     String amt,
  //     String totamt,
  //     String categ,
  //     String code,
  //     String date) async {
  //   // String url = UrlAddress.url + '/addtranline';
  //   var url = Uri.parse(UrlAddress.url + '/addtranline');
  //   final response = await retry(() => http.post(url, headers: {
  //         "Accept": "Application/json"
  //       }, body: {
  //         'tran_no': encrypt(tranNo),
  //         'itm_code': encrypt(itmcode),
  //         'item_desc': encrypt(desc),
  //         'req_qty': encrypt(qty),
  //         'uom': encrypt(uom),
  //         'amt': encrypt(amt),
  //         'tot_amt': encrypt(totamt),
  //         'itm_cat': encrypt(categ),
  //         'account_code': encrypt(code),
  //         'date_req': encrypt(date),
  //       }));
  //   var convertedDatatoJson = jsonDecode(response.body);
  //   return convertedDatatoJson;
  // }

  Future checkStat() async {
    try {
      // String url = UrlAddress.url + '/checkstat';
      var url = Uri.parse('${UrlAddress.url}/checkstat');
      final response = await http
          .post(url, headers: {"Accept": "Application/json"}, body: {});
      var convertedDatatoJson = jsonDecode(response.body);
      return convertedDatatoJson;
    } on SocketException {
      return 'ERROR1';
    } on HttpException {
      return 'ERROR2';
    } on FormatException {
      return 'ERROR3';
    }
  }

  /////////
  /////////
  /////////
  //////// HEPE DE VIAJE CODE
  /////////
  /////////
  /////////

  // Future getPendingOrders() async {
  //   var client = await db;
  //   return client.rawQuery(
  //       'SELECT * FROM tb_tran_head WHERE tran_stat ="Pending" ORDER BY store_name ASC',
  //       null);
  // }

  Future checkDiscounted(id) async {
    var client = await db;
    List<Map> res = await client.rawQuery(
        'SELECT * FROM tbl_discounts WHERE cus_id ="$id"', null);
    if (res.isNotEmpty) {
      return "TRUE";
    } else {
      return "FALSE";
    }
  }

  Future getCustInfo(code) async {
    var client = await db;
    return client.rawQuery(
        'SELECT address1,address2,address3,cus_mobile_number,customer_id FROM customer_master_files WHERE account_code ="$code"',
        null);
  }

  Future getOrders(tran) async {
    var client = await db;
    return client.rawQuery(
        'SELECT *,(req_qty - del_qty) as outstock,(del_qty) as temp_qty FROM tb_tran_line WHERE tran_no ="$tran" ORDER BY nav_invoice_no ASC',
        null);
  }

  Future getAll(tran) async {
    var client = await db;
    return client.rawQuery('SELECT * FROM tb_tran_line', null);
  }

  Future addtoUnserved(tranNo, itemCode, itemDesc, itemUom, itemAmt, itemQty,
      totAmt, itemCat) async {
    int fqty = 0;
    double ftotal = 0.00;
    String itmStat = "Returned";
    String date = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
    var client = await db;

    List<Map> res = await client.rawQuery(
        'SELECT * FROM tb_unserved_items WHERE tran_no ="$tranNo" AND itm_code ="$itemCode" AND  uom = "$itemUom" AND itm_stat = "$itmStat"',
        null);
    if (res.isEmpty) {
      return client.insert('tb_unserved_items', {
        'tran_no': tranNo,
        'date': date,
        'itm_code': itemCode,
        'item_desc': itemDesc,
        'qty': itemQty,
        'uom': itemUom,
        'amt': itemAmt,
        'tot_amt': totAmt,
        'itm_cat': itemCat,
        'itm_stat': itmStat,
      });
    } else {
      for (var element in res) {
        fqty = int.parse(element['qty']);
        ftotal = double.parse(element['tot_amt']);
      }
      return client.update(
          'tb_unserved_items',
          {
            'qty': (fqty + int.parse(itemQty)).toString(),
            'tot_amt': (ftotal + double.parse(totAmt)).toString()
          },
          where: 'tran_no = ? AND itm_stat = ? AND itm_code = ? AND uom = ?',
          whereArgs: [tranNo, itmStat, itemCode, itemUom]);
    }
  }

  Future addtoReturnLine(
      tran, itmcode, desc, uom, amt, qty, itmtotal, categ) async {
    String stat = 'Returned';
    var client = await db;
    return client.insert('tb_unserved_items', {
      'tran_no': tran,
      'itm_code': itmcode,
      'item_desc': desc,
      'uom': uom,
      'amt': amt,
      'qty': qty,
      'tot_amt': itmtotal,
      'itm_cat': categ,
      'itm_stat': stat,
    });
  }

  Future addtoReturnedTran(tranNo, accountCode, storeName, itemCount, totAmt,
      hepeCode, reason, sign) async {
    String stat = 'FALSE';
    String date = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
    var client = await db;

    return client.insert('tb_returned_tran', {
      'tran_no': tranNo,
      'date': date,
      'account_code': accountCode,
      'store_name': storeName,
      'itm_count': itemCount,
      'tot_amt': totAmt,
      'hepe_code': hepeCode,
      'reason': reason,
      'signature': sign,
      'uploaded': stat
    });
  }

  Future updateReturnStatus(tranNo, hepeCode, status, amount, sign) async {
    var client = await db;
    String date = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());

    return client.update(
        'tb_tran_head',
        {
          'tran_stat': status,
          'hepe_code': hepeCode,
          'tot_del_amt': amount,
          'date_del': date,
          'signature': sign,
        },
        where: 'tran_no = ?',
        whereArgs: [tranNo]);
  }

  Future getStatus(
      tranNo, status, amt, itmdelcount, hepecode, type, sign) async {
    var client = await db;
    String date = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());

    return client.update(
        'tb_tran_head',
        {
          'tran_stat': status,
          'tot_del_amt': amt,
          'date_del': date,
          'itm_del_count': itmdelcount,
          'hepe_code': hepecode,
          'pmeth_type': type,
          'signature': sign,
        },
        where: 'tran_no = ?',
        whereArgs: [tranNo]);
  }

  Future updateLineStatus(tranNo, status, date) async {
    var client = await db;

    return client.update(
        'tb_tran_line',
        {
          'itm_stat': status,
          'date_del': date,
        },
        where: 'tran_no = ?',
        whereArgs: [tranNo]);
  }

  Future addCheque(
      tranNo,
      accountcode,
      smcode,
      hepecode,
      datetime,
      payeename,
      payorname,
      bankname,
      chequeno,
      branchno,
      accountno,
      chequedate,
      amount,
      status,
      img) async {
    var client = await db;
    String date = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
    return client.insert('tb_cheque_data', {
      'tran_no': tranNo,
      'account_code': accountcode,
      'sm_code': smcode,
      'hepe_code': hepecode,
      'datetime': date,
      'payee_name': payeename,
      'payor_name': payorname,
      'bank_name': bankname,
      'cheque_no': chequeno,
      'branch_code': branchno,
      'account_no': accountno,
      'cheque_date': chequedate,
      'amount': amount,
      'status': status,
      'image': img,
    });
  }

  Future getBankList() async {
    var client = await db;
    return client.rawQuery('SELECT * FROM tb_bank_list ', null);
  }

  Future checkChequeNo(chequeNum, smCode) async {
    var client = await db;
    List<Map> res = await client.rawQuery(
        'SELECT * FROM tb_cheque_data WHERE cheque_no ="$chequeNum" AND sm_code!="$smCode"',
        null);
    if (res.isNotEmpty) {
      return "Already Used";
    } else {
      return "No Transaction";
    }
  }

  Future getChequeData(tranNo) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM tb_cheque_data WHERE tran_no ="$tranNo"', null);
  }

  Future getUnservedOrders(tranNo) async {
    String stat = 'Unserved';
    var client = await db;
    return client.rawQuery(
        'SELECT *,tb_tran_head.tran_stat FROM tb_unserved_items INNER JOIN tb_tran_head on tb_tran_head.tran_no = tb_unserved_items.tran_no WHERE tb_unserved_items.tran_no ="$tranNo" AND tb_unserved_items.itm_stat = "$stat"  ORDER BY doc_no ASC',
        null);
  }

  Future getReturnedOrders(tranNo) async {
    String stat = 'Returned';
    var client = await db;
    return client.rawQuery(
        'SELECT *,tb_tran_head.tran_stat FROM tb_unserved_items INNER JOIN tb_tran_head on tb_tran_head.tran_no = tb_unserved_items.tran_no WHERE tb_unserved_items.tran_no ="$tranNo" AND tb_unserved_items.itm_stat = "$stat"  ORDER BY doc_no ASC',
        null);
  }

  Future getDeliveredOrders(tranNo) async {
    String stat = 'Delivered';
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM tb_tran_line  WHERE tran_no ="$tranNo" AND itm_stat = "$stat" ORDER BY doc_no ASC',
        null);
  }

  Future checkChanges(tranNo) async {
    String stat = 'Returned';
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM tb_unserved_items WHERE tb_unserved_items.tran_no ="$tranNo" AND tb_unserved_items.itm_stat = "$stat"  ORDER BY doc_no ASC',
        null);
  }

  Future setChequeData(
      String tranNo,
      String accountCode,
      String smCode,
      String hepeCode,
      String datetime,
      String payeeName,
      String payorName,
      String bankName,
      String chequeNo,
      String branchCode,
      String accountNo,
      String chequeDate,
      String amount,
      String status,
      String img) async {
    // String url = UrlAddress.url + '/addcheque';
    var url = Uri.parse('${UrlAddress.url}/addcheque');
    final response = await retry(() => http.post(url, headers: {
          "Accept": "Application/json"
        }, body: {
          'tran_no': tranNo,
          'account_code': accountCode,
          'sm_code': smCode,
          'hepe_code': hepeCode,
          'datetime': datetime,
          'payee_name': payeeName,
          'payor_name': payorName,
          'bank_name': bankName,
          'cheque_no': chequeNo,
          'branch_code': branchCode,
          'account_no': accountNo,
          'cheque_date': chequeDate,
          'amount': amount,
          'status': status,
          'image': img,
        }));
    var convertedDatatoJson = jsonDecode(response.body);
    return convertedDatatoJson;
  }

  Future viewStatus() async {
    var client = await db;
    return client.rawQuery('SELECT * FROM tb_returned_tran', null);
    // return client.rawQuery(
    //     'SELECT * FROM tb_tran_head WHERE tran_stat ="Delivered" OR tran_stat="Returned"',
    //     null);
  }

  Future getRemovedOrders() async {
    var client = await db;
    return client.rawQuery('SELECT * FROM tb_unserved_items', null);
    // return client.rawQuery(
    //     'SELECT * FROM tb_tran_head WHERE tran_stat ="Delivered" OR tran_stat="Returned"',
    //     null);
  }

  Future ofFetchSampleLine(tranNo) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM tb_tran_line WHERE tran_no ="$tranNo"', null);
  }

  Future ofFetchSampleTable() async {
    var client = await db;
    return client.rawQuery(
        'SELECT tran_no FROM tb_tran_line WHERE doc_no!=" "', null);
  }

  //////
  ///HEPE API
  ///
  // Future oldupdateTranStat(
  //     String tranNo,
  //     String status,
  //     String itmdel,
  //     String amt,
  //     String date,
  //     String hepecode,
  //     String type,
  //     String signature) async {
  //   // String url = UrlAddress.url + '/updatetranstat';
  //   var url = Uri.parse(UrlAddress.url + '/updatetranstat');
  //   final response = await retry(() => http.post(url, headers: {
  //         "Accept": "Application/json"
  //       }, body: {
  //         'tran_no': encrypt(tranNo),
  //         'tran_stat': encrypt(status),
  //         'itm_del_count': encrypt(itmdel),
  //         'tot_del_amt': encrypt(amt),
  //         'date_del': encrypt(date),
  //         'hepe_code': encrypt(hepecode),
  //         'pmeth_type': encrypt(type),
  //         'signature': encrypt(signature),
  //       }));
  //   var convertedDatatoJson = jsonDecode(response.body);
  //   return convertedDatatoJson;
  // }

  Future updateDeliveredTranStat(
      BuildContext context,
      String tranNo,
      String status,
      String itmdel,
      String amt,
      String date,
      String hepecode,
      String type,
      String signature,
      List tranLine,
      List unsLine) async {
    try {
      var url = Uri.parse('${UrlAddress.url}/updatedeliveredtranstatwithline');
      final response = await retry(() => http.post(url, headers: {
            "Accept": "Application/json"
          }, body: {
            'tran_no': encrypt(tranNo),
            'tran_stat': encrypt(status),
            'itm_del_count': encrypt(itmdel),
            'tot_del_amt': encrypt(amt),
            'date_del': encrypt(date),
            'hepe_code': encrypt(hepecode),
            'pmeth_type': encrypt(type),
            'signature': encrypt(signature),
            'tranline': jsonEncode(tranLine),
            'unsline': jsonEncode(unsLine),
          }));
      var convertedDatatoJson = jsonDecode(response.body);
      return convertedDatatoJson;
      // if (response.statusCode == 200) {
      //   var convertedDatatoJson = jsonDecode(response.body);
      //   return convertedDatatoJson;
      // } else if (response.statusCode >= 400 || response.statusCode <= 499) {
      //   customModal(
      //       context,
      //       Icon(CupertinoIcons.exclamationmark_circle,
      //           size: 50, color: Colors.red),
      //       Text(
      //           "Error: ${response.statusCode}. Your client has issued a malformed or illegal request.",
      //           textAlign: TextAlign.center),
      //       true,
      //       Icon(
      //         CupertinoIcons.checkmark_alt,
      //         size: 25,
      //         color: Colors.greenAccent,
      //       ),
      //       '',
      //       () {});
      // } else if (response.statusCode >= 500 || response.statusCode <= 599) {
      //   customModal(
      //       context,
      //       Icon(CupertinoIcons.exclamationmark_circle,
      //           size: 50, color: Colors.red),
      //       Text("Error: ${response.statusCode}. Internal server error.",
      //           textAlign: TextAlign.center),
      //       true,
      //       Icon(
      //         CupertinoIcons.checkmark_alt,
      //         size: 25,
      //         color: Colors.greenAccent,
      //       ),
      //       '',
      //       () {});
      // }
    } on TimeoutException {
      // customModal(
      //     context,
      //     Icon(CupertinoIcons.exclamationmark_circle,
      //         size: 50, color: Colors.red),
      //     Text(
      //         "Connection timed out. Please check internet connection or proxy server configurations.",
      //         textAlign: TextAlign.center),
      //     true,
      //     Icon(
      //       CupertinoIcons.checkmark_alt,
      //       size: 25,
      //       color: Colors.greenAccent,
      //     ),
      //     'Okay',
      //     () {});
    } on SocketException {
      // customModal(
      //     context,
      //     Icon(CupertinoIcons.exclamationmark_circle,
      //         size: 50, color: Colors.red),
      //     Text(
      //         "Connection timed out. Please check internet connection or proxy server configurations.",
      //         textAlign: TextAlign.center),
      //     true,
      //     Icon(
      //       CupertinoIcons.checkmark_alt,
      //       size: 25,
      //       color: Colors.greenAccent,
      //     ),
      //     'Okay',
      //     () {});
    } on HttpException {
      // customModal(
      //     context,
      //     Icon(CupertinoIcons.exclamationmark_circle,
      //         size: 50, color: Colors.red),
      //     Text("An HTTP error eccured. Please try again later.",
      //         textAlign: TextAlign.center),
      //     true,
      //     Icon(
      //       CupertinoIcons.checkmark_alt,
      //       size: 25,
      //       color: Colors.greenAccent,
      //     ),
      //     'Okay',
      //     () {});
    } on FormatException {
      // customModal(
      //     context,
      //     Icon(CupertinoIcons.exclamationmark_circle,
      //         size: 50, color: Colors.red),
      //     Text("Format exception error occured. Please try again later.",
      //         textAlign: TextAlign.center),
      //     true,
      //     Icon(
      //       CupertinoIcons.checkmark_alt,
      //       size: 25,
      //       color: Colors.greenAccent,
      //     ),
      //     'Okay',
      //     () {});
    }
  }

  Future updateReturnedTranStat(
      BuildContext context,
      String tranNo,
      String status,
      // String itmdel,
      String amt,
      String date,
      String hepecode,
      // String type,
      String signature,
      List rettran,
      List retline) async {
    try {
      var url = Uri.parse('${UrlAddress.url}/updatereturnedtranstatwithline');
      final response = await retry(() => http.post(url, headers: {
            "Accept": "Application/json"
          }, body: {
            'tran_no': encrypt(tranNo),
            'tran_stat': encrypt(status),
            // 'itm_del_count': encrypt(itmdel),
            'tot_del_amt': encrypt(amt),
            'date_del': encrypt(date),
            'hepe_code': encrypt(hepecode),
            // 'pmeth_type': encrypt(type),
            'signature': encrypt(signature),
            'rettran': jsonEncode(rettran),
            'retline': jsonEncode(retline),
          }));
      var convertedDatatoJson = jsonDecode(response.body);
      return convertedDatatoJson;
    } on TimeoutException {
    } on SocketException {
    } on HttpException {
    } on FormatException {}
  }

  Future getConversionLine(BuildContext context, code) async {
    try {
      var url = Uri.parse('${UrlAddress.url}/getconversionline');
      final response = await retry(() => http.post(url,
          headers: {"Accept": "Application/json"},
          body: {'sm_code': encrypt(code)}));
      var convertedDatatoJson = jsonDecode(decrypt(response.body));
      return convertedDatatoJson;
    } on TimeoutException {
    } on SocketException {
    } on HttpException {
    } on FormatException {}
  }

  Future getConversionHead(BuildContext context, code) async {
    try {
      var url = Uri.parse('${UrlAddress.url}/getconversionhead');
      final response = await retry(() => http.post(url,
          headers: {"Accept": "Application/json"},
          body: {'sm_code': encrypt(code)}));
      var convertedDatatoJson = jsonDecode(decrypt(response.body));
      return convertedDatatoJson;
    } on TimeoutException {
    } on SocketException {
    } on HttpException {
    } on FormatException {}
  }

  Future getLoadLedger(BuildContext context, code) async {
    try {
      var url = Uri.parse('${UrlAddress.url}/getloadledger');
      final response = await retry(() => http.post(url,
          headers: {"Accept": "Application/json"},
          body: {'sm_code': encrypt(code)}));
      var convertedDatatoJson = jsonDecode(decrypt(response.body));
      return convertedDatatoJson;
    } on TimeoutException {
    } on SocketException {
    } on HttpException {
    } on FormatException {}
  }

  // Future getRevolvingLedger(BuildContext context, code) async {
  //   try {
  //     var url = Uri.parse('${UrlAddress.url}/getrevolvingledger');
  //     final response = await retry(() => http.post(url,
  //         headers: {"Accept": "Application/json"},
  //         body: {'sm_code': encrypt(code)}));
  //     var convertedDatatoJson = jsonDecode(decrypt(response.body));
  //     return convertedDatatoJson;
  //   } on TimeoutException {
  //   } on SocketException {
  //   } on HttpException {
  //   } on FormatException {}
  // }

  // Future getRevolvingFund(BuildContext context, code) async {
  //   try {
  //     var url = Uri.parse('${UrlAddress.url}/getrevolvingfund');
  //     final response = await retry(() => http.post(url,
  //         headers: {"Accept": "Application/json"},
  //         body: {'sm_code': encrypt(code)}));
  //     var convertedDatatoJson = jsonDecode(decrypt(response.body));
  //     return convertedDatatoJson;
  //   } on TimeoutException {
  //   } on SocketException {
  //   } on HttpException {
  //   } on FormatException {}
  // }

  Future getCashLedgerOnline(BuildContext context, code) async {
    try {
      var url = Uri.parse('${UrlAddress.url}/getcashledger');
      final response = await retry(() => http.post(url,
          headers: {"Accept": "Application/json"},
          body: {'sm_code': encrypt(code)}));
      var convertedDatatoJson = jsonDecode(decrypt(response.body));
      return convertedDatatoJson;
    } on TimeoutException {
    } on SocketException {
    } on HttpException {
    } on FormatException {}
  }

  Future getSmLoad(BuildContext context, code) async {
    try {
      var url = Uri.parse('${UrlAddress.url}/getsmload');
      final response = await retry(() => http.post(url,
          headers: {"Accept": "Application/json"},
          body: {'sm_code': encrypt(code)}));
      var convertedDatatoJson = jsonDecode(decrypt(response.body));
      return convertedDatatoJson;
    } on TimeoutException {
    } on SocketException {
    } on HttpException {
    } on FormatException {}
  }

  Future getSmBalance(BuildContext context, code) async {
    try {
      var url = Uri.parse('${UrlAddress.url}/getsmbalance');
      final response = await retry(() => http.post(url,
          headers: {"Accept": "Application/json"},
          body: {'sm_code': encrypt(code)}));
      var convertedDatatoJson = jsonDecode(decrypt(response.body));
      return convertedDatatoJson;
    } on TimeoutException {
    } on SocketException {
    } on HttpException {
    } on FormatException {}
  }

  //UPDATING TRANSACTIONS
  Future getTranCheque(BuildContext context, code, type, date1, date2) async {
    try {
      var url = Uri.parse('${UrlAddress.url}/gettrancheque');
      final response = await retry(() => http.post(
            url,
            headers: {"Accept": "Application/json"},
            body: {
              'sm_code': encrypt(code),
              'type': encrypt(type),
              'date1': encrypt(date1),
              'date2': encrypt(date2),
            },
          ));
      var convertedDatatoJson = jsonDecode(decrypt(response.body));
      return convertedDatatoJson;
    } on TimeoutException {
    } on SocketException {
    } on HttpException {
    } on FormatException {}
  }

  Future getXtTranLine(BuildContext context, code, type, date1, date2) async {
    try {
      var url = Uri.parse('${UrlAddress.url}/getxttranline');
      final response = await retry(() => http.post(
            url,
            headers: {"Accept": "Application/json"},
            body: {
              'sm_code': encrypt(code),
              'type': encrypt(type),
              'date1': encrypt(date1),
              'date2': encrypt(date2),
            },
          ));
      var convertedDatatoJson = jsonDecode(decrypt(response.body));
      return convertedDatatoJson;
    } on TimeoutException {
    } on SocketException {
    } on HttpException {
    } on FormatException {}
  }

  Future getXtTranHead(BuildContext context, code, type, date1, date2) async {
    try {
      var url = Uri.parse('${UrlAddress.url}/getxttranhead');
      final response = await retry(() => http.post(
            url,
            headers: {"Accept": "Application/json"},
            body: {
              'sm_code': encrypt(code),
              'type': encrypt(type),
              'date1': encrypt(date1),
              'date2': encrypt(date2),
            },
          ));
      var convertedDatatoJson = jsonDecode(decrypt(response.body));
      return convertedDatatoJson;
    } on TimeoutException {
    } on SocketException {
    } on HttpException {
    } on FormatException {}
  }

  Future getXtChequeData(BuildContext context, code, type, date1, date2) async {
    try {
      var url = Uri.parse('${UrlAddress.url}/getxtchequedata');
      final response = await retry(() => http.post(
            url,
            headers: {"Accept": "Application/json"},
            body: {
              'sm_code': encrypt(code),
              'type': encrypt(type),
              'date1': encrypt(date1),
              'date2': encrypt(date2),
            },
          ));
      var convertedDatatoJson = jsonDecode(decrypt(response.body));
      return convertedDatatoJson;
    } on TimeoutException {
    } on SocketException {
    } on HttpException {
    } on FormatException {}
  }

  Future getRmtLine(BuildContext context, code, type, date1, date2) async {
    try {
      var url = Uri.parse('${UrlAddress.url}/getrmtline');
      final response = await retry(() => http.post(
            url,
            headers: {"Accept": "Application/json"},
            body: {
              'sm_code': encrypt(code),
              'type': encrypt(type),
              'date1': encrypt(date1),
              'date2': encrypt(date2),
            },
          ));
      var convertedDatatoJson = jsonDecode(decrypt(response.body));
      return convertedDatatoJson;
    } on TimeoutException {
    } on SocketException {
    } on HttpException {
    } on FormatException {}
  }

  Future getRmtHead(BuildContext context, code, type, date1, date2) async {
    try {
      var url = Uri.parse('${UrlAddress.url}/getrmthead');
      final response = await retry(() => http.post(
            url,
            headers: {"Accept": "Application/json"},
            body: {
              'sm_code': encrypt(code),
              'type': encrypt(type),
              'date1': encrypt(date1),
              'date2': encrypt(date2),
            },
          ));
      var convertedDatatoJson = jsonDecode(decrypt(response.body));
      return convertedDatatoJson;
    } on TimeoutException {
    } on SocketException {
    } on HttpException {
    } on FormatException {}
  }

  Future getRemittance(BuildContext context, code, type, date1, date2) async {
    try {
      var url = Uri.parse('${UrlAddress.url}/getremittance');
      final response = await retry(() => http.post(
            url,
            headers: {"Accept": "Application/json"},
            body: {
              'sm_code': encrypt(code),
              'type': encrypt(type),
              'date1': encrypt(date1),
              'date2': encrypt(date2),
            },
          ));
      var convertedDatatoJson = jsonDecode(decrypt(response.body));
      return convertedDatatoJson;
    } on TimeoutException {
    } on SocketException {
    } on HttpException {
    } on FormatException {}
  }

  // Future updateLineStat(String tranNo, String status, String qty, String totAmt,
  //     String totDiscAmt, String itmcode, String uom, String date) async {
  //   try {
  //     // String url = UrlAddress.url + '/updatelinestat';
  //     var url = Uri.parse(UrlAddress.url + '/updatelinestat');
  //     final response = await http.post(url, headers: {
  //       "Accept": "Application/json"
  //     }, body: {
  //       'tran_no': encrypt(tranNo),
  //       'itm_stat': encrypt(status),
  //       'del_qty': encrypt(qty),
  //       'tot_amt': encrypt(totAmt),
  //       'discounted_amount': encrypt(totDiscAmt),
  //       'itm_code': encrypt(itmcode),
  //       'uom': encrypt(uom),
  //       'date_del': encrypt(date),
  //     });
  //     var convertedDatatoJson = jsonDecode(response.body);
  //     return convertedDatatoJson;
  //   } on SocketException {
  //     return 'ERROR';
  //   } on HttpException {
  //     return 'ERROR';
  //   } on FormatException {
  //     return 'ERROR';
  //   }
  // }

  //FOR ADDING RETURNED TRAN TO SERVER
  // Future setReturnStatus(
  //   String userId,
  //   String date,
  //   String signature,
  //   String accountCode,
  //   String sName,
  //   String itmcount,
  //   String retamt,
  //   String smcode,
  //   String reason,
  // ) async {
  //   // String url = UrlAddress.url + '/setreturnstatus';
  //   var url = Uri.parse(UrlAddress.url + '/setreturnstatus');
  //   final response = await retry(() => http.post(url, headers: {
  //         "Accept": "Application/json"
  //       }, body: {
  //         'tran_no': userId,
  //         'date': date,
  //         'signature': signature,
  //         'account_code': accountCode,
  //         'store_name': sName,
  //         'itm_count': itmcount,
  //         'tot_amt': retamt,
  //         'hepe_code': smcode,
  //         'reason': reason,
  //       }));
  //   var convertedDatatoJson = jsonDecode(response.body);
  //   return convertedDatatoJson;
  // }

  // Future setReturnLineStatus(String tran, String itmcode, String desc,
  //     String uom, String amt, String qty, String itmtotal, String categ) async {
  //   try {
  //     // String url = UrlAddress.url + '/addreturnline';
  //     var url = Uri.parse(UrlAddress.url + '/addreturnline');
  //     final response = await http.post(url, headers: {
  //       "Accept": "Application/json"
  //     }, body: {
  //       'tran_no': tran,
  //       'itm_code': itmcode,
  //       'item_desc': desc,
  //       'uom': uom,
  //       'amt': amt,
  //       'qty': qty,
  //       'tot_amt': itmtotal,
  //       'itm_cat': categ,
  //     });
  //     var convertedDatatoJson = jsonDecode(response.body);
  //     return convertedDatatoJson;
  //   } on SocketException {
  //     return 'ERROR';
  //   } on HttpException {
  //     return 'ERROR';
  //   } on FormatException {
  //     return 'ERROR';
  //   }
  // }

  Future addfav(cusCode, itmCode, uom) async {
    var client = await db;
    return client.insert('tb_favorites', {
      'account_code': cusCode,
      'item_code': itmCode,
      'item_uom': uom,
    });
  }

  Future deleteFav(cusCode, itmCode, uom) async {
    var client = await db;
    return client.rawQuery(
        'DELETE FROM tb_favorites WHERE account_code = "$cusCode" AND item_code= "$itmCode" AND item_uom= "$uom"',
        null);
  }

  Future getFav(code) async {
    var client = await db;
    return client.rawQuery(
        'SELECT *,item_masterfiles.product_name,item_masterfiles.product_family,item_masterfiles.uom,item_masterfiles.list_price_wtax, item_masterfiles.image FROM tb_favorites INNER JOIN item_masterfiles on tb_favorites.item_code = item_masterfiles.itemcode  WHERE tb_favorites.account_code ="$code" AND item_masterfiles.conversion_qty="1"',
        null);
  }

  ////////
  /// HEPE DE VIAJE SALES
  /////////
  ///

  ///
  ///SALES REPORT API
  Future getSalesType() async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM tb_sales_type WHERE categ ="Sales"', null);
  }

  Future getTotalSalesType() async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM tb_sales_type WHERE categ ="Total"', null);
  }

  Future getDailySales(id, type) async {
    String date = DateFormat("yyyy-MM-dd").format(DateTime.now());
    String stat = 'Delivered';
    var client = await db;
    if (type == "OVERALL") {
      return client.rawQuery(
          'SELECT SUM(tb_tran_head.tot_del_amt) as total FROM tb_tran_head WHERE hepe_code ="$id" AND tran_stat="$stat" AND strftime("%Y-%m-%d", date_del)="$date"',
          null);
    } else {
      return client.rawQuery(
          'SELECT SUM(tb_tran_head.tot_del_amt) as total FROM tb_tran_head WHERE hepe_code ="$id" AND tran_stat="$stat" AND pmeth_type="$type" AND (strftime("%Y-%m-%d", date_del)="$date")',
          null);
    }
  }

  Future getWeeklySales(id, type, d1, d2) async {
    String weekstart = DateFormat("yyyy-MM-dd").format(d1);
    String weekend = DateFormat("yyyy-MM-dd").format(d2);
    String stat = 'Delivered';
    var client = await db;

    if (type == "OVERALL") {
      return client.rawQuery(
          'SELECT SUM(tb_tran_head.tot_del_amt) as total FROM tb_tran_head WHERE hepe_code ="$id" AND tran_stat="$stat" AND strftime("%Y-%m-%d", date_del)>="$weekstart" AND strftime("%Y-%m-%d", date_del)<="$weekend"',
          null);
    } else {
      return client.rawQuery(
          'SELECT SUM(tb_tran_head.tot_del_amt) as total FROM tb_tran_head WHERE hepe_code ="$id" AND tran_stat="$stat" AND pmeth_type="$type" AND (strftime("%Y-%m-%d", date_del)>="$weekstart") AND (strftime("%Y-%m-%d", date_del)<="$weekend")',
          null);
    }
  }

  Future getMonthlySales(id, type) async {
    String date = DateFormat("yyyy-MM").format(DateTime.now());
    String stat = 'Delivered';
    var client = await db;
    if (type == "OVERALL") {
      return client.rawQuery(
          'SELECT SUM(tb_tran_head.tot_del_amt) as total FROM tb_tran_head WHERE hepe_code ="$id" AND tran_stat="$stat" AND strftime("%Y-%m", date_del)="$date"',
          null);
    } else {
      return client.rawQuery(
          'SELECT SUM(tb_tran_head.tot_del_amt) as total FROM tb_tran_head WHERE hepe_code ="$id" AND tran_stat="$stat" AND pmeth_type="$type" AND (strftime("%Y-%m", date_del)="$date")',
          null);
    }
  }

  Future getYearlySales(id, type) async {
    String date = DateFormat("yyyy").format(DateTime.now());
    String stat = 'Delivered';
    var client = await db;
    if (type == "OVERALL") {
      return client.rawQuery(
          'SELECT SUM(tb_tran_head.tot_del_amt) as total FROM tb_tran_head WHERE hepe_code ="$id" AND tran_stat="$stat" AND strftime("%Y", date_del)="$date"',
          null);
    } else {
      return client.rawQuery(
          'SELECT SUM(tb_tran_head.tot_del_amt) as total FROM tb_tran_head WHERE hepe_code ="$id" AND tran_stat="$stat" AND pmeth_type="$type" AND (strftime("%Y", date_del)="$date")',
          null);
    }
  }

  Future getCustomerDailySales(id, type) async {
    String date = DateFormat("yyyy-MM-dd").format(DateTime.now());
    String stat = 'Delivered';
    var client = await db;
    if (type == "OVERALL") {
      return client.rawQuery(
          'SELECT tb_tran_head.store_name,SUM(tb_tran_head.tot_del_amt) as total FROM tb_tran_head WHERE hepe_code ="$id" AND tran_stat="$stat" AND strftime("%Y-%m-%d", date_del)="$date" GROUP BY account_code',
          null);
    } else {
      return client.rawQuery(
          'SELECT tb_tran_head.store_name,SUM(tb_tran_head.tot_del_amt) as total FROM tb_tran_head WHERE hepe_code ="$id" AND tran_stat="$stat" AND pmeth_type="$type" AND (strftime("%Y-%m-%d", date_del)="$date") GROUP BY account_code',
          null);
    }
  }

  Future getCustomerWeeklySales(id, type, d1, d2) async {
    String weekstart = DateFormat("yyyy-MM-dd").format(d1);
    String weekend = DateFormat("yyyy-MM-dd").format(d2);
    String stat = 'Delivered';
    var client = await db;

    if (type == "OVERALL") {
      return client.rawQuery(
          'SELECT tb_tran_head.store_name,SUM(tb_tran_head.tot_del_amt) as total FROM tb_tran_head WHERE hepe_code ="$id" AND tran_stat="$stat" AND strftime("%Y-%m-%d", date_del)>="$weekstart" AND strftime("%Y-%m-%d", date_del)<="$weekend" GROUP BY account_code',
          null);
    } else {
      return client.rawQuery(
          'SELECT tb_tran_head.store_name,SUM(tb_tran_head.tot_del_amt) as total FROM tb_tran_head WHERE hepe_code ="$id" AND tran_stat="$stat" AND pmeth_type="$type" AND (strftime("%Y-%m-%d", date_del)>="$weekstart") AND (strftime("%Y-%m-%d", date_del)<="$weekend") GROUP BY account_code',
          null);
    }
  }

  Future getCustomerMonthlySales(id, type) async {
    String date = DateFormat("yyyy-MM").format(DateTime.now());
    String stat = 'Delivered';
    var client = await db;
    if (type == "OVERALL") {
      return client.rawQuery(
          'SELECT tb_tran_head.store_name,SUM(tb_tran_head.tot_del_amt) as total FROM tb_tran_head WHERE hepe_code ="$id" AND tran_stat="$stat" AND strftime("%Y-%m", date_del)="$date" GROUP BY account_code',
          null);
    } else {
      return client.rawQuery(
          'SELECT tb_tran_head.store_name,SUM(tb_tran_head.tot_del_amt) as total FROM tb_tran_head WHERE hepe_code ="$id" AND tran_stat="$stat" AND pmeth_type="$type" AND (strftime("%Y-%m", date_del)="$date") GROUP BY account_code',
          null);
    }
  }

  Future getCustomerYearlySales(id, type) async {
    String date = DateFormat("yyyy").format(DateTime.now());
    String stat = 'Delivered';
    var client = await db;
    if (type == "OVERALL") {
      return client.rawQuery(
          'SELECT tb_tran_head.store_name,SUM(tb_tran_head.tot_del_amt) as total FROM tb_tran_head WHERE hepe_code ="$id" AND tran_stat="$stat" AND strftime("%Y", date_del)="$date" GROUP BY account_code',
          null);
    } else {
      return client.rawQuery(
          'SELECT tb_tran_head.store_name,SUM(tb_tran_head.tot_del_amt) as total FROM tb_tran_head WHERE hepe_code ="$id" AND tran_stat="$stat" AND pmeth_type="$type" AND (strftime("%Y", date_del)="$date") GROUP BY account_code',
          null);
    }
  }

  Future getItemDailySales() async {
    String date = DateFormat("yyyy-MM-dd").format(DateTime.now());
    String stat = 'Delivered';
    var client = await db;
    return client.rawQuery(
        'SELECT *,item_masterfiles.image,SUM(tb_tran_line.del_qty) as total FROM tb_tran_line INNER JOIN item_masterfiles on item_masterfiles.itemcode = tb_tran_line.itm_code AND item_masterfiles.uom =  tb_tran_line.uom WHERE tb_tran_line.itm_stat="$stat" AND strftime("%Y-%m-%d", tb_tran_line.date_del)="$date" GROUP BY tb_tran_line.itm_code',
        null);
  }

  Future getItemWeeklySales(d1, d2) async {
    String weekstart = DateFormat("yyyy-MM-dd").format(d1);
    String weekend = DateFormat("yyyy-MM-dd").format(d2);
    String stat = 'Delivered';
    var client = await db;

    return client.rawQuery(
        'SELECT *,item_masterfiles.image,SUM(tb_tran_line.del_qty) as total FROM tb_tran_line INNER JOIN item_masterfiles on item_masterfiles.itemcode = tb_tran_line.itm_code AND item_masterfiles.uom =  tb_tran_line.uom WHERE tb_tran_line.itm_stat="$stat" AND strftime("%Y-%m-%d", tb_tran_line.date_del)>="$weekstart" AND strftime("%Y-%m-%d", tb_tran_line.date_del)<="$weekend" GROUP BY tb_tran_line.itm_code',
        null);
  }

  Future getItemMonthlySales() async {
    String date = DateFormat("yyyy-MM").format(DateTime.now());
    String stat = 'Delivered';
    var client = await db;
    return client.rawQuery(
        'SELECT *,item_masterfiles.image,SUM(tb_tran_line.del_qty) as total FROM tb_tran_line INNER JOIN item_masterfiles on item_masterfiles.itemcode = tb_tran_line.itm_code AND item_masterfiles.uom =  tb_tran_line.uom WHERE tb_tran_line.itm_stat="$stat" AND strftime("%Y-%m", tb_tran_line.date_del)="$date" GROUP BY tb_tran_line.itm_code',
        null);
  }

  Future getItemYearlySales() async {
    String date = DateFormat("yyyy").format(DateTime.now());
    String stat = 'Delivered';
    var client = await db;
    return client.rawQuery(
        'SELECT *,item_masterfiles.image,SUM(tb_tran_line.del_qty) as total FROM tb_tran_line INNER JOIN item_masterfiles on item_masterfiles.itemcode = tb_tran_line.itm_code AND item_masterfiles.uom =  tb_tran_line.uom WHERE tb_tran_line.itm_stat="$stat" AND strftime("%Y", tb_tran_line.date_del)="$date" GROUP BY tb_tran_line.itm_code',
        null);
  }

  //////////////////////////////////////////////

  Future getConsolidatedApprovedRequestHead() async {
    String stat = 'Approved';
    var client = await db;

    return client.rawQuery(
        'SELECT *,SUM(tb_tran_head.tot_amt) as total FROM tb_tran_head WHERE tran_stat="$stat" GROUP BY strftime("%Y-%m-%d", date_req), account_code ORDER BY date_req ASC ',
        null);
  }

  Future getTransactionNoList(code, date) async {
    String stat = 'Delivered';
    var client = await db;

    return client.rawQuery(
        'SELECT tran_no,SUM(amt*del_qty) as total,SUM(discounted_amount) as disc_total FROM tb_tran_line WHERE itm_stat !="$stat" AND account_code ="$code" AND strftime("%Y-%m-%d", date_req)="$date"  GROUP BY tran_no ORDER BY doc_no ASC ',
        null);
  }

  Future getConsolidatedApprovedRequestLine(code, date) async {
    String stat = 'Delivered';
    var client = await db;

    return client.rawQuery(
        'SELECT *,SUM(del_qty) as total_qty FROM tb_tran_line WHERE itm_stat !="$stat" AND account_code ="$code" AND strftime("%Y-%m-%d", date_req)="$date"  GROUP BY itm_code ORDER BY doc_no ASC ',
        null);
  }

  Future getTranperLine(itmcode, code, date) async {
    String stat = 'Delivered';
    var client = await db;

    return client.rawQuery(
        'SELECT * FROM tb_tran_line WHERE itm_stat !="$stat" AND account_code ="$code" AND strftime("%Y-%m-%d", date_req)="$date" AND itm_code="$itmcode"',
        null);
  }

  // Future getOrderLimit() async {
  //   // String url = UrlAddress.url + '/gorderlimit';
  //   var url = Uri.parse(UrlAddress.url + '/gorderlimit');
  //   final response =
  //       await http.post(url, headers: {"Accept": "Application/json"}, body: {});
  //   var convertedDatatoJson = jsonDecode(response.body);
  //   return convertedDatatoJson;
  // }

  Future loginUser(String username, String password) async {
    // String url = UrlAddress.url + '/signin';
    var url = Uri.parse('${UrlAddress.url}/signin');
    final response = await retry(() => http.post(url,
        headers: {"Accept": "Application/json"},
        body: {'username': encrypt(username), 'password': encrypt(password)}));
    var convertedDatatoJson = jsonDecode(response.body);
    return convertedDatatoJson;
  }

  Future loginHepe(String username, String password) async {
    // String url = UrlAddress.url + '/signinhepe';
    var url = Uri.parse('${UrlAddress.url}/signinhepe');
    final response = await retry(() => http.post(url,
        headers: {"Accept": "Application/json"},
        body: {'username': encrypt(username), 'password': encrypt(password)}));
    var convertedDatatoJson = jsonDecode(response.body);
    return convertedDatatoJson;
  }

  Future changeSalesmanPassword(String code, String pass) async {
    // String url = UrlAddress.url + '/changesmpassword';
    var url = Uri.parse('${UrlAddress.url}/changesmpassword');
    final response = await retry(() => http.post(url,
        headers: {"Accept": "Application/json"},
        body: {'user_code': encrypt(code), 'password': encrypt(pass)}));
    var convertedDatatoJson = jsonDecode(response.body);
    return convertedDatatoJson;
  }

  Future changeHepePassword(String code, String pass) async {
    // String url = UrlAddress.url + '/changehepepassword';
    var url = Uri.parse('${UrlAddress.url}/changehepepassword');
    final response = await retry(() => http.post(url,
        headers: {"Accept": "Application/json"},
        body: {'user_code': encrypt(code), 'password': encrypt(pass)}));
    var convertedDatatoJson = jsonDecode(response.body);
    return convertedDatatoJson;
  }

  Future addSmsCode(String username, String code, String mobile) async {
    // String url = UrlAddress.url + '/addsmscode';
    var url = Uri.parse('${UrlAddress.url}/addsmscode');
    final response = await retry(() => http.post(url, headers: {
          "Accept": "Application/json"
        }, body: {
          'username': encrypt(username),
          'smscode': encrypt(code),
          'mobile': encrypt(mobile)
        }));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future checkSmsCode(String username, String code) async {
    // String url = UrlAddress.url + '/checksmscode';
    var url = Uri.parse('${UrlAddress.url}/checksmscode');
    final response = await retry(() => http.post(url, headers: {
          "Accept": "Application/json"
        }, body: {
          'username': encrypt(username),
          'smscode': encrypt(code),
        }));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future addHepeSmsCode(String username, String code, String mobile) async {
    // String url = UrlAddress.url + '/addhepesmscode';
    var url = Uri.parse('${UrlAddress.url}/addhepesmscode');
    final response = await retry(() => http.post(url, headers: {
          "Accept": "Application/json"
        }, body: {
          'username': encrypt(username),
          'smscode': encrypt(code),
          'mobile': encrypt(mobile)
        }));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future checkHepeSmsCode(String username, String code) async {
    // String url = UrlAddress.url + '/checkhepesmscode';
    var url = Uri.parse('${UrlAddress.url}/checkhepesmscode');
    final response = await retry(() => http.post(url, headers: {
          "Accept": "Application/json"
        }, body: {
          'username': encrypt(username),
          'smscode': encrypt(code),
        }));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future updateSalesmanStatus(username) async {
    var client = await db;
    String stat = '0';
    return client.update('xt_sm_list', {'status': stat},
        where: 'username = ?', whereArgs: [username]);
  }

  Future updateHepeStatus(username) async {
    var client = await db;
    String stat = '0';
    return client.update('tbl_hepe_de_viaje', {'status': stat},
        where: 'username = ?', whereArgs: [username]);
  }

  Future updateSalesmanStatusOnline(String username) async {
    String stat = '0';
    // String url = UrlAddress.url + '/updatesmstatus';
    var url = Uri.parse('${UrlAddress.url}/updatesmstatus');
    final response = await retry(() => http.post(url, headers: {
          "Accept": "Application/json"
        }, body: {
          'username': encrypt(username),
          'status': encrypt(stat),
        }));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future updateHepeStatusOnline(String username) async {
    String stat = '0';
    // String url = UrlAddress.url + '/updatehepestatus';
    var url = Uri.parse('${UrlAddress.url}/updatehepestatus');
    final response = await retry(() => http.post(url, headers: {
          "Accept": "Application/json"
        }, body: {
          'username': encrypt(username),
          'status': encrypt(stat),
        }));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future getSMPasswordHistory(String userId, String password) async {
    // String url = UrlAddress.url + '/checksmpasshistory';
    var url = Uri.parse('${UrlAddress.url}/checksmpasshistory');
    // var passwordF = md5.convert(utf8.encode(password));
    final response = await retry(() => http.post(url, headers: {
          "Accept": "Application/json"
        }, body: {
          'account_code': encrypt(userId),
          'password': encrypt(password),
        }));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future getHEPEPasswordHistory(String userId, String password) async {
    // String url = UrlAddress.url + '/checkhepepasshistory';
    var url = Uri.parse('${UrlAddress.url}/checkhepepasshistory');
    // var passwordF = md5.convert(utf8.encode(password));
    final response = await retry(() => http.post(url, headers: {
          "Accept": "Application/json"
        }, body: {
          'account_code': encrypt(userId),
          'password': encrypt(password),
        }));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future setLoginDevice(String code, String device) async {
    // String url = UrlAddress.url + '/setlogindevice';
    var url = Uri.parse('${UrlAddress.url}/setlogindevice');
    // var passwordF = md5.convert(utf8.encode(password));
    final response = await retry(() => http.post(url,
        headers: {"Accept": "Application/json"},
        body: {'account_code': encrypt(code), 'device': encrypt(device)}));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future checkLoginDevice(String code, String device) async {
    // String url = UrlAddress.url + '/checklogindevice';
    var url = Uri.parse('${UrlAddress.url}/checklogindevice');
    // var passwordF = md5.convert(utf8.encode(password));
    final response = await retry(() => http.post(url,
        headers: {"Accept": "Application/json"},
        body: {'account_code': code, 'device': device}));
    var convertedDatatoJson = jsonDecode(response.body);
    return convertedDatatoJson;
  }

  Future checkCustomerMessages(code) async {
    // String url = UrlAddress.url + '/checkcustomermessage';
    var url = Uri.parse('${UrlAddress.url}/checkcustomermessage');
    // var passwordF = md5.convert(utf8.encode(password));
    final response = await retry(() => http.post(url,
        headers: {"Accept": "Application/json"}, body: {'account_code': code}));
    var convertedDatatoJson = jsonDecode(response.body);
    return convertedDatatoJson;
  }

  Future getMessageHead(code) async {
    // String url = UrlAddress.url + '/getallmessagehead';
    var url = Uri.parse('${UrlAddress.url}/getallmessagehead');
    // var passwordF = md5.convert(utf8.encode(password));
    final response = await retry(() => http.post(url,
        headers: {"Accept": "Application/json"},
        body: {'account_code': encrypt(code)}));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future getMessage(ref) async {
    // String url = UrlAddress.url + '/getmessage';
    var url = Uri.parse('${UrlAddress.url}/getmessage');
    // var passwordF = md5.convert(utf8.encode(password));
    final response = await retry(() => http.post(url,
        headers: {"Accept": "Application/json"},
        body: {'ref_no': encrypt(ref)}));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future sendMsg(code, ref, msg) async {
    // String url = UrlAddress.url + '/addreply';
    var url = Uri.parse('${UrlAddress.url}/addreply');
    // var passwordF = md5.convert(utf8.encode(password));
    final response = await retry(() => http.post(url, headers: {
          "Accept": "Application/json"
        }, body: {
          'account_code': encrypt(code),
          'ref_no': encrypt(ref),
          'msg_body': encrypt(msg)
        }));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future changeMsgStat(ref) async {
    // String url = UrlAddress.url + '/changemsgstat';
    var url = Uri.parse('${UrlAddress.url}/changemsgstat');
    // var passwordF = md5.convert(utf8.encode(password));
    final response = await retry(() => http.post(url,
        headers: {"Accept": "Application/json"},
        body: {'ref_no': encrypt(ref)}));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future checkAppversion(tvar) async {
    var url = Uri.parse('${UrlAddress.url}/checkappversion');
    // var passwordF = md5.convert(utf8.encode(password));
    final response = await retry(() => http.post(url,
        headers: {"Accept": "Application/json"},
        body: {'tvar': encrypt(tvar)}));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future getAllMessageLog() async {
    // String url = UrlAddress.url + '/getallmessagehead';
    var url = Uri.parse('${UrlAddress.url}/getallmessageheadlog');
    // var passwordF = md5.convert(utf8.encode(password));
    final response = await retry(() =>
        http.post(url, headers: {"Accept": "Application/json"}, body: {}));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future updateSalesmanImg(String code, String img) async {
    // String url = UrlAddress.url + '/updatehepestatus';
    var url = Uri.parse('${UrlAddress.url}/updatesmimage');
    final response = await retry(() => http.post(url, headers: {
          "Accept": "Application/json"
        }, body: {
          'user_code': encrypt(code),
          'img': encrypt(img),
        }));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future updateHepeImg(String code, String img) async {
    // String url = UrlAddress.url + '/updatehepestatus';
    var url = Uri.parse('${UrlAddress.url}/updatehepeimage');
    final response = await retry(() => http.post(url, headers: {
          "Accept": "Application/json"
        }, body: {
          'user_code': encrypt(code),
          'img': encrypt(img),
        }));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future getOrderLimit(code) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM tbl_order_limit WHERE code ="$code"', null);
  }

  ///////////////////////SELECTIVE SYNC TRANSACTIONS
  ///

  ///
  ///EX_TRUCK CODE FOR CI

  Future checkRevolvingFund(code) async {
    var url = Uri.parse('${UrlAddress.url}/checkrevolvingfund');
    // var passwordF = md5.convert(utf8.encode(password));
    final response = await retry(() => http.post(url,
        headers: {"Accept": "Application/json"},
        body: {'sm_code': encrypt(code)}));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  // Future checkRequestStat(tran, stat) async {
  //   var url = Uri.parse('${UrlAddress.url}/checkrequeststat');
  //   // var passwordF = md5.convert(utf8.encode(password));
  //   final response = await retry(() => http.post(url,
  //       headers: {"Accept": "Application/json"},
  //       body: {'tran_no': encrypt(tran), 'tran_stat': encrypt(stat)}));
  //   var convertedDatatoJson = jsonDecode(decrypt(response.body));
  //   return convertedDatatoJson;
  // }

  Future checkApproved(code) async {
    var url = Uri.parse('${UrlAddress.url}/checkapprovedstat');
    // var passwordF = md5.convert(utf8.encode(password));
    final response = await retry(() => http.post(url,
        headers: {"Accept": "Application/json"},
        body: {'sm_code': encrypt(code)}));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future getApprovedLine(tran) async {
    var url = Uri.parse('${UrlAddress.url}/getapprovedline');
    // var passwordF = md5.convert(utf8.encode(password));
    final response = await retry(() => http.post(url,
        headers: {"Accept": "Application/json"},
        body: {'tran_no': encrypt(tran)}));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future uploadRequest(
      BuildContext context,
      String warehouse,
      String userId,
      String payment,
      String itmcount,
      String totamt,
      String stat,
      String signature,
      List line) async {
    try {
      var url = Uri.parse('${UrlAddress.url}/addxtruckrequest');
      final response = await retry(() => http.post(url, headers: {
            "Accept": "Application/json"
          }, body: {
            'warehouse': encrypt(warehouse),
            'sm_code': encrypt(userId),
            'pmeth_type': encrypt(payment),
            'item_count': encrypt(itmcount),
            'tot_amt': encrypt(totamt),
            'tran_stat': encrypt(stat),
            'auth_signature': encrypt(signature),
            'line': jsonEncode(line),
          }));
      if (response.statusCode == 200) {
        var convertedDatatoJson = jsonDecode(response.body);
        return convertedDatatoJson;
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
          const Text("Format exception error occured. Please try again later.",
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

  Future changeLoadStatus(code, tran, List list) async {
    var url = Uri.parse('${UrlAddress.url}/changextstat');
    // var passwordF = md5.convert(utf8.encode(password));
    final response = await retry(() => http.post(url, headers: {
          "Accept": "Application/json"
        }, body: {
          'sm_code': encrypt(code),
          'tran_no': encrypt(tran),
          'line': jsonEncode(list),
        }));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future addtoloadLedgerOnline(code, qty, bal, type, refno) async {
    var url = Uri.parse('${UrlAddress.url}/addloadledger');
    // var passwordF = md5.convert(utf8.encode(password));
    final response = await retry(() => http.post(url, headers: {
          "Accept": "Application/json"
        }, body: {
          'sm_code': encrypt(code),
          'qty_in': encrypt(qty),
          'bal': encrypt(bal),
          'type': encrypt(type),
          'ref_no': encrypt(refno),
        }));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future uploadConversion(
      code, convNo, date, itmNo, totAmt, itmQty, nitmQty, List list) async {
    var url = Uri.parse('${UrlAddress.url}/uploadconversion');
    // var passwordF = md5.convert(utf8.encode(password));
    final response = await retry(() => http.post(url, headers: {
          "Accept": "Application/json"
        }, body: {
          'sm_code': encrypt(code),
          'conv_no': encrypt(convNo),
          'conv_date': encrypt(date),
          'itmno': encrypt(itmNo),
          'totAmt': encrypt(totAmt),
          'item_qty': encrypt(itmQty),
          'nitem_qty': encrypt(nitmQty),
          'line': jsonEncode(list),
        }));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future checkLoadLedger(code) async {
    var url = Uri.parse('${UrlAddress.url}/checkloadledger');
    final response = await http.post(url, headers: {
      "Accept": "Application/json"
    }, body: {
      'sm_code': encrypt(code),
    });
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future checkCashLedger(code) async {
    var url = Uri.parse('${UrlAddress.url}/checkcashledger');
    final response = await http.post(url, headers: {
      "Accept": "Application/json"
    }, body: {
      'sm_code': encrypt(code),
    });
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future updateLoadLedger(code, List line) async {
    var url = Uri.parse('${UrlAddress.url}/updateloadledger');
    final response = await http.post(url, headers: {
      "Accept": "Application/json"
    }, body: {
      'sm_code': encrypt(code),
      'line': jsonEncode(line),
    });
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future updateCashLedger(code, List line) async {
    var url = Uri.parse('${UrlAddress.url}/updatecashledger');
    final response = await http.post(url, headers: {
      "Accept": "Application/json"
    }, body: {
      'sm_code': encrypt(code),
      'line': jsonEncode(line),
    });
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future saveitemLoad(code, List line) async {
    var url = Uri.parse('${UrlAddress.url}/updateitemload');
    final response = await http.post(url, headers: {
      "Accept": "Application/json"
    }, body: {
      'sm_code': encrypt(code),
      'line': jsonEncode(line),
    });
    // var convertedDatatoJson = jsonDecode(decrypt(response.body));
    var convertedDatatoJson = jsonDecode(response.body);
    return convertedDatatoJson;
  }

  Future checkPriceChange(List line) async {
    var url = Uri.parse('${UrlAddress.url}/checkpricechange');
    final response = await http.post(url, headers: {
      "Accept": "Application/json"
    }, body: {
      'line': jsonEncode(line),
    });
    // var convertedDatatoJson = jsonDecode(decrypt(response.body));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future updateRevolving(code, amount, type, cpno) async {
    var url = Uri.parse('${UrlAddress.url}/updaterevolving');
    final response = await http.post(url, headers: {
      "Accept": "Application/json"
    }, body: {
      'sm_code': encrypt(code),
      'bal': encrypt(amount),
      'type': encrypt(type),
      'no': encrypt(cpno),
    });
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future saveRemittance(
      code,
      rmtNo,
      date,
      ordNo,
      revBal,
      loadBal,
      boAmt,
      totAmt,
      totCash,
      totCheque,
      totDisc,
      totSatwh,
      totNet,
      replAmt,
      stat,
      flag,
      List tlist,
      List llist) async {
    var url = Uri.parse('${UrlAddress.url}/uploadremittance');
    // var passwordF = md5.convert(utf8.encode(password));
    final response = await retry(() => http.post(url, headers: {
          "Accept": "Application/json"
        }, body: {
          'sm_code': encrypt(code),
          'rmt_no': encrypt(rmtNo),
          'date': encrypt(date),
          'order_count': encrypt(ordNo),
          'rev_bal': encrypt(revBal),
          'load_bal': encrypt(loadBal),
          'bo_amt': encrypt(boAmt),
          'tot_amt': encrypt(totAmt),
          'tot_cash': encrypt(totCash),
          'tot_cheque': encrypt(totCheque),
          'tot_disc': encrypt(totDisc),
          'tot_satwh': encrypt(totSatwh),
          'tot_net': encrypt(totNet),
          'repl_amt': encrypt(replAmt),
          'status': encrypt(stat),
          'flag': encrypt(flag),
          'line1': jsonEncode(tlist),
          'line2': jsonEncode(llist),
        }));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future uploadChequeData(code, List line) async {
    var url = Uri.parse('${UrlAddress.url}/uploadchequedata');
    // var passwordF = md5.convert(utf8.encode(password));
    final response = await retry(() => http.post(url, headers: {
          "Accept": "Application/json"
        }, body: {
          'sm_code': encrypt(code),
          'line': jsonEncode(line),
        }));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future uploadChequeData2(code, dtm, ordNo, accCode, bankName, accName, accNo,
      cheqNo, cheqDate, cheqType, amt, stat) async {
    var url = Uri.parse('${UrlAddress.url}/uploadchequedata2');
    // var passwordF = md5.convert(utf8.encode(password));
    final response = await retry(() => http.post(url, headers: {
          "Accept": "Application/json"
        }, body: {
          'sm_code': encrypt(code),
          'dtm': encrypt(dtm),
          'order_no': encrypt(ordNo),
          'account_code': encrypt(accCode),
          'bank_name': encrypt(bankName),
          'account_name': encrypt(accName),
          'account_no': encrypt(accNo),
          'cheque_no': encrypt(cheqNo),
          'cheque_date': encrypt(cheqDate),
          'cheque_type': encrypt(cheqType),
          'amount': encrypt(amt),
          'status': encrypt(stat),
        }));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future uploadSmBalance(
      code, revfund, revbal, loadbal, cash, cheque, disc, bo, rmt) async {
    var url = Uri.parse('${UrlAddress.url}/updatesmbalance');
    // var passwordF = md5.convert(utf8.encode(password));
    final response = await retry(() => http.post(url, headers: {
          "Accept": "Application/json"
        }, body: {
          'sm_code': encrypt(code),
          'rev_fund': encrypt(revfund),
          'rev_bal': encrypt(revbal),
          'load_bal': encrypt(loadbal),
          'cash_onhand': encrypt(cash),
          'cheque_amt': encrypt(cheque),
          'disc_amt': encrypt(disc),
          'bo_amt': encrypt(bo),
          'rmt_amt': encrypt(rmt),
        }));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  Future uploadxttrandetails(
      smCode, date, tranNo, chequeNo, amount, status) async {
    var url = Uri.parse('${UrlAddress.url}/uploadxttrancheque');
    // var passwordF = md5.convert(utf8.encode(password));
    final response = await retry(() => http.post(url, headers: {
          "Accept": "Application/json"
        }, body: {
          'sm_code': encrypt(smCode),
          'date': encrypt(date),
          'tran_no': encrypt(tranNo),
          'cheque_no': encrypt(chequeNo),
          'amount': encrypt(amount),
          'status': encrypt(status),
        }));
    var convertedDatatoJson = jsonDecode(decrypt(response.body));
    return convertedDatatoJson;
  }

  /////
  ///EXTRUCK CODE FOR SQL
  ///
  ///
  ///

  Future getXTPendingRequests(code) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM xt_tran_head WHERE sm_code ="$code" AND tran_stat = "Pending" OR sm_code ="$code" AND tran_stat = "Approved" ORDER BY tran_no DESC',
        null);
  }

  Future getRequestLine(tran) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM xt_tran_line WHERE tran_no ="$tran"', null);
  }

  Future updatePendingStat(tran, stat, date, appcount, totamt) async {
    var client = await db;
    return client.update(
        'xt_tran_head',
        {
          'tran_stat': stat,
          'date_app': date,
          'app_count': appcount,
          'tot_amt': totamt,
        },
        where: 'tran_no = ?',
        whereArgs: [tran]);
  }

  Future updateStat(tran, appQty, stat, date) async {
    var client = await db;
    return client.update(
        'xt_tran_head',
        {
          'app_count': appQty,
          'tran_stat': stat,
          'date_load': date,
        },
        where: 'tran_no = ?',
        whereArgs: [tran]);
  }

  Future getInventory(code) async {
    String z = '0';
    var client = await db;
    return client.rawQuery(
        'SELECT *, 0 as amt, false as discounted FROM xt_sm_load WHERE sm_code ="$code" AND item_qty!="$z" ORDER BY item_desc ASC',
        null);
  }

  Future getforConversionItems(code) async {
    String z = '0';
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM xt_sm_load WHERE sm_code ="$code" AND item_qty!="$z" AND conv_qty!="1" ORDER BY item_desc ASC',
        null);
  }

  Future searchInventory(code, text) async {
    String z = '0';
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM xt_sm_load WHERE sm_code ="$code" AND item_desc LIKE "%$text%" AND item_qty!="$z"',
        null);
  }

  Future searchforConversionInventory(code, text) async {
    String z = '0';
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM xt_sm_load WHERE sm_code ="$code" AND item_desc LIKE "%$text%" AND item_qty!="$z" AND conv_qty!="1"',
        null);
  }

  Future loadItemtoInventory(smcode, itmcode, itmdesc, itmPrincipal, itmuom,
      itmamt, qty, cqty, cuom, img) async {
    int fqty = 0;
    // double famt = 0.00;
    var client = await db;

    List<Map> res = await client.rawQuery(
        'SELECT item_qty,item_amt FROM xt_sm_load WHERE sm_code = "$smcode" AND item_code = "$itmcode" AND item_uom = "$itmuom"',
        null);
    // final result = count;
    // return res;
    if (res.isEmpty) {
      return client.insert('xt_sm_load', {
        'sm_code': smcode,
        'item_code': itmcode,
        'item_desc': itmdesc,
        'item_principal': itmPrincipal,
        'item_uom': itmuom,
        'item_amt': itmamt,
        'item_qty': qty,
        'conv_qty': cqty,
        'conv_uom': cuom,
        'image': img,
      });
    } else {
      for (var element in res) {
        fqty = int.parse(element['item_qty']);
        // famt = double.parse(element['item_amt']);
      }
      return client.update(
          'xt_sm_load',
          {
            'item_qty': (fqty + int.parse(qty)).toString(),
            'item_amt': itmamt,
          },
          where: 'sm_code = ? AND item_code = ? AND item_uom = ?',
          whereArgs: [smcode, itmcode, itmuom]);
    }
  }

  Future addtoLoadLedger(smcode, date, qty, type, refno) async {
    int fqty = 0;
    int nqty = 0;
    // double ftotal = 0.00;
    var client = await db;

    List<Map> res = await client.rawQuery(
        'SELECT bal FROM xt_load_ldg WHERE sm_code = "$smcode" ORDER BY date ASC',
        null);
    // final result = count;
    // return res;
    if (res.isEmpty) {
      return client.insert('xt_load_ldg', {
        'sm_code': smcode,
        'date': date,
        'qty_in': qty,
        'qty_out': '0',
        'bal': qty,
        'type': type,
        'ref_no': refno,
      });
    } else {
      for (var element in res) {
        fqty = int.parse(element['bal']);
        nqty = int.parse(qty);
        // ftotal = double.parse(element['item_total']);
      }
      return client.insert('xt_load_ldg', {
        'sm_code': smcode,
        'date': date,
        'qty_in': qty,
        'qty_out': '0',
        'bal': fqty + nqty,
        'type': type,
        'ref_no': refno,
      });
    }
  }

  Future getStockEntries(code) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM xt_load_ldg WHERE sm_code ="$code" ORDER BY doc_no DESC',
        null);
  }

  Future getBalance(code, tran) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM xt_load_ldg WHERE sm_code ="$code" AND ref_no = "$tran"',
        null);
  }

  Future minusInventory(code, itemCode, itemDesc, itemUom, itemQty) async {
    int fqty = 0;
    var client = await db;

    List<Map> res = await client.rawQuery(
        'SELECT item_qty FROM xt_sm_load WHERE sm_code  = "$code" AND item_code = "$itemCode" AND item_desc= "$itemDesc" AND item_uom = "$itemUom"',
        null);

    for (var element in res) {
      fqty = int.parse(element['item_qty']);
    }
    return client.update(
        'xt_sm_load',
        {
          'item_qty': (fqty - int.parse(itemQty)).toString(),
        },
        where:
            'sm_code  = ? AND item_code = ? AND  item_desc = ? AND item_uom = ?',
        whereArgs: [code, itemCode, itemDesc, itemUom]);
  }

  Future addInventory(code, itemCode, itemDesc, itemUom, itemQty) async {
    int fqty = 0;
    var client = await db;

    List<Map> res = await client.rawQuery(
        'SELECT item_qty FROM xt_sm_load WHERE sm_code  = "$code" AND item_code = "$itemCode" AND item_desc= "$itemDesc" AND item_uom = "$itemUom"',
        null);

    for (var element in res) {
      fqty = int.parse(element['item_qty']);
    }
    return client.update(
        'xt_sm_load',
        {
          'item_qty': (fqty + int.parse(itemQty)).toString(),
        },
        where:
            'sm_code  = ? AND item_code = ? AND  item_desc = ? AND item_uom = ?',
        whereArgs: [code, itemCode, itemDesc, itemUom]);
  }

  Future checkCount(smcode, custcode) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM xt_rmt_head WHERE sm_code="$smcode" AND account_code="$custcode"',
        null);
  }

  Future addTransactionHead(ordno, sino, date, acccode, storename, itmcount,
      totAmt, discAmt, netAmt, pmeth, tranType, smCode) async {
    // int rsp = 0;
    String stat = 'Pending';
    var client = await db;

    List<Map> res = await client.rawQuery(
        'SELECT * FROM xt_rmt_head WHERE order_no = "$ordno"', null);

    if (res.isEmpty) {
      return client.insert('xt_rmt_head', {
        'order_no': ordno,
        'si_no': sino,
        'date': date,
        'account_code': acccode,
        'store_name': storename,
        'item_count': itmcount,
        'tot_amt': totAmt,
        'disc_amt': discAmt,
        'net_amt': netAmt,
        'pmeth_type': pmeth,
        'tran_type': tranType,
        'sm_code': smCode,
        'stat': stat,
      });
    } else {
      return null;
    }
  }

  Future addTransactionLine(
      ordNo,
      siNo,
      itmCode,
      itmDesc,
      qty,
      uom,
      amt,
      discount,
      totAmt,
      discAmt,
      itmCat,
      itmStat,
      discFlag,
      smCOde,
      date,
      image) async {
    // int fqty = 0;
    // double ftotal = 0.00;
    var client = await db;

    List<Map> res = await client.rawQuery(
        'SELECT * FROM xt_rmt_line WHERE order_no ="$ordNo" AND sm_code ="$smCOde" AND  item_code = "$itmCode" AND uom = "$uom"',
        null);
    // final result = count;
    // return res;
    if (res.isEmpty) {
      return client.insert('xt_rmt_line', {
        'order_no': ordNo,
        'si_no': siNo,
        'item_code': itmCode,
        'item_desc': itmDesc,
        'qty': qty,
        'uom': uom,
        'amt': amt,
        'discount': discount,
        'tot_amt': totAmt,
        'disc_amt': discAmt,
        'item_cat': itmCat,
        'item_stat': itmStat,
        'disc_flag': discFlag,
        'sm_code': smCOde,
        'date': date,
        'image': image,
      });
    } else {
      return 0;
    }
  }

  Future minustoLoadLedger(smcode, date, qty, type, refno) async {
    int fqty = 0;
    int nqty = 0;
    var client = await db;

    List<Map> res = await client.rawQuery(
        'SELECT bal FROM xt_load_ldg WHERE sm_code = "$smcode" ORDER BY date ASC',
        null);

    if (res.isEmpty) {
      return client.insert('xt_load_ldg', {
        'sm_code': smcode,
        'date': date,
        'qty_in': qty,
        'qty_out': '0',
        'bal': qty,
        'type': type,
        'ref_no': refno,
      });
    } else {
      for (var element in res) {
        fqty = int.parse(element['bal']);
        nqty = int.parse(qty);
        // ftotal = double.parse(element['item_total']);
      }
      return client.insert('xt_load_ldg', {
        'sm_code': smcode,
        'date': date,
        'qty_in': '0',
        'qty_out': qty,
        'bal': fqty - nqty,
        'type': type,
        'ref_no': refno,
      });
    }
  }

  Future addChequeData(date, ordNo, accCode, smCode, bnkName, accName, accNo,
      chqNo, chqDate, chqType, amt, stat) async {
    var client = await db;
    return client.insert('xt_cheque_data', {
      'dtm': date,
      'order_no': ordNo,
      'account_code': accCode,
      'sm_code': smCode,
      'bank_name': bnkName,
      'account_name': accName,
      'account_no': accNo,
      'cheque_no': chqNo,
      'cheque_date': chqDate,
      'cheque_type': chqType,
      'amount': amt,
      'status': stat,
    });
  }

  Future addforConversion(smcode, itmcode, itmdesc, itmPrincipal, itmQty,
      availQty, itmUom, itmAmt, convQty, convUom, convAmt, img) async {
    int fqty = 0;
    var client = await db;

    List<Map> res = await client.rawQuery(
        'SELECT item_qty FROM xt_conv_cart WHERE sm_code = "$smcode" AND item_code = "$itmcode" AND item_uom = "$itmUom"',
        null);
    if (res.isEmpty) {
      return client.insert('xt_conv_cart', {
        'sm_code': smcode,
        'item_code': itmcode,
        'item_desc': itmdesc,
        'item_principal': itmPrincipal,
        'item_qty': itmQty,
        'avail_qty': availQty,
        'item_uom': itmUom,
        'item_amt': itmAmt,
        'conv_qty': convQty,
        'conv_uom': convUom,
        'conv_amt': convAmt,
        'image': img,
      });
    } else {
      for (var element in res) {
        fqty = int.parse(element['item_qty']);
      }
      return client.update(
          'xt_conv_cart',
          {
            'item_qty': (fqty + int.parse(itmQty)).toString(),
          },
          where: 'sm_code = ? AND item_code = ? AND item_uom = ?',
          whereArgs: [smcode, itmcode, itmUom]);
    }
  }

  Future getConversionAmt(itmcode, uom) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM item_masterfiles WHERE itemcode ="$itmcode" AND uom ="$uom"',
        null);
  }

  Future getConversionList(code) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM xt_conv_cart WHERE sm_code="$code"', null);
  }

  Future searchConversionCart(smcode, itmcode, uom) async {
    var client = await db;

    return client.rawQuery(
        'SELECT * FROM xt_conv_cart WHERE sm_code ="$smcode" AND item_code ="$itmcode" AND item_uom ="$uom"',
        null);
  }

  Future checkConversionCount(smcode) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM xt_conv_head WHERE sm_code = "$smcode" ', null);
  }

  Future saveConvertedLine(smCode, convNo, itmCode, itmDesc, itmQty, itmUom,
      itmAmt, conQty, conUom, conAmt, image) async {
    var client = await db;
    return client.insert('xt_conv_line', {
      'sm_code': smCode,
      'conv_no': convNo,
      'item_code': itmCode,
      'item_desc': itmDesc,
      'item_qty': itmQty,
      'item_uom': itmUom,
      'item_amt': itmAmt,
      'conv_qty': conQty,
      'conv_uom': conUom,
      'conv_amt': conAmt,
      'image': image,
    });
  }

  Future saveConvertedHead(
      smCode, convNo, date, itmNo, totAmt, itmQty, nitmQty) async {
    String stat = 'Pending';
    var client = await db;
    return client.insert('xt_conv_head', {
      'sm_code': smCode,
      'conv_no': convNo,
      'conv_date ': date,
      'itmno': itmNo,
      'totAmt': totAmt,
      'item_qty': itmQty,
      'nitem_qty': nitmQty,
      'stat': stat,
    });
  }

  Future deleteAllConvItem(smcode) async {
    var client = await db;
    return client.rawQuery(
        'DELETE FROM xt_conv_cart WHERE sm_code ="$smcode"', null);
  }

  Future getConversionHistory(smcode) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM xt_conv_head WHERE sm_code ="$smcode" ORDER BY doc_no DESC',
        null);
  }

  Future loadConvertedItems(convNo) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM xt_conv_line WHERE conv_no ="$convNo"', null);
  }

  Future loadOrderHistory(smcode) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM xt_rmt_head WHERE sm_code ="$smcode" AND tran_type ="ORDER" ORDER BY doc_no DESC',
        null);
  }

  Future loadBoHistory(smcode) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM xt_rmt_head WHERE sm_code ="$smcode" AND tran_type ="BO" ORDER BY doc_no DESC',
        null);
  }

  Future loadPending(smcode) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM xt_rmt_head WHERE sm_code ="$smcode" AND stat ="Pending" ORDER BY doc_no DESC',
        null);
  }

  Future loadPendingCheque(smcode) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM xt_rmt_head WHERE sm_code ="$smcode" AND tran_type="ORDER" AND pmeth_type="Cheque" AND stat ="Pending" ORDER BY doc_no DESC',
        null);
  }

  Future loadPendingOrders(smcode) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM xt_rmt_head WHERE sm_code ="$smcode" AND tran_type="ORDER" AND stat ="Pending" ORDER BY doc_no DESC',
        null);
  }

  Future loadPendingBo(smcode) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM xt_rmt_head WHERE sm_code ="$smcode" AND tran_type="BO" AND stat ="Pending" ORDER BY doc_no DESC',
        null);
  }

  Future searchOrder(text, code) async {
    var client = await db;
    return client.rawQuery(
        "SELECT * FROM xt_rmt_head WHERE order_no AND tran_type = 'ORDER' LIKE '%$text%' AND sm_code ='$code'",
        null);
  }

  Future searchBO(text, code) async {
    var client = await db;
    return client.rawQuery(
        "SELECT * FROM xt_rmt_head WHERE order_no AND tran_type = 'BO' LIKE '%$text%' AND sm_code ='$code'",
        null);
  }

  Future loadRemitItems(ordNo) async {
    var client = await db;
    return client.rawQuery(
        'SELECT *, false as mark FROM xt_rmt_line WHERE order_no ="$ordNo"',
        null);
  }

  Future getPendingOrders(smcode) async {
    var client = await db;
    String stat = 'null';
    return client.rawQuery(
        'SELECT * FROM xt_rmt_head WHERE sm_code ="$smcode" AND rmt_no="$stat" ORDER BY doc_no DESC',
        null);
  }

  Future checkRMTCount(smcode) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM xt_rmt WHERE  sm_code  = "$smcode"', null);
  }

  Future saveRemittanceReport(
      rmtNo,
      date,
      smCode,
      ordCount,
      revBal,
      loadBal,
      boAmt,
      totAmt,
      totCash,
      totCheque,
      totDisc,
      totSatWh,
      totNet,
      replAmt,
      stat) async {
    String flag = '0';
    var client = await db;
    return client.insert('xt_rmt', {
      'rmt_no': rmtNo,
      'date': date,
      'sm_code ': smCode,
      'order_count': ordCount,
      'rev_bal': revBal,
      'load_bal': loadBal,
      'bo_amt': boAmt,
      'tot_amt': totAmt,
      'tot_cash': totCash,
      'tot_cheque': totCheque,
      'tot_disc': totDisc,
      'tot_satwh': totSatWh,
      'tot_net': totNet,
      'repl_amt': replAmt,
      'status': stat,
      'flag': flag,
    });
  }

  Future changeOrderStat(ordNo, rmtNo, stat) async {
    var client = await db;
    return client.update('xt_rmt_head', {'rmt_no': rmtNo, 'stat': stat},
        where: 'order_no = ?', whereArgs: [ordNo]);
  }

  Future loadRmtHistory(smcode) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM xt_rmt WHERE sm_code ="$smcode" ORDER BY doc_no DESC',
        null);
  }

  Future loadRmtHistoryHead(rmtNo) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM xt_rmt_head WHERE rmt_no ="$rmtNo"', null);
  }

  Future loadRmtDetails(rmt) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM xt_rmt WHERE rmt_no ="$rmt" ORDER BY doc_no DESC', null);
  }

  Future loadPendingRemittance(smcode) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM xt_rmt WHERE sm_code ="$smcode" AND status="Pending" ORDER BY doc_no DESC',
        null);
  }

  Future getRequestsHistory(code) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM xt_tran_head WHERE sm_code ="$code"  ORDER BY tran_no DESC',
        null);
  }

  Future getPendingConversion(code) async {
    String stat = 'Pending';
    var client = await db;

    return client.rawQuery(
        'SELECT * FROM xt_conv_head WHERE sm_code ="$code" AND stat ="$stat"  ORDER BY doc_no ASC',
        null);
  }

  Future changeConvStat(convNo, stat) async {
    var client = await db;
    return client.update('xt_conv_head', {'stat': stat},
        where: 'conv_no = ?', whereArgs: [convNo]);
  }

  Future checkLoadLedgerLocal(code) async {
    var client = await db;

    return client.rawQuery(
        'SELECT * FROM xt_load_ldg WHERE sm_code ="$code" ORDER BY doc_no ASC',
        null);
  }

  Future checkCashLedgerLocal(code) async {
    var client = await db;

    return client.rawQuery(
        'SELECT * FROM xt_cash_ldg WHERE sm_code ="$code" ORDER BY doc_no ASC',
        null);
  }

  Future getApprovedOrders(code) async {
    var client = await db;
    return client.rawQuery(
        "SELECT * FROM xt_rmt_head WHERE sm_code='$code' AND stat ='Approved' AND tran_type = 'ORDER' ORDER BY doc_no ASC",
        null);
  }

  Future getRefundLines(ordNo, itmCode, itmUom) async {
    var client = await db;
    return client.rawQuery(
        "SELECT *,' ' as rf_itmcode,' ' as rf_itemdesc,' ' as rf_qty, ' ' as rf_uom,' ' as rf_amount,' ' as rf_totamt,' ' as rf_image FROM xt_rmt_line WHERE order_no ='$ordNo' AND item_code ='$itmCode' AND uom ='$itmUom' ORDER BY doc_no ASC",
        null);
  }

  Future checkSmBalance(code) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM xt_sm_balance WHERE sm_code="$code" ', null);
  }

  Future addSmBalance(code, amt) async {
    // String nb = '0';
    var client = await db;
    return client.insert('xt_sm_balance', {
      'sm_code ': code,
      'rev_fund ': amt,
      'rev_bal  ': amt,
      'load_bal ': amt,
      'cash_onhand ': amt,
      'cheque_amt': amt,
      'disc_amt ': amt,
      'bo_amt ': amt,
      'rmt_amt ': amt,
      'stat': 0,
    });
  }

  Future setRevolvingFund(code, fund, bal) async {
    var client = await db;
    return client.update('xt_sm_balance', {'rev_fund': fund, 'rev_bal': bal},
        where: 'sm_code = ?', whereArgs: [code]);
  }

  Future updateRevBal(smcode, revBal, amt) async {
    double bal = 0.00;
    var client = await db;

    List<Map> res = await client.rawQuery(
        'SELECT * FROM xt_sm_balance WHERE sm_code = "$smcode"', null);
    if (res.isEmpty) {
    } else {
      for (var element in res) {
        bal = double.parse(element['load_bal']);
      }
      return client.update(
          'xt_sm_balance',
          {
            'rev_bal': revBal,
            'load_bal': (bal + double.parse(amt)).toString(),
          },
          where: 'sm_code = ?',
          whereArgs: [smcode]);
    }
  }

  Future setRevBal(smcode, revBal) async {
    // double bal = 0.00;
    var client = await db;

    List<Map> res = await client.rawQuery(
        'SELECT * FROM xt_sm_balance WHERE sm_code = "$smcode"', null);
    if (res.isEmpty) {
    } else {
      return client.update(
          'xt_sm_balance',
          {
            'rev_bal': revBal,
          },
          where: 'sm_code = ?',
          whereArgs: [smcode]);
    }
  }

  Future addLoadBal(smcode, amt) async {
    double bal = 0.00;
    var client = await db;

    List<Map> res = await client.rawQuery(
        'SELECT * FROM xt_sm_balance WHERE sm_code = "$smcode"', null);
    if (res.isEmpty) {
    } else {
      for (var element in res) {
        bal = double.parse(element['load_bal']);
      }
      return client.update(
          'xt_sm_balance',
          {
            'load_bal': (bal + double.parse(amt)).toString(),
          },
          where: 'sm_code = ?',
          whereArgs: [smcode]);
    }
  }

  Future minusLoadBal(smcode, amt) async {
    double bal = 0.00;
    var client = await db;

    List<Map> res = await client.rawQuery(
        'SELECT * FROM xt_sm_balance WHERE sm_code = "$smcode"', null);
    if (res.isEmpty) {
    } else {
      for (var element in res) {
        bal = double.parse(element['load_bal']);
      }
      return client.update(
          'xt_sm_balance',
          {
            'load_bal': (bal - double.parse(amt)).toString(),
          },
          where: 'sm_code = ?',
          whereArgs: [smcode]);
    }
  }

  Future addCashBal(smcode, amt) async {
    double bal = 0.00;
    var client = await db;

    List<Map> res = await client.rawQuery(
        'SELECT * FROM xt_sm_balance WHERE sm_code = "$smcode"', null);
    if (res.isEmpty) {
    } else {
      for (var element in res) {
        bal = double.parse(element['cash_onhand']);
      }
      return client.update(
          'xt_sm_balance',
          {
            'cash_onhand': (bal + double.parse(amt)).toString(),
          },
          where: 'sm_code = ?',
          whereArgs: [smcode]);
    }
  }

  Future minusCashBal(smcode, amt) async {
    double bal = 0.00;
    var client = await db;

    List<Map> res = await client.rawQuery(
        'SELECT * FROM xt_sm_balance WHERE sm_code = "$smcode"', null);
    if (res.isEmpty) {
    } else {
      for (var element in res) {
        bal = double.parse(element['cash_onhand']);
      }
      return client.update(
          'xt_sm_balance',
          {
            'cash_onhand': (bal - double.parse(amt)).toString(),
          },
          where: 'sm_code = ?',
          whereArgs: [smcode]);
    }
  }

  Future addChequeBal(smcode, amt) async {
    double bal = 0.00;
    var client = await db;

    List<Map> res = await client.rawQuery(
        'SELECT * FROM xt_sm_balance WHERE sm_code = "$smcode"', null);
    if (res.isEmpty) {
    } else {
      for (var element in res) {
        bal = double.parse(element['cheque_amt']);
      }
      return client.update(
          'xt_sm_balance',
          {
            'cheque_amt': (bal + double.parse(amt)).toString(),
          },
          where: 'sm_code = ?',
          whereArgs: [smcode]);
    }
  }

  Future minusChequeBal(smcode, amt) async {
    double bal = 0.00;
    var client = await db;

    List<Map> res = await client.rawQuery(
        'SELECT * FROM xt_sm_balance WHERE sm_code = "$smcode"', null);
    if (res.isEmpty) {
    } else {
      for (var element in res) {
        bal = double.parse(element['cheque_amt']);
      }
      return client.update(
          'xt_sm_balance',
          {
            'cheque_amt': (bal - double.parse(amt)).toStringAsFixed(2),
          },
          where: 'sm_code = ?',
          whereArgs: [smcode]);
    }
  }

  Future addDiscBal(smcode, amt) async {
    double bal = 0.00;
    var client = await db;

    List<Map> res = await client.rawQuery(
        'SELECT * FROM xt_sm_balance WHERE sm_code = "$smcode"', null);
    if (res.isEmpty) {
    } else {
      for (var element in res) {
        bal = double.parse(element['disc_amt']);
      }
      return client.update(
          'xt_sm_balance',
          {
            'disc_amt': (bal + double.parse(amt)).toStringAsFixed(2),
          },
          where: 'sm_code = ?',
          whereArgs: [smcode]);
    }
  }

  Future minusDiscBal(smcode, amt) async {
    double bal = 0.00;
    var client = await db;

    List<Map> res = await client.rawQuery(
        'SELECT * FROM xt_sm_balance WHERE sm_code = "$smcode"', null);
    if (res.isEmpty) {
    } else {
      for (var element in res) {
        bal = double.parse(element['disc_amt']);
      }
      return client.update(
          'xt_sm_balance',
          {
            'disc_amt': (bal - double.parse(amt)).toStringAsFixed(2),
          },
          where: 'sm_code = ?',
          whereArgs: [smcode]);
    }
  }

  Future addBoBal(smcode, amt) async {
    double bal = 0.00;
    var client = await db;

    List<Map> res = await client.rawQuery(
        'SELECT * FROM xt_sm_balance WHERE sm_code = "$smcode"', null);
    if (res.isEmpty) {
    } else {
      for (var element in res) {
        bal = double.parse(element['bo_amt']);
      }
      return client.update(
          'xt_sm_balance',
          {
            'bo_amt': (bal + double.parse(amt)).toString(),
          },
          where: 'sm_code = ?',
          whereArgs: [smcode]);
    }
  }

  Future minusBoBal(smcode, amt) async {
    double bal = 0.00;
    var client = await db;

    List<Map> res = await client.rawQuery(
        'SELECT * FROM xt_sm_balance WHERE sm_code = "$smcode"', null);
    if (res.isEmpty) {
    } else {
      for (var element in res) {
        bal = double.parse(element['bo_amt']);
      }
      return client.update(
          'xt_sm_balance',
          {
            'bo_amt': (bal - double.parse(amt)).toString(),
          },
          where: 'sm_code = ?',
          whereArgs: [smcode]);
    }
  }

  Future addRemitBal(smcode, amt) async {
    double bal = 0.00;
    var client = await db;

    List<Map> res = await client.rawQuery(
        'SELECT * FROM xt_sm_balance WHERE sm_code = "$smcode"', null);
    if (res.isEmpty) {
    } else {
      for (var element in res) {
        bal = double.parse(element['rmt_amt']);
      }
      return client.update(
          'xt_sm_balance',
          {
            'rmt_amt': (bal + double.parse(amt)).toString(),
          },
          where: 'sm_code = ?',
          whereArgs: [smcode]);
    }
  }

  Future addtoCashLog(smcode, date, amt, type, details, refno) async {
    double bal = 0.00;
    var client = await db;

    List<Map> res = await client.rawQuery(
        'SELECT bal FROM xt_cash_ldg WHERE sm_code = "$smcode" ORDER BY date ASC',
        null);
    if (res.isEmpty) {
      return client.insert('xt_cash_ldg', {
        'sm_code': smcode,
        'date': date,
        'qty_in': amt,
        'qty_out': '0.00',
        'bal': amt,
        'type': type,
        'details': details,
        'ref_no': refno,
      });
    } else {
      for (var element in res) {
        bal = double.parse(element['bal']);
      }
      return client.insert('xt_cash_ldg', {
        'sm_code': smcode,
        'date': date,
        'qty_in': amt,
        'qty_out': '0.00',
        'bal': (bal + double.parse(amt)).toStringAsFixed(2),
        'type': type,
        'details': details,
        'ref_no': refno,
      });
    }
  }

  Future minustoCashLog(smcode, date, amt, type, details, refno) async {
    double bal = 0.00;
    var client = await db;

    List<Map> res = await client.rawQuery(
        'SELECT bal FROM xt_cash_ldg WHERE sm_code = "$smcode" ORDER BY date ASC',
        null);
    if (res.isEmpty) {
      return client.insert('xt_cash_ldg', {
        'sm_code': smcode,
        'date': date,
        'qty_in': '0.00',
        'qty_out': amt,
        'bal': amt,
        'type': type,
        'details': details,
        'ref_no': refno,
      });
    } else {
      for (var element in res) {
        bal = double.parse(element['bal']);
      }
      return client.insert('xt_cash_ldg', {
        'sm_code': smcode,
        'date': date,
        'qty_in': '0.00',
        'qty_out': double.parse(amt).toStringAsFixed(2),
        'bal': (bal - double.parse(amt)).toStringAsFixed(2),
        'type': type,
        'details': details,
        'ref_no': refno,
      });
    }
  }

  Future getCashLedger(code) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM xt_cash_ldg WHERE sm_code="$code" ORDER BY doc_no DESC',
        null);
  }

  Future getChequeDetails(ordNo) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM xt_cheque_data WHERE order_no ="$ordNo"', null);
  }

  Future getForUploadRemit(smcode) async {
    var client = await db;
    return client.rawQuery(
        'SELECT *, " " as newdate FROM xt_rmt WHERE sm_code ="$smcode" AND flag = "0" ORDER BY doc_no ASC',
        null);
  }

  Future checkItemPrice(itmcode, uom) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM item_masterfiles WHERE itemcode ="$itmcode" AND uom = "$uom"',
        null);
  }

  Future checkCPCount(smcode, itmcode, itmuom) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM xt_price_change_log WHERE sm_code="$smcode" AND item_code="$itmcode" AND item_code="$itmuom"',
        null);
  }

  Future setItemPrice(smcode, itmcode, itmuom, itmamt) async {
    // int fqty = 0;
    // double famt = 0.00;
    var client = await db;

    List<Map> res = await client.rawQuery(
        'SELECT item_qty,item_amt FROM xt_sm_load WHERE sm_code = "$smcode" AND item_code = "$itmcode" AND item_uom = "$itmuom"',
        null);
    // final result = count;
    // return res;
    if (res.isEmpty) {
    } else {
      return client.update(
          'xt_sm_load',
          {
            'item_amt': itmamt,
          },
          where: 'sm_code = ? AND item_code = ? AND item_uom = ?',
          whereArgs: [smcode, itmcode, itmuom]);
    }
  }

  // Future setLoadBal(smcode, amt) async {
  //   // double bal = 0.00;
  //   var client = await db;

  //   List<Map> res = await client.rawQuery(
  //       'SELECT * FROM xt_sm_balance WHERE sm_code = "$smcode"', null);
  //   if (res.isEmpty) {
  //   } else {
  //     return client.update(
  //         'xt_sm_balance',
  //         {
  //           'load_bal': amt,
  //         },
  //         where: 'sm_code = ?',
  //         whereArgs: [smcode]);
  //   }
  // }

  Future checkPrincipal() async {
    var client = await db;
    return client.rawQuery(
        'SELECT *,0.00 as discamt FROM tb_principal_discount WHERE status="1"',
        null);
  }

  Future getDiscountDetails(name) async {
    var client = await db;
    return client.rawQuery(
        'SELECT * FROM tb_principal_discount WHERE principal="$name" AND status="1"',
        null);
  }

  Future getTotalAmountperPrincipal(code) async {
    var client = await db;
    return client.rawQuery(
        'SELECT item_principal,SUM(tb_salesman_cart.item_total) as total FROM tb_salesman_cart WHERE salesman_code ="$code" GROUP BY item_principal',
        null);
  }

  Future getSatWarehouseRequestTotal(code) async {
    var client = await db;
    return client.rawQuery(
        'SELECT SUM(xt_tran_head.tot_amt) as total FROM xt_tran_head WHERE sm_code ="$code" AND pmeth_type!="RF" AND tran_stat="Loaded"',
        null);
  }

  Future changeSatWhStat(smcode, stat) async {
    var client = await db;

    List<Map> res = await client.rawQuery(
        'SELECT * FROM xt_tran_head WHERE sm_code = "$smcode" AND pmeth_type!="RF" AND tran_stat="Loaded"',
        null);
    if (res.isEmpty) {
    } else {
      for (var element in res) {
        return client.update(
            'xt_tran_head',
            {
              'tran_stat': stat,
            },
            where: 'sm_code = ?',
            whereArgs: [smcode]);
      }
    }
  }

  Future setBal(smcode, amt) async {
    // double bal = 0.00;
    var client = await db;

    List<Map> res = await client.rawQuery(
        'SELECT * FROM xt_sm_balance WHERE sm_code = "$smcode"', null);
    if (res.isEmpty) {
    } else {
      return client.update(
          'xt_sm_balance',
          {
            'disc_amt': amt,
          },
          where: 'sm_code = ?',
          whereArgs: [smcode]);
    }
  }

  Future getPendingCheque(smcode) async {
    var client = await db;
    return client.rawQuery(
        'SELECT *,false as mark FROM xt_cheque_data WHERE sm_code ="$smcode" AND status="Pending"',
        null);
  }

  Future updateChequeStat(code, ordNo, chequeNo) async {
    var client = await db;
    return client.update(
        'xt_cheque_data',
        {
          'status': 'Uploaded',
        },
        where: 'sm_code = ? AND order_no = ? AND cheque_no = ?',
        whereArgs: [code, ordNo, chequeNo]);
  }

  Future changeRemittanceFlag(code, rmtNo, stat, flag) async {
    var client = await db;
    return client.update(
        'xt_rmt',
        {
          'status': stat,
          'flag': flag,
        },
        where: 'sm_code = ? AND rmt_no = ?',
        whereArgs: [code, rmtNo]);
  }

  Future changeChequeStat(code, stat) async {
    String status = 'Pending';
    var client = await db;
    return client.update(
        'xt_cheque_data',
        {
          'status': stat,
        },
        where: 'sm_code = ? AND status = ?',
        whereArgs: [code, status]);
  }

  Future savexttrandetails(
      smCode, date, tranNo, chequeNo, amount, status) async {
    var client = await db;
    return client.insert('xt_tran_cheque', {
      'sm_code': smCode,
      'date': date,
      'tran_no': tranNo,
      'cheque_no': chequeNo,
      'amount': amount,
      'status': status,
    });
  }

  Future ofFetchSample() async {
    var client = await db;
    return client.rawQuery('SELECT * FROM xt_conv_head ', null);
  }
}
