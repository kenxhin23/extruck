import 'dart:async';

import 'package:extruck/providers/caption_provider.dart';
import 'package:extruck/providers/cart_items.dart';
import 'package:extruck/providers/cart_total.dart';
import 'package:extruck/providers/img_download.dart';
import 'package:extruck/providers/pending_counter.dart';
import 'package:extruck/providers/sync_caption.dart';
import 'package:extruck/providers/upload_count.dart';
import 'package:extruck/providers/upload_length.dart';
import 'package:extruck/values/assets.dart';
import 'package:extruck/values/colors.dart';
import 'package:extruck/welcome/menu.dart';
import 'package:extruck/welcome/welcome.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => Caption()),
    ChangeNotifierProvider(create: (_) => SyncCaption()),
    ChangeNotifierProvider(create: (_) => UploadLength()),
    ChangeNotifierProvider(create: (_) => CartItemCounter()),
    ChangeNotifierProvider(create: (_) => CartTotalCounter()),
    ChangeNotifierProvider(create: (_) => DownloadStat()),
    ChangeNotifierProvider(create: (_) => PendingCounter()),
    ChangeNotifierProvider(create: (_) => UploadCount()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return GetMaterialApp(
      title: 'Ex-Truck',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      initialRoute: "/splash",
      routes: {
        "/splash": (context) => const Splash(),
        "/menu": (context) => const Menu(),
        // "/login": (context) => MyLoginPage(),
      },
    );
  }
}

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isRootedDevice = false;
  // String _text = 'Unknown';

  // Future<void> initPlatformState() async {
  //   bool isRooted = await RootCheck.isRooted;

  //   if (!mounted) return;

  //   setState(() {
  //     // _text = t;
  //     isRootedDevice = isRooted;
  //   });
  // }

  @override
  void initState() {
    super.initState();
    //ROOT CHECK
    // initPlatformState();
    // isRootedDevice = false;
    Timer(const Duration(seconds: 3), () {
      checkFirstSeen();
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
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetsValues.wallImg,
                  fit: BoxFit.cover,
                ),
              ),
              // color: ColorsTheme.mainColor,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Center(
                        child: SizedBox(
                          // padding: EdgeInsets.only(top: 50),
                          width: MediaQuery.of(context).size.width / 1.5,
                          height: MediaQuery.of(context).size.height / 2,
                          child: Column(
                            children: [
                              Image(
                                image: AssetsValues.mainlogo,
                              ),
                              // SpinKitThreeBounce(
                              //   color: Colors.white,
                              //   size: 60,
                              // )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                // height: 30,
                // color: Colors.grey,
                child: Text('E-COMMERCE COPYRIGHT 2020',
                    style: TextStyle(
                        color: ColorsTheme.mainColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future checkFirstSeen() async {
    // if (isRootedDevice == false) {
    dispose();
    Navigator.push(
        context,
        PageRouteBuilder(
            transitionDuration: const Duration(seconds: 1),
            transitionsBuilder: (context, animation, animationTimne, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            pageBuilder: (context, animation, animationTime) {
              return const WelcomePage();
            }));
  }
}
