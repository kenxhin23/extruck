import 'package:extruck/values/colors.dart';
import 'package:extruck/values/userdata.dart';
import 'package:extruck/widgets/buttons.dart';
import 'package:flutter/material.dart';

class ConfirmUpload extends StatefulWidget {
  final String? title, description1, description2;

  // ignore: use_key_in_widget_constructors
  const ConfirmUpload({this.title, this.description1, this.description2});

  @override
  // ignore: library_private_types_in_public_api
  _ConfirmUploadState createState() => _ConfirmUploadState();
}

class _ConfirmUploadState extends State<ConfirmUpload> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: unableContent(context),
    );
  }

  unableContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(top: 5, bottom: 16, right: 5, left: 5),
          margin: const EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(20),
              // ignore: prefer_const_literals_to_create_immutables
              boxShadow: [
                const BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 10.0),
                ),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.help_outline,
                color: ColorsTheme.mainColor,
                size: 72,
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 5),
                height: 100,
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                // decoration: BoxDecoration(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(
                      height: 15,
                    ),
                    // ignore: avoid_unnecessary_containers
                    Container(
                      child: Text(
                        widget.title.toString(),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    // ignore: avoid_unnecessary_containers
                    Container(
                      child: Column(
                        children: [
                          Text(
                            widget.description1.toString(),
                            style: const TextStyle(fontSize: 12),
                            textAlign: TextAlign.justify,
                          ),
                          Text(
                            widget.description2.toString(),
                            style: const TextStyle(fontSize: 12),
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      style: raisedButtonDialogStyle,
                      onPressed: () {
                        setState(() {
                          GlobalVariables.upload = true;
                          Navigator.pop(context);
                        });
                      },
                      child: const Text(
                        'Confirm',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    ElevatedButton(
                      style: raisedButtonStyleWhite,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: ColorsTheme.mainColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
