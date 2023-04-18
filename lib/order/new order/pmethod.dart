import 'dart:convert';

import 'package:extruck/db/db_helper.dart';
import 'package:extruck/values/colors.dart';
import 'package:extruck/values/userdata.dart';
import 'package:extruck/widgets/buttons.dart';
import 'package:extruck/widgets/dialogs.dart';
import 'package:extruck/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:flutter/src/foundation/key.dart';
// import 'package:flutter/src/widgets/framework.dart';

enum PMethodName { none, cash, cheque }

enum ChequeTypeName { none, dated, postdated }

class PaymentMethod extends StatefulWidget {
  const PaymentMethod({Key? key}) : super(key: key);

  @override
  State<PaymentMethod> createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  bool cheque = false;
  bool chequeType = false;
  bool pMeth = false;
  DateTime pickedDate = DateTime.now();
  List _banklist = [];

  final db = DatabaseHelper();

  PMethodName? _pmeth = PMethodName.none;
  ChequeTypeName? _checktype = ChequeTypeName.none;

  final accNameController = TextEditingController();
  final accNumController = TextEditingController();
  final chequeNumController = TextEditingController();
  final chequeDateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String date = DateFormat("dd-MM-yyyy").format(DateTime.now());

  final formatCurrencyAmt = NumberFormat.currency(locale: "en_US", symbol: "₱");
  final formatCurrencyTot = NumberFormat.currency(locale: "en_US", symbol: "Php ");

  @override
  void initState() {
    super.initState();
    getBankList();
  }

  getBankList() async {
    pMeth = false;
    var rsp = await db.getBankList();
    setState(() {
      _banklist = json.decode(json.encode(rsp));
      ChequeData.bankName = 'Bank of Commerce';
    });
    // print(_banklist);
  }

