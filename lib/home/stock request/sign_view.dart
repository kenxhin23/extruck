import 'dart:convert';

import 'package:extruck/home/stock%20request/sign.dart';
import 'package:extruck/values/userdata.dart';
import 'package:flutter/material.dart';
// import 'package:salesman/home/signature.dart';

class ViewSignature extends StatefulWidget {
  const ViewSignature({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ViewSignatureState createState() => _ViewSignatureState();
}

class _ViewSignatureState extends State<ViewSignature> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Signature Captured')),
      ),
      body: Center(
          child: Stack(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 20),
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width,
            color: Colors.grey[100],
            child: Image.memory(base64Decode(OrderData.signature!)),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 250),
              width: MediaQuery.of(context).size.width / 2,
              height: 40,
              // color: Colors.grey,
              child: OutlinedButton(
                onPressed: () {
                  // ChequeData.changeImg = true;
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return const MyApp();
                  }));
                },
                child: const Text('Change Signature'),
              ),
            ),
          ),
        ],
      )),
    );
  }
}
