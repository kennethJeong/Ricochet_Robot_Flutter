import 'package:flutter/material.dart';
import 'package:ricochet_robot_v1/screens/bottom_screen.dart';
import 'dart:math';
import 'dart:typed_data';
import 'package:screenshot/screenshot.dart';
import 'package:provider/provider.dart';
import 'package:ricochet_robot_v1/screens/result_screen.dart';
import 'package:ricochet_robot_v1/utils/globals.dart';

class TopScreen extends StatefulWidget {
  const TopScreen({Key? key}) : super(key: key);

  movePiece(BuildContext context) => _TopScreenState()._movePiece(context);
  movePieceRollBack(BuildContext context) => _TopScreenState()._movePieceRollBack(context);

  @override
  State createState() => _TopScreenState();
}

class _TopScreenState extends State<TopScreen> {
  static const int rectCount = 16;
  static const int rectSize = rectCount * rectCount;

  List<int> listCenterWall = [119, 120, 135, 136];  // 중앙 벽 위치
  List<Widget> listWall = [];
  List<Widget> listTarget = [];
  List<Widget> listPiece = [];
  Map<int, Map<String, List<String>>> mapObj = {}; // [벽, 타겟, 말(Piece)] 의 위치(벽의 position(top||bottom||right||left) 포함)

  var listTopMost = List<int>.generate(rectCount, (i) => i);
  var listBottomMost = List<int>.generate(rectCount, (i) => rectSize - rectCount + i);
  var listLeftMost = List<int>.generate(rectCount, (i) => rectSize - rectCount * (i + 1));
  var listRightMost = List<int>.generate(rectCount, (i) => (rectSize - 1) - rectCount * i);

  Uint8List _imageInitBoard = Uint8List.fromList([0]);
  ScreenshotController screenshotController = ScreenshotController();   // Create Instance of Screenshot Controller

  void resetVars() {
    listWall = [];
    listTarget = [];
    listPiece = [];
    mapObj = {};
    _imageInitBoard = Uint8List.fromList([0]);
  }

