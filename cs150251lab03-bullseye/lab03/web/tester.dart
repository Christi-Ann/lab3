import 'common_types.dart';
import 'model.dart';

ConnectTacToeModel make(WinConditionType winConditionType, TokenPhysicsType tokenPhysicsType) {
  late WinCondition winCondition;
  switch (winConditionType) {
    case WinConditionType.notConnectFour:
      winCondition = NotConnectFourWC();
    case WinConditionType.ticTacToe:
      winCondition = TicTacToeWC();
  }

  late TokenPhysics tokenPhysics;
  switch (tokenPhysicsType) {
    case TokenPhysicsType.floating:
      tokenPhysics = FloatingTP();
    case TokenPhysicsType.strongGravity:
      tokenPhysics = StrongGravityTP();
    case TokenPhysicsType.weakGravity:
      tokenPhysics = WeakGravityTP();
  }

  return ConnectTacToeModel(winCondition, tokenPhysics);
}
