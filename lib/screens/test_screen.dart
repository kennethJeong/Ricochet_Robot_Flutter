import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:ricochet_robot_v1/utils/globals.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  State createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  static const int rectCount = 16;
  static const int rectSize = rectCount * rectCount;
  static const double containerInsetX = 10;
  static const double containerInsetY = 50;

  List<int> listCenterWall = [119, 120, 135, 136];  // 중앙 벽 위치
  List<Widget> listWall = [];
  List<Widget> listTarget = [];
  Map<int, Map<String, List<String>>> mapObj = {}; // [벽, 타겟, 말(Piece)] 의 위치(벽의 position(top||bottom||right||left) 포함)

  var listTopMost = List<int>.generate(rectCount, (i) => i);
  var listBottomMost = List<int>.generate(rectCount, (i) => rectSize - rectCount + i);
  var listLeftMost = List<int>.generate(rectCount, (i) => rectSize - rectCount * (i + 1));
  var listRightMost = List<int>.generate(rectCount, (i) => (rectSize - 1) - rectCount * i);

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

  //
  // 랜덤 위치에 타겟 이미지 아이콘 생성
  //
  List<Widget> mkRandomTarget() {
    List<int> tempNumberList = List<int>.generate(rectSize, (i) => i + 1);
    List<int> listException = (listCenterWall + listTopMost + listBottomMost + listLeftMost + listRightMost).toSet().toList();
    List<int> diffTempNumberList = (tempNumberList.toSet().difference(listException.toSet())).toList();
    int randomNumber = diffTempNumberList[Random().nextInt(diffTempNumberList.length)];

    debugPrint(listException.toString(), wrapWidth: 1024);

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

  void init() {
    mkRandomWall();   // 벽 세우기
    mkRandomTarget();
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: containerInsetX, vertical: containerInsetY),
      child: GridView.builder(
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
                  // context.watch<Globals>().listPieceState[index], // 말(piece) list -> provider 이용해서 실시간 position 변경
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}