  //
  // 랜덤 벽 이미지 생성
  //
  List<Widget> mkRandomWall() {
    int limitOfWall = 20; // 벽 갯수 제한
    List<String> wallNames = ['top', 'bottom', 'left', 'right', 'left_top', 'left_bottom', 'right_top', 'right_bottom'];
    String dir = 'assets/images/wall/';
    String extension = '.png';

    // 전체(rectSize)를 흰 배경으로 설정
    List<int> allPosition = List.generate(rectSize, (i) => i);
    for (var position in allPosition) {
      Container tempWidget = Container(color: Colors.white.withOpacity(0));
      listWall.insert(position, tempWidget);
    }

    // 가운데 4개 = 중앙 벽 설정
    for (var position in listCenterWall) {
      Container tempWidget = Container(color: Colors.black);
      listWall[position] = tempWidget;
    }

    // 배치할 수 있는 wall 의 갯수가 limitOfWall 의 절반 이상일 때 -> walls 배치하기
    while(true) {
      // limitOfWall 개 만큼의 랜덤 위치에 wall image 넣기
      List<int> randomPosition = List.generate(limitOfWall, (_) => Random().nextInt(rectSize));
      List<int> listCorner = [0, 1, 14, 15, 16, 31, 224, 239, 240, 241, 254, 255];   // 끝 모서리
      List<int> listAroundCenterWall = [103, 104, 118, 121, 134, 137, 151, 152];    // 중앙 벽 근처
      List<int> listException = [listCenterWall, listCorner, listAroundCenterWall].expand((x) => x).toList();
      for (var i in randomPosition) {
        List<int> positionException = [
          i - rectCount,
          i - 1,
          i + 1,
          i + rectCount,
        ];

        for (var j in positionException) {
          if(j >= 0 && j < rectSize && !listException.contains(j)) {
            listException.add(j);
          }
        }
      }

      Map<int, Widget> tempListWalls = {};
      var countSettableWall = 0;
      for (var position in randomPosition) {
        String randomWallName = '';
        List<String> wallNamesSingle = ['top', 'bottom', 'left', 'right'];

        if(!listException.contains(position)) {   // wall 이미지가 listException 에 해당하지 않고,
          // board 제일 바깥 줄에 각각 위치할 때 -> single wall 사용.
          if(listTopMost.contains(position) || listBottomMost.contains(position) || listLeftMost.contains(position) || listRightMost.contains(position)) {
            if(listTopMost.contains(position)) {    // topmost 에 위치할 때
              wallNamesSingle.remove('top');
            }
            else if(listBottomMost.contains(position)) {    // bottommost 에 위치할 때
              wallNamesSingle.remove('bottom');
            }
            else if(listLeftMost.contains(position)) {    // leftmost 에 위치할 때
              wallNamesSingle.remove('left');
            }
            else if(listRightMost.contains(position)) {    // rightmost 에 위치할 때
              wallNamesSingle.remove('right');
            }
            randomWallName = (wallNamesSingle..shuffle()).first;
          }
          // 안쪽 어디든 위치할 때 -> single + multi wall 사용.
          else {
            randomWallName = (wallNames..shuffle()).first;
          }

          Image tempWidget = Image.asset(dir + randomWallName + extension);
          tempListWalls[position] = tempWidget;

          countSettableWall++;
        }
      }

      // 배치할 수 있는 wall 의 갯수가 limitOfWall 의 절반 이상일 때 -> walls 배치 -> while loop 종료
      if(countSettableWall >= limitOfWall / 2) {
        tempListWalls.forEach((position, widget) {
          listWall[position] = widget;
        });
        break;
      } else {
        continue;
      }
    }

    // 벽 위치 mapObj 에 저장
    if(mapObj.isEmpty) {
      for(var i=0; i<listWall.length; i++) {
        mapObj[i] = {};
        if(listWall[i].runtimeType == Image) {
          String imagePropToString = listWall[i].toString();
          String wallDirection = '';
          for (var direction in wallNames) {
            if(imagePropToString.contains(dir + direction + extension)) {
              wallDirection = direction;
            }
          }

          if(wallDirection.contains('_')) {
            String wallDirection1 = wallDirection.split('_')[0];
            String wallDirection2 = wallDirection.split('_')[1];

            mapObj[i] = {'wall': [wallDirection1, wallDirection2]};
          } else {
            mapObj[i] = {'wall': [wallDirection]};
          }
        }
        else if(listWall[i].runtimeType == Container) {
          for (var cw in listCenterWall) {
            if(i == cw) {
              mapObj[i] = {'wall': ['center']};
            }
          }
        } else {
          continue;
        }
      }
    }

    return listWall;
  }
  // List<Widget> mkRandomWall() {
  //   int limitOfWall = 50; // 벽 갯수 제한
  //   List<String> wallNames = ['top', 'bottom', 'left', 'right', 'left_top', 'left_bottom', 'right_top', 'right_bottom'];
  //   String dir = 'assets/images/wall/';
  //   String extension = '.png';
  //
  //   for(var i=0; i<limitOfWall; i++) {  // wallImageFiles 20개 랜덤 추가
  //     Image tempWidget = Image.asset(dir + (wallNames..shuffle()).first + extension);
  //     listWall.add(tempWidget);
  //   }
  //   for(var i=0; i<rectSize-limitOfWall; i++) {   // 전체(255개)에서 랜덤으로 추가된 20개의 wallImageFiles 를 뺀 나머지 = 흰 배경으로 설정
  //     Container tempWidget = Container(color: Colors.white.withOpacity(0));
  //     listWall.add(tempWidget);
  //   }
  //   listWall.shuffle();  // 전체 셔플
  //
  //   // 가운데 4개 = 중앙 벽 설정
  //   Container containerCenterWall = Container(color: Colors.black);
  //   for (var centerWallNum in listCenterWall) {
  //     listWall[centerWallNum] = containerCenterWall;
  //   }
  //
  //   // 벽 위치 mapObj 에 저장
  //   if(mapObj.isEmpty) {
  //     for(var i=0; i<listWall.length; i++) {
  //       mapObj[i] = {};
  //       if(listWall[i].runtimeType == Image) {
  //         String imagePropToString = listWall[i].toString();
  //         String wallDirection = '';
  //         for (var direction in wallNames) {
  //           if(imagePropToString.contains(dir + direction + extension)) {
  //             wallDirection = direction;
  //           }
  //         }
  //
  //         if(wallDirection.contains('_')) {
  //           String wallDirection1 = wallDirection.split('_')[0];
  //           String wallDirection2 = wallDirection.split('_')[1];
  //
  //           mapObj[i] = {'wall': [wallDirection1, wallDirection2]};
  //         } else {
  //           mapObj[i] = {'wall': [wallDirection]};
  //         }
  //       }
  //       else if(listWall[i].runtimeType == Container) {
  //         for (var cw in listCenterWall) {
  //           if(i == cw) {
  //             mapObj[i] = {'wall': ['center']};
  //           }
  //         }
  //       } else {
  //         continue;
  //       }
  //     }
  //   }
  //   return listWall;
  // }

