import 'dart:async';
import 'package:extruck/db/db_helper.dart';
import 'package:extruck/values/colors.dart';
import 'package:extruck/values/userdata.dart';
import 'package:extruck/welcome/welcome.dart';
import 'package:extruck/widgets/buttons.dart';
import 'package:extruck/widgets/dialogs.dart';
import 'package:extruck/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ChangePass extends StatefulWidget {
  const ChangePass({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ChangePassState createState() => _ChangePassState();
}

class _ChangePassState extends State<ChangePass> {
  bool hasUppercase = false;
  bool hasDigits = false;
  bool hasLowercase = false;
  bool hasSpecialCharacters = false;
  bool hasMinLength = false;
  bool passReq = false;
  bool viewSpinkit = true;
  bool _obscureText = true;
  bool _obscureText2 = true;
  bool validPass = false;

  // List _userdata = [];
  List device = [];
  List pass = [];

  String response = '';
  String loginDialog = '';
  String err1 = 'No Internet Connection';
  String err2 = 'No Connection to Server';
  String err3 = 'API Error';
  String message = '';

  final db = DatabaseHelper();
  final orangeColor = ColorsTheme.mainColor;
  final yellowColor = Colors.amber;
  final blueColor = Colors.blue;

  Timer? timer;

  // static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  // Map<String, dynamic> _deviceData = <String, dynamic>{};

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final newPassController = TextEditingController();
  final confPassController = TextEditingController();

  bool isPasswordCompliant(String password, [int minLength = 7]) {
    if (password.isEmpty) {
      return false;
    }

    hasUppercase = password.contains(RegExp(r'[A-Z]'));
    hasDigits = password.contains(RegExp(r'[0-9]'));
    hasLowercase = password.contains(RegExp(r'[a-z]'));
    hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    hasMinLength = password.length > minLength;

    return hasDigits &
        hasUppercase &
        hasLowercase &
        hasSpecialCharacters &
        hasMinLength;
  }

  @override
  void initState() {
    super.initState();
    // initPlatformState();
  }

  @override
  void dispose() {
    newPassController.dispose();
    confPassController.dispose();
    timer?.cancel();
    // print('Timer Disposed');
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _toggle2() {
    setState(() {
      _obscureText2 = !_obscureText2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 20, bottom: 20),
                child: Column(
                  children: <Widget>[
                    const SizedBox(
                      height: 80,
                    ),
                    // Container(
                    //   margin: EdgeInsets.only(top: 24),
                    //   width: 200,
                    //   height: 200,
                    //   child: Center(
                    //     child: Image(
                    //       image: AssetImage('assets/images/dtruck.png'),
                    //     ),
                    //   ),
                    // ),
                    Text("Change Password",
                      style: TextStyle(color: ColorsTheme.mainColor, fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      /*curve: Curves.easeInOutBack,*/
                      // height: 250,
                      width: MediaQuery.of(context).size.width,
                      // color: Colors.grey,
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: SingleChildScrollView(
                        child: buildSignInTextField(),
                      ),
                    ),
                    buildNextButton(),
                    buildPassReq(),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                // height: 30,
                // color: Colors.grey,
                child: Text('${'E-COMMERCE(EXTRUCK APP) V1.${GlobalVariables.appVersion}'} COPYRIGHT 2020',
                  style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container buildNextButton() {
    return Container(
      margin: const EdgeInsets.only(top: 0),
      child: Column(
        children: [
          ElevatedButton(
            style: raisedButtonLoginStyle,
            onPressed: () async {
              setState(() {
                if (!mounted) {
                  // print(hasUppercase);
                }
              });
              if (_formKey.currentState!.validate()) {
                var npass = newPassController.text;
                if (!NetworkData.connected) {
                  if (NetworkData.errorNo == '1') {
                    showGlobalSnackbar(
                        'Connectivity',
                        'Please connect to internet.',
                        Colors.red.shade900,
                        Colors.white);
                  }
                  if (NetworkData.errorNo == '2') {
                    showGlobalSnackbar(
                        'Connectivity',
                        'API Problem. Please contact admin.',
                        Colors.red.shade900,
                        Colors.white);
                  }
                  if (NetworkData.errorNo == '3') {
                    showGlobalSnackbar(
                        'Connectivity',
                        'Cannot connect to server. Try again later.',
                        Colors.red.shade900,
                        Colors.white);
                  }
                } else {
                  // showDialog(
                  //     context: context,
                  //     builder: (context) => LoadingSpinkit(
                  //           description: 'Changing Password...',
                  //         ));
                  if (UserData.position == 'Salesman') {
                    var getP = await db.getSMPasswordHistory(
                        UserData.id!, newPassController.text);
                    pass = getP;
                    if (pass.isNotEmpty) {
                      showGlobalSnackbar(
                          'Information',
                          "Choose a password you haven't previously used with this account.",
                          Colors.blue,
                          Colors.white);
                    } else {
                      showDialog(
                          context: context,
                          builder: (context) => const LoadingSpinkit(
                                description: 'Changing Password...',
                              ));
                      var cPass =
                          await db.changeSalesmanPassword(UserData.id!, npass);
                      // print(cPass);
                      if (cPass != 'failed') {
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                        await db.updateSalesmanPassword(
                            GlobalVariables.fpassusercode, cPass);

                        // ignore: use_build_context_synchronously
                        final action = await WarningDialogs.openDialog(
                          context,
                          'Information',
                          'Password changed successfully.',
                          false,
                          'OK',
                        );
                        if (action == DialogAction.yes) {
                          // ignore: use_build_context_synchronously
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const WelcomePage()),
                              ModalRoute.withName('/splash'));
                        } else {}
                      }
                    }
                  }
                  if (UserData.position == 'Jefe de Viaje') {
                    var getP = await db.getHEPEPasswordHistory(
                        UserData.id!, newPassController.text);
                    pass = getP;
                    if (pass.isNotEmpty) {
                      showGlobalSnackbar(
                          'Information',
                          "Choose a password you haven't previously used with this account.",
                          Colors.blue,
                          Colors.white);
                    } else {
                      showDialog(
                          context: context,
                          builder: (context) => const LoadingSpinkit(
                                description: 'Changing Password...',
                              ));
                      var cPass =
                          await db.changeHepePassword(UserData.id!, npass);
                      if (cPass != 'failed') {
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                        await db.updateHepePassword(
                            GlobalVariables.fpassusercode, cPass);

                        // ignore: use_build_context_synchronously
                        final action = await WarningDialogs.openDialog(
                          context,
                          'Information',
                          'Password changed successfully.',
                          false,
                          'OK',
                        );
                        if (action == DialogAction.yes) {
                          // ignore: use_build_context_synchronously
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const WelcomePage()),
                              ModalRoute.withName('/splash'));
                        } else {}
                      }
                    }
                  }
                }
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              // ignore: prefer_const_literals_to_create_immutables
              children: [
                const Text(
                  "Confirm",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // SizedBox(
          //   height: 60,
          // ),
          // Text(message),
        ],
      ),
    );
  }

  Column buildSignInTextField() {
    final node = FocusScope.of(context);
    return Column(children: [
      Form(
        key: _formKey,
        child: Column(children: <Widget>[
          TextFormField(
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'[ ]')),
            ],
            // onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
            onEditingComplete: () => node.nextFocus(),
            // onEditingComplete: () {
            //   if (_formKey.currentState.validate()) {}
            // },
            obscureText: _obscureText,
            controller: newPassController,
            decoration: InputDecoration(
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black87),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                  size: 30,
                ),
                onPressed: () {
                  _toggle();
                },
              ),
              hintText: 'Enter new password',
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Field cannot be empty';
              }
              passReq = isPasswordCompliant(value);
              if (!passReq) {
                return 'Invalid Password';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 25,
          ),
          TextFormField(
            textInputAction: TextInputAction.done,
            // onFieldSubmitted: (_) => node.unfocus(),
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'[ ]')),
            ],
            obscureText: _obscureText2,
            controller: confPassController,
            decoration: InputDecoration(
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText2 ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                  size: 30,
                ),
                onPressed: () {
                  _toggle2();
                },
              ),
              hintText: 'Confirm password',
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Field cannot be empty';
              }
              if (value != newPassController.text) {
                return "Password does not match";
              }
              return null;
            },
          ),
        ]),
      )
    ]);
  }

  Container buildPassReq() {
    return Container(
      margin: const EdgeInsets.only(top: 30, left: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('* Must have a minimum of 8 characters',
            style: TextStyle(fontSize: 12, color: hasMinLength ? Colors.green : ColorsTheme.mainColor,
            ),
          ),
          Text('* Must include at least 1 uppercase',
            style: TextStyle(fontSize: 12, color: hasUppercase ? Colors.green : ColorsTheme.mainColor,
            ),
          ),
          Text('* Must include at least 1 lowercase',
            style: TextStyle(fontSize: 12, color: hasLowercase ? Colors.green : ColorsTheme.mainColor,
            ),
          ),
          Text('* Must include at least 1 digit ',
            style: TextStyle(fontSize: 12, color: hasDigits ? Colors.green : ColorsTheme.mainColor,
            ),
            // textAlign: TextAlign.left,
          ),
          Text('* Must include at least 1 special character: ! @ # % ^ & * ( ) , . ? : { } | < > ]',
            style: TextStyle(fontSize: 12, color: hasSpecialCharacters ? Colors.green : ColorsTheme.mainColor,
            ),
            // textAlign: TextAlign.left,
          ),

          Visibility(
            visible: GlobalVariables.passExp,
            child: Container(
              padding: const EdgeInsets.only(top: 15),
              child: Text('Your password already expired. Please change to a new password to continue.',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: hasSpecialCharacters ? Colors.green : ColorsTheme.mainColor,
                ),
              ),
            ),
          ),
          // Text(message),
        ],
      ),
    );
  }
}

class LoadingSpinkit extends StatefulWidget {
  final String? description;

  // ignore: use_key_in_widget_constructors
  const LoadingSpinkit({this.description});
  @override
  // ignore: library_private_types_in_public_api
  _LoadingSpinkitState createState() => _LoadingSpinkitState();
}

class _LoadingSpinkitState extends State<LoadingSpinkit> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      // child: confirmContent(context),
      child: loadingContent(context),
    );
  }

  loadingContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          // width: MediaQuery.of(context).size.width,
          padding:
              const EdgeInsets.only(top: 50, bottom: 16, right: 5, left: 5),
          margin: const EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.transparent,
                  // blurRadius: 10.0,
                  // offset: Offset(0.0, 10.0),
                ),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                // 'Checking username...',
                widget.description.toString(),
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: Colors.white),
              ),
              SpinKitCircle(
                color: ColorsTheme.mainColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
