import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();

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
  void dispose() {
    _timer.cancel();
    super.dispose();
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
                const SizedBox(
                  height: 440.0,
                  child: TopScreen(),
                ),
                //////////////////////////
                /* Bottom - ArrowPad && Clicked Arrow Buttons */
                //////////////////////////
                const Expanded(
                  child: BottomScreen(),
                ),
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