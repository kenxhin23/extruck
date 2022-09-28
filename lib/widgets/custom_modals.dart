import 'package:flutter/material.dart';

customModal(BuildContext context, Icon icon, Text msg, bool isDismissible,
    Icon iconBtn, String txtBtn, Function fn) {
  return showModalBottomSheet(
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      context: context,
      builder: (context) {
        var size = MediaQuery.of(context).size;
        return WillPopScope(
          onWillPop: () async => isDismissible,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(top: 8.0), child: icon),
                    Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: msg),
                    !isDismissible
                        ? InkWell(
                            child: SizedBox(
                              width: size.width / 3,
                              height: size.height / 20,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  const Spacer(),
                                  iconBtn,
                                  Text(txtBtn),
                                  const Spacer(),
                                ],
                              ),
                            ),
                            onTap: () {
                              fn();
                            },
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            ),
          ),
        );
      });
}
