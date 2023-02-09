import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ricochet_robot_v1/utils/globals.dart';
import 'package:ricochet_robot_v1/screens/init_screen.dart';
import 'package:ricochet_robot_v1/screens/main_screen.dart';
import 'package:screenshot/screenshot.dart';

void dialogGameOver(BuildContext context) {
  double whiteSpaceWidth = MediaQuery.of(context).size.width / 10;
  double whiteSpaceHeight = MediaQuery.of(context).size.height / 10;

  List<Widget> moveHistoryIcons = [];   // piece 이동 기록 아이콘
  void mkMoveHistoryIcons(String direction, Color iconColor) {    // piece 이동 기록 아이콘 생성
    double iconSize = whiteSpaceWidth + 10;   // trailing 보다 살짝 크게 만들어서 listView 임을 인지하도록 만듦
    IconData iconShape = Icons.arrow_circle_left_outlined;
    if(direction == 'up') {
      iconShape = Icons.arrow_circle_up_outlined;
    }
    else if(direction == 'down') {
      iconShape = Icons.arrow_circle_down_outlined;
    }
    else if(direction == 'right') {
      iconShape = Icons.arrow_circle_right_outlined;
    }
    else if(direction == 'left') {
      iconShape = Icons.arrow_circle_left_outlined;
    }
    var icon = Icon(
      iconShape,
      size: iconSize,
      color: iconColor,
    );
    moveHistoryIcons.add(icon);
  }

  var moveHistory = Globals().moveHistory;
  // target 정보
  // int -> [color, position]
  // Map<int, Map<String, dynamic>> moveHistoryTarget = moveHistory['target'];

  // piece 정보
  // int -> [color, moveDirection, positionStart, positionEnd, moveRoutes, moveCounts]
  Map<int, Map<String, dynamic>> infoPieces = moveHistory['piece'];
  int totalMoveCount = infoPieces.length;   // 전체 이동 횟수
  int moveCountR = 0;
  int moveCountB = 0;
  int moveCountG = 0;
  int moveCountY = 0;

  for(var i=0; i<totalMoveCount; i++) {
    var infoPiece = infoPieces[i];
    var infoPieceDirection = infoPiece!['moveDirection'];
    var infoPieceColorHex = infoPiece['colorHex'];
    var infoPieceColorString = infoPiece['colorString'];
    switch(infoPieceColorString) {
      case 'red' : moveCountR++; break;
      case 'blue' : moveCountB++; break;
      case 'green' : moveCountG++; break;
      case 'yellow' : moveCountY++; break;
    }
    mkMoveHistoryIcons(infoPieceDirection, infoPieceColorHex);
  }

  String gameTime = Globals().saveGameTimer.last;

  ScreenshotController screenshotControllerBoard = ScreenshotController();   // Create instance of Screenshot Controller for Board
  ScreenshotController screenshotControllerStats = ScreenshotController();   // Create Instance of Screenshot Controller for Stats

  showDialog(
    context: context,
    builder: (context) => Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40.0),
          ),
          margin: EdgeInsets.symmetric(horizontal: whiteSpaceWidth, vertical: whiteSpaceHeight),
          child: Column(
            children: [
              SizedBox(
                height: 70,
                child: Stack(
                  children: [
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Game Clear !",
                        style: TextStyle(
                          fontFamily: 'FirstJob',
                          fontSize: 30,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                        icon: const Icon(
                          Icons.close,
                          size: 35,
                        ),
                      ),
                    ),
                  ],
                )
              ),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 초기 Board 스크린샷
                    Flexible(
                      flex: 4,
                      child: Container(
                        alignment: Alignment.topCenter,
                        child: Screenshot(
                          controller: screenshotControllerBoard,
                          child: Image.memory(
                            Globals().imageInitBoard,
                            fit: BoxFit.cover,
                          )
                        ),
                      ),
                    ),

                    // 클릭한 방향 아이콘 모음
                    Expanded(
                      child: SizedBox(
                        // height: whiteSpaceHeight,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: moveHistoryIcons.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              child: moveHistoryIcons[index],
                            );
                          },
                        )
                      ),
                    ),

                    // 색상 별 이동 횟수, 총 이동 횟수, 총 걸린 시간
                    // 게임 결과 인사이트
                    Expanded(
                      child: Screenshot(
                        controller: screenshotControllerStats,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              flex: 3,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.arrow_circle_right_outlined,
                                            size: 30,
                                            color: Colors.red,
                                          ),
                                          Text(
                                            ": $moveCountR",
                                            style: const TextStyle(
                                              fontFamily: 'Atarian',
                                              fontSize: 24,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.arrow_circle_right_outlined,
                                            size: 30,
                                            color: Colors.blue,
                                          ),
                                          Text(
                                            ": $moveCountB",
                                            style: const TextStyle(
                                              fontFamily: 'Atarian',
                                              fontSize: 24,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ]
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.arrow_circle_right_outlined,
                                            size: 30,
                                            color: Colors.green,
                                          ),
                                          Text(
                                            ": $moveCountG",
                                            style: const TextStyle(
                                              fontFamily: 'Atarian',
                                              fontSize: 24,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.arrow_circle_right_outlined,
                                            size: 30,
                                            color: Colors.yellow,
                                          ),
                                          Text(
                                            ": $moveCountY",
                                            style: const TextStyle(
                                              fontFamily: 'Atarian',
                                              fontSize: 24,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ]
                                  ),
                                ]
                              )
                            ),
                            Flexible(
                              flex: 3,
                              child: Column(   // 총 이동 횟수, 총 걸린 시간
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Movement: $totalMoveCount",
                                      textAlign: TextAlign.start,
                                      style: const TextStyle(
                                        fontFamily: 'Atarian',
                                        fontSize: 24,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Game Time: $gameTime s",
                                      textAlign: TextAlign.start,
                                      style: const TextStyle(
                                        fontFamily: 'Atarian',
                                        fontSize: 24,
                                        color: Colors.black,
                                      ),
                                    )
                                  ),
                                ]
                              ),
                            ),
                          ],
                        ),
                      )
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () => goHome(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black26, width: 2),
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15))
                        )
                      ),
                      child: const Text(
                        "Go Home",
                        style: TextStyle(
                          fontFamily: 'FirstJob',
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () => newGame(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black26, width: 2),
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15))
                        )
                      ),
                      child: const Text(
                        "New Game",
                        style: TextStyle(
                          fontFamily: 'FirstJob',
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                )
              )
            ],
          )
        ),
      ),
    ),
  );

  _screenshotBoard(screenshotControllerBoard, "board");   // board 위젯 캡쳐 및 이미지 저장
  _screenshotBoard(screenshotControllerStats, "stats");   // stats 위젯 캡쳐 및 이미지 저장
}

