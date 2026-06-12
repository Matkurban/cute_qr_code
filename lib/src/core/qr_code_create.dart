import 'color/default_color_function.dart';
import 'color/linear_gradient_color_function.dart';
import 'color/qr_code_color_function.dart';
import 'internals/qr_math.dart';
import 'qr_code.dart';
import 'qr_code_config.dart';
import 'qr_code_hook.dart';
import 'qr_code_shapes_enum.dart';
import 'render/qr_code_graphics.dart';
import 'shape/circle_shape_function.dart';
import 'shape/default_shape_function.dart';
import 'shape/qr_code_shape_function.dart';
import 'shape/round_squares_shape_function.dart';

QrCode assembleQrCode({required String data, required QrCodeConfig config}) {
  final squareSize = config.squareSize < 1 ? 1 : config.squareSize;
  final innerSpace = _innerSpaceForShape(config.shape, squareSize, config.innerSpacing);
  final radius = config.radius != null && config.radius! >= 0
      ? config.radius!
      : RoundSquaresShapeFunction.defaultRadius(squareSize);

  final colorFn = _colorFunction(config);
  final shapeFn = _shapeFunction(config, squareSize, innerSpace, radius);

  QrCodeHook drawLogoBeforeAction = emptyQrCodeHook;
  QrCodeHook drawLogoAction = emptyQrCodeHook;

  final logo = config.logo;
  if (logo != null) {
    if (config.clearLogoArea) {
      drawLogoBeforeAction = (qr, _, _, _) {
        final width = qr.logoDrawWidth;
        final height = qr.logoDrawHeight;
        if (width == null || height == null) return;

        final logoX = (qr.canvasSize - width) ~/ 2;
        final logoY = (qr.canvasSize - height) ~/ 2;

        for (final row in qr.rawData) {
          for (final cell in row) {
            final cellX = cell.absoluteX(qr.squareSize);
            final cellY = cell.absoluteY(qr.squareSize);

            cell.rendered = !QrMath.rectsIntersect(
              logoX,
              logoY,
              width,
              height,
              cellX,
              cellY,
              qr.squareSize,
              qr.squareSize,
            );
          }
        }
      };
    }

    drawLogoAction = (qr, canvas, xOffset, yOffset) {
      final image = qr.resolvedLogo;
      if (image == null) return;
      final width = qr.logoDrawWidth;
      final height = qr.logoDrawHeight;
      if (width == null || height == null) return;

      final logoX = xOffset + (qr.canvasSize - width) ~/ 2;
      final logoY = yOffset + (qr.canvasSize - height) ~/ 2;
      canvas.drawUiImage(image, logoX, logoY, drawWidth: width, drawHeight: height);
    };
  }

  final userBefore = config.onBeforeRender;
  final userAfter = config.onAfterRender;

  void beforeFn(QrCode qr, QrCodeGraphics canvas, int xOffset, int yOffset) {
    drawLogoBeforeAction(qr, canvas, xOffset, yOffset);
    if (userBefore != null) userBefore(qr, canvas);
  }

  void afterFn(QrCode qr, QrCodeGraphics canvas, int xOffset, int yOffset) {
    drawLogoAction(qr, canvas, xOffset, yOffset);
    if (userAfter != null) userAfter(qr, canvas);
  }

  final qr = QrCode(
    data: data,
    squareSize: squareSize,
    canvasSize: config.canvasSize,
    xOffset: config.xOffset + config.margin,
    yOffset: config.yOffset + config.margin,
    colorFn: colorFn,
    shapeFn: shapeFn,
    graphicsFactory: config.graphicsFactory,
    errorCorrectionLevel: config.errorCorrectionLevel,
    informationDensity: config.informationDensity,
    maskPattern: config.maskPattern,
    doBefore: beforeFn,
    doAfter: afterFn,
    logoProvider: logo,
    logoWidth: config.logoWidth,
    logoHeight: config.logoHeight,
  );

  if (config.margin > 0) {
    qr.resize(qr.canvasSize + config.margin * 2);
  }

  return qr;
}

int _innerSpaceForShape(QrCodeShapesEnum shape, int squareSize, int? innerSpacing) {
  if (innerSpacing != null && innerSpacing >= 0) return innerSpacing;
  final space = switch (shape) {
    QrCodeShapesEnum.square => 1,
    QrCodeShapesEnum.circle => CircleShapeFunction.defaultInnerSpace(squareSize),
    QrCodeShapesEnum.roundedSquare => RoundSquaresShapeFunction.defaultInnerSpace(squareSize),
    QrCodeShapesEnum.custom => 0,
  };
  return space < squareSize ? space : 0;
}

QrCodeColorFunction _colorFunction(QrCodeConfig config) {
  if (config.colorFunction != null) return config.colorFunction!;
  if (config.gradientEnd == null) {
    return DefaultColorFunction(foreground: config.color, background: config.backgroundColor);
  }
  return LinearGradientColorFunction(
    startForegroundColor: config.color,
    endForegroundColor: config.gradientEnd!,
    backgroundColor: config.backgroundColor,
    vertical: config.gradientVertical,
  );
}

QrCodeShapeFunction _shapeFunction(
  QrCodeConfig config,
  int squareSize,
  int innerSpace,
  int radius,
) {
  if (config.shapeFunction != null) return config.shapeFunction!;
  return switch (config.shape) {
    QrCodeShapesEnum.square ||
    QrCodeShapesEnum.custom => DefaultShapeFunction(squareSize, innerSpace: innerSpace),
    QrCodeShapesEnum.circle => CircleShapeFunction(squareSize, innerSpace: innerSpace),
    QrCodeShapesEnum.roundedSquare => RoundSquaresShapeFunction(
      squareSize,
      radius: radius,
      innerSpace: innerSpace,
    ),
  };
}
