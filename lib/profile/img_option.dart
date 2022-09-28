import 'package:extruck/values/userdata.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Option extends StatelessWidget {
  const Option({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        backgroundColor: Colors.grey[100],
        child: dialogContent(context),
      ),
    );
  }

  dialogContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(
            'Choose image from',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                UserData.getImgfrom = 'Camera';
                Navigator.pop(context);
              },
              child: Column(
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  const Icon(
                    CupertinoIcons.camera_circle,
                    size: 45,
                  ),
                  const Text('Camera'),
                ],
              ),
            ),
            const SizedBox(
              width: 50,
            ),
            InkWell(
              onTap: () {
                UserData.getImgfrom = 'Gallery';
                Navigator.pop(context);
              },
              child: Column(
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  const Icon(
                    CupertinoIcons.photo,
                    size: 45,
                  ),
                  const Text('Gallery'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        )
      ],
    );
  }
}