//
// initScreen 의 records 를 위한 board & stats 위젯 스크린샷 및 로컬 저장.
//
void _screenshotBoard(ScreenshotController screenshotController, String object) async {
  final directory = (await getApplicationDocumentsDirectory ()).path;
  // DateTime localTime = await NTP.now();
  final dateStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
  final path = '$directory/records/$dateStr/';
  String fileName = '$object.jpg';

  // 스크린샷 캡쳐
  screenshotController.captureAndSave(
    delay: const Duration(seconds: 1),
    path,
    fileName: fileName
  );

  int limitRecords = 4;   // 기록할 게임 수
  var listOfRecords = Directory("$directory/records").listSync()..sort((a, b) => a.path.compareTo(b.path));   // 가장 오래된 순으로 정렬 -> return List
  var counts = listOfRecords.length;
  if(counts > limitRecords) {   // 기록 수가 limit 보다 많으면 -> 가장 오래된 것부터 하나씩 삭제
    listOfRecords.toList().first.deleteSync(recursive: true);
  }
}

//
// init_screen 으로 이동
//
void goHome(BuildContext context) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (BuildContext context) => const InitScreen()), (route) => false,
  );
}

//
// main_screen 으로 이동
//
void newGame(BuildContext context) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (BuildContext context) => const MainScreen()), (route) => false,
  );
}