import 'dart:ui';

import '../render/qr_code_graphics.dart';
import 'default_shape_function.dart';

class RoundSquaresShapeFunction extends DefaultShapeFunction {
  RoundSquaresShapeFunction(super.squareSize, {int radius = -1, int innerSpace = -1})
    : radius = radius >= 0 ? radius : defaultRadius(squareSize),
      super(innerSpace: innerSpace >= 0 ? innerSpace : defaultInnerSpace(squareSize));

  final int radius;

  static int defaultRadius(int squareSize) => (squareSize / 1.75).round();

  static int defaultInnerSpace(int squareSize) => (squareSize * 0.05).round();

  @override
  void fillRect(int x, int y, int width, int height, Color color, QrCodeGraphics canvas) {
    canvas.fillRoundRect(x, y, width, height, radius, color);
  }

  @override
  void drawRect(
    int x,
    int y,
    int width,
    int height,
    Color color,
    double thickness,
    QrCodeGraphics canvas,
  ) {
    canvas.drawRoundRect(x, y, width, height, radius, color, thickness);
  }
}
