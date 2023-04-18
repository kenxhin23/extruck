import 'dart:async';
import 'dart:convert';
// import 'dart:io';
// import 'dart:convert';
// import 'package:device_info_plus/device_info_plus.dart';
import 'package:extruck/db/db_helper.dart';
import 'package:extruck/values/assets.dart';
import 'package:extruck/values/colors.dart';
import 'package:extruck/values/userdata.dart';
import 'package:extruck/widgets/buttons.dart';
import 'package:extruck/widgets/snackbar.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:salesman/salesman_home/menu.dart';
// import 'dart:developer' as developer;
// import 'package:flutter/services.dart';

class SalesmanLoginPage extends StatefulWidget {
  const SalesmanLoginPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SalesmanLoginPageState createState() => _SalesmanLoginPageState();
}

class _SalesmanLoginPageState extends State<SalesmanLoginPage> {
  List _userdata = [];
  List device = [];
  List _userAttempt = [];
  // List _deviceData = [];
  String loginDialog = '';
  String err1 = 'No Internet Connection';
  String err2 = 'API Error';
  String err3 = 'No Connection to Server';
  final db = DatabaseHelper();
  final orangeColor = ColorsTheme.mainColor;
  final yellowColor = Colors.amber;
  final blueColor = Colors.blue;

  Timer? timer;

  // static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  // final Map<String, dynamic> _deviceData = <String, dynamic>{};

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool viewSpinkit = true;
  bool _obscureText = true;
  String message = '';
  String? imgPath;

  // final List _userAttempt = [];

  // @override
  // void initState() {
  //   super.initState();
  //   initPlatformState();
  // }

  @override
  void initState() {
    timer =
        Timer.periodic(const Duration(seconds: 1), (Timer t) => checkStatus());
    super.initState();
    getImagePath();
    checkStatus();
    // initPlatformState();
  }

  getImagePath() async {
    var documentDirectory = await getApplicationDocumentsDirectory();
    var firstPath = '${documentDirectory.path}/images/user/';
    // setState(() {
    imgPath = firstPath.toString();
    // imgName = UserData.img.toString();
    // loadingImg = false;
    // UserData
    // print(imgPath + imgName);
    // });
  }

  checkFailureAttempts() async {
    for (var element in _userAttempt) {
      if (element['username'] == usernameController.text &&
          int.parse(element['attempt'].toString()) >= 3) {
        // print('ACCOUNT WILL BE LOCKED OUT');
        // showDialog(
        //     barrierDismissible: false,
        //     context: context,
        //     builder: (context) => LockAccount(
        //           title: 'Account Locked',
        //           description:
        //               'This account will be locked due to excessive login failures. Please contact your administrator.',
        //           buttonText: 'Okay',
        //         ));
        showGlobalSnackbar(
          'Information',
          'This account has been locked due to excessive login failures. Please contact your administrator.',
          Colors.blue,
          Colors.white,
        );
        db.updateSalesmanStatus(usernameController.text);
        if (NetworkData.connected) {
          db.updateSalesmanStatusOnline(usernameController.text);
        }
      }
    }
  }

  checkStatus() async {
    var stat = await db.checkStat();
    // print(stat);
    // setState(() {
    if (stat == 'Connected') {
      NetworkData.connected = true;
      NetworkData.errorMsgShow = false;
      // upload();
      NetworkData.errorMsg = '';
      // print('Connected to Internet!');
    } else {
      if (stat == 'ERROR1') {
        NetworkData.connected = false;
        NetworkData.errorMsgShow = true;
        NetworkData.errorMsg = err1;
        NetworkData.errorNo = '1';
        // print('Network Error...');
      }
      if (stat == 'ERROR2') {
        NetworkData.connected = false;
        NetworkData.errorMsgShow = true;
        NetworkData.errorMsg = err2;
        NetworkData.errorNo = '2';
        // print('Connection to API Error...');
      }
      if (stat == 'ERROR3') {
        NetworkData.connected = false;
        NetworkData.errorMsgShow = true;
        NetworkData.errorMsg = err3;
        NetworkData.errorNo = '3';
        // print('Cannot connect to the Server...');
      }
      if (stat == 'Updating') {
        NetworkData.connected = false;
        NetworkData.errorMsgShow = true;
        NetworkData.errorMsg = 'Updating Server';
        NetworkData.errorNo = '4';
        // print('Updating Server...');
      }
    }
    // });
  }