  _pickDate() async {
    pickedDate = DateTime.now();
    DateTime? dt = await showDatePicker(
      context: context,
      initialDate: pickedDate,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (dt != null) {
      setState(() {
        pickedDate = dt;
        date = DateFormat("dd-MM-yyyy").format(dt);
        ChequeData.chequeDate = date;
        chequeDateController.text = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: ColorsTheme.mainColor,
        ),
        backgroundColor: Colors.grey[100],
        body: Column(
          children: [
            pmethodCont(),
            pmethOptCont(context),
            const SizedBox(height: 10),
            Visibility(visible: cheque, child: chequeDetCont(context)),
            const SizedBox(height: 2),
            Visibility(visible: cheque, child: chequeFieldsCont(context, node)),
            selectCont(context),
          ],
        ),
      ),
    );
  }

  Container selectCont(BuildContext context) {
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
                style: !pMeth ? raisedButtonStyleGrey : raisedButtonStyleGreen,
                onPressed: () async {
                  if (pMeth) {
                    if (CartData.pMeth == 'Cash') {
                      String msg = 'Successfully selected cash as payment method.';
                      // ignore: use_build_context_synchronously
                      final action = await WarningDialogs.openDialog(
                        context,
                        'Information',
                        msg,
                        false,
                        'OK',
                      );
                      if (action == DialogAction.yes) {
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      } else {}
                    }
                    if (CartData.pMeth == 'Cheque') {
                      // print(accNameController.text);
                      if (_formKey.currentState!.validate()) {
                        if (!chequeType) {
                          showGlobalSnackbar(
                            'Information',
                            'Please select cheque type.',
                            Colors.grey,
                            Colors.white,
                          );
                        } else {
                          ChequeData.accName = accNameController.text;
                          ChequeData.accNum = accNumController.text;
                          ChequeData.chequeNum = chequeNumController.text;
                          ChequeData.chequeDate = chequeDateController.text;

                          String msg = 'Cheque details has been saved successfully.';
                          // ignore: use_build_context_synchronously
                          final action = await WarningDialogs.openDialog(
                            context,
                            'Information',
                            msg,
                            false,
                            'OK',
                          );
                          if (action == DialogAction.yes) {
                            // ignore: use_build_context_synchronously
                            Navigator.pop(context);
                          } else {}
                        }
                      } else {
                        if (accNameController.text.isEmpty) {
                          showGlobalSnackbar(
                            'Information',
                            'Invalid account name.',
                            Colors.grey,
                            Colors.white,
                          );
                        }
                      }
                    }
                  } else {
                    showGlobalSnackbar(
                      'Information',
                      'Please select payment method.',
                      Colors.grey,
                      Colors.white,
                    );
                  }
                },
                child: const Text('SELECT PAYMENT METHOD',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Row pmethOptCont(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width / 2 - 15,
          height: 40,
          child: ListTile(
            title: const Text('Cash'),
            leading: Radio<PMethodName>(
              value: PMethodName.cash,
              groupValue: _pmeth,
              onChanged: (PMethodName? value) {
                setState(() {
                  _pmeth = value;
                  cheque = false;
                  pMeth = true;
                  CartData.pMeth = 'Cash';
                });
              },
            ),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width / 2 - 15,
          height: 40,
          child: ListTile(
            title: const Text('Cheque'),
            leading: Radio<PMethodName>(
              value: PMethodName.cheque,
              groupValue: _pmeth,
              onChanged: (PMethodName? value) {
                setState(() {
                  _pmeth = value;
                  cheque = true;
                  pMeth = true;
                  CartData.pMeth = 'Cheque';
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Expanded chequeFieldsCont(BuildContext context, FocusScopeNode node) {
    return Expanded(
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 15, right: 15),
                width: MediaQuery.of(context).size.width,
                height: 90,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Account Name',
                      style: TextStyle(fontWeight: FontWeight.w400, color: Colors.grey[500]),
                    ),
                    TextFormField(
                      enabled: cheque,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.characters,
                      // onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      onEditingComplete: () => node.nextFocus(),
                      controller: accNameController,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      decoration: const InputDecoration(
                          hintText: 'Input Account Name',
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black87),
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                          ),
                        ),
                      validator: (value) {
                        if (value!.isEmpty || value == ' ') {
                          return 'Account Name cannot be empty';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.only(left: 15, right: 15),
                width: MediaQuery.of(context).size.width,
                height: 90,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Account No.',
                      style: TextStyle(
                        fontWeight: FontWeight.w400, color: Colors.grey[500],
                      ),
                    ),
                    TextFormField(
                      enabled: cheque,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      // onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      onEditingComplete: () => node.nextFocus(),
                      controller: accNumController,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      decoration: const InputDecoration(
                        hintText: 'Input Account Number',
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.all(Radius.circular(0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black87),
                          borderRadius: BorderRadius.all(Radius.circular(0)),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty || value == ' ') {
                          return 'Account Number cannot be empty';
                        }
                        return null;
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.only(left: 15, right: 15),
                width: MediaQuery.of(context).size.width,
                height: 80,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bank Name',
                      style: TextStyle(fontWeight: FontWeight.w400, color: Colors.grey[500]),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: ButtonTheme(
                              // padding: const EdgeInsets.symmetric(
                              //     vertical: 30, horizontal: 60),
                              alignedDropdown: true,
                              child: DropdownButton<String>(
                                // style: const TextStyle(
                                //   fontSize: 14,
                                // ),
                                value: ChequeData.bankName,
                                items: _banklist.map((item) {
                                  return DropdownMenuItem(
                                    value: item['bank_name'].toString(),
                                    child: Text(
                                      item['bank_name'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (!cheque) {
                                    null;
                                  } else {
                                    setState(() {
                                      ChequeData.bankName = newValue.toString();
                                      // itemSalesTypeChanged();
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.only(left: 15, right: 15),
                width: MediaQuery.of(context).size.width,
                height: 90,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cheque No.',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[500],
                      ),
                    ),
                    TextFormField(
                      enabled: cheque,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      // onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      onEditingComplete: () => node.nextFocus(),
                      controller: chequeNumController,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      decoration: const InputDecoration(
                        hintText: 'Input Cheque Number',
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.all(Radius.circular(0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black87),
                          borderRadius: BorderRadius.all(Radius.circular(0)),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty || value == ' ') {
                          return 'Cheque Number cannot be empty';
                        }
                        return null;
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.only(left: 15, right: 15),
                width: MediaQuery.of(context).size.width,
                height: 90,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cheque Date',
                      style: TextStyle(
                        fontWeight: FontWeight.w400, color: Colors.grey[500],
                      ),
                    ),
                    TextFormField(
                      enabled: cheque,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.datetime,
                      // onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      onEditingComplete: () => node.nextFocus(),
                      controller: chequeDateController,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      decoration: const InputDecoration(
                        hintText: 'Input Cheque Date',
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.all(Radius.circular(0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black87),
                          borderRadius: BorderRadius.all(Radius.circular(0)),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty || value == ' ') {
                          return 'Cheque Date cannot be empty';
                        }
                        return null;
                      },
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        _pickDate();
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.only(left: 15, right: 15),
                width: MediaQuery.of(context).size.width,
                height: 80,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cheque Type',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[500],
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2 - 15,
                          child: ListTile(
                            title: const Text('Dated'),
                            leading: Radio<ChequeTypeName>(
                              value: ChequeTypeName.dated,
                              groupValue: _checktype,
                              onChanged: (ChequeTypeName? value) {
                                setState(() {
                                  _checktype = value;
                                  chequeType = true;
                                  ChequeData.type = 'Dated';
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2 - 15,
                          child: ListTile(
                            title: const Text('Post Dated'),
                            leading: Radio<ChequeTypeName>(
                              value: ChequeTypeName.postdated,
                              groupValue: _checktype,
                              onChanged: (ChequeTypeName? value) {
                                setState(() {
                                  _checktype = value;
                                  chequeType = true;
                                  ChequeData.type = 'Post Dated';
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
            ],
          ),
        ),
      ),
    );
  }

  Container chequeDetCont(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15),
      width: MediaQuery.of(context).size.width,
      height: 40,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cheque details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Container pmethodCont() {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 15),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.blue,
              size: 24,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Text('Payment Method',
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
