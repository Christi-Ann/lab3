import 'package:test/test.dart';
import '../web/common_types.dart';
import '../web/model.dart';
import '../web/tester.dart';

void main() {
  group('ConnectTacToeModel Tests', () {
    test('Constructor and basic getters', () {
      var model = make(WinConditionType.ticTacToe, TokenPhysicsType.floating);
      
      expect(model.currentPlayer, equals(Player.p1));
      expect(model.winner, isNull);
      expect(model.rowCount, equals(6));
      expect(model.colCount, equals(7));
      expect(model.isGameDone, isFalse);
      expect(model.didAllWin, isFalse);
    });

    test('getOwner - valid coordinates', () {
      var model = make(WinConditionType.ticTacToe, TokenPhysicsType.floating);
      
      for (int row = 0; row < model.rowCount; row++) {
        for (int col = 0; col < model.colCount; col++) {
          expect(model.getOwner(row, col), isNull);
        }
      }
    });

    test('getOwner - invalid coordinates', () {
      var model = make(WinConditionType.ticTacToe, TokenPhysicsType.floating);
      
      expect(model.getOwner(-1, 0), isNull);
      expect(model.getOwner(0, -1), isNull);
      expect(model.getOwner(-1, -1), isNull);
      
      expect(model.getOwner(6, 0), isNull);
      expect(model.getOwner(0, 7), isNull);
      expect(model.getOwner(6, 7), isNull);
    });

    test('chooseCell - valid moves', () {
      var model = make(WinConditionType.ticTacToe, TokenPhysicsType.floating);
      
      expect(model.chooseCell(0, 0), isTrue);
      expect(model.getOwner(0, 0), equals(Player.p1));
      expect(model.currentPlayer, equals(Player.p2));
      
      expect(model.chooseCell(1, 1), isTrue);
      expect(model.getOwner(1, 1), equals(Player.p2));
      expect(model.currentPlayer, equals(Player.p1));
    });

    test('chooseCell - invalid moves', () {
      var model = make(WinConditionType.ticTacToe, TokenPhysicsType.floating);
      
      expect(model.chooseCell(0, 0), isTrue);
      
      expect(model.chooseCell(0, 0), isFalse);
      expect(model.currentPlayer, equals(Player.p2));
      
      expect(model.chooseCell(-1, 0), isFalse);
      expect(model.chooseCell(0, -1), isFalse);
      expect(model.chooseCell(6, 0), isFalse);
      expect(model.chooseCell(0, 7), isFalse);
    });

    test('chooseCell - game already done', () {
      var model = make(WinConditionType.ticTacToe, TokenPhysicsType.floating);
      
      model.chooseCell(0, 0);
      model.chooseCell(1, 0);
      model.chooseCell(0, 1);
      model.chooseCell(1, 1);
      model.chooseCell(0, 2);
      model.chooseCell(1, 2);
      model.chooseCell(0, 3);
      model.chooseCell(1, 3);
      model.chooseCell(0, 4);
      model.chooseCell(1, 4);
      model.chooseCell(0, 5);
      model.chooseCell(1, 5);
      model.chooseCell(0, 6);
      
      expect(model.isGameDone, isTrue);
      expect(model.winner, equals(Player.p1));
      expect(model.didAllWin, isFalse);
      
      expect(model.chooseCell(2, 0), isFalse);
    });
  });

  group('TokenPhysics Tests', () {
    test('FloatingTP - tokens stay in place', () {
      var model = make(WinConditionType.ticTacToe, TokenPhysicsType.floating);
      var physics = FloatingTP();
      
      expect(physics.tpType, equals(TokenPhysicsType.floating));
      
      model.chooseCell(0, 0);
      model.chooseCell(2, 3);
      model.chooseCell(4, 6);
      
      expect(model.getOwner(0, 0), equals(Player.p1));
      expect(model.getOwner(2, 3), equals(Player.p2));
      expect(model.getOwner(4, 6), equals(Player.p1));
    });

    test('StrongGravityTP - tokens fall to bottom', () {
      var model = make(WinConditionType.ticTacToe, TokenPhysicsType.strongGravity);
      var physics = StrongGravityTP();
      
      expect(physics.tpType, equals(TokenPhysicsType.strongGravity));
      
      model.chooseCell(0, 0);
      expect(model.getOwner(5, 0), equals(Player.p1));
      expect(model.getOwner(0, 0), isNull);
      
      model.chooseCell(1, 0);
      expect(model.getOwner(4, 0), equals(Player.p2));
      expect(model.getOwner(1, 0), isNull);
    });

    test('WeakGravityTP - tokens move down one step', () {
      var model = make(WinConditionType.ticTacToe, TokenPhysicsType.weakGravity);
      var physics = WeakGravityTP();
      
      expect(physics.tpType, equals(TokenPhysicsType.weakGravity));
      
      model.chooseCell(0, 0);
      expect(model.getOwner(1, 0), equals(Player.p1));
      expect(model.getOwner(0, 0), isNull);
      
      model.chooseCell(0, 0);
      expect(model.getOwner(1, 0), equals(Player.p2));
      expect(model.getOwner(2, 0), equals(Player.p1));
    });

    test('WeakGravityTP - multiple tokens scenario', () {
      var model = make(WinConditionType.ticTacToe, TokenPhysicsType.weakGravity);
      
      model.chooseCell(4, 1);
      model.chooseCell(3, 1);
      model.chooseCell(2, 1);
      
      expect(model.getOwner(5, 1), equals(Player.p1));
      expect(model.getOwner(4, 1), equals(Player.p2));
      expect(model.getOwner(3, 1), equals(Player.p1));
    });
  });

  group('WinCondition Tests', () {
    test('TicTacToeWC - row win', () {
      var model = make(WinConditionType.ticTacToe, TokenPhysicsType.floating);
      var winCondition = TicTacToeWC();
      
      expect(winCondition.wcType, equals(WinConditionType.ticTacToe));
      
      model.chooseCell(0, 0);
      model.chooseCell(1, 0);
      model.chooseCell(0, 1);
      model.chooseCell(1, 1);
      model.chooseCell(0, 2);
      model.chooseCell(1, 2);
      model.chooseCell(0, 3);
      model.chooseCell(1, 3);
      model.chooseCell(0, 4);
      model.chooseCell(1, 4);
      model.chooseCell(0, 5);
      model.chooseCell(1, 5);
      model.chooseCell(0, 6);
      
      expect(model.isGameDone, isTrue);
      expect(model.winner, equals(Player.p1));
      expect(model.didAllWin, isFalse);
    });

    test('TicTacToeWC - column win', () {
      var model = make(WinConditionType.ticTacToe, TokenPhysicsType.floating);
      
      model.chooseCell(0, 0);
      model.chooseCell(0, 1);
      model.chooseCell(1, 0);
      model.chooseCell(1, 1);
      model.chooseCell(2, 0);
      model.chooseCell(2, 1);
      model.chooseCell(3, 0);
      model.chooseCell(3, 1);
      model.chooseCell(4, 0);
      model.chooseCell(4, 1);
      model.chooseCell(5, 0);
      
      expect(model.isGameDone, isTrue);
      expect(model.winner, equals(Player.p1));
      expect(model.didAllWin, isFalse);
    });

    test('TicTacToeWC - win-win', () {
      final ConnectTacToeModel model = make(WinConditionType.ticTacToe, TokenPhysicsType.weakGravity);

      model.chooseCell(3, 0);
      model.chooseCell(3, 0);
      model.chooseCell(3, 1);
      model.chooseCell(3, 1);
      model.chooseCell(3, 2);
      model.chooseCell(3, 2);
      model.chooseCell(3, 3);
      model.chooseCell(3, 3);
      model.chooseCell(3, 4);
      model.chooseCell(3, 4);
      model.chooseCell(3, 5);
      model.chooseCell(3, 5);
      model.chooseCell(3, 6);
      model.chooseCell(3, 6);

      expect(model.isGameDone, isTrue);
      expect(model.winner, isNull);
      expect(model.didAllWin, isTrue);
    });

    test('TicTacToeWC - lose-lose', () {
      final ConnectTacToeModel model = make(WinConditionType.ticTacToe, TokenPhysicsType.floating);

      model.chooseCell(0, 0);
      model.chooseCell(0, 1);
      model.chooseCell(0, 2);
      model.chooseCell(0, 3);
      model.chooseCell(0, 4);
      model.chooseCell(0, 5);
      model.chooseCell(0, 6);
      model.chooseCell(1, 0);
      model.chooseCell(1, 1);
      model.chooseCell(1, 2);
      model.chooseCell(1, 3);
      model.chooseCell(1, 4);
      model.chooseCell(1, 5);
      model.chooseCell(1, 6);
      model.chooseCell(2, 0);
      model.chooseCell(2, 1);
      model.chooseCell(2, 2);
      model.chooseCell(2, 3);
      model.chooseCell(2, 4);
      model.chooseCell(2, 5);
      model.chooseCell(2, 6);
      model.chooseCell(3, 0);
      model.chooseCell(3, 1);
      model.chooseCell(3, 2);
      model.chooseCell(3, 3);
      model.chooseCell(3, 4);
      model.chooseCell(3, 5);
      model.chooseCell(3, 6);
      model.chooseCell(4, 0);
      model.chooseCell(4, 1);
      model.chooseCell(4, 2);
      model.chooseCell(4, 3);
      model.chooseCell(4, 4);
      model.chooseCell(4, 5);
      model.chooseCell(4, 6);
      model.chooseCell(5, 0);
      model.chooseCell(5, 1);
      model.chooseCell(5, 2);
      model.chooseCell(5, 3);
      model.chooseCell(5, 4);
      model.chooseCell(5, 5);
      model.chooseCell(5, 6);

      expect(model.isGameDone, isTrue);
      expect(model.winner, isNull);
      expect(model.didAllWin, isFalse);
    });

    test('NotConnectFourWC - horizontal connection of 4', () {
      var model = make(WinConditionType.notConnectFour, TokenPhysicsType.floating);
      var winCondition = NotConnectFourWC();
      
      expect(winCondition.wcType, equals(WinConditionType.notConnectFour));
      
      model.chooseCell(0, 0);
      model.chooseCell(1, 0);
      model.chooseCell(0, 1);
      model.chooseCell(1, 1);
      model.chooseCell(0, 2);
      model.chooseCell(1, 2);
      model.chooseCell(0, 3);
      
      expect(model.isGameDone, isTrue);
      expect(model.winner, equals(Player.p1));
      expect(model.didAllWin, isFalse);
    });

    test('NotConnectFourWC - vertical connection of 4', () {
      var model = make(WinConditionType.notConnectFour, TokenPhysicsType.floating);
      
      model.chooseCell(0, 0);
      model.chooseCell(0, 1);
      model.chooseCell(1, 0);
      model.chooseCell(1, 1);
      model.chooseCell(2, 0);
      model.chooseCell(2, 1);
      model.chooseCell(3, 0);
      
      expect(model.isGameDone, isTrue);
      expect(model.winner, equals(Player.p1));
      expect(model.didAllWin, isFalse);
    });

    test('NotConnectFourWC - L-shaped connection of 4', () {
      var model = make(WinConditionType.notConnectFour, TokenPhysicsType.floating);
      
      model.chooseCell(2, 2);
      model.chooseCell(1, 1);
      model.chooseCell(2, 1);
      model.chooseCell(1, 3);
      model.chooseCell(2, 0);
      model.chooseCell(1, 4);
      model.chooseCell(3, 2);
      
      expect(model.isGameDone, isTrue);
      expect(model.winner, equals(Player.p1));
      expect(model.didAllWin, isFalse);
    });

    test('NotConnectFourWC - win-win', () {
      final ConnectTacToeModel model = make(WinConditionType.notConnectFour, TokenPhysicsType.weakGravity);

      model.chooseCell(3, 0);
      model.chooseCell(3, 0);
      model.chooseCell(3, 1);
      model.chooseCell(3, 1);
      model.chooseCell(3, 2);
      model.chooseCell(3, 2);
      model.chooseCell(3, 3);
      model.chooseCell(3, 3);

      expect(model.isGameDone, isTrue);
      expect(model.winner, isNull);
      expect(model.didAllWin, isTrue);
    });
    
    test('NotConnectFourWC - lose-lose', () {
      final ConnectTacToeModel model = make(WinConditionType.notConnectFour, TokenPhysicsType.floating);

      model.chooseCell(0, 0);
      model.chooseCell(0, 1);
      model.chooseCell(0, 2);
      model.chooseCell(0, 3);
      model.chooseCell(0, 4);
      model.chooseCell(0, 5);
      model.chooseCell(0, 6);
      model.chooseCell(1, 0);
      model.chooseCell(1, 1);
      model.chooseCell(1, 2);
      model.chooseCell(1, 3);
      model.chooseCell(1, 4);
      model.chooseCell(1, 5);
      model.chooseCell(1, 6);
      model.chooseCell(2, 0);
      model.chooseCell(2, 1);
      model.chooseCell(2, 2);
      model.chooseCell(2, 3);
      model.chooseCell(2, 4);
      model.chooseCell(2, 5);
      model.chooseCell(2, 6);
      model.chooseCell(3, 0);
      model.chooseCell(3, 1);
      model.chooseCell(3, 2);
      model.chooseCell(3, 3);
      model.chooseCell(3, 4);
      model.chooseCell(3, 5);
      model.chooseCell(3, 6);
      model.chooseCell(4, 0);
      model.chooseCell(4, 1);
      model.chooseCell(4, 2);
      model.chooseCell(4, 3);
      model.chooseCell(4, 4);
      model.chooseCell(4, 5);
      model.chooseCell(4, 6);
      model.chooseCell(5, 0);
      model.chooseCell(5, 1);
      model.chooseCell(5, 2);
      model.chooseCell(5, 3);
      model.chooseCell(5, 4);
      model.chooseCell(5, 5);
      model.chooseCell(5, 6);

      expect(model.isGameDone, isTrue);
      expect(model.winner, isNull);
      expect(model.didAllWin, isFalse);
    });
  });

  group('Integration Tests', () {
    test('TicTacToe with StrongGravity - column win', () {
      var model = make(WinConditionType.ticTacToe, TokenPhysicsType.strongGravity);
      
      model.chooseCell(0, 0);
      model.chooseCell(0, 1);
      model.chooseCell(0, 0);
      model.chooseCell(0, 1);
      model.chooseCell(0, 0);
      model.chooseCell(0, 1);
      model.chooseCell(0, 0);
      model.chooseCell(0, 1);
      model.chooseCell(0, 0);
      model.chooseCell(0, 1);
      model.chooseCell(0, 0);
      
      expect(model.isGameDone, isTrue);
      expect(model.winner, equals(Player.p1));
      expect(model.didAllWin, isFalse);
    });

    test('NotConnectFour with WeakGravity - shifting connections', () {
      var model = make(WinConditionType.notConnectFour, TokenPhysicsType.weakGravity);
      
      model.chooseCell(5, 0);
      model.chooseCell(4, 4);
      model.chooseCell(5, 1);
      model.chooseCell(3, 4);
      model.chooseCell(5, 2);
      model.chooseCell(2, 4);
      model.chooseCell(5, 3);
      
      expect(model.isGameDone, isTrue);
      expect(model.winner, equals(Player.p1));
      expect(model.didAllWin, isFalse);
    });
  });

  group('Tester Function Tests', () {
    test('make - all combinations', () {
      for (var winType in WinConditionType.values) {
        for (var physicsType in TokenPhysicsType.values) {
          var model = make(winType, physicsType);
          
          expect(model, isNotNull);
          expect(model.rowCount, equals(6));
          expect(model.colCount, equals(7));
          expect(model.currentPlayer, equals(Player.p1));
          expect(model.winner, isNull);
          expect(model.isGameDone, isFalse);
        }
      }
    });
  });

  group('Edge Cases', () {
    test('TicTacToeWC - empty grid check', () {
      var model = make(WinConditionType.ticTacToe, TokenPhysicsType.floating);
      
      expect(model.isGameDone, isFalse);
      expect(model.winner, isNull);
    });

    test('NotConnectFourWC - single token', () {
      var model = make(WinConditionType.notConnectFour, TokenPhysicsType.floating);
      
      model.chooseCell(3, 3);
      
      expect(model.isGameDone, isFalse);
      expect(model.winner, isNull);
    });

    test('StrongGravity - empty column behavior', () {
      var model = make(WinConditionType.ticTacToe, TokenPhysicsType.strongGravity);
      
      model.chooseCell(0, 3);
      
      expect(model.getOwner(5, 3), equals(Player.p1));
      expect(model.getOwner(0, 3), isNull);
    });

    test('WeakGravity - bottom row tokens stay', () {
      var model = make(WinConditionType.ticTacToe, TokenPhysicsType.weakGravity);
      
      model.chooseCell(5, 3);
      
      expect(model.getOwner(5, 3), equals(Player.p1));
    });

    test('Player alternation consistency', () {
      var model = make(WinConditionType.ticTacToe, TokenPhysicsType.floating);
      
      expect(model.currentPlayer, equals(Player.p1));
      
      model.chooseCell(0, 0);
      expect(model.currentPlayer, equals(Player.p2));
      
      model.chooseCell(0, 1);
      expect(model.currentPlayer, equals(Player.p1));
      
      model.chooseCell(0, 2);
      expect(model.currentPlayer, equals(Player.p2));
    });

    test('Game state after win - no further moves allowed', () {
      var model = make(WinConditionType.notConnectFour, TokenPhysicsType.floating);
      
      model.chooseCell(0, 0);
      model.chooseCell(1, 1);
      model.chooseCell(0, 1);
      model.chooseCell(2, 2);
      model.chooseCell(0, 2);
      model.chooseCell(3, 3);
      model.chooseCell(0, 3);
      
      expect(model.isGameDone, isTrue);
      expect(model.winner, equals(Player.p1));
      expect(model.didAllWin, isFalse);
      
      expect(model.chooseCell(1, 0), isFalse);
      expect(model.chooseCell(2, 0), isFalse);
      
      expect(model.currentPlayer, equals(Player.p1));
      expect(model.winner, equals(Player.p1));
      expect(model.didAllWin, isFalse);
    });
  });
}