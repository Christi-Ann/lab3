import 'common_types.dart';

const int _gridRows = 6, _gridCols = 7;

typedef CheckResult = ({bool isGameDone, Player? winner, bool didAllWin});

class ConnectTacToeModel {
  final WinCondition _winCondition;
  final TokenPhysics _tokenPhysics;
  final List<List<Player?>> _grid;
  Player _currentPlayer;
  Player? _winner;
  bool _didAllWin;
  bool _isGameDone;

  ConnectTacToeModel(this._winCondition, this._tokenPhysics)
      : _grid = List.generate(_gridRows, (_) => List.filled(_gridCols, null)),
        _currentPlayer = Player.p1,
        _isGameDone = false,
        _didAllWin = false;

  Player get currentPlayer => _currentPlayer;
  Player? get winner => _winner;
  bool get didAllWin => _didAllWin;
  int get rowCount => _gridRows;
  int get colCount => _gridCols;
  bool get isGameDone => _isGameDone;

  Player? getOwner(int row, int col) {
    return (0 <= row && row < rowCount && 0 <= col && col < colCount)
      ? _grid[row][col]
      : null;
  }

  bool chooseCell(int row, int col) {
    if (_isGameDone) return false;
    if (row < 0 || row >= rowCount || col < 0 || col >= colCount) return false;
    if (_grid[row][col] != null) return false;

    _grid[row][col] = _currentPlayer;
    _tokenPhysics.apply(_grid);

    CheckResult res = _winCondition.check(_grid);
    _isGameDone = res.isGameDone;

    if (_isGameDone) {
      _winner = res.winner;
      _didAllWin = res.didAllWin;
    } else {
      // Check if board is still playable (still has an empty cells)
      // Should return true if all cells are full
      _isGameDone = _grid.every((row) => row.every((cell) => cell != null));
      
      _currentPlayer = _currentPlayer == Player.p1 ? Player.p2 : Player.p1;
    }
    
    return true;
  }
}


// Token Physics
abstract interface class TokenPhysics {
  TokenPhysicsType get tpType;

  void apply(List<List<Player?>> grid);
}

class FloatingTP implements TokenPhysics {
  @override
  TokenPhysicsType get tpType => TokenPhysicsType.floating;

  @override
  void apply(List<List<Player?>> grid) {}
}

class StrongGravityTP implements TokenPhysics {
  @override
  TokenPhysicsType get tpType => TokenPhysicsType.strongGravity;

  @override
  void apply(List<List<Player?>> grid) {
    final int rowCount = grid.length, colCount = grid[0].length;

    // Suppose each column is a stack. This stores the head pointer of each stack
    List<int> nullRowIdxs = List.filled(colCount, rowCount);

    for (int row = rowCount - 1; row >= 0; row--) {
      for (int col = 0; col < colCount; col++) {
        // Store grid value (token)
        Player? token = grid[row][col];

        // Check if there's an actual token there
        if (token == null) continue;

        // Nullify previous position
        grid[row][col] = null;

        // Allocate stack space
        nullRowIdxs[col]--;

        // Add to stack
        grid[nullRowIdxs[col]][col] = token;
      }
    }
  }
}

class WeakGravityTP implements TokenPhysics {
  @override
  TokenPhysicsType get tpType => TokenPhysicsType.weakGravity;

  @override
  void apply(List<List<Player?>> grid) {
    final int rowCount = grid.length, colCount = grid[0].length;

    for (int row = rowCount - 2; row >= 0; row--) {
      for (int col = 0; col < colCount; col++) {
        // Store grid value (token)
        Player? token = grid[row][col];
        
        // Nothing happens if there's no token to be moved
        if (token == null) {
          continue;
        }

        // Don't move if the row below is occupied
        if (grid[row + 1][col] != null) {
          continue;
        }

        // Nullify previous position
        grid[row][col] = null;

        // Move the token
        grid[row + 1][col] = token;
      }
    }
  }
}


// Win Condition
abstract interface class WinCondition {
  WinConditionType get wcType;

  CheckResult check(List<List<Player?>> grid);
}

class TicTacToeWC implements WinCondition {
  @override
  WinConditionType get wcType => WinConditionType.ticTacToe;

  @override
  CheckResult check(List<List<Player?>> grid) {
    final rowCount = grid.length, colCount = grid[0].length;
    bool isGameDone = false;
    Set<Player> winners = {};

    // row
    for (int row = 0; row < rowCount; row++) {
      Player? firstPlayer = grid[row][0];

      if (firstPlayer == null) {
        continue;
      }

      if (grid[row].every((token) => token == firstPlayer)) {
        // Game can have multiple winners (draw), so don't return yet
        isGameDone = true;
        winners.add(firstPlayer);
      }
    }

    // col
    List<int> rowIdxs = List.generate(rowCount - 1, (int idx) => idx + 1);
    for (int col = 0; col < colCount; col++) {
      Player? firstPlayer = grid[0][col];

      if (firstPlayer == null) {
        continue;
      }

      if (rowIdxs.every((row) => grid[row][col] == firstPlayer)) {
        // Game can have multiple winners (draw), so don't return yet
        isGameDone = true;
        winners.add(firstPlayer);
      }
    }

    // Only return once entire board is checked
    return (
      isGameDone: isGameDone, 
      winner: (winners.length == 1) ? List.from(winners)[0] : null, // Only one winner
      didAllWin: winners.length == Player.values.length // Means all (both) players won
    );
  }
}

class NotConnectFourWC implements WinCondition {
  @override
  WinConditionType get wcType => WinConditionType.notConnectFour;

  @override
  CheckResult check(List<List<Player?>> grid) {
    final int rowCount = grid.length, colCount = grid[0].length;
    bool isGameDone = false;
    Set<Player> winners = {};

    int getConnectedGroupSize(int row, int col, Player player, Set<String> visited) {
      String key = '$row,$col';
      if (visited.contains(key)) return 0;
      if (row < 0 || row >= rowCount || col < 0 || col >= colCount) return 0;
      if (grid[row][col] != player) return 0;

      visited.add(key);
      int size = 1;

      // check direction
      size += getConnectedGroupSize(row - 1, col, player, visited);
      size += getConnectedGroupSize(row + 1, col, player, visited);
      size += getConnectedGroupSize(row, col - 1, player, visited);
      size += getConnectedGroupSize(row, col + 1, player, visited);

      return size;
    }


    for (Player player in Player.values) {
      Set<String> visited = {};

      for (int row = 0; row < rowCount; row++) {
        for (int col = 0; col < colCount; col++) {
          if (grid[row][col] == player) {
            int groupSize = getConnectedGroupSize(row, col, player, visited);
            if (groupSize >= 4) {
              // Game can have multiple winners (draw), so don't return yet
              isGameDone = true;
              winners.add(player);
            }
          }
        }
      }
    }

    // Only return once entire board is checked
    return (
      isGameDone: isGameDone, 
      winner: (winners.length == 1) ? List.from(winners)[0] : null, // Only one winner
      didAllWin: winners.length == Player.values.length // Means all (both) players won
    );
  }
}
