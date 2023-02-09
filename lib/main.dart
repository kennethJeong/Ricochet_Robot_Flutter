import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:ricochet_robot_v1/utils/globals.dart';
import 'package:ricochet_robot_v1/screens/init_screen.dart';
import 'package:ricochet_robot_v1/screens/test_screen.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<Globals>(create: (_) => Globals()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        // home: const MainScreen(),
        home: const InitScreen(),
        // home: const TestScreen(),
      ),
    ),
  );

  // records 디렉토리 생성
  final directory = (await getApplicationDocumentsDirectory ()).path;
  if(!Directory("$directory/records").existsSync()) {
    Directory("$directory/records").create(recursive: true);
  }
}




/*

    // 1. bottom_screen 의 ArrowPad 버튼 클릭 시, [색깔, 방향] 데이터 전달 받기.
    // 2. mapObj 에서 match 되는 값 찾기.
    // 3. 그 값이 이동할 수 있는 range(벽에 부딪히는 상황) 계산 후 이동.
    // 4. mapObj 에 도착한 지점 값 저장.
    // 5. 전체 이동한 결과 값([색깔, 방향, 움직인 count]) log 저장. ( -> 새로운 List || map 변수 생성 필요)
    // 6. piece 의 이동이 arrowPad 클릭과 동시에 즉각적으로 보이게 만들기 !!
    // 7. moveHistory 이용하여 bottom_screen 의 mkColorToggleButton 에 goBack 함수 구현하기
    // 8. bottom_screen 의 addContainer 발동 시, 움직일 수 없는 범위 확인 후 생성
    // 9. bottom_screen 의 sizedBoxList 에 버튼이 추가될 때마다 카운트(countSizedBoxList) 표시
    // 10. piece 가 target 에 도착 -> Game Over 및 Continue 개발 -> ShowDialog 활용
    // 10-1. ShowDialog UI 구상 -> result_screen 으로 코드 이동 및 적용
    //   L 게임 결과 - 색상 별 이동 횟수, 총 이동 횟수, 총 걸린 시간, 초기 화면 캡쳐본
    //   L 같은 게임 다시하기, 새로 시작하기
    11. 첫 화면 UI 제작
      // L 게임 시작하기
      // L 중앙에 ListView(4x4/piece 2개/wall 8개)로 random 배치 및 auto + repeat
      L 제작자 정보
      // L 게임 기록(DB 연동)
    // 12. Database 선정 && 설정 -> 기록 저장 // 초기화면에서 인사이트 볼 수 있게.
        ===> 내부저장소(local directory) 사용해서 구현 완료.
    // 13. 벽(mkRandomWall) 함수 수정 -> 하나의 벽 주변(상하좌우)에 다른 벽이 위치하지 않게 + Board 의 끝에 닿은 부분에 벽이 생성되지 않게 (ex. Board 왼쪽 끝에 Left wall 위치하지 않게)
    // 14. init_screen 에 [Records] 생성
    //   L records_screen 만들기
    //   L 내부 저장소 이용
    //   L 인사이트 구상
    //   L ListView or SingleChildScrollView 사용하기
    //   L ScrollView 기능 살펴보기 (Vertical)
       // * 230116 작성
       //    Widget 스크린샷 이미지(Uint8List)를 PNG 등의 형식으로 저장 후 load 하여 사용하고자 했으나 실패.
       //    외부 DB 를 사용하거나 다른 방법(캐시 저장)을 찾아봐야할 듯.
       //    . 예를 들어, assets/records 에는 txt 파일 생성을 게임 클리어 DataTime 의 파일명으로 저장 후 내용에 게임 결과를 json 처럼 저장.
       //      이미지는 DataTime 으로 된 캐시 이미지로 저장.
       //       L 20230116_190803 파일명의 txt 파일 내용 -> 이동경로(lR_rB_rB_tY_bG_...)
       //                                            -> 색깔별 이동 횟수(R4_B2_Y1_G3)
       //                                            -> 걸린 시간(85min)
       //                                            -> 이동 횟수(11count)
       //                                              => 결과 ---> [ lR_rB_rB_tY_bG_.../R4_B2_Y1_G3/85min/11count ] (slash 로 각각 구분)
       //       L 20230116_190803 이름의 캐시 이미지(Board) load 하여 사용
       //
       //    ===> local directory 및 pageView 사용하여 구현 완료.
    // 15. main_screen 의 'Home' 버튼 -> debug(bottom_screen 의 타이머가 문제인 듯) 해결하기

    16. 구글 및 앱 스토어에 앱 등록하기


    *** Debugging ***
      // l piece 이동 중, 서로 위치가 바뀌는 현상
      // L 좌 or 우로 움직일 때, 벽이 있어도 넘어가는 현상 (경험에 의하면, 가는 방향에 wall+target 있을 때 발생함.)

*/
