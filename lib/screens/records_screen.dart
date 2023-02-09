import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:ricochet_robot_v1/screens/init_screen.dart';
import 'package:page_view_indicators/page_view_indicators.dart';

void dialogRecords(BuildContext context) async {
  double whiteSpaceWidth = 15;
  double whiteSpaceHeight = 30;

  final directory = (await getApplicationDocumentsDirectory ()).path;
  var listSyncOfRecords = Directory("$directory/records").listSync()..sort((a, b) => b.path.compareTo(a.path));   // Sorting reversely the listOfRecords
  List listOfRecords = listSyncOfRecords.toList();
  int countOfRecords = listOfRecords.length;

  List imagesOfBoard = [];
  List imagesOfStats = [];
  for(var i=0; i<countOfRecords; i++) {
    Directory directoryOfEachRecord = listOfRecords[i];
    String eachRecord = directoryOfEachRecord.path;

    imagesOfBoard.add("$eachRecord/board.jpg");
    imagesOfStats.add("$eachRecord/stats.jpg");
  }

  var pageViewController = PageController(viewportFraction: 1);
  var pageViewNotifier = ValueNotifier<int>(0);

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
              //
              // Header
              //
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.black12,
                      width: 2,
                    )
                  )
                ),
                height: 80,
                child: Stack(
                  children: [
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Records",
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
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const InitScreen())),
                        icon: const Icon(
                          Icons.close,
                          size: 35,
                        ),
                      ),
                    ),
                  ],
                )
              ),

              //
              // Body
              //
              FutureBuilder(
                future: _fetch(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  // data 를 아직 받아 오지 못했을 때.
                  if (snapshot.hasData == false) {
                    return const CircularProgressIndicator();
                  }
                  // error 가 발생하게 될 경우.
                  else if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(fontSize: 30),
                      ),
                    );
                  }
                  // 데이터를 정상적으로 받아올 경우.
                  else {
                    return Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 600,
                          padding: const EdgeInsets.all(10),
                          child: PageView.builder(
                            controller: pageViewController,
                            onPageChanged:(index) {
                              pageViewNotifier.value = index;
                            },
                            padEnds: false,
                            itemCount: countOfRecords,
                            itemBuilder: (BuildContext context, index) {
                              String eachRecordBaseName = listOfRecords[index].path.split("/").last;

                              return Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.black,
                                          width: 1,
                                        )
                                      )
                                    ),
                                    child: Text(
                                      eachRecordBaseName,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: 'Atarian',
                                        fontSize: 25,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Image.file(
                                        File(imagesOfBoard[index])
                                      ),
                                      Container(
                                        height: 20,
                                      ),
                                      Image(
                                        image: FileImage(
                                          File(imagesOfStats[index])
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          height: 50,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: CirclePageIndicator(
                              currentPageNotifier: pageViewNotifier,
                              itemCount: countOfRecords,
                            ),
                          )
                        )
                      ],
                    );
                  }
                }
              ),
            ],
          ),
        ),
      ),
    )
  );
}

Future<String> _fetch() async {
  await Future.delayed(const Duration(seconds: 1));
  return 'Call Data';
}