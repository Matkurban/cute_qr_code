import 'package:flutter/material.dart' show Color, Colors, ImageProvider;

import 'color/qr_code_color_function.dart';
import 'qr_code.dart';
import 'qr_code_shapes_enum.dart';
import 'raw/qr_code_enums.dart';
import 'raw/qr_code_processor.dart';
import 'render/qr_code_graphics.dart';
import 'render/qr_code_graphics_factory.dart';
import 'shape/qr_code_shape_function.dart';

/// Configuration for [QrCode.create] and [CuteQrCode].
class QrCodeConfig {
  const QrCodeConfig({
    this.shape = QrCodeShapesEnum.square,
    this.color = Colors.black,
    this.backgroundColor = Colors.transparent,
    this.gradientEnd,
    this.gradientVertical = true,
    this.squareSize = QrCodeProcessor.defaultCellSize,
    this.radius,
    this.innerSpacing,
    this.logo,
    this.logoWidth,
    this.logoHeight,
    this.clearLogoArea = true,
    this.errorCorrectionLevel = ErrorCorrectionLevel.low,
    this.maskPattern = MaskPattern.pattern000,
    this.informationDensity,
    this.canvasSize = 0,
    this.margin = 0,
    this.xOffset = 0,
    this.yOffset = 0,
    this.colorFunction,
    this.shapeFunction,
    this.graphicsFactory,
    this.onBeforeRender,
    this.onAfterRender,
  });

  final QrCodeShapesEnum shape;
  final Color color;
  final Color backgroundColor;
  final Color? gradientEnd;
  final bool gradientVertical;
  final int squareSize;
  final int? radius;
  final int? innerSpacing;
  final ImageProvider? logo;
  final double? logoWidth;
  final double? logoHeight;
  final bool clearLogoArea;
  final ErrorCorrectionLevel errorCorrectionLevel;
  final MaskPattern maskPattern;
  final int? informationDensity;
  final int canvasSize;
  final int margin;
  final int xOffset;
  final int yOffset;
  final QrCodeColorFunction? colorFunction;
  final QrCodeShapeFunction? shapeFunction;
  final QrCodeGraphicsFactory? graphicsFactory;
  final void Function(QrCode, QrCodeGraphics)? onBeforeRender;
  final void Function(QrCode, QrCodeGraphics)? onAfterRender;

  QrCodeConfig copyWith({
    QrCodeShapesEnum? shape,
    Color? color,
    Color? backgroundColor,
    Color? gradientEnd,
    bool? gradientVertical,
    int? squareSize,
    int? radius,
    int? innerSpacing,
    ImageProvider? logo,
    double? logoWidth,
    double? logoHeight,
    bool? clearLogoArea,
    ErrorCorrectionLevel? errorCorrectionLevel,
    MaskPattern? maskPattern,
    int? informationDensity,
    int? canvasSize,
    int? margin,
    int? xOffset,
    int? yOffset,
    QrCodeColorFunction? colorFunction,
    QrCodeShapeFunction? shapeFunction,
    QrCodeGraphicsFactory? graphicsFactory,
    void Function(QrCode, QrCodeGraphics)? onBeforeRender,
    void Function(QrCode, QrCodeGraphics)? onAfterRender,
  }) {
    return QrCodeConfig(
      shape: shape ?? this.shape,
      color: color ?? this.color,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      gradientVertical: gradientVertical ?? this.gradientVertical,
      squareSize: squareSize ?? this.squareSize,
      radius: radius ?? this.radius,
      innerSpacing: innerSpacing ?? this.innerSpacing,
      logo: logo ?? this.logo,
      logoWidth: logoWidth ?? this.logoWidth,
      logoHeight: logoHeight ?? this.logoHeight,
      clearLogoArea: clearLogoArea ?? this.clearLogoArea,
      errorCorrectionLevel: errorCorrectionLevel ?? this.errorCorrectionLevel,
      maskPattern: maskPattern ?? this.maskPattern,
      informationDensity: informationDensity ?? this.informationDensity,
      canvasSize: canvasSize ?? this.canvasSize,
      margin: margin ?? this.margin,
      xOffset: xOffset ?? this.xOffset,
      yOffset: yOffset ?? this.yOffset,
      colorFunction: colorFunction ?? this.colorFunction,
      shapeFunction: shapeFunction ?? this.shapeFunction,
      graphicsFactory: graphicsFactory ?? this.graphicsFactory,
      onBeforeRender: onBeforeRender ?? this.onBeforeRender,
      onAfterRender: onAfterRender ?? this.onAfterRender,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is QrCodeConfig &&
            shape == other.shape &&
            color == other.color &&
            backgroundColor == other.backgroundColor &&
            gradientEnd == other.gradientEnd &&
            gradientVertical == other.gradientVertical &&
            squareSize == other.squareSize &&
            radius == other.radius &&
            innerSpacing == other.innerSpacing &&
            identical(logo, other.logo) &&
            logoWidth == other.logoWidth &&
            logoHeight == other.logoHeight &&
            clearLogoArea == other.clearLogoArea &&
            errorCorrectionLevel == other.errorCorrectionLevel &&
            maskPattern == other.maskPattern &&
            informationDensity == other.informationDensity &&
            canvasSize == other.canvasSize &&
            margin == other.margin &&
            xOffset == other.xOffset &&
            yOffset == other.yOffset &&
            identical(colorFunction, other.colorFunction) &&
            identical(shapeFunction, other.shapeFunction) &&
            identical(graphicsFactory, other.graphicsFactory) &&
            identical(onBeforeRender, other.onBeforeRender) &&
            identical(onAfterRender, other.onAfterRender);
  }

  @override
  int get hashCode => Object.hashAll([
    shape,
    color,
    backgroundColor,
    gradientEnd,
    gradientVertical,
    squareSize,
    radius,
    innerSpacing,
    logo,
    logoWidth,
    logoHeight,
    clearLogoArea,
    errorCorrectionLevel,
    maskPattern,
    informationDensity,
    canvasSize,
    margin,
    xOffset,
    yOffset,
    colorFunction,
    shapeFunction,
    graphicsFactory,
    onBeforeRender,
    onAfterRender,
  ]);
}
