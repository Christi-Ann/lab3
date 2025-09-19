import 'package:bullseye2d/bullseye2d.dart';

import 'common_types.dart';
import 'other_common_types.dart';

abstract interface class ViewObserver {
  void onUpdate(bool wasMouseJustClicked, double x, double y);

  void onRender();
}

class Bullseye2DView extends App {
  late BitmapFont _font;
  final ViewObserver _observer;

  Bullseye2DView(this._observer) : super();

  // Coordinates
  CoordinateConstants getCoordinates({required int rowCount, required int colCount}) {
    final double wMid = width / 2, hMid = height / 2, lineThickness = 2;
    final double cellWidth = 100, cellHeight = 100;
    final double gridWidth = (colCount * cellWidth) + ((colCount + 1) * lineThickness),
                  gridHeight = (rowCount * cellHeight) + ((rowCount + 1) * lineThickness);

    final double xRow = wMid - (gridWidth / 2), yCol = hMid - (gridHeight / 2);

    List<double> xLineCoords = [
      wMid - ((cellWidth * (7 / 2)) + (4 * lineThickness)),
      wMid - ((cellWidth * (5 / 2)) + (3 * lineThickness)),
      wMid - ((cellWidth * (3 / 2)) + (2 * lineThickness)),
      wMid - ((cellWidth / 2) + lineThickness),
      wMid + (cellWidth / 2),
      wMid + ((cellWidth * (3 / 2)) + lineThickness),
      wMid + ((cellWidth * (5 / 2)) + (2 * lineThickness)),
      wMid + ((cellWidth * (7 / 2)) + (3 * lineThickness)),
    ];

    List<double> yLineCoords = [
      hMid - ((lineThickness * (7 / 2)) + (3 * cellHeight)),
      hMid - ((lineThickness * (5 / 2)) + (2 * cellHeight)),
      hMid - (lineThickness * (3 / 2) + cellHeight),
      hMid - (lineThickness / 2),
      hMid + (lineThickness / 2 + cellHeight),
      hMid + ((lineThickness * (3 / 2)) + (2 * cellHeight)),
      hMid + ((lineThickness * (5 / 2)) + (3 * cellHeight)),
    ];

    return (
      xRow: xRow,
      xLineCoords: xLineCoords,
      yCol: yCol,
      yLineCoords: yLineCoords,
      lineThickness: lineThickness,
      gridWidth: gridWidth,
      gridHeight: gridHeight,
      cellWidth: cellWidth,
      cellHeight: cellHeight,
    );
  }

  @override
  onCreate() async {
    _font = resources.loadFont("fonts/roboto/Roboto-Regular.ttf", 20);
    log("MyApp :: MyApp created");
  }

  @override
  onUpdate() {
    bool wasMouseJustClicked = mouse.mouseHit(MouseButton.Left);

    _observer.onUpdate(wasMouseJustClicked, mouse.x, mouse.y);
  }

  @override
  onRender() {
    _observer.onRender();
  }

  final Color _p1Color = Color(245 / 255, 255 / 255, 144 / 255, 1.0),
              _p2Color = Color(255 / 255, 89 / 255, 100 / 255, 1.0),
              _drawColor = Color(250 / 255, 172 / 255, 122 / 255, 1.0);

  void clearScreen() {
    gfx.clear(0, 0, 0);
  }

  void showGridLines({required CoordinateConstants coordConsts}) {
    final CoordinateConstants (
      :xRow, :xLineCoords,
      :yCol, :yLineCoords,
      :lineThickness,
      :gridWidth, :gridHeight,
    ) = coordConsts;

    // rows
    for (int idx = 0; idx < yLineCoords.length; idx++) {
      gfx.drawRect(xRow, yLineCoords[idx], gridWidth, lineThickness);
    }
    
    // cols
    for (int idx = 0; idx < xLineCoords.length; idx++) {
      gfx.drawRect(xLineCoords[idx], yCol, lineThickness, gridHeight);
    }
  }

  void showToken({
    required double x,
    required double y,
    required double cellWidth,
    required Player token
  }) {
    gfx.drawCircle(
      x, y,
      cellWidth * (3 / 8),
      colors: (token == Player.p1) ? [_p1Color] : [_p2Color],
    );
  }

  void showCurrentPlayer(Player currentPlayer) {
    gfx.drawText(
      _font,
      "$currentPlayer",
      colors: (currentPlayer == Player.p1) ? [_p1Color] : [_p2Color],
      x: width / 2,
      y: height / 16,
      alignX: 0.5,
      alignY: 1,
    );
  }

  void showWinner(Player? winner, bool didAllWin) {
    late String txt;
    late Color clr;
    if (winner == null) {
      txt = (didAllWin) ? "It's a draw!" : "No one wins the game!";
      clr = (didAllWin) ? _drawColor : Color(1, 1, 1, 1.0);
    } else {
      txt = "$winner wins the game!";
      clr = (winner == Player.p1) ? _p1Color : _p2Color;
    }

    gfx.drawText(
      _font,
      txt,
      colors: [clr],
      x: width / 2,
      y: height / 16,
      alignX: 0.5,
      alignY: 1,
    );
  }
}

class ConnectTacToeView {
  late Bullseye2DView _bullseye2dView;

  void start(ViewObserver observer) {
    _bullseye2dView = Bullseye2DView(observer);
  }

  void clearScreen() {
    _bullseye2dView.clearScreen();
  }

  CoordinateConstants getCoordinates({required int rowCount, required int colCount}) {
    return _bullseye2dView.getCoordinates(rowCount: rowCount, colCount: colCount);
  }

  void showGridLines({required CoordinateConstants coordConsts}) {
    _bullseye2dView.showGridLines(coordConsts: coordConsts);
  }

  void showToken({
    required double x,
    required double y,
    required double cellWidth,
    required Player token,
  }) {
    _bullseye2dView.showToken(x: x, y: y, cellWidth: cellWidth, token: token);
  }

  void showCurrentPlayer(Player currentPlayer) {
    _bullseye2dView.showCurrentPlayer(currentPlayer);
  }

  void showWinner(Player? winner, bool didAllWin) {
    _bullseye2dView.showWinner(winner, didAllWin);
  }
}
