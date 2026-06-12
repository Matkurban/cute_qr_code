import 'round_squares_shape_function.dart';

class CircleShapeFunction extends RoundSquaresShapeFunction {
  CircleShapeFunction(super.squareSize, {int innerSpace = -1})
    : super(
        radius: squareSize,
        innerSpace: innerSpace >= 0 ? innerSpace : defaultInnerSpace(squareSize),
      );

  static int defaultRadius(int squareSize) => (squareSize / 1.75).round();

  static int defaultInnerSpace(int squareSize) => (squareSize * 0.05).round();
}
