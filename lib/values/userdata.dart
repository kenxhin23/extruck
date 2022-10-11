import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class AppData {
  static String appName = 'E-COMMERCE(ex-Truck App)';
  static String? appVersion;
  static String appYear = ' COPYRIGHT 2022';
  static bool appUptodate = true;
  static String updesc = 'XTRUCK';
}

class ScreenData {
  static double scrWidth = 0.00;
  static double scrHeight = 0.00;
}

class UserData {
  static String? id;
  static String? firstname;
  static String? lastname;
  static String? position;
  static String? department;
  static String? division;
  static String? district;
  static String? contact;
  static String? postal;
  static String? email;
  static String? address;
  static String? routes;
  static String? trans;
  static String? sname;
  static String? username;
  static String? newPassword;
  static String? passwordAge;
  static String? img;
  static String? imgPath;
  static String? getImgfrom;
}

class UserAccess {
  static bool noMinOrder = false;
  static bool multiSalesman = false;
  static List customerList = [];
}

class OrderData {
  static String? trans;
  static String? pmeth;
  static String? name;
  static String? dateReq;
  static String? dateApp;
  static String? dateDel;
  static String? itmno;
  static String? address;
  static String? contact;
  static String? qty;
  static String? smcode;
  static String totamt = '0';
  static String retAmt = '0';
  static String totalDisc = '0';
  static String grandTotal = '0';
  static bool visible = true;
  static String? status;
  static String? changeStat;
  static String? signature;
  static String? pmtype;
  static bool setPmType = false;
  static bool setSign = false;
  static bool setChequeImg = false;
  static List tranLine = [];
  static bool returnOrder = false;
  static String returnReason = "";
  static String specialInstruction = "";
  static bool note = false;
}

class CustomerData {
  static String? id;
  static String? accountCode;
  static String? groupCode;
  static String? province;
  static String? city;
  static String? district;
  static String? accountName;
  static String? accountDescription;
  static String? contactNo;
  static String? paymentType;
  static String? status;
  static String? colorCode;
  static Color? custColor;
  static String? creditLimit;
  static String? creditBal;
  static bool discounted = false;
  static bool placeOrder = true;
  static List tranNoList = [];
  static bool minOrderLock = true;
}

class CartData {
  static String itmNo = '0';
  static String? itmLineNo;
  static String totalAmount = '0';
  static String setCateg = '';
  static String? itmCode;
  static String? itmDesc;
  static String? itmUom;
  static String? itmAmt;
  static String itmQty = '';
  static String itmTotal = "";
  static String? cartTotal;
  static String? imgpath;
  static bool allProd = false;
  static String pMeth = '';
  static String warehouse = '';
  static List list = [];
  static String availableQty = '';
  static String siNum = '';
  static String discAmt = '0.00';
  static String convQty = '';
  static String convUom = '';
  static String convAmt = '';
  static String boAmt = '';
}

class RequestData {
  static String tranNo = '';
  static String status = '';
  static String reqQty = '';
  static String appQty = '';
  static String totAmt = '';
}

class GlobalVariables {
  static bool viewImg = false;
  static String? itmQty;
  static int menuKey = 0;
  static String? tranNo;
  static bool isDone = false;
  static bool showSign = false;
  static bool showCheque = false;
  static List itemlist = [];
  static List favlist = [];
  static List returnList = [];
  static bool emptyFav = true;
  static bool processedPressed = false;
  static String minOrder = '0';
  static bool outofStock = false;
  static bool consolidatedOrder = false;
  static String appVersion = '01';
  static String updateType = '';
  static String updateBy = '';
  // static String dlPercentage = '';
  static String progressString = '';
  static bool updateSpinkit = true;
  static bool uploaded = false;
  static String tableProcessing = '';
  static List processList = [];
  // static List<String> processList = List<String>();
  // processList['process'] = '';
  static bool viewPolicy = true;
  static bool dataPrivacyNoticeScrollBottom = false;
  static String? fpassUsername;
  static String? fpassmobile;
  static String? fpassusercode;
  static String statusCaption = '';
  static String? uploadLength;
  static bool upload = false;
  static bool? uploadSpinkit;
  static double? spinProgress;
  static bool passExp = false;
  static String? deviceData;
  static bool fullSync = false;
  // static String? syncStartDate;
  // static String? syncEndDate;
  static String syncStartDate = DateFormat("yyyy-MM-dd")
      .format(DateTime.now().subtract(const Duration(days: 15)));
  static String syncEndDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  static String revBal = '0.00';
  static String revFund = '0.00';
}

class GlobalTimer {
  static Timer? timerSessionInactivity;
}

class ChequeData {
  static String? accName;
  static String? accNum;
  static String? bankName;
  static String? chequeNum;
  static String? chequeDate;
  static String? status;
  static String? chequeAmt;
  static String? numToWords;
  static String? imgName;
  static String? type;
  static bool changeImg = false;
}

class SalesData {
  static String? salesToday;
  static String? salesWeekly;
  static String? salesMonthly;
  static String? salesYearly;
  static String? salesmanSalesType;
  static String? customerSalesType;
  static String? overallSalesType;
  static String? smTotalCaption;
  static String? custTotalCaption;
  static String? itmTotalCaption;
  static String? itemSalesType;
}

class NetworkData {
  static Timer? timer;
  static bool connected = false;
  static bool errorMsgShow = true;
  static String? errorMsg;
  static bool uploaded = false;
  static String? errorNo;
}

class PrinterData {
  static bool connected = false;
  static String? printerName;
  static String? mac;
}

class ForgetPassData {
  static String? type;
  static String? smsCode;
  static String? number;
}

class ChatData {
  static String? senderName;
  static String? accountCode;
  static String? accountName;
  static String? accountNum;
  static String? refNo;
  static String? status;
  static bool newNotif = false;
}

MyGlobals myGlobals = MyGlobals();

class MyGlobals {
  GlobalKey? _scaffoldKey;
  MyGlobals() {
    _scaffoldKey = GlobalKey();
  }
  GlobalKey get scaffoldKey => _scaffoldKey!;
}

class Spinkit {
  static String? label;
}

class RefundData {
  static List tmplist = [];
}

class ConversionData {
  static List list = [];
}
