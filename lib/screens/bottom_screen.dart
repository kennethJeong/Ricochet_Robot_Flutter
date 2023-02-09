import 'dart:async';
import 'package:flutter/material.dart';
import 'package:arrow_pad/arrow_pad.dart';
import 'package:ricochet_robot_v1/utils/globals.dart';
import 'package:ricochet_robot_v1/screens/top_screen.dart';
import 'package:provider/provider.dart';

class BottomScreen extends StatefulWidget {
  const BottomScreen({Key? key}) : super(key: key);

  endTimer() => _BottomScreenState()._endTimer();

  @override
  State createState() => _BottomScreenState();
}

class _BottomScreenState extends State<BottomScreen> {
  List<Widget> sizedBoxList = [];
  int countSizedBoxList = 0;
  String arrowDirection = '';
  Color arrowColor = Colors.red;
  IconData iconShape = Icons.arrow_circle_left_outlined;
  final ScrollController _listViewController = ScrollController();

  late Timer gameTimer;
  int timeCount = 0;
  List<String> saveGameTimer = [];

  SizedBox createNewIconButton(String direction) {
    double iconSize = (MediaQuery.of(context).size.width - 6) / 8;

    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: IconButton(
        padding: const EdgeInsets.all(3),
        onPressed: () => popContainer(),
        icon: Icon(
          iconShape,
          size: iconSize,
          color: arrowColor,
        ),
        // icon: Image.asset(assetDir),
      )
    );
  }

  // Add
  void addContainer(String direction) {
    // ArrowPad 에 입력된 방향에 따라 아이콘 모양 설정
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

    // ArrowPad 의 [색깔, 방향] 데이터를 top_screen 으로 전달하는 함수 실행
    transferPieceData(direction, arrowColor);

    // 이동 불가능(바로 옆에 벽 or piece 존재할 때)한 상태 확인 변수(canMove) 값 수정.
    bool canMove = Globals().canMove;
    if(canMove) {
      sizedBoxList.add(createNewIconButton(direction));
      Globals().setNewCanMove(false);
    }

    // sizedBox 의 count 값 수정.
    setSizedBoxCount();

    // arrow 버튼이 추가되었을 때, 자동으로 maxWidth 까지 Scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(_listViewController.hasClients) {
        _listViewController.jumpTo(_listViewController.position.maxScrollExtent);
      }
    });

    setState(() {});
  }

  // ArrowPad 의 [색깔, 방향] 데이터를 top_screen 으로 전달.
  void transferPieceData(String direction, Color arrowColor) {
    String selectedDirection = direction; // 방향
    Color selectedColor = arrowColor; // 색깔

    // 전역 변수에 새로운 [방향, 색깔] 저장 (Provider 사용)
    context.read<Globals>().setNewValue(selectedDirection, selectedColor);

    // top_screen 의 Piece 이동 함수 실행
    const TopScreen().movePiece(context);
  }

  // Pop
  void popContainer() {
    // *************************************
    // context.read<Globals>().setNewValue(selectedDirection, selectedColor);
    // 이걸 설정하지 않으면 dynamic 하게 piece rollback 이 되지 않는 이유를 모르겠음!!
    // *************************************
    // context.read<Globals>().mounting();

    // top_screen 의 Piece 롤백 이동 함수 실행
    const TopScreen().movePieceRollBack(context);

    sizedBoxList.removeLast();
    setSizedBoxCount();

    setState(() {});
  }

  ElevatedButton mkColorToggleButton(Color color) {
    return ElevatedButton(
      onPressed: () => changeButtonColor(color),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: const CircleBorder(),
      ),
      child: const Text(''),
    );

  }

  void changeButtonColor(Color color) {
    setState(() {
      arrowColor = color;
    });
  }

  void setSizedBoxCount() {
    countSizedBoxList = sizedBoxList.length;
  }

  void _startTimer(BuildContext context) {
    int delayTime = 3;
    Future.delayed(Duration(seconds: delayTime), () {
      gameTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
        setState(() {
          timeCount++;
          int sec = timeCount ~/ 100;   // seconds
          // String milliSec = '${timeCount % 100}'.padLeft(2, '0');   // milliseconds
          if(!saveGameTimer.contains('$sec')) {
            saveGameTimer.add('$sec');
            Globals().setSaveGameTimer(saveGameTimer);
          }
        });
      });
      Globals().setGameTimer(gameTimer);
    });
  }

  void _endTimer() {
    Timer timer = Globals().gameTimer;
    timer.cancel();
  }

  @override
  void initState() {
    super.initState();
    _startTimer(context);
  }

  @override
  void dispose() {
    super.dispose();
    _endTimer();
  }

  @override
  Widget build(BuildContext context) {
    int secondCount = timeCount ~/ 100;
    String hundredthCount = '${timeCount % 100}'.padLeft(2, '0');

    return Column(
      children: [
        //////////////////////////
        /* Clicked Arrow Button Array */
        //////////////////////////
        SizedBox(
          height: 100.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: sizedBoxList.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                child: sizedBoxList[index],
              );
            },
            controller: _listViewController,
          )
        ),

        ///////////////////////////////
        /* Footer - Direction Button */
        ///////////////////////////////
        Flexible(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 30),
                        child: Text(
                          countSizedBoxList.toString(),
                          style: const TextStyle(
                            fontFamily: 'DS-DIGIB',
                            fontSize: 50,
                            color: Colors.black ,
                          ),
                        )
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$secondCount',
                          style: const TextStyle(
                            fontSize: 30,
                          ),
                        ),
                        Text(
                          hundredthCount,
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        )
                      ],
                    )
                  ],
                )
              ),
              Flexible(
                flex: 2,
                child: Center(
                  child: FractionallySizedBox(
                    widthFactor: 1.0,
                    heightFactor: 1.0,
                    child: ArrowPad(
                      outerColor: arrowColor,
                      onPressedUp: () => addContainer('up'),
                      onPressedLeft: () => addContainer('left'),
                      onPressedRight: () => addContainer('right'),
                      onPressedDown: () => addContainer('down'),
                    ),
                  )
                )
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    mkColorToggleButton(Colors.red),
                    mkColorToggleButton(Colors.blue),
                    mkColorToggleButton(Colors.green),
                    mkColorToggleButton(Colors.yellow),
                  ].map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0),
                    child: e,
                  )).toList(),
                ),
              ),
            ],
          )
        )
      ],
    );
  }
}