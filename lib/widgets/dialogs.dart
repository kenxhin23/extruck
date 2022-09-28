import 'package:extruck/values/colors.dart';
import 'package:extruck/widgets/buttons.dart';
import 'package:flutter/material.dart';

enum DialogAction { yes, abort }

class Dialogs {
  static Future<DialogAction> openDialog(
    BuildContext context,
    String title,
    String body,
    bool barrier,
    String abortText,
    String yesText,
  ) async {
    final action = await showDialog(
        context: context,
        barrierDismissible: barrier,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Text(
              title,
              style: TextStyle(color: ColorsTheme.mainColor),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    body,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(DialogAction.abort),
                child: Text(
                  abortText,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(DialogAction.yes),
                style: raisedButtonDialogStyle,
                child: Text(
                  yesText,
                  style: const TextStyle(color: Colors.white),
                ),
              )
            ],
          );
        });
    return (action != null) ? action : DialogAction.abort;
  }
}

class WarningDialogs {
  static Future<DialogAction> openDialog(
    BuildContext context,
    String title,
    String body,
    bool barrier,
    String yesText,
  ) async {
    final action = await showDialog(
        context: context,
        barrierDismissible: barrier,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Text(
              title,
              style: TextStyle(color: ColorsTheme.mainColor),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    body,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(DialogAction.yes),
                style: raisedButtonDialogStyle,
                child: Text(
                  yesText,
                  style: const TextStyle(color: Colors.white),
                ),
              )
            ],
          );
        });
    return (action != null) ? action : DialogAction.abort;
  }
}
