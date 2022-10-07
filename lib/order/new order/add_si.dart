import 'package:extruck/values/userdata.dart';
import 'package:extruck/widgets/buttons.dart';
import 'package:extruck/widgets/dialogs.dart';
import 'package:extruck/widgets/snackbar.dart';
import 'package:flutter/material.dart';

class AddSalesInvoice extends StatefulWidget {
  const AddSalesInvoice({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AddSalesInvoiceState createState() => _AddSalesInvoiceState();
}

class _AddSalesInvoiceState extends State<AddSalesInvoice> {
  final salesinvoicecontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    final node = FocusScope.of(context);
    if (CartData.siNum != '') {
      salesinvoicecontroller.text = CartData.siNum;
    }
    return Container(
      padding: const EdgeInsets.all(15),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Enter Sales Invoice #',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.grey[500]),
          ),
          const SizedBox(height: 5),
          TextFormField(
            textInputAction: TextInputAction.next,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            // initialValue: salesinvoicecontroller.text,
            // onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
            onEditingComplete: () => node.nextFocus(),
            controller: salesinvoicecontroller,
            style: const TextStyle(fontWeight: FontWeight.w500),
            decoration: const InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.all(Radius.circular(0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black87),
                  borderRadius: BorderRadius.all(Radius.circular(0)),
                ),
                hintText: 'Input Sales Invoice Number'),
            validator: (value) {
              if (value!.isEmpty || value == ' ') {
                return 'Sales Invoice Number cannot be empty';
              }
              return null;
            },
          ),
          const SizedBox(height: 5),
          ElevatedButton(
            style: raisedButtonStyleGreen,
            onPressed: () async {
              if (salesinvoicecontroller.text.isEmpty) {
                showGlobalSnackbar(
                    'Information',
                    'Please input sales invoice number.',
                    Colors.grey,
                    Colors.white);
              } else {
                CartData.siNum = salesinvoicecontroller.text;
                String msg =
                    'Sales Invoice number has been saved successfully.';
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
                }
              }
            },
            child: const Text(
              'SAVE SALES INVOICE NUMBER',
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
