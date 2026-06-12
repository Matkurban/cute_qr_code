import 'dart:ui';

import '../color/qr_code_color_function.dart';
import '../internals/qr_code_square.dart';
import '../qr_code.dart';
import '../render/qr_code_graphics.dart';
import 'qr_code_shape_function.dart';

class DefaultShapeFunction extends QrCodeShapeFunction {
  DefaultShapeFunction(this.squareSize, {int innerSpace = 1})
    : innerSpace = innerSpace,
      _innerSpacing = innerSpace.clamp(0, squareSize ~/ 2);

  final int innerSpace;
  int squareSize;
  int _innerSpacing;

  @override
  void resize(int newSquareSize) {
    final sizeRatio = newSquareSize / squareSize;
    squareSize = newSquareSize;
    _innerSpacing = (innerSpace * sizeRatio).round().clamp(0, newSquareSize ~/ 2);
  }

  @override
  void renderSquare(
    int x,
    int y,
    QrCodeColorFunction colorFn,
    QrCodeSquare square,
    QrCodeGraphics canvas,
    QrCode qrCode,
  ) {
    final bg = colorFn.bg(square.row, square.col, qrCode, canvas);
    final fg = colorFn.fg(square.row, square.col, qrCode, canvas);
    final color = square.dark ? fg : bg;

    fillRect(
      x + _innerSpacing,
      y + _innerSpacing,
      squareSize - _innerSpacing * 2,
      squareSize - _innerSpacing * 2,
      color,
      canvas,
    );
  }

  @override
  void renderControlSquare(
    int xOffset,
    int yOffset,
    QrCodeColorFunction colorFn,
    QrCodeSquare square,
    QrCodeGraphics canvas,
    QrCode qrCode,
  ) {
    final actualSquare = square.parent ?? square;
    final bg = colorFn.bg(actualSquare.row, actualSquare.col, qrCode, canvas);
    final fg = colorFn.fg(actualSquare.row, actualSquare.col, qrCode, canvas);
    final size = squareSize * actualSquare.rowSize;
    final startX = xOffset + actualSquare.absoluteX(squareSize);
    final startY = yOffset + actualSquare.absoluteY(squareSize);

    if (actualSquare.squareInfo.type == QrCodeSquareType.positionProbe) {
      canvas.fillRect(startX, startY, size + squareSize * 2, size + squareSize * 2, bg);

      drawRect(
        startX + _innerSpacing,
        startY + _innerSpacing,
        size - _innerSpacing * 2,
        size - _innerSpacing * 2,
        fg,
        squareSize.toDouble(),
        canvas,
      );

      fillRect(
        startX + squareSize * 2,
        startY + squareSize * 2,
        size - squareSize * 4,
        size - squareSize * 4,
        fg,
        canvas,
      );
    } else {
      canvas.fillRect(startX, startY, size, size, bg);
      _drawSquaresLine(startX, startY, 5, 1, fg, canvas);
      _drawSquaresLine(startX, startY + squareSize, 5, 4, fg, canvas);
      _drawSquaresLine(startX, startY + squareSize * 2, 5, 2, fg, canvas);
      _drawSquaresLine(startX, startY + squareSize * 3, 5, 4, fg, canvas);
      _drawSquaresLine(startX, startY + squareSize * 4, 5, 1, fg, canvas);
    }
  }

  void _drawSquaresLine(int x, int y, int amount, int skip, Color color, QrCodeGraphics canvas) {
    for (var i = 0; i < amount; i += skip) {
      fillRect(
        x + (squareSize * i) + _innerSpacing,
        y + _innerSpacing,
        squareSize - _innerSpacing * 2,
        squareSize - _innerSpacing * 2,
        color,
        canvas,
      );
    }
  }

  void fillRect(int x, int y, int width, int height, Color color, QrCodeGraphics canvas) {
    canvas.fillRect(x, y, width, height, color);
  }

  void drawRect(
    int x,
    int y,
    int width,
    int height,
    Color color,
    double thickness,
    QrCodeGraphics canvas,
  ) {
    canvas.drawRect(x, y, width, height, color, thickness);
  }
}