  //
  // 랜덤 위치에 타겟 이미지 아이콘 생성
  //
  List<Widget> mkRandomTarget() {
    List<int> tempNumberList = List<int>.generate(rectSize, (i) => i + 1);
    List<int> listException = (listCenterWall + listTopMost + listBottomMost + listLeftMost + listRightMost).toSet().toList();
    List<int> diffTempNumberList = (tempNumberList.toSet().difference(listException.toSet())).toList();
    int randomNumber = diffTempNumberList[Random().nextInt(diffTempNumberList.length)];

    String fileInit = 'target_';
    List<String> targetNames = ['red', 'blue', 'green', 'yellow'];
    String dir = 'assets/icons/topScreen/';
    String extension = '.png';
    String randomTargetName = (targetNames..shuffle()).first;

    Container targetWidget = Container(
      margin: const EdgeInsets.all(4),
      child: Image.asset(dir + fileInit + randomTargetName + extension),
    );
    Container tempWidget = Container(color: Colors.white.withOpacity(0));
    for(var i=0; i<rectSize; i++) {
      if(i != randomNumber) {
        listTarget.add(tempWidget);
      } else {
        listTarget.add(targetWidget);
      }
    }

    // randomTargetName == target 의 색상(한글)
    // randomNumber == target 의 위치
    final targetEntry = <String, List<String>> {'target': [randomTargetName]};
    mapObj[randomNumber]?.addEntries(targetEntry.entries);  // mapObj 업데이트

    // moveHistory 업데이트
    var moveHistory = Globals().moveHistory;
    int targetCount = Globals().targetCount;
    moveHistory['target'] = <int, Map<String, dynamic>> {targetCount : {}};
    moveHistory['target']?[targetCount]['color'] = randomTargetName;
    moveHistory['target']?[targetCount]['position'] = randomNumber;
    Globals().setTargetCount();
    Globals().setNewMoveHistory(moveHistory);

    return listTarget;
  }

  //
  // 랜덤 위치에 말(piece) 이미지 아이콘 생성
  //
  List<Widget> mkRandomPiece() {
    String fileInit = 'piece_';
    List<String> pieceNames = ['red', 'blue', 'green', 'yellow'];
    String dir = 'assets/icons/topScreen/';
    String extension = '.png';

    List<int> preListPiece = [];
    for(var i=0; i<mapObj.length; i++) {
      final eachMapObj = mapObj[i];
      if(!listCenterWall.contains(i) && !eachMapObj!.containsKey("target")) {
        preListPiece.add(i);
      }
    }

    List<int> listRandomNumbers = [];
    List<int> tempPreListPiece = preListPiece;
    for(var i=0; i<pieceNames.length; i++) {
      int randomNumber = tempPreListPiece[Random().nextInt(preListPiece.length)];
      listRandomNumbers.add(randomNumber);
      tempPreListPiece.remove(randomNumber);
    }

    List<String> tempPieceNames = pieceNames;
    Container tempWidget = Container(color: Colors.white.withOpacity(0));
    for(var i=0; i<rectSize; i++) {
      if(listRandomNumbers.contains(i)) {
        int pieceNumber = i;
        String pieceName = tempPieceNames[Random().nextInt(tempPieceNames.length)];
        tempPieceNames.remove(pieceName);

        Container pieceWidget = Container(
          margin: const EdgeInsets.all(4),
          child: Image.asset(dir + fileInit + pieceName + extension),
        );

        listPiece.add(pieceWidget);

        final pieceEntry = <String, List<String>> {'piece': [pieceName]};
        mapObj[pieceNumber]?.addEntries(pieceEntry.entries);
      } else {
        listPiece.add(tempWidget);
      }
    }

    return listPiece;
  }

