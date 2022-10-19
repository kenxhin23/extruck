import 'package:extruck/providers/caption_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoadingSpinkit extends StatefulWidget {
  const LoadingSpinkit({Key? key}) : super(key: key);

  @override
  _LoadingSpinkitState createState() => _LoadingSpinkitState();
}

class _LoadingSpinkitState extends State<LoadingSpinkit> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(true),
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
