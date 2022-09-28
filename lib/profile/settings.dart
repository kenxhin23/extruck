import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:extruck/providers/img_download.dart';
import 'package:extruck/session/session_timer.dart';
import 'package:extruck/url/url.dart';
import 'package:extruck/values/colors.dart';
import 'package:extruck/values/userdata.dart';
import 'package:extruck/widgets/buttons.dart';
import 'package:extruck/widgets/dialogs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:switcher/core/switcher_size.dart';
import 'package:switcher/switcher.dart';

class ViewSettings extends StatefulWidget {
  const ViewSettings({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ViewSettingsState createState() => _ViewSettingsState();
}

class _ViewSettingsState extends State<ViewSettings> {
  // List<String>? _images, _tempImages;
  List<String> _images = [];
  List<String> _tempImages = [];
  String? _dir;
  // 'img.zip'
  String _zipPath = '';
  String _localZipFileName = '';
  // final String _zipPath = '${UrlAddress.itemImg}img10k.zip';
  // final String _localZipFileName = 'img10k.zip';

  bool imgPk1downloaded = false;
  bool imgPk2downloaded = false;
  bool downloading = false;

  @override
  void initState() {
    super.initState();
    _initDir();
  }

  _initDir() async {
    if (null == _dir) {
      _dir = (await getApplicationDocumentsDirectory()).path;
      if (kDebugMode) {
        print('DIRECTORY: $_dir');
      }
    }
    _images = [];
    // _tempImages = List();
    _tempImages = [];
    checkImages();
  }

  void handleUserInteraction([_]) {
    // _initializeTimer();

    SessionTimer sessionTimer = SessionTimer();
    sessionTimer.initializeTimer(context);
  }

  checkImages() async {
    var file1 = '$_dir/175027.JPG';
    if (await File(file1).exists()) {
      setState(() {
        imgPk1downloaded = true;
      });
    } else {
      // print('NOT FOUND!');
    }
    var file2 = '$_dir/no_image_item.jpg';
    if (await File(file2).exists()) {
      setState(() {
        imgPk2downloaded = true;
      });
    }
  }

  downloadImageP1() async {
    final action = await Dialogs.openDialog(context, 'Confirmation',
        'Are you sure you want to download image pack 1?', true, 'No', 'Yes');
    if (action == DialogAction.yes) {
      _zipPath = '${UrlAddress.itemImg}imgPack1.zip';
      _localZipFileName = 'imgPack1.zip';
      // print('Downloading');
      setState(() {
        downloading = true;
        GlobalVariables.progressString = "Preparing Download...";
      });
      // ignore: use_build_context_synchronously
      Provider.of<DownloadStat>(context, listen: false)
          .changeCap('Preparing Download...');
      // showDialog(
      //     barrierDismissible: false,
      //     context: context,
      //     builder: (context) => LoadingImageSpinkit());
      downloadingImage();
    }
  }

  downloadImageP2() async {
    final action = await Dialogs.openDialog(context, 'Confirmation',
        'Are you sure you want to download image pack 2?', true, 'No', 'Yes');
    if (action == DialogAction.yes) {
      _zipPath = '${UrlAddress.itemImg}imgPack2.zip';
      _localZipFileName = 'imgPack2.zip';
      // print('Downloading');
      setState(() {
        downloading = true;
        GlobalVariables.progressString = "Preparing Download...";
      });
      // ignore: use_build_context_synchronously
      Provider.of<DownloadStat>(context, listen: false)
          .changeCap('Preparing Download...');
      // showDialog(
      //     barrierDismissible: false,
      //     context: context,
      //     builder: (context) => LoadingImageSpinkit());
      downloadingImage();
    }
  }

  Future<void> downloadingImage() async {
    Dio dio = Dio();
    GlobalVariables.progressString = '';
    _images.clear();
    _tempImages.clear();
    try {
      await dio.download(_zipPath, "$_dir/$_localZipFileName",
          onReceiveProgress: (int rec, int total) {
        Provider.of<DownloadStat>(context, listen: false).changeCap(
            // ignore: prefer_interpolation_to_compose_strings
            'Downloading...' + ((rec / total) * 100).toStringAsFixed(0) + "%");
        // print(GlobalVariables.progressString);
      });
      await unarchiveAndSave();
      setState(() {
        _images.addAll(_tempImages);
        downloading = false;
        // GlobalVariables.progressString = 'Completed';
      });
      // ignore: use_build_context_synchronously
      Provider.of<DownloadStat>(context, listen: false).changeCap('Completed');
    } catch (e) {
      // print(e);
      // setState(() {
      //   GlobalVariables.progressString = 'Error when Downloading';
      //   downloading = false;
      // });
      Provider.of<DownloadStat>(context, listen: false)
          .changeCap('Error when downloading...');
    }
    setState(() {
      //   _images.addAll(_tempImages);
      //   downloading = false;
      // GlobalVariables.progressString = 'Extracting Zipped File...';
    });

    // print('Download Complete');
  }

  unarchiveAndSave() async {
    // print('NAHUMAN NAG DOWNLOAD');
    var file = '$_dir/$_localZipFileName';

    // GlobalVariables.progressString = 'Extracting Zipped File...';
    Provider.of<DownloadStat>(context, listen: false)
        .changeCap('Extracting Zipped File...');
    var bytes = File(file).readAsBytesSync();
    var archive = ZipDecoder().decodeBytes(bytes);
    for (var file in archive) {
      var fileName = '$_dir/${file.name}';
      // print(fileName);
      if (file.isFile) {
        var outFile = File(fileName);
        // print('File: ' + outFile.path);
        _tempImages.add(outFile.path);
        outFile = await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content);
        // print(_tempImages);
      }
    }
  }

  // _toggle() {
  //   setState(() {
  //     GlobalVariables.viewImg = !GlobalVariables.viewImg;
  //     print(GlobalVariables.viewImg);
  //   });
  // }

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
      child: WillPopScope(
        onWillPop: () => Future.value(!downloading),
        child: Scaffold(
          appBar: AppBar(
            // automaticallyImplyLeading: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // ignore: prefer_const_literals_to_create_immutables
              children: [
                const Text(
                  'Settings',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            // centerTitle: true,
            elevation: 0,
            // toolbarHeight: 50,
          ),
          backgroundColor: ColorsTheme.mainColor,
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                      padding: const EdgeInsets.only(top: 15),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          )),
                      child: Column(
                        children: [
                          const SizedBox(height: 15),
                          Container(
                            padding: const EdgeInsets.only(left: 10),
                            width: MediaQuery.of(context).size.width,
                            height: 20,
                            child: const Text(
                              'Image Settings',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(height: 10),
                          buildImageOption(context),
                          const SizedBox(height: 3),
                          Visibility(
                              visible: !imgPk1downloaded,
                              child: buildImgPack1(context)),
                          const SizedBox(height: 3),
                          Visibility(
                              visible: !imgPk2downloaded,
                              child: buildImgPack2(context)),
                          // Visibility(
                          //     visible: !downloading,
                          //     child: buildDownloadProgress(context)),
                        ],
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container buildImageOption(BuildContext context) {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(right: 15, left: 15),
      color: Colors.white,
      child: InkWell(
        onTap: () async {},
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 0, right: 0),
              child: Icon(
                CupertinoIcons.photo_fill,
                color: Colors.grey[700],
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'View Item Images',
                style: TextStyle(
                  color: Colors.grey[900],
                  fontSize: 14,
                ),
              ),
            ),
            Switcher(
              switcherRadius: 50,
              value: GlobalVariables.viewImg,
              colorOff: Colors.grey,
              colorOn: Colors.greenAccent,
              iconOff: CupertinoIcons.xmark,
              onChanged: (bool val) {
                if (val) {}
                // print('VALUE OF VAL   : $val');
                GlobalVariables.viewImg = val;
              },
              size: SwitcherSize.small,
            ),
          ],
        ),
      ),
    );
  }

  Container buildImgPack1(BuildContext context) {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(right: 15, left: 15),
      color: Colors.white,
      child: InkWell(
        onTap: () async {},
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 0, right: 0),
              child: Icon(
                CupertinoIcons.archivebox,
                color: Colors.grey[700],
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Image Pack 1',
                style: TextStyle(
                  color: Colors.grey[900],
                  fontSize: 14,
                ),
              ),
            ),
            !downloading
                ? buildDownloadButton1(context)
                : buildDownloadProgress(context),
          ],
        ),
      ),
    );
  }

  Container buildImgPack2(BuildContext context) {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(right: 15, left: 15),
      color: Colors.white,
      child: InkWell(
        onTap: () async {},
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 0, right: 0),
              child: Icon(
                CupertinoIcons.archivebox,
                color: Colors.grey[700],
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Image Pack 2',
                style: TextStyle(
                  color: Colors.grey[900],
                  fontSize: 14,
                ),
              ),
            ),
            !downloading
                ? buildDownloadButton2(context)
                : buildDownloadProgress(context),
          ],
        ),
      ),
    );
  }

  Container buildDownloadButton1(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            style: raisedButtonStyleWhite,
            onPressed: () {
              if (downloading) {
              } else {
                downloadImageP1();
              }
              // _launchURL(Uri.parse(UrlAddress.appLink));
            },
            child: const Text(
              'Download',
              style: TextStyle(fontSize: 12),
            ),
          )
        ],
      ),
    );
  }

  Container buildDownloadButton2(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            style: raisedButtonStyleWhite,
            onPressed: () {
              if (downloading) {
              } else {
                downloadImageP2();
              }
            },
            child: const Text(
              'Download',
              style: TextStyle(fontSize: 12),
            ),
          )
        ],
      ),
    );
  }

  Container buildDownloadProgress(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            // GlobalVariables.progressString,
            Provider.of<DownloadStat>(context).cap,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.greenAccent.shade700),
          ),
          const SpinKitCircle(
            size: 24,
            color: Colors.greenAccent,
          ),
        ],
      ),
    );
  }
}