  //
  // ArrowPad 버튼 입력 시, 말(piece) 이동 함수
  // * bottom_screen 에서 call
  //
  void _movePiece(BuildContext context) {
    final globalDirection = Globals().arrowDirection;
    final globalColor = Globals().arrowColor;
    final globalMapObj = Globals().mapObjState;
    // final globalListTarget = Globals().listTargetState;
    final globalListPiece = Globals().listPieceState;
    bool gameOverState = false;


    Map<int, String> mapColorValueWithString = {
      4294198070 : 'red',
      4280391411 : 'blue',
      4283215696 : 'green',
      4294961979 : 'yellow'
    };
    final int globalColorValue = globalColor.value;
    final String? globalColorString = mapColorValueWithString[globalColorValue];

    for(var i=0; i<globalMapObj.length; i++) {
      if(globalMapObj[i].toString().contains('piece') && globalMapObj[i]['piece'][0] == globalColorString) {
        int pieceNumber = i;
        List<int> moveRoutes = [];
        int moveStart = 0;
        int moveEnd = 0;

        if(globalDirection == 'up') {
          for(var j=0; j<=pieceNumber~/rectCount; j++) {
            int preRouteNumber = pieceNumber - rectCount * j;

            var globalMapObjKeys = globalMapObj[preRouteNumber].toString();
            var globalMapObjWallValues = globalMapObj[preRouteNumber]['wall'].toString();
            if(preRouteNumber == pieceNumber) {   // 제자리일 때
              if(globalMapObjWallValues.contains('top')) {    // 바로 벽이 있으면 -> 바로 정지
                moveRoutes.add(preRouteNumber);
                break;
              }
            } else {    // 제자리가 아닐 때
              if(globalMapObjKeys.contains('target') && globalMapObjKeys.contains(globalColorString!)) {   // 타겟이 있을 때 -> 이동 후 정지
                gameOverState = true;
                moveRoutes.add(preRouteNumber);
                break;
              }
              if(globalMapObjKeys.contains('piece')) {    // 다른 말이 있으면 -> 바로 정지
                break;
              }
              if(globalMapObjWallValues.contains('top')) {    // 다음 칸으로 이동하기 전에 벽이 있으면 -> 이동 후 정지
                moveRoutes.add(preRouteNumber);
                break;
              }
              else if(globalMapObjWallValues.contains('bottom')) {    // 바로 벽이 있으면 -> 바로 정지
                break;
              }
              else if(globalMapObjWallValues.contains('center')) {    // 바로 중앙 벽이 있으면 -> 바로 정지
                break;
              }
            }
            moveRoutes.add(preRouteNumber);
          }
        }
        else if(globalDirection == 'down') {
          for(var j=0; j<rectCount-pieceNumber~/rectCount; j++) {
            int preRouteNumber = pieceNumber + rectCount * j;

            var globalMapObjKeys = globalMapObj[preRouteNumber].toString();
            var globalMapObjWallValues = globalMapObj[preRouteNumber]['wall'].toString();
            if(preRouteNumber == pieceNumber) {   // 제자리일 때
              if(globalMapObjWallValues.contains('bottom')) {    // 바로 벽이 있으면 -> 바로 정지
                moveRoutes.add(preRouteNumber);
                break;
              }
            } else {    // 제자리가 아닐 때
              if(globalMapObjKeys.contains('target') && globalMapObjKeys.contains(globalColorString!)) {   // 타겟이 있을 때 -> 이동 후 정지
                gameOverState = true;
                moveRoutes.add(preRouteNumber);
                break;
              }
              if(globalMapObjKeys.contains('piece')) {    // 다른 말이 있으면 -> 바로 정지
                break;
              }
              if(globalMapObjWallValues.contains('bottom')) {    // 다음 칸으로 이동하기 전에 벽이 있으면 -> 이동 후 정지
                moveRoutes.add(preRouteNumber);
                break;
              }
              if(globalMapObjWallValues.contains('top')) {    // 바로 벽이 있으면 -> 바로 정지
                break;
              }
              if(globalMapObjWallValues.contains('center')) {    // 바로 중앙 벽이 있으면 -> 바로 정지
                break;
              }
            }
            moveRoutes.add(preRouteNumber);
          }
        }
        else if(globalDirection == 'left') {
          for(var j=0; j<=pieceNumber % rectCount; j++) {
            int preRouteNumber = pieceNumber - j;

            var globalMapObjKeys = globalMapObj[preRouteNumber].toString();
            var globalMapObjWallValues = globalMapObj[preRouteNumber]['wall'].toString();
            if(preRouteNumber == pieceNumber) {   // 제자리일 때
              if(globalMapObjWallValues.contains('left')) {    // 바로 벽이 있으면 -> 바로 정지
                moveRoutes.add(preRouteNumber);
                break;
              }
            } else {    // 제자리가 아닐 때
              if(globalMapObjKeys.contains('target') && globalMapObjKeys.contains(globalColorString!)) {   // 타겟이 있을 때 -> 이동 후 정지
                gameOverState = true;
                moveRoutes.add(preRouteNumber);
                break;
              }
              if(globalMapObjKeys.contains('piece')) {    // 다른 말이 있으면 -> 바로 정지
                break;
              }
              if(globalMapObjWallValues.contains('left')) {    // 다음 칸으로 이동하기 전에 벽이 있으면 -> 이동 후 정지
                moveRoutes.add(preRouteNumber);
                break;
              }
              if(globalMapObjWallValues.contains('right')) {    // 바로 벽이 있으면 -> 바로 정지
                break;
              }
              if(globalMapObjWallValues.contains('center')) {    // 바로 중앙 벽이 있으면 -> 바로 정지
                break;
              }
            }
            moveRoutes.add(preRouteNumber);
          }
        }
        else if(globalDirection == 'right') {
          for(var j=0; j<rectCount - pieceNumber % rectCount; j++) {
            int preRouteNumber = pieceNumber + j;

            var globalMapObjKeys = globalMapObj[preRouteNumber].toString();
            var globalMapObjWallValues = globalMapObj[preRouteNumber]['wall'].toString();
            if(preRouteNumber == pieceNumber) {   // 제자리일 때
              if(globalMapObjWallValues.contains('right')) {    // 바로 벽이 있으면 -> 바로 정지
                moveRoutes.add(preRouteNumber);
                break;
              }
            } else {    // 제자리가 아닐 때
              if(globalMapObjKeys.contains('target') && globalMapObjKeys.contains(globalColorString!)) {   // 타겟이 있을 때 -> 이동 후 정지
                gameOverState = true;
                moveRoutes.add(preRouteNumber);
                break;
              }
              if(globalMapObjKeys.contains('piece')) {    // 다른 말이 있으면 -> 바로 정지
                break;
              }
              if(globalMapObjWallValues.contains('right')) {    // 다음 칸으로 이동하기 전에 벽이 있으면 -> 이동 후 정지
                moveRoutes.add(preRouteNumber);
                break;
              }
              if(globalMapObjWallValues.contains('left')) {    // 바로 벽이 있으면 -> 바로 정지
                break;
              }
              if(globalMapObjWallValues.contains('center')) {    // 바로 중앙 벽이 있으면 -> 바로 정지
                break;
              }
            }
            moveRoutes.add(preRouteNumber);
          }
        }

        if(moveRoutes.length > 1) {
          Provider.of<Globals>(context, listen: false).setNewCanMove(true);

          moveStart = pieceNumber;  // 원래 포지션
          moveEnd = moveRoutes.last;  // 이동한 포지션

          // moveHistory 에 정보 저장
          //
          // -target -포지션
          // -target -색상
          // -piece -색상
          // -piece -움직임 방향
          // -시작 포지션 - int
          // -도착 포지션 - int
          // -이동한 칸 - List<int>
          // -이동한 칸 수 - int

          // moveHistory 업데이트
          final moveHistory = Globals().moveHistory;
          int moveHistoryCount = Globals().moveHistoryCount;
          moveHistory['piece']?[moveHistoryCount] = {
            'colorString' : globalColorString,  // String
            'colorHex' : globalColor,  // Color
            'moveDirection' : globalDirection,  // String
            'positionStart' : moveStart,  // int
            'positionEnd' : moveEnd,  // int
            'moveRoutes' : moveRoutes,  // List<int>
            'moveCounts' : moveRoutes.length  // int
          };
          Provider.of<Globals>(context, listen: false).setMoveHistoryCount('+');
          Provider.of<Globals>(context, listen: false).setNewMoveHistory(moveHistory);

          // mapObj 에서 [원래 포지션]->[이동한 포지션] 값 변경
          globalMapObj[moveEnd]['piece'] = globalMapObj[moveStart]['piece'];
          globalMapObj[moveStart].remove('piece');
          mapObj = globalMapObj;
          Provider.of<Globals>(context, listen: false).setNewMapState(mapObj);

          // listPiece 에서 [원래 포지션]->[이동한 포지션] 값 변경
          Widget tempWidget = globalListPiece[moveEnd];
          globalListPiece[moveEnd] = globalListPiece[moveStart];
          globalListPiece[moveStart] = tempWidget;
          listPiece = globalListPiece;
          Provider.of<Globals>(context, listen: false).setNewPieceState(listPiece);

          // piece 가 target 에 도착 했을 때 == 게임 오버
          if(gameOverState == true) {
            const BottomScreen().endTimer();
            dialogGameOver(context);
          }
          break;
        }
      }
    }
  }