  // Future<void> initPlatformState() async {
  //   Map<String, dynamic> deviceData;

  //   try {
  //     if (Platform.isAndroid) {
  //       deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
  //     }
  //   } on PlatformException {
  //     deviceData = <String, dynamic>{
  //       'Error:': 'Failed to get platform version.'
  //     };
  //   }

  //   if (!mounted) return;

  //   setState(() {
  //     _deviceData = deviceData;
  //   });
  // }
  // Future<void> initPlatformState() async {
  //   var deviceData = <String, dynamic>{};

  //   try {
  //     if (kIsWeb) {
  //       deviceData = _readWebBrowserInfo(await deviceInfoPlugin.webBrowserInfo);
  //     } else {
  //       if (Platform.isAndroid) {
  //         deviceData =
  //             _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
  //       }
  //     }
  //   } on PlatformException {
  //     deviceData = <String, dynamic>{
  //       'Error:': 'Failed to get platform version.'
  //     };
  //   }

  //   if (!mounted) return;

  //   setState(() {
  //     _deviceData = deviceData;
  //   });
  // }

  // Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
  //   return <String, dynamic>{
  //     'version.securityPatch': build.version.securityPatch,
  //     'version.sdkInt': build.version.sdkInt,
  //     'version.release': build.version.release,
  //     'version.previewSdkInt': build.version.previewSdkInt,
  //     'version.incremental': build.version.incremental,
  //     'version.codename': build.version.codename,
  //     'version.baseOS': build.version.baseOS,
  //     'board': build.board,
  //     'bootloader': build.bootloader,
  //     'brand': build.brand,
  //     'device': build.device,
  //     'display': build.display,
  //     'fingerprint': build.fingerprint,
  //     'hardware': build.hardware,
  //     'host': build.host,
  //     'id': build.id,
  //     'manufacturer': build.manufacturer,
  //     'model': build.model,
  //     'product': build.product,
  //     'supported32BitAbis': build.supported32BitAbis,
  //     'supported64BitAbis': build.supported64BitAbis,
  //     'supportedAbis': build.supportedAbis,
  //     'tags': build.tags,
  //     'type': build.type,
  //     'isPhysicalDevice': build.isPhysicalDevice,
  //     'androidId': build.androidId,
  //     'systemFeatures': build.systemFeatures,
  //   };
  // }

