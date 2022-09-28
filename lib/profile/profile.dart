import 'package:avatar_view/avatar_view.dart';
import 'package:extruck/profile/input_oldpass.dart';
import 'package:extruck/profile/notice.dart';
import 'package:extruck/profile/profile_info.dart';
import 'package:extruck/profile/settings.dart';
import 'package:extruck/session/session_timer.dart';
import 'package:extruck/url/url.dart';
import 'package:extruck/values/colors.dart';
import 'package:extruck/values/userdata.dart';
import 'package:extruck/widgets/buttons.dart';
import 'package:extruck/widgets/dialogs.dart';
import 'package:extruck/widgets/snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter/src/foundation/key.dart';
// import 'package:flutter/src/widgets/framework.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool checking = false;

  Future<void> _launchURL(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }

  void handleUserInteraction([_]) {
    SessionTimer sessionTimer = SessionTimer();
    sessionTimer.initializeTimer(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          handleUserInteraction();
        },
        onPanDown: (details) {
          handleUserInteraction();
        },
        child: Scaffold(
          appBar: AppBar(
            // toolbarHeight: 85,
            toolbarHeight: ScreenData.scrHeight * .19,
            automaticallyImplyLeading: false,
            backgroundColor: ColorsTheme.mainColor,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  "Profile",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 45,
                      fontWeight: FontWeight.bold),
                ),
                // SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          // loadingImg
                          //     ? CircleAvatar(
                          //         backgroundColor: Colors.white,
                          //         radius: 45,
                          //         child: SpinKitFadingCircle(
                          //           color: ColorsTheme.mainColor,
                          //           size: 20,
                          //         ),
                          //       )
                          //     :
                          AvatarView(
                            radius: 45,
                            borderWidth: 5,
                            borderColor: Colors.white,
                            avatarType: AvatarType.CIRCLE,
                            backgroundColor: Colors.black,
                            imagePath: NetworkData.connected
                                ? UrlAddress.userImg + UserData.img!
                                : UserData.imgPath!,
                            placeHolder: const Icon(
                              Icons.person,
                              size: 50,
                            ),
                            errorWidget: const Icon(
                              Icons.error,
                              size: 50,
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${UserData.firstname!} ${UserData.lastname!}",
                              ),
                              Text(
                                UserData.position!,
                                style: const TextStyle(fontSize: 12),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (NetworkData.connected == true) {
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) => const ProfileInfo());
                        } else {
                          showGlobalSnackbar(
                              'Connectivity',
                              'Please connect to internet.',
                              Colors.red.shade900,
                              Colors.white);
                        }
                      },
                      child: Column(
                        // ignore: prefer_const_literals_to_create_immutables
                        children: [
                          const Text(
                            'Edit',
                            style: TextStyle(fontSize: 10),
                          ),
                          const Icon(
                            CupertinoIcons.pencil_circle, size: 24,
                            // color: Colors.deepOrange[800],
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          backgroundColor: ColorsTheme.mainColor,
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.only(
                      left: 0, right: 0, top: 0, bottom: 0),
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      )),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      // buildHeader(),
                      // buildInfo(context),
                      const SizedBox(height: 20),
                      // buildMessages(context),
                      // const SizedBox(height: 3),
                      buildChangePass(context),
                      const SizedBox(height: 3),
                      buildPrivacyNot(context),
                      const SizedBox(height: 3),
                      buildSettings(context),
                      const SizedBox(height: 30),
                      buildLogout(context),
                      const SizedBox(height: 30),
                      buildVersionUp(context),
                      Visibility(
                          visible: !AppData.appUptodate,
                          child: buildUpdateButton(context)),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                'E-COMMERCE(MY NETGOSYO APP)'
                                ' COPYRIGHT 2020',
                                style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Container buildChangePass(BuildContext context) {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(right: 15),
      color: Colors.white,
      child: InkWell(
        onTap: () async {
          if (NetworkData.connected == true) {
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => const InputPassDialog());
          } else {
            showGlobalSnackbar('Connectivity', 'Please connect to internet.',
                Colors.red.shade900, Colors.white);
          }
        },
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Icon(
                Icons.lock_open,
                color: Colors.grey[700],
                size: 24,
              ),
            ),
            Expanded(
              child: Text(
                'Change Password',
                style: TextStyle(
                  color: Colors.grey[900],
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            )
          ],
        ),
      ),
    );
  }

  Container buildPrivacyNot(BuildContext context) {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(right: 15),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          // Navigator.push(context, MaterialPageRoute(builder: (context) {
          //   return ViewNotice();
          // }));
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: const ViewNotice()));
        },
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Icon(
                Icons.description,
                color: Colors.grey[700],
                size: 24,
              ),
            ),
            Expanded(
              child: Text(
                'Privacy Notice',
                style: TextStyle(
                  color: Colors.grey[900],
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            )
          ],
        ),
      ),
    );
  }

  Container buildSettings(BuildContext context) {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(right: 15),
      color: Colors.white,
      child: InkWell(
        onTap: () async {
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: const ViewSettings()));
        },
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Icon(
                CupertinoIcons.gear_alt_fill,
                color: Colors.grey[700],
                size: 24,
              ),
            ),
            Expanded(
              child: Text(
                'Settings',
                style: TextStyle(
                  color: Colors.grey[900],
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            )
          ],
        ),
      ),
    );
  }

  Container buildLogout(BuildContext context) {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(right: 15),
      color: Colors.white,
      child: InkWell(
        onTap: () async {
          final action = await Dialogs.openDialog(context, 'Confirmation',
              'Are you sure you want to logout?', true, 'No', 'Yes');
          if (action == DialogAction.yes) {
            GlobalVariables.menuKey = 0;
            // ignore: use_build_context_synchronously
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/splash', (Route<dynamic> route) => false);
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'LOGOUT',
              style: TextStyle(
                  color: ColorsTheme.mainColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Container buildVersionUp(BuildContext context) {
    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(right: 15),
      // color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Text(
                'Version: ${AppData.appVersion!}',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 12,
                ),
              ),
              checking
                  ? Row(
                      children: [
                        Text(
                          'Checking for new updates ',
                          style: TextStyle(
                            color: ColorsTheme.mainColor,
                            fontSize: 12,
                          ),
                        ),
                        SpinKitCircle(
                          color: ColorsTheme.mainColor,
                          size: 18,
                        ),
                      ],
                    )
                  : AppData.appUptodate
                      ? Text(
                          'You are on latest version',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                        )
                      : Text(
                          'A new update is available',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                        )
            ],
          ),
        ],
      ),
    );
  }

  Container buildUpdateButton(BuildContext context) {
    // ignore: sized_box_for_whitespace
    return Container(
      // height: 60,
      width: MediaQuery.of(context).size.width,
      // padding: EdgeInsets.only(right: 15),
      // color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            style: raisedButtonStyleWhite,
            onPressed: () {
              _launchURL(Uri.parse(UrlAddress.appLink));
            },
            child: const Text(
              'Update',
              style: TextStyle(fontSize: 12),
            ),
          )
        ],
      ),
    );
  }
}