  //
  // 이전에 입력한 말(piece) 이동 기록 icon 클릭 시, piece 롤백 함수
  // * bottom_screen 에서 call
  //
  void _movePieceRollBack(BuildContext context) {
    final moveHistory = Globals().moveHistory;
    final prevMoveHistory = moveHistory['piece'];
    int countPMH = prevMoveHistory.length;
    int presentKeyPMH = countPMH-1;
    final presentPMH = prevMoveHistory[presentKeyPMH];
    int presentPosition = presentPMH['positionEnd'];  // 현재 위치
    int prevPosition = presentPMH['positionStart'];   // 롤백 위치

    prevMoveHistory.remove(presentKeyPMH);  // moveHistory 의 piece 정보 중, 마지막 요소 제거
    moveHistory['piece'] = prevMoveHistory;
    Provider.of<Globals>(context, listen: false).setMoveHistoryCount('-');
    Provider.of<Globals>(context, listen: false).setNewMoveHistory(moveHistory);

    // mapObj 에서 [현재 포지션]->[롤백한 포지션] 값 변경
    final globalMapObj = Globals().mapObjState;
    globalMapObj[prevPosition]['piece'] = globalMapObj[presentPosition]['piece'];
    globalMapObj[presentPosition].remove('piece');
    mapObj = globalMapObj;
    Provider.of<Globals>(context, listen: false).setNewMapState(mapObj);

    // listPiece 에서 [현재 포지션]->[롤백한 포지션] 값 변경
    final globalListPiece = Globals().listPieceState;
    Widget tempWidget = globalListPiece[prevPosition];
    globalListPiece[prevPosition] = globalListPiece[presentPosition];
    globalListPiece[presentPosition] = tempWidget;
    listPiece = globalListPiece;
    Provider.of<Globals>(context, listen: false).setNewPieceState(listPiece);
  }

