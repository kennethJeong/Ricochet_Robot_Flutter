import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ricochet_robot_v1/admob.dart';
import 'package:ricochet_robot_v1/screens/init_screen.dart';
import 'dart:async';
import 'package:ricochet_robot_v1/screens/top_screen.dart';
import 'package:ricochet_robot_v1/screens/bottom_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late Timer _timer;
  int timeCount = 3;
  bool isVisibleCountDown = true;
  bool isFirst = true;

  BannerAd? bannerAD;

  //
  // 게임 시작 시, 시작 카운트다운
  //
  void countDowns() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if(timeCount > 0) {
          timeCount--;
        } else {
          _timer.cancel();
        }
      });
    });
  }

  //
  // Home 버튼
  //
  void goHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (BuildContext context) => const InitScreen()), (route) => false,
    );
  }

  Future<bool> readIsFirst() async {
    bool isFirst;

    final directory = (await getApplicationDocumentsDirectory ()).path;
    final String pathTxt = '$directory/isFirst.txt';

    int result = int.parse(await File(pathTxt).readAsString());
    result == 1 ? isFirst = true : isFirst = false;

    return isFirst;
  }

  Future<void> writeIsFirst() async {
    final directory = (await getApplicationDocumentsDirectory ()).path;
    final String pathTxt = '$directory/isFirst.txt';

    int isFirst = 0;
    File(pathTxt).writeAsString(isFirst.toString());
  }

  void doCountDown() {
    setState(() {
      isFirst = false;
    });

    countDowns();   // 카운트 다운

    // 3초 딜레이 후 -> Container 위젯 안보이게 변환
    int delayTime = 3;
    Future.delayed(Duration(seconds: delayTime), () {
      if (mounted) {
        setState(() {
          isVisibleCountDown = false;
        });
      }
    });
  }


  @override
  void initState() {
    super.initState();

    bannerAD = Admob().adLoadBanner();

    readIsFirst().then((value) {
      if(value == true) {
        writeIsFirst();

        showDialog(
          context: context,
          builder: (BuildContext context) => Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40.0),
                ),
                // margin: EdgeInsets.symmetric(
                //   horizontal: MediaQuery.of(context).size.height * 0.3,
                //   vertical: MediaQuery.of(context).size.height * 0.3,
                // ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 10),
                      height: 50,
                      child: Stack(
                        children: [
                          const Align(
                            alignment: Alignment.center,
                            child: AutoSizeText(
                              "How to play ?",
                              maxLines: 1,
                              minFontSize: 24,
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.black
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.topRight,
                            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                            child: IconButton(
                              icon: const Icon(
                                  Icons.clear
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                doCountDown();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: AutoSizeText(
                                "1. Each colored piece can only move in a straight line and stops if there are obstructions (walls, pieces) in its moving position.",
                                minFontSize: 15,
                                maxLines: null,
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: AutoSizeText(
                                "2. Move the piece to clear the game when you reach the target of the same color.",
                                minFontSize: 15,
                                maxLines: null,
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    )
                  ],
                ),
              )
            )
          )
        );
      } else {
        doCountDown();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    _timer.cancel();

    bannerAD?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: 60.0,
                  child: Row(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => goHome(),
                          icon: const Icon(
                            Icons.home_outlined,
                            size: 50,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ///////////////////////
                /* Top - Game Board */
                ///////////////////////
                !isFirst ? const SizedBox(
                  height: 440.0,
                  child: TopScreen(),
                ) : Container(),
                //////////////////////////
                /* Bottom - ArrowPad && Clicked Arrow Buttons */
                //////////////////////////
                !isFirst ? const Expanded(
                  child: BottomScreen(),
                ) : Container(),
                !isFirst ? SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 60,
                  child: AdWidget(ad: bannerAD!),
                ) : Container(),
              ]
            ),
            Visibility(
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              visible: isVisibleCountDown,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.black87,
                alignment: Alignment.center,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        'START',
                        style: TextStyle(
                          fontSize: 100,
                          fontFamily: 'Atarian',
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        '$timeCount',
                        style: const TextStyle(
                          fontSize: 100,
                          fontFamily: 'Atarian',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              ),

            )
          ],
        )
      )
    );
  }
}