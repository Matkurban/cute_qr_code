import 'dart:ui';

import '../../rendering/qr_code_graphics.dart';
import 'default_shape_function.dart';

/// Rounded-square modules derived from [DefaultShapeFunction].
/// 基于 [DefaultShapeFunction] 的圆角方形模块。
class RoundSquaresShapeFunction extends DefaultShapeFunction {
  RoundSquaresShapeFunction(super.squareSize, {int radius = -1, int innerSpace = -1})
    : radius = radius >= 0 ? radius : defaultRadius(squareSize),
      super(innerSpace: innerSpace >= 0 ? innerSpace : defaultInnerSpace(squareSize));

  /// Corner radius in pixels. 圆角半径（像素）。
  final int radius;

  /// Default corner radius for a module size. 给定模块尺寸的默认圆角半径。
  static int defaultRadius(int squareSize) => (squareSize / 1.75).round();

  /// Default inner padding for a module size. 给定模块尺寸的默认内边距。
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