  //
  // 초기 board 스크린샷 함수
  // * imageInitBoard 변수에 [Unit8List] 타입으로 저장
  //
  void captureInitBoard(Uint8List capturedImage) {
    screenshotController.capture(delay: const Duration(seconds: 1)).then((capturedImage) {
      Globals().setImageInitBoard(capturedImage!);
    });
  }

  //
  // State 변경 시 Map 내 값([벽, 타겟, 말(Piece)] 의 위치(벽의 position(top||bottom||right||left) 포함) 변경
  //
  void setStateMapObj() {   // 전역 변수에 새로운 mapObj 저장
    Globals().setNewMapState(mapObj);
  }
  void setStateListTarget() {   // 전역 변수에 새로운 listTarget 저장
    Globals().setNewTargetState(listTarget);
  }
  void setStateListPiece() {   // 전역 변수에 새로운 listPiece 저장
    Globals().setNewPieceState(listPiece);
  }

  void init() {
    mkRandomWall();   // 벽 세우기
    mkRandomTarget();   // 타켓 위치시키기
    mkRandomPiece();    // 말 세우기

    setStateMapObj();   // 전역 변수에 새로운 mapObj 업데이트
    setStateListTarget();   // 전역 변수에 새로운 listTarget 업데이트
    setStateListPiece();   // 전역 변수에 새로운 listPiece 업데이트
  }

  @override
  void initState() {
    super.initState();

    resetVars();  //    list 변수 초기화
    Globals().initProviders();    // Provider 초기화

    init();
  }

  @override
  Widget build(BuildContext context) {
    captureInitBoard(_imageInitBoard);  // 초기 board 스크린샷

    return Screenshot(
      controller: screenshotController,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
        width: MediaQuery.of(context).size.width * 0.95,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount (
            crossAxisCount: rectCount,
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
          ),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rectSize,
          itemBuilder: (BuildContext context, int index) {
            return ChangeNotifierProvider(
              create: (_) => Globals(),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 0.5,
                  ),
                ),
                child: Stack(
                  children: [
                    listWall[index],  // 벽 list
                    listTarget[index],  // 타겟 list
                    context.watch<Globals>().listPieceState[index], // 말(piece) list -> provider 이용해서 실시간 position 변경
                  ],
                ),
              ),
            );
          }
        ),
      ),
    );
  }
}
