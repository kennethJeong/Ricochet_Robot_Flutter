import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ricochet_robot_v1/admob.dart';
import 'package:ricochet_robot_v1/screens/main_screen.dart';
import 'package:ricochet_robot_v1/screens/records_screen.dart';

class InitScreen extends StatefulWidget {
  const InitScreen({Key? key}) : super(key: key);

  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  List<Widget> listWall = [];
  List<Widget> listPiece = [];
  int boardRowCount = 4;
  int boardSize = 16;   // 4x4 크기의 보드

  List<int> routesRed = [5, 7, 3, 2, 14, 15, 11, 8, 0, 1, 5];  // red piece 의 이동 경로
  List<int> routesBlue = [11, 8, 0, 1, 5, 7, 3, 2, 14, 15, 11];  // blue piece 의 이동 경로
  bool stateAutoPlay = true;

  BannerAd? bannerAD;

  // Walls
  Map<int, String> wallPositions = {1: 'right', 5: 'bottom', 11: 'top', 14: 'left'};
  Image wallImage(String wallNames) {
    String dir = 'assets/images/wall/';
    String extension = '.png';
    return Image.asset(
      dir + wallNames + extension,
      alignment: Alignment.center,
      width: double.maxFinite,
      height: double.maxFinite,
      fit: BoxFit.fill,
    );
  }

  // Pieces
  Container pieceContainer(String colorKR) {
    String fileInit = 'piece_';
    String dir = 'assets/icons/topScreen/';
    String extension = '.png';
    return Container(
      padding: const EdgeInsets.all(12),
      child: Image.asset(dir + fileInit + colorKR + extension),
    );
  }

  //
  // listWalls && listPieces 생성
  //
  void mkLists() {
    // Walls
    for (int i=0; i<boardSize; i++) {
      listWall.add(Container(color: Colors.white.withOpacity(0)));
    }
    wallPositions.forEach((int key, String value) {
      listWall[key] = wallImage(value);
    });

    // Pieces
    for (int i=0; i<boardSize; i++) {
      listPiece.add(Container(color: Colors.white.withOpacity(0)));
    }
    listPiece[5] = pieceContainer('red');
    listPiece[11] = pieceContainer('blue');
  }

  // 무한 루프를 이용해 auto play
  void autoPlayingPieces(List<int> listRoutes) async {
    Container emptyContainer = Container(color: Colors.white.withOpacity(0));

    while(stateAutoPlay) {
      for (var i = 1; i < listRoutes.length; i++) {
        int routeNow = listRoutes[i];
        int routePrev = listRoutes[i - 1];

        await Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            listPiece[routeNow] = listPiece[routePrev];
            listPiece[routePrev] = emptyContainer;
          });
        });

        if(i == listRoutes.length) {
          i = 1;
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();

    mkLists();

    autoPlayingPieces(routesRed);
    autoPlayingPieces(routesBlue);

    bannerAD = Admob().adLoadBanner();
  }

  @override
  void dispose() {
    super.dispose();
    bannerAD?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            alignment: Alignment.bottomCenter,
            height: 180,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: const AutoSizeText(
              'Ricochet Robot',
              maxLines: 1,
              softWrap: true,
              minFontSize: 54,
              style: TextStyle(
                color: Colors.black,
                fontSize: 60,
                fontFamily: 'Atarian',
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          Flexible(
            flex: 3,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(15),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: boardRowCount,
                ),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: boardSize,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 0.5,
                      ),
                    ),
                    child: Stack(
                      children: [
                        listWall[index],  // 벽 list
                        listPiece[index], // 말(piece) list
                      ],
                    ),
                  );
                }
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: Container(
              width: MediaQuery.of(context).size.width / 1.7,
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black26, width: 2),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15))
                        )
                      ),
                      onPressed: () {
                        setState(() => stateAutoPlay = false);  // auto playing -> dispose.
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const MainScreen())); // main_screen 으로 이동.
                      },
                      child: const AutoSizeText(
                        'New Game',
                        maxLines: 1,
                        softWrap: true,
                        minFontSize: 34,
                        style: TextStyle(
                          fontFamily: 'Atarian',
                          fontSize: 40,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black26, width: 2),
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15))
                        )
                      ),
                      onPressed: () {
                        setState(() => stateAutoPlay = false);  // auto playing -> dispose.
                        dialogRecords(context);
                      },
                      child: const AutoSizeText(
                        'Records',
                        maxLines: 1,
                        softWrap: true,
                        minFontSize: 34,
                        style: TextStyle(
                          fontFamily: 'Atarian',
                          fontSize: 40,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            )
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 60,
            child: AdWidget(ad: bannerAD!),
          ),
        ],
      ),
    );
  }
}