  @override
  void dispose() {
    timer?.cancel();
    usernameController.dispose();
    passwordController.dispose();
    // print('Timer Disposed');
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    // margin: EdgeInsets.only(top: 0),
                    // width: 200,
                    width: ScreenData.scrWidth * .55,
                    height: ScreenData.scrWidth * .4,
                    child: Center(
                      child: Image(
                        image: AssetsValues.loginLogo,
                      ),
                    ),
                  ),
                  const Text("Salesman Login",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: ScreenData.scrHeight * .030,
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: ScreenData.scrHeight * .27,
                    width: ScreenData.scrWidth * .84,
                    child: SingleChildScrollView(
                      child: buildSignInTextField(),
                    ),
                  ),
                  SizedBox(
                    height: ScreenData.scrHeight * .030,
                  ),
                  buildSignInButton(),
                  buildForgetPass(),
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
              child: const Text('E-COMMERCE(exTruck App) COPYRIGHT 2022',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container buildSignInButton() {
    return Container(
      margin: const EdgeInsets.only(top: 0),
      child: Column(
        children: [
          ElevatedButton(
            style: raisedButtonLoginStyle,
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                checkFailureAttempts();
                var username = usernameController.text;
                var password = passwordController.text;

                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) => const LoggingInBox());

                var rsp = await db.salesmanLogin(username, password);

                if (rsp == '') {
                  loginDialog = 'Account not Found!';
                } else {
                  // print(rsp);
                  //Username found but incorrect password
                  if (rsp[0]['username'].toString() == username &&
                      rsp[0]['success'].toString() == '0') {
                    if (_userAttempt.isEmpty) {
                      // _userAttempt = rsp;
                      _userAttempt = json.decode(json.encode(rsp));
                      // print(_userAttempt);
                    } else {
                      int x = 0;
                      bool found = false;
                      for (var element in _userAttempt) {
                        x++;
                        if (username.toString() ==
                            element['username'].toString()) {
                          element['attempt'] =
                              (int.parse(element['attempt'].toString()) + 1)
                                  .toString();
                          found = true;
                        } else {
                          if (_userAttempt.length == x && !found) {
                            _userAttempt.addAll(json.decode(json.encode(rsp)));
                          }
                        }
                        // print(_userAttempt);
                      }
                    }
                    loginDialog = 'Account not Found!';
                  } else {
                    _userdata = rsp;
                    loginDialog = 'Found!';
                  }
                }

                // showDialog(
                //     barrierDismissible: false,
                //     context: context,
                //     builder: (context) => LoggingInBox());

                if (loginDialog == 'Account not Found!') {
                  // print("Invalid username or Password");
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.red,
                      content: Text("Invalid username or Password"),
                    ),
                  );
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                } else {
                  if (_userdata[0]['status'] == '0') {
                    // showDialog(
                    //     barrierDismissible: false,
                    //     context: context,
                    //     builder: (context) => LockAccount(
                    //           title: 'Account Locked',
                    //           description:
                    //               'This account has been locked due to excessive login failures. Please contact your administrator.',
                    //           buttonText: 'Okay',
                    //         ));
                    showGlobalSnackbar(
                      'Information',
                      'This account has been locked due to excessive login failures. Please contact your administrator.',
                      Colors.blue,
                      Colors.white,
                    );
                  } else {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) => const LoggingInBox(),
                    );

                    UserData.id = _userdata[0]['sm_code'];
                    UserData.firstname = _userdata[0]['firstname'];
                    UserData.lastname = _userdata[0]['lastname'];
                    UserData.department = _userdata[0]['department'];
                    // UserData.division = _userdata[0]['division'];
                    // UserData.district = _userdata[0]['district'];
                    UserData.position = _userdata[0]['title'];
                    UserData.contact = _userdata[0]['mobile'];
                    // UserData.postal = _userdata[0]['postal_code'];
                    // UserData.email = _userdata[0]['email'];
                    UserData.address = _userdata[0]['address'];
                    UserData.routes = _userdata[0]['area'];
                    UserData.passwordAge = _userdata[0]['password_date'];
                    UserData.img = _userdata[0]['img'];
                    UserData.imgPath = imgPath.toString() + _userdata[0]['img'];
                    UserData.username = username;
                    // print(_userdata[0]['sm_code']);
                    //CHECK FOR DEVICE LOGIN
                    // GlobalVariables.deviceData =
                    //     _deviceData['brand'].toString() +
                    //         '_' +
                    //         _deviceData['device'].toString() +
                    //         '-' +
                    //         _deviceData['androidId'].toString();

                    ///MONITORING SA NI LOGIN
                    // GlobalVariables.deviceData =
                    //     '${_deviceData['brand']}_${_deviceData['device']}-${_deviceData['androidId']}';
                    // print(GlobalVariables.deviceData);
                    // if (NetworkData.connected) {
                    //   var setDev = await db.setLoginDevice(
                    //       UserData.id!, GlobalVariables.deviceData!);
                    //   print(setDev);
                    // }

                    viewSpinkit = false;
                    if (viewSpinkit == false) {
                      dispose();
                      DateTime a = DateTime.parse(UserData.passwordAge!);
                      final date1 = DateTime(a.year, a.month, a.day);

                      final date2 = DateTime.now();
                      // ignore: unused_local_variable
                      final difference = date2.difference(date1).inDays;
                      //PASSWORD AGE
                      // if (difference >= 90) {
                      //   GlobalVariables.passExp = true;
                      //   Navigator.push(context,
                      //       MaterialPageRoute(builder: (context) {
                      //     return ChangePass();
                      //   }));
                      // } else {
                      //   GlobalVariables.passExp = false;

                      //   Navigator.of(context).pushNamedAndRemoveUntil(
                      //       '/menu', (Route<dynamic> route) => false);
                      //   print("Login Successful!");
                      // }
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          '/menu', (Route<dynamic> route) => false);
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
                const Text("LOGIN",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: ScreenData.scrHeight * .070,
          ),
        ],
      ),
    );
  }

  Column buildSignInTextField() {
    final node = FocusScope.of(context);
    return Column(
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                textInputAction: TextInputAction.next,
                // onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                onEditingComplete: () => node.nextFocus(),
                controller: usernameController,
                decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black87),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  hintText: 'Username',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Username cannot be empty';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: ScreenData.scrHeight * .020,
              ),
              TextFormField(
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => node.unfocus(),
                obscureText: _obscureText,
                controller: passwordController,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  hintText: 'Password',
                  suffixIcon: GestureDetector(
                    onLongPressStart: (_) async {
                      _toggle();
                    },
                    onLongPressEnd: (_) {
                      setState(() {
                        _toggle();
                      });
                    },
                    child: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                        size: 30,
                      ),
                      onPressed: () {
                        // _toggle();
                      },
                    ),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Password cannot be empty';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Container buildForgetPass() {
    return Container(
      margin: const EdgeInsets.only(top: 0),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              // if (NetworkData.connected == true) {
              //   ForgetPassData.type = 'Salesman';
              //   Navigator.push(context, MaterialPageRoute(builder: (context) {
              //     return ForgetPass();
              //   }));
              //   // print('Forget Password Form');
              // } else {
              //   // showDialog(
              //   //     context: context,
              //   //     builder: (context) => UnableDialog(
              //   //           title: 'Connection Problem!',
              //   //           description: 'Check Internet Connection' +
              //   //               ' to use this feature.',
              //   //           buttonText: 'Okay',
              //   //         ));
              //   showGlobalSnackbar(
              //       'Connectivity',
              //       'Please connect to internet.',
              //       Colors.red.shade900,
              //       Colors.white);
              // }
              // // ForgetPassData.type = 'Salesman';
              // // Navigator.push(context, MaterialPageRoute(builder: (context) {
              // //   return ForgetPass();
              // // }));
            },
            child: Text('Forgot Password?',
              style: TextStyle(
                fontSize: 12,
                color: ColorsTheme.mainColor,
              ),
            ),
          ),
          // Text(message),
        ],
      ),
    );
  }
}

class LoggingInBox extends StatefulWidget {
  const LoggingInBox({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LoggingInBoxState createState() => _LoggingInBoxState();
}

class _LoggingInBoxState extends State<LoggingInBox> {
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
          padding: const EdgeInsets.only(top: 50, bottom: 16, right: 5, left: 5),
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
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                // color: Colors.white,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10),
                  // ignore: prefer_const_literals_to_create_immutables
                  boxShadow: [
                    const BoxShadow(
                      color: Colors.transparent,
                    ),
                  ],
                ),
                child: Column(
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    const Text('Logging in as Salesman...',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    const LinearProgressIndicator(),
                  ],
                ),
              ),
              // SpinKitCircle(
              //   color: ColorsTheme.mainColor,
              // ),
            ],
          ),
        ),
      ],
    );
  }
}
