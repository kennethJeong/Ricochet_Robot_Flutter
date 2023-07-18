import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:typed_data';

class Globals with ChangeNotifier {
  static String _arrowDirection = '';
  static Color _arrowColor = Colors.white;
  static Map<int, Map<String, List<String>>> _mapObjState = {};
  static List<Widget> _listTargetState = [];
  static List<Widget> _listPieceState = [];
  static Map<String, Map<int, Map<String, dynamic>>> _moveHistory = {   // target 의 정보 및 piece 의 이동 기록 저장
    'target' : {},
    'piece' : {},
  };
  static int _moveHistoryCount = 0;   // piece 의 몇 번째 이동 인지 count
  static int _targetCount = 0;  // 몇 번째 target 인지 count
  static bool _canMove = false;   // bottom_screen 에서 ArrowPad 클릭 시, piece 의 이동 가능 여부 확인
  static Uint8List _imageInitBoard = Uint8List.fromList([0]);
  static Timer _gameTimer = Timer(const Duration(), () { });
  static List<String> _saveGameTimer = [];

  void initProviders() {
    _arrowDirection = '';
    _arrowColor = Colors.white;
    _mapObjState = {};
    _listTargetState = [];
    _listPieceState = [];
    _moveHistory = {   // target 의 정보 및 piece 의 이동 기록 저장
      'target' : {},
      'piece' : {},
    };
    _moveHistoryCount = 0;   // piece 의 몇 번째 이동 인지 count
    _targetCount = 0;  // 몇 번째 target 인지 count
    _canMove = false;   // bottom_screen 에서 ArrowPad 클릭 시, piece 의 이동 가능 여부 확인
    _imageInitBoard = Uint8List.fromList([0]);
    _gameTimer = Timer(const Duration(), () { });
    _saveGameTimer = [];
  }

  get arrowDirection => _arrowDirection;
  get arrowColor => _arrowColor;
  get mapObjState => _mapObjState;
  get listTargetState => _listTargetState;
  get listPieceState => _listPieceState;
  get targetCount => _targetCount;
  get moveHistory => _moveHistory;
  get moveHistoryCount => _moveHistoryCount;
  get canMove => _canMove;
  get imageInitBoard => _imageInitBoard;
  get gameTimer => _gameTimer;
  get saveGameTimer => _saveGameTimer;

  ////////////////////////////////////////////////////////////////////////////////////////////////

  void setNewValue(String direction, Color color) {
    _arrowDirection = direction;
    _arrowColor = color;
    notifyListeners();
  }

  void setNewMapState(Map<int, Map<String, List<String>>> mapObj) {
    _mapObjState = mapObj;
    notifyListeners();
  }

  void setNewTargetState(List<Widget> listTarget) {
    _listTargetState = listTarget;
    notifyListeners();
  }

  void setNewPieceState(List<Widget> listPiece) {
    _listPieceState = listPiece;
    notifyListeners();
  }

  void setTargetCount() {
    _targetCount++;
    notifyListeners();
  }

  void setNewMoveHistory(Map<String, Map<int, Map<String, dynamic>>> newMoveHistory) {
    _moveHistory = newMoveHistory;
    notifyListeners();
  }

  void setMoveHistoryCount(String plusOrMinus) {
    if(plusOrMinus == '+') {
      _moveHistoryCount++;
    }
    else if(plusOrMinus == '-') {
      _moveHistoryCount--;
    }
    notifyListeners();
  }

  void setNewCanMove(bool canMove) {
    _canMove = canMove;
    notifyListeners();
  }

  void setImageInitBoard(Uint8List imageInitBoard) {
    _imageInitBoard = imageInitBoard;
    notifyListeners();
  }

  void setGameTimer(Timer gameTimer) {
    _gameTimer = gameTimer;
    notifyListeners();
  }

  void setSaveGameTimer(List<String> saveGameTimer) {
    _saveGameTimer = saveGameTimer;
    notifyListeners();
  }
}