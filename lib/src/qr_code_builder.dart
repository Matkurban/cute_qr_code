import 'dart:typed_data';

import 'package:flutter/material.dart' show Color, Colors;

import 'color/default_color_function.dart';
import 'color/linear_gradient_color_function.dart';
import 'color/qr_code_color_function.dart';
import 'internals/qr_math.dart';
import 'qr_code.dart';
import 'qr_code_hook.dart';
import 'qr_code_shapes_enum.dart';
import 'raw/qr_code_enums.dart';
import 'raw/qr_code_processor.dart';
import 'render/qr_code_graphics.dart';
import 'render/qr_code_graphics_factory.dart';
import 'shape/circle_shape_function.dart';
import 'shape/default_shape_function.dart';
import 'shape/qr_code_shape_function.dart';
import 'shape/round_squares_shape_function.dart';

class QrCodeBuilder {
  QrCodeBuilder(this._shape, [this._customShapeFunction]) {
    _radiusInPixels = RoundSquaresShapeFunction.defaultRadius(_squareSize);
  }

  QrCodeShapesEnum _shape;

  QrCodeShapeFunction? _customShapeFunction;

  QrCodeColorFunction? _customColorFunction;

  int _squareSize = QrCodeProcessor.defaultCellSize;

  Color _color = Colors.black;

  Color? _endColor;

  bool _vertical = true;

  Color _background = Colors.transparent;

  late int _innerSpace = _innerSpaceForShape();

  int _radiusInPixels = 14;

  QrCodeHook _drawLogoAction = emptyQrCodeHook;

  QrCodeHook _drawLogoBeforeAction = emptyQrCodeHook;

  QrCodeHook _userDoAfter = emptyQrCodeHook;

  QrCodeHook _userDoBefore = emptyQrCodeHook;

  QrCodeGraphicsFactory _graphicsFactory = QrCodeGraphicsFactory();

  ErrorCorrectionLevel _errorCorrectionLevel = ErrorCorrectionLevel.low;

  int _informationDensity = 0;

  MaskPattern _maskPattern = MaskPattern.pattern000;

  int _canvasSize = QrCode.defaultQrCodeSize;

  int _xOffset = 0;

  int _yOffset = 0;

  int _margin = 0;

  Uint8List? _logoBytes;

  int _innerSpaceForShape() {
    final space = switch (_shape) {
      QrCodeShapesEnum.square => 1,
      QrCodeShapesEnum.circle => CircleShapeFunction.defaultInnerSpace(_squareSize),
      QrCodeShapesEnum.roundedSquare => RoundSquaresShapeFunction.defaultInnerSpace(_squareSize),
      QrCodeShapesEnum.custom => 0,
    };
    return space < _squareSize ? space : 0;
  }

  QrCodeBuilder withShape(QrCodeShapesEnum shape) {
    _shape = shape;
    return withInnerSpacing();
  }

  QrCodeBuilder withSize(int size) {
    _squareSize = size < 1 ? 1 : size;
    return withInnerSpacing();
  }

  QrCodeBuilder withColor(Color color) {
    _color = color;
    return this;
  }

  QrCodeBuilder withBackgroundColor(Color bgColor) {
    _background = bgColor;
    return this;
  }

  QrCodeBuilder withGradientColor(Color startColor, Color? endColor, {bool vertical = true}) {
    _color = startColor;
    _endColor = endColor;
    _vertical = vertical;
    return this;
  }

  QrCodeBuilder withRadius(int radius) {
    _radiusInPixels = radius >= 0 ? radius : RoundSquaresShapeFunction.defaultRadius(_squareSize);
    return this;
  }

  QrCodeBuilder withInnerSpacing([int? innerSpacing]) {
    _innerSpace = innerSpacing != null && innerSpacing >= 0 ? innerSpacing : _innerSpaceForShape();
    return this;
  }

