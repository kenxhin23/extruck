import 'package:extruck/values/colors.dart';
import 'package:flutter/material.dart';

final ButtonStyle raisedButtonLoginStyle = ElevatedButton.styleFrom(
  onPrimary: Colors.black87,
  primary: ColorsTheme.mainColor,
  minimumSize: const Size(150, 36),
  padding: const EdgeInsets.symmetric(horizontal: 30),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
  ),
);

final ButtonStyle raisedButtonDialogStyle = ElevatedButton.styleFrom(
  onPrimary: Colors.black87,
  primary: ColorsTheme.mainColor,
  minimumSize: const Size(88, 36),
  padding: const EdgeInsets.symmetric(horizontal: 16),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(5)),
  ),
);

final ButtonStyle raisedButtonStyleBlack = ElevatedButton.styleFrom(
  onPrimary: Colors.black87,
  primary: Colors.black,
  minimumSize: const Size(88, 36),
  padding: const EdgeInsets.symmetric(horizontal: 16),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(5)),
  ),
);

final ButtonStyle raisedButtonStyleGreen = ElevatedButton.styleFrom(
  onPrimary: Colors.black87,
  primary: Colors.green,
  minimumSize: const Size(88, 36),
  padding: const EdgeInsets.symmetric(horizontal: 16),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(5)),
  ),
);

final ButtonStyle raisedButtonStyleOrange = ElevatedButton.styleFrom(
  onPrimary: Colors.black87,
  primary: Colors.deepOrange,
  minimumSize: const Size(88, 36),
  padding: const EdgeInsets.symmetric(horizontal: 16),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(5)),
  ),
);

final ButtonStyle raisedButtonStyleGrey = ElevatedButton.styleFrom(
  onPrimary: Colors.black87,
  primary: Colors.grey,
  minimumSize: const Size(88, 36),
  padding: const EdgeInsets.symmetric(horizontal: 16),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(5)),
  ),
);
final ButtonStyle raisedButtonStyleBlue = ElevatedButton.styleFrom(
  onPrimary: Colors.black87,
  primary: Colors.blue,
  minimumSize: const Size(88, 36),
  padding: const EdgeInsets.symmetric(horizontal: 16),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(5)),
  ),
);

final ButtonStyle raisedButtonStyleWhite = ElevatedButton.styleFrom(
  onPrimary: ColorsTheme.mainColor,
  primary: Colors.white,
  minimumSize: const Size(88, 36),
  padding: const EdgeInsets.symmetric(horizontal: 16),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(5)),
    side: BorderSide(color: Colors.white, width: 1),
  ),
);

final ButtonStyle raisedButtonStyleBlackOut = ElevatedButton.styleFrom(
  onPrimary: ColorsTheme.mainColor,
  primary: Colors.white,
  minimumSize: const Size(88, 36),
  padding: const EdgeInsets.symmetric(horizontal: 16),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(5)),
    side: BorderSide(color: Colors.black, width: 1),
  ),
);

final ButtonStyle syncButtonDialogStyle = ElevatedButton.styleFrom(
  onPrimary: Colors.black87,
  primary: ColorsTheme.mainColor,
  minimumSize: const Size(98, 46),
  padding: const EdgeInsets.symmetric(horizontal: 24),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(5)),
  ),
);

final ButtonStyle syncButtonStyleWhite = ElevatedButton.styleFrom(
  onPrimary: ColorsTheme.mainColor,
  primary: Colors.white,
  minimumSize: const Size(98, 46),
  padding: const EdgeInsets.symmetric(horizontal: 24),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(5)),
    side: BorderSide(color: Colors.white, width: 1),
  ),
);
