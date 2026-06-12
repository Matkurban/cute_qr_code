import 'round_squares_shape_function.dart';

/// Circular modules (full module radius).
/// 圆形模块（半径等于模块尺寸）。
class CircleShapeFunction extends RoundSquaresShapeFunction {
  CircleShapeFunction(super.squareSize, {int innerSpace = -1})
    : super(
        radius: squareSize,
        innerSpace: innerSpace >= 0 ? innerSpace : defaultInnerSpace(squareSize),
      );

  /// Default radius helper (unused for circles; radius equals module size).
  /// 默认半径辅助值（圆形未使用；半径等于模块尺寸）。
  static int defaultRadius(int squareSize) => (squareSize / 1.75).round();

  /// Default inner padding for circular modules. 圆形模块的默认内边距。
  static int defaultInnerSpace(int squareSize) => (squareSize * 0.05).round();
}