  QrCodeBuilder withLogo(Uint8List? logo, int width, int height, {bool clearLogoArea = true}) {
    _logoBytes = logo;
    if (logo != null) {
      if (clearLogoArea) {
        _drawLogoBeforeAction = (qr, _, _, _) {
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
      } else {
        _drawLogoBeforeAction = emptyQrCodeHook;
      }

      _drawLogoAction = (qr, canvas, xOffset, yOffset) {
        final logoX = xOffset + (qr.canvasSize - width) ~/ 2;
        final logoY = yOffset + (qr.canvasSize - height) ~/ 2;
        canvas.drawImage(logo, logoX, logoY, drawWidth: width, drawHeight: height);
      };
    }
    return this;
  }

  QrCodeBuilder withAfterRenderAction(void Function(QrCode, QrCodeGraphics) action) {
    _userDoAfter = (qr, canvas, _, _) => action(qr, canvas);
    return this;
  }

  QrCodeBuilder withBeforeRenderAction(void Function(QrCode, QrCodeGraphics) action) {
    _userDoBefore = (qr, canvas, _, _) => action(qr, canvas);
    return this;
  }

  QrCodeBuilder withGraphicsFactory(QrCodeGraphicsFactory factory) {
    _graphicsFactory = factory;
    return this;
  }

  QrCodeBuilder withCustomColorFunction(QrCodeColorFunction? colorFn) {
    _customColorFunction = colorFn;
    return this;
  }

  QrCodeBuilder withCustomShapeFunction(QrCodeShapeFunction? shapeFn) {
    _customShapeFunction = shapeFn;
    return this;
  }

  QrCodeBuilder withErrorCorrectionLevel(ErrorCorrectionLevel ecl) {
    _errorCorrectionLevel = ecl;
    return this;
  }

  QrCodeBuilder withInformationDensity(int informationDensity) {
    _informationDensity = informationDensity.clamp(0, QrCodeProcessor.maximumInfoDensity);
    return this;
  }

  QrCodeBuilder withMaskPattern(MaskPattern maskPattern) {
    _maskPattern = maskPattern;
    return this;
  }

  QrCodeBuilder withCanvasSize(int size) {
    _canvasSize = size;
    return this;
  }

  QrCodeBuilder withXOffset(int xOffset) {
    _xOffset = xOffset;
    return this;
  }

  QrCodeBuilder withYOffset(int yOffset) {
    _yOffset = yOffset;
    return this;
  }

  QrCodeBuilder withMargin(int margin) {
    _margin = margin;
    return this;
  }

  QrCodeHook get _beforeFn => (qr, canvas, xOffset, yOffset) {
    _drawLogoBeforeAction(qr, canvas, xOffset, yOffset);
    _userDoBefore(qr, canvas, xOffset, yOffset);
  };

  QrCodeHook get _afterFn => (qr, canvas, xOffset, yOffset) {
    _drawLogoAction(qr, canvas, xOffset, yOffset);
    _userDoAfter(qr, canvas, xOffset, yOffset);
  };

  QrCodeColorFunction get _colorFunction {
    if (_endColor == null) {
      return _customColorFunction ??
          DefaultColorFunction(foreground: _color, background: _background);
    }
    return _customColorFunction ??
        LinearGradientColorFunction(
          startForegroundColor: _color,
          endForegroundColor: _endColor!,
          backgroundColor: _background,
          vertical: _vertical,
        );
  }

  QrCodeShapeFunction get _shapeFunction {
    if (_customShapeFunction != null) return _customShapeFunction!;
    return switch (_shape) {
      QrCodeShapesEnum.square ||
      QrCodeShapesEnum.custom => DefaultShapeFunction(_squareSize, innerSpace: _innerSpace),
      QrCodeShapesEnum.circle => CircleShapeFunction(_squareSize, innerSpace: _innerSpace),
      QrCodeShapesEnum.roundedSquare => RoundSquaresShapeFunction(
        _squareSize,
        radius: _radiusInPixels,
        innerSpace: _innerSpace,
      ),
    };
  }

  QrCode build(String data) {
    final qr = QrCode(
      data: data,
      squareSize: _squareSize,
      canvasSize: _canvasSize,
      xOffset: _xOffset + _margin,
      yOffset: _yOffset + _margin,
      colorFn: _colorFunction,
      shapeFn: _shapeFunction,
      graphicsFactory: _graphicsFactory,
      errorCorrectionLevel: _errorCorrectionLevel,
      informationDensity: _informationDensity == 0
          ? QrCodeProcessor.infoDensityForDataAndEcl(data, _errorCorrectionLevel)
          : _informationDensity,
      maskPattern: _maskPattern,
      doBefore: _beforeFn,
      doAfter: _afterFn,
      logoBytes: _logoBytes,
    );

    if (_margin > 0) {
      qr.resize(qr.canvasSize + _margin * 2);
    }

    return qr;
  }

  static QrCodeBuilder ofSquares() => QrCodeBuilder(QrCodeShapesEnum.square);

  static QrCodeBuilder ofCircles() => QrCodeBuilder(QrCodeShapesEnum.circle);

  static QrCodeBuilder ofRoundedSquares() => QrCodeBuilder(QrCodeShapesEnum.roundedSquare);

  static QrCodeBuilder ofCustomShape(QrCodeShapeFunction customShapeFunction) =>
      QrCodeBuilder(QrCodeShapesEnum.custom, customShapeFunction);
}
