// provider/curtain_provider.dart

import 'package:flutter/material.dart';
import '../models/curtain_state.dart';

class CurtainProvider extends ChangeNotifier {
  CurtainState _state = CurtainState();

  CurtainState get state => _state;

  void updatePosition(double position) {
    _state.position = position.clamp(0.0, 1.0);
    notifyListeners();
  }

  void setMoving(bool moving) {
    _state.isMoving = moving;
    notifyListeners();
  }

  void startMoving() {
    _state.isMoving = true;
    notifyListeners();
  }

  void stopMoving() {
    _state.isMoving = false;
    notifyListeners();
  }

  void setConnected(bool connected) {
    _state.isConnected = connected;
    notifyListeners();
  }

  void reset() {
    _state = CurtainState();
    notifyListeners();
  }
}