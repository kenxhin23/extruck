import 'dart:convert';
import 'dart:io';
import 'package:extruck/db/db_helper.dart';
import 'package:extruck/profile/img_option.dart';
import 'package:extruck/session/session_timer.dart';
import 'package:extruck/url/url.dart';
import 'package:extruck/values/colors.dart';
import 'package:extruck/values/userdata.dart';
import 'package:extruck/widgets/dialogs.dart';
import 'package:extruck/widgets/snackbar.dart';
import 'package:extruck/widgets/spinkit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

// import 'package:salesman/widgets/snackbar.dart';

class ProfileInfo extends StatefulWidget {
  const ProfileInfo({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ProfileInfoState createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  static final String uploadEndpoint = '${UrlAddress.url}uploaduserimg';
  Future<File>? file;
  String status = "";
  String? base64Image;
  File? tmpFile;
  String errMessage = 'Error Uploading Image';
  String? fileName;
  int? result;

  File? _image;
  final picker = ImagePicker();
  final txtController = TextEditingController();

  final db = DatabaseHelper();
  @override
  void initState() {
    super.initState();
    _image = null;
    if (kDebugMode) {
      print(uploadEndpoint);
    }
  }

  // chooseImage() async {
  //   // setState(() {
  //   final ImagePicker _picker = ImagePicker();
  //   // file = ImagePicker.pickImage(source: ImageSource.camera);
  //   final file = await _picker.pickImage(source: ImageSource.gallery);
  //   // file = ImagePicker.getImage(source: ImageSource.camera);
  //   // });
  //   print(file);
  // }
  Future getImagefromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile!.path);
      showImage();
      fileName = _image!.path.split('/').last;
      // print(fileName);
    });
  }

  Future openCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = File(pickedFile!.path);
      showImage();
      fileName = _image!.path.split('/').last;
      // print(pickedFile.path);
      // print(fileName);
    });
  }

  uploadImage() async {
    // print(uploadEndpoint);
    final uri = Uri.parse(uploadEndpoint);
    var request = http.MultipartRequest('POST', uri);
    request.fields['name'] = fileName.toString();
    var pic = await http.MultipartFile.fromPath('image', _image!.path);
    request.files.add(pic);
    var response = await request.send();
    // print(request.fields['name']);
    // print('PATH: ' + _image!.path);
    // print(_image);

    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    if (kDebugMode) {
      print(responseString);
    }
    if (response.statusCode == 200) {
      // print(response.statusCode);
      // print('Image Upload');
      // ChequeData.imgName = fileName.toString();
      // OrderData.setChequeImg = true;
      UserData.img = fileName.toString();
      showGlobalSnackbar('Information', 'Image Uploaded', Colors.white, ColorsTheme.mainColor);

      if (UserData.position == 'Salesman') {
        // print(UserData.id);
        // print(UserData.img);
        var changeImg = await db.updateSalesmanImg(UserData.id!, UserData.img!);
        // print(changeImg);
        setState(() {
          result = changeImg;
        });
        if (result == 1) {
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
          // ignore: use_build_context_synchronously
          final action = await WarningDialogs.openDialog(context, 'Information',
              'Changes Successfully Saved!', false, 'OK');
          if (action == DialogAction.yes) {
            GlobalVariables.processedPressed = true;
            GlobalVariables.menuKey = 4;
            // Navigator.pushReplacement(context,
            //     MaterialPageRoute(builder: (context) {
            //   return SalesmanMenu();
            // }));
            // ignore: use_build_context_synchronously
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/smmenu', (Route<dynamic> route) => false,
            );
          }
        }
      } else {
        var changeImg = await db.updateHepeImg(UserData.id!, UserData.img!);
        // print(changeImg);
        setState(() {
          result = changeImg;
        });
        if (result == 1) {
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
          // ignore: use_build_context_synchronously
          final action = await WarningDialogs.openDialog(context, 'Information', 'Changes Successfully Saved!', false, 'OK');
          if (action == DialogAction.yes) {
            GlobalVariables.processedPressed = true;
            GlobalVariables.menuKey = 4;
            // ignore: use_build_context_synchronously
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/hepemenu', (Route<dynamic> route) => false,
            );
          }
        }
      }
    } else {
      // print('Image not Upload');
    }
  }

  Widget showImage() {
    return FutureBuilder<File>(
      future: file,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            null != snapshot.data) {
          _image = snapshot.data;
          base64Image = base64Encode(snapshot.data!.readAsBytesSync());
          fileName = _image!.path.split('/').last;
          // print('PRINT FILE NAME: ' + fileName!);
          return Flexible(
            child: Image.file(
              snapshot.data!,
              fit: BoxFit.fill,
            ),
          );
        } else if (null != snapshot.error) {
          return const Text('Error Picking Image',
            textAlign: TextAlign.center,
          );
        } else {
          return const Text('No Image Selected',
            textAlign: TextAlign.center,
          );
        }
      },
    );
  }

  void handleUserInteraction([_]) {
    // _initializeTimer();

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
          toolbarHeight: MediaQuery.of(context).size.width / 2 + 50,
          automaticallyImplyLeading: false,
          backgroundColor: ColorsTheme.mainColor,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text("Edit Profile",
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Visibility(visible: false, child: showImage()),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      // AvatarView(
                      //   radius: 80,
                      //   borderWidth: 5,
                      //   borderColor: Colors.white,
                      //   avatarType: AvatarType.CIRCLE,
                      //   backgroundColor: Colors.red,
                      //   imagePath: NetworkData.connected
                      //       ? UrlAddress.userImg + UserData.img
                      //       : UserData.imgPath,
                      //   placeHolder: Container(
                      //     child: Icon(
                      //       Icons.person,
                      //       size: 50,
                      //     ),
                      //   ),
                      //   errorWidget: Container(
                      //     child: Icon(
                      //       Icons.error,
                      //       size: 50,
                      //     ),
                      //   ),
                      // ),
                      CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 75,
                          backgroundImage: (_image != null)
                            ? Image.file(
                                _image!,
                                fit: BoxFit.cover,
                              ).image
                            : NetworkImage(
                                UrlAddress.userImg + UserData.img!),

                          // backgroundImage:
                          //     NetworkImage(UrlAddress.userImg + UserData.img),
                          backgroundColor: Colors.black,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),
                      InkWell(
                        onTap: () {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) => const Option()).then((value) {
                            if (UserData.getImgfrom == 'Camera') {
                              openCamera();
                            } else {
                              getImagefromGallery();
                            }
                          });
                          // getImagefromGallery();
                        },
                        child: Row(
                          // ignore: prefer_const_literals_to_create_immutables
                          children: [
                            const Text('Change Photo',
                              style: TextStyle(fontSize: 12),
                            ),
                            const Icon(CupertinoIcons.camera_circle)
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
        backgroundColor: ColorsTheme.mainColor,
        body: Column(
          children: [
            Expanded(
              child: Container(
                // padding: EdgeInsets.symmetric(horizontal: 10),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 25,
                    ),
                    buildPersonalInfo(context),
                    const SizedBox(
                      height: 20,
                    ),
                    buildContactInfo(context),
                    const SizedBox(
                      height: 30,
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final action = await Dialogs.openDialog(
                                    context,
                                    'Confirmation',
                                    'Are you sure you want to save image?',
                                    true,
                                    'No',
                                    'Yes',
                                  );
                                  if (action == DialogAction.yes) {
                                    Spinkit.label = 'Uploading Image...';
                                    showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (context) => const LoadingSpinkit());
                                    uploadImage();
                                  }

                                  // final action = await Dialogs.openDialog(
                                  //     context,
                                  //     'Confirmation',
                                  //     'Are you sure you want to logout?',
                                  //     true,
                                  //     'No',
                                  //     'Yes');
                                  // if (action == DialogAction.yes) {
                                  //   GlobalVariables.menuKey = 0;
                                  //   Navigator.of(context).pushNamedAndRemoveUntil(
                                  //       '/splash',
                                  //       (Route<dynamic> route) => false);
                                  // }
                                },
                                child: Container(
                                  color: Colors.white,
                                  height: 50,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('SAVE CHANGES',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: ColorsTheme.mainColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container buildPersonalInfo(BuildContext context) {
    // ignore: avoid_unnecessary_containers
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text('Personal Information',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(left: 15),
                  color: Colors.white,
                  height: 50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${UserData.firstname!} ${UserData.lastname!}",
                        style: TextStyle(
                          color: Colors.grey[850],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(left: 15),
                  color: Colors.white,
                  height: 50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${UserData.position!}(${UserData.department!} - ExTruck)',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(left: 15),
                  color: Colors.white,
                  height: 50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        UserData.address.toString(),
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Container buildContactInfo(BuildContext context) {
    // ignore: avoid_unnecessary_containers
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text('Contact Information',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(left: 15),
                  color: Colors.white,
                  height: 50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            // ignore: avoid_unnecessary_containers
                            child: Container(
                              child: Row(
                                children: [
                                  Text('Mobile:',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    UserData.contact!,
                                    style: TextStyle(
                                      color: Colors.grey[850],
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              showGlobalSnackbar(
                                'Information',
                                'This feature is currently unavailable.',
                                Colors.white,
                                ColorsTheme.mainColor,
                              );
                            },
                            child: Row(
                              children: [
                                Text('Edit',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: ColorsTheme.mainColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Icon(
                                  CupertinoIcons.pencil,
                                  size: 20,
                                  color: ColorsTheme.mainColor,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(left: 15),
                  color: Colors.white,
                  height: 50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text('Email:',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text('sample@mail.com',
                                  style: TextStyle(
                                    color: Colors.grey[850],
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              showGlobalSnackbar(
                                'Information',
                                'This feature is currently unavailable.',
                                Colors.white,
                                ColorsTheme.mainColor,
                              );
                            },
                            child: Row(
                              children: [
                                Text('Edit',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: ColorsTheme.mainColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Icon(
                                  CupertinoIcons.pencil,
                                  size: 20,
                                  color: ColorsTheme.mainColor,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
