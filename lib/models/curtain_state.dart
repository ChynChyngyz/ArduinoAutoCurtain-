// models/curtain_state.dart

class CurtainState {
  double position; //
  bool isMoving;
  bool isConnected;

  CurtainState({
    this.position = 0.5,
    this.isMoving = false,
    this.isConnected = false,
  });
}