import 'dart:html';

import 'common_types.dart';
import 'other_common_types.dart';

import 'model.dart';
import 'view.dart';

typedef Coordinates = ({int row, int col});

class ConnectTacToeController implements ViewObserver {
  final ConnectTacToeModel _model;
  final ConnectTacToeView _view;

  ConnectTacToeController(this._model, this._view);

  @override
  void onUpdate(bool wasMouseJustClicked, double x, double y) {
    if (!wasMouseJustClicked) return;

    Coordinates? coordinates = _checkCell(x, y);
    if (coordinates != null) {
      final (:row, :col) = coordinates;
      _model.chooseCell(row, col);
    }
  }

  @override
  void onRender() {
    Player currentPlayer = _model.currentPlayer;
    Player? winner = _model.winner;
    bool didAllWin = _model.didAllWin;

    _view.clearScreen();

    // Get computed Bullseye2D coordinate constants
    final CoordinateConstants coordConsts = _view.getCoordinates(rowCount: _model.rowCount, colCount: _model.colCount);

    // Show grid lines
    _view.showGridLines(coordConsts: coordConsts);

    // Unpack necessary calculated Bullseye2D coordinate constants
    final CoordinateConstants (
      :xLineCoords,
      :yLineCoords,
      :lineThickness,
      :cellWidth, :cellHeight
    ) = coordConsts;

    // Show tokens as circles
    for (int row = 0; row < _model.rowCount; row++) {
      // Get y-coordinate of circle center
      double yCellMid = (yLineCoords[row] + lineThickness) + (cellHeight / 2);

      for (int col = 0; col < _model.colCount; col++){
        // Store token value
        Player? token = _model.getOwner(row, col);

        // Can't show token if there's no actual token
        if (token == null) {
          continue;
        }

        // Get x-coordinate of circle center
        double xCellMid = (xLineCoords[col] + lineThickness) + (cellWidth / 2);

        // Call view
        _view.showToken(x: xCellMid, y: yCellMid, cellWidth: cellWidth, token: token);
      }
    }
  
    (_model.isGameDone) ? _view.showWinner(winner, didAllWin) : _view.showCurrentPlayer(currentPlayer);
  }

  void start() {
    _view.start(this);
  }

  Coordinates? _checkCell(double x, double y) {
    final CoordinateConstants (:xLineCoords, :yLineCoords, :lineThickness) = _view.getCoordinates(rowCount: _model.rowCount, colCount: _model.colCount);

    int? finalRow, finalCol;

    for (int row = 0; row < yLineCoords.length - 1; row++) {
      if (yLineCoords[row] + lineThickness > y || y >= yLineCoords[row + 1]) {
        continue;
      }

      finalRow = row;
      break;
    }

    for (int col = 0; col < xLineCoords.length - 1; col++) {
      if (xLineCoords[col] + lineThickness > x || x >= xLineCoords[col + 1]) {
        continue;
      }

      finalCol = col;
      break;
    }

    return (finalRow == null || finalCol == null) ? null : (row: finalRow, col: finalCol);
  }
}

void main() {
  // Get input
  String url = window.location.href;
  Uri uri = Uri.parse(url);
  Map<String, String> queryParams = uri.queryParameters;

  // Validate input
  if (queryParams.keys.length != 2 || !queryParams.keys.contains('win') || !queryParams.keys.contains('physics')) {
    throw ArgumentError('invalid arguments');
  }

  late WinCondition winCondition;
  switch(queryParams['win']) {
    case 'notconnectfour':
      winCondition = NotConnectFourWC();
    case 'tictactoe':
      winCondition = TicTacToeWC();
    default:
      throw ArgumentError('invalid arguments');
  }

  late TokenPhysics tokenPhysics;
  switch(queryParams['physics']) {
    case 'floating':
      tokenPhysics = FloatingTP();
    case 'strong':
      tokenPhysics = StrongGravityTP();
    case 'weak':
      tokenPhysics = WeakGravityTP();
    default:
      throw ArgumentError('invalid arguments');
  }

  // Initialize game
  ConnectTacToeModel model = ConnectTacToeModel(winCondition, tokenPhysics);
  ConnectTacToeView view = ConnectTacToeView();
  ConnectTacToeController controller = ConnectTacToeController(model, view);

  controller.start();
}
