import 'package:flutter/material.dart' show Color, Colors, ImageProvider;

import '../core/qr_code.dart';
import '../core/qr_code_shapes_enum.dart';
import '../encoding/qr_code_enums.dart';
import '../encoding/qr_code_processor.dart';
import '../painting/color/qr_code_color_function.dart';
import '../painting/shape/qr_code_shape_function.dart';
import '../rendering/qr_code_graphics.dart';
import '../rendering/qr_code_graphics_factory.dart';

/// Style and encoding options for [QrCode.create] and [CuteQrCode].
/// [QrCode.create] 与 [CuteQrCode] 的样式与编码配置。
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
    this.strictTypeNumber = false,
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

  /// Module shape preset. 模块形状预设。
  final QrCodeShapesEnum shape;

  /// Foreground (dark module) color. 前景（深色模块）颜色。
  final Color color;

  /// Background color behind modules. 模块背后的背景色。
  final Color backgroundColor;

  /// When set, enables linear gradient from [color] to this color. 设置后从 [color] 到该色的线性渐变。
  final Color? gradientEnd;

  /// Gradient direction: vertical if true, horizontal if false. 渐变方向：true 为垂直。
  final bool gradientVertical;

  /// Module pixel size for PNG export (widgets use container size). PNG 导出时的模块像素尺寸（Widget 用容器尺寸）。
  final int squareSize;

  /// Corner radius for rounded-square shape; auto if null. 圆角方形的圆角半径；null 为自动。
  final int? radius;

  /// Gap between modules; auto per shape if null. 模块间距；null 时按形状自动。
  final int? innerSpacing;

  /// Center logo image provider. 居中 Logo 图片。
  final ImageProvider? logo;

  /// Logo draw width; image width if null. Logo 绘制宽度；null 用图片宽度。
  final double? logoWidth;

  /// Logo draw height; image height if null. Logo 绘制高度；null 用图片高度。
  final double? logoHeight;

  /// Skip modules under the logo area. 是否跳过 Logo 区域的模块。
  final bool clearLogoArea;

  /// Error correction level (L/M/Q/H). 纠错等级（L/M/Q/H）。
  final ErrorCorrectionLevel errorCorrectionLevel;

  /// Mask pattern for the encoded matrix. 编码矩阵的掩码模式。
  final MaskPattern maskPattern;

  /// QR version 1–40; null or 0 auto-selects minimum fitting version.
  /// QR 版本 1–40；null 或 0 自动选择最小可用版本。
  final int? informationDensity;

  /// Alias for [informationDensity] (ISO type number). [informationDensity] 的别名（ISO 类型号）。
  int? get typeNumber => informationDensity;

  /// If true, explicit [informationDensity] too small throws instead of upgrading.
  /// 为 true 时，显式版本过小将抛错而非自动升级。
  final bool strictTypeNumber;

  /// Fixed canvas pixels; 0 computes from [squareSize] and matrix size. 固定画布像素；0 由 [squareSize] 与矩阵计算。
  final int canvasSize;

  /// Quiet-zone margin in pixels (added via resize). 静默区边距（像素，通过 resize 添加）。
  final int margin;

  /// Horizontal draw offset in pixels. 水平绘制偏移（像素）。
  final int xOffset;

  /// Vertical draw offset in pixels. 垂直绘制偏移（像素）。
  final int yOffset;

  /// Custom per-module coloring; overrides [color]/gradient when set. 自定义模块着色；设置后覆盖 [color]/渐变。
  final QrCodeColorFunction? colorFunction;

  /// Custom module shape renderer; required for [QrCodeShapesEnum.custom]. 自定义模块形状；[QrCodeShapesEnum.custom] 时必填。
  final QrCodeShapeFunction? shapeFunction;

  /// Backend for raster output (default in-memory canvas). 光栅输出后端（默认内存画布）。
  final QrCodeGraphicsFactory? graphicsFactory;

  /// Called on [QrCode] before modules are drawn. 绘制模块前回调。
  final void Function(QrCode, QrCodeGraphics)? onBeforeRender;

  /// Called on [QrCode] after modules are drawn. 绘制模块后回调。
  final void Function(QrCode, QrCodeGraphics)? onAfterRender;

  /// Returns a copy with the given fields replaced. 返回替换指定字段后的副本。
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
    bool? strictTypeNumber,
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
      strictTypeNumber: strictTypeNumber ?? this.strictTypeNumber,
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
            strictTypeNumber == other.strictTypeNumber &&
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
    strictTypeNumber,
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
