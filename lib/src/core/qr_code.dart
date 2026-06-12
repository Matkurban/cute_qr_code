import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart' show Canvas, ImageProvider, Size;

import '../config/qr_code_config.dart';
import '../encoding/qr_code_enums.dart';
import '../encoding/qr_code_processor.dart';
import '../encoding/qr_code_raw_data.dart';
import '../encoding/qr_code_square.dart';
import '../painting/color/default_color_function.dart';
import '../painting/color/qr_code_color_function.dart';
import '../painting/shape/default_shape_function.dart';
import '../painting/shape/qr_code_shape_function.dart';
import '../rendering/qr_code_graphics.dart';
import '../rendering/qr_code_graphics_factory.dart';
import 'qr_code_create.dart';
import 'qr_code_hook.dart';
import 'qr_code_shapes_enum.dart';

/// Encoded and styled QR symbol with rendering helpers.
/// 已编码且可样式化的 QR 符号，提供渲染辅助方法。
class QrCode {
  /// Creates a [QrCode] from raw [data] and styling parameters.
  /// 根据原始 [data] 与样式参数创建 [QrCode]。
  QrCode({
    required this.data,
    int squareSize = defaultSquareSize,
    int canvasSize = defaultQrCodeSize,
    this.xOffset = defaultXOffset,
    this.yOffset = defaultYOffset,
    QrCodeColorFunction? colorFn,
    QrCodeShapeFunction? shapeFn,
    QrCodeGraphicsFactory? graphicsFactory,
    this.errorCorrectionLevel = ErrorCorrectionLevel.low,
    int? informationDensity,
    this.maskPattern = MaskPattern.pattern000,
    QrCodeHook? doBefore,
    QrCodeHook? doAfter,
    this.logoProvider,
    this.logoWidth,
    this.logoHeight,
  }) : colorFn = colorFn ?? DefaultColorFunction(),
       shapeFn = shapeFn ?? DefaultShapeFunction(squareSize, innerSpace: 0),
       graphicsFactory = graphicsFactory ?? QrCodeGraphicsFactory(),
       _doBefore = doBefore ?? emptyQrCodeHook,
       _doAfter = doAfter ?? emptyQrCodeHook {
    this.squareSize = squareSize;
    final density =
        informationDensity ?? QrCodeProcessor.minTypeForData(data, errorCorrectionLevel);
    this.informationDensity = density;

    qrCodeProcessor = QrCodeProcessor(
      data,
      errorCorrectionLevel: errorCorrectionLevel,
      graphicsFactory: this.graphicsFactory,
    );
    rawData = qrCodeProcessor.encode(type: density, maskPattern: maskPattern);
    this.canvasSize = canvasSize > defaultQrCodeSize
        ? canvasSize
        : qrCodeProcessor.computeImageSize(this.squareSize, rawData.length);
    graphics = this.graphicsFactory.newGraphicsSquare(this.canvasSize);
  }

  /// Default module pixel size used during encoding layout.
  /// 编码布局时使用的默认模块像素尺寸。
  static const int defaultSquareSize = QrCodeProcessor.defaultCellSize;

  /// Sentinel canvas size; actual size is computed from modules.
  /// 画布尺寸哨兵值；实际尺寸由模块数计算。
  static const int defaultQrCodeSize = 0;

  /// Default horizontal offset when painting.
  /// 绘制时的默认水平偏移。
  static const int defaultXOffset = 0;

  /// Default vertical offset when painting.
  /// 绘制时的默认垂直偏移。
  static const int defaultYOffset = 0;

  /// Payload string encoded into the symbol.
  /// 编码进符号的载荷字符串。
  final String data;

  /// Horizontal paint offset in pixels.
  /// 水平绘制偏移（像素）。
  final int xOffset;

  /// Vertical paint offset in pixels.
  /// 垂直绘制偏移（像素）。
  final int yOffset;

  /// Resolves foreground/background colors per module.
  /// 按模块解析前景/背景色。
  final QrCodeColorFunction colorFn;

  /// Draws each module shape (square, circle, rounded, etc.).
  /// 绘制各模块形状（方形、圆形、圆角等）。
  final QrCodeShapeFunction shapeFn;

  /// Factory for raster backing stores used during render.
  /// 渲染时使用的光栅画布工厂。
  final QrCodeGraphicsFactory graphicsFactory;

  /// Reed–Solomon error correction level for encoding.
  /// 编码所用的 RS 纠错等级。
  final ErrorCorrectionLevel errorCorrectionLevel;

  /// QR version (type number, 1–40) used for this symbol.
  /// 本符号使用的 QR 版本号（类型号，1–40）。
  late final int informationDensity;

  /// Mask pattern applied during matrix setup.
  /// 矩阵设置时应用的掩码图案。
  final MaskPattern maskPattern;

  /// Pixel size of one module in the internal buffer.
  /// 内部缓冲区中单个模块的像素尺寸。
  late int squareSize;

  /// Encoder used to build [rawData].
  /// 用于构建 [rawData] 的编码器。
  late QrCodeProcessor qrCodeProcessor;

  /// Module matrix after encoding.
  /// 编码后的模块矩阵。
  late QrCodeRawData rawData;

  /// Output canvas side length in pixels.
  /// 输出画布边长（像素）。
  late int canvasSize;

  /// Default graphics buffer for [render].
  /// [render] 使用的默认图形缓冲区。
  late QrCodeGraphics graphics;

  final QrCodeHook _doBefore;

  final QrCodeHook _doAfter;

  /// Optional center logo image provider.
  /// 可选的中心 Logo 图片提供器。
  final ImageProvider? logoProvider;

  /// Logo draw width in pixels; defaults to image width.
  /// Logo 绘制宽度（像素）；默认取图片宽度。
  final double? logoWidth;

  /// Logo draw height in pixels; defaults to image height.
  /// Logo 绘制高度（像素）；默认取图片高度。
  final double? logoHeight;

  /// Resolved logo image after [prepare].
  /// [prepare] 后解析得到的 Logo 图片。
  ui.Image? resolvedLogo;

  /// Computed logo width used when drawing.
  /// 绘制时使用的 Logo 宽度。
  int? logoDrawWidth;

  /// Computed logo height used when drawing.
  /// 绘制时使用的 Logo 高度。
  int? logoDrawHeight;

  /// Builds a [QrCode] from [data] and [config].
  /// 根据 [data] 与 [config] 构建 [QrCode]。
  static QrCode create({required String data, QrCodeConfig config = const QrCodeConfig()}) =>
      assembleQrCode(data: data, config: config);

  /// Creates a QR code with square modules.
  /// 创建方形模块的 QR 码。
  static QrCode squares({required String data, QrCodeConfig config = const QrCodeConfig()}) =>
      create(
        data: data,
        config: config.copyWith(shape: QrCodeShapesEnum.square),
      );

  /// Creates a QR code with circular modules.
  /// 创建圆形模块的 QR 码。
  static QrCode circles({required String data, QrCodeConfig config = const QrCodeConfig()}) =>
      create(
        data: data,
        config: config.copyWith(shape: QrCodeShapesEnum.circle),
      );

  /// Creates a QR code with rounded-square modules.
  /// 创建圆角方形模块的 QR 码。
  static QrCode roundedSquares({
    required String data,
    QrCodeConfig config = const QrCodeConfig(),
  }) => create(
    data: data,
    config: config.copyWith(shape: QrCodeShapesEnum.roundedSquare),
  );

  /// Creates a QR code with a custom [QrCodeConfig.shapeFunction].
  /// 使用自定义 [QrCodeConfig.shapeFunction] 创建 QR 码。
  static QrCode custom({required String data, required QrCodeConfig config}) {
    assert(config.shapeFunction != null, 'QrCode.custom requires config.shapeFunction');
    return create(
      data: data,
      config: config.copyWith(shape: QrCodeShapesEnum.custom),
    );
  }

  /// Resizes the internal canvas to [size] and clears render flags.
  /// 将内部画布调整为 [size] 并清除渲染标记。
  QrCode resize(int size) {
    canvasSize = size;
    _clearRenderedFlags();
    graphics = graphicsFactory.newGraphicsSquare(canvasSize);
    return this;
  }

  /// Paints the QR code into [canvas] scaled to [size] without permanently resizing this instance.
  /// 将 QR 码绘制到 [canvas] 并按 [size] 缩放，不永久改变本实例尺寸。
  void paintOntoCanvas(Canvas canvas, Size size) {
    final side = size.shortestSide.floor();
    if (side <= 0) return;

    final moduleCount = rawData.length;
    final cellSize = (side / moduleCount).floor();
    if (cellSize <= 0) return;

    final previousSquareSize = squareSize;
    final previousCanvasSize = canvasSize;

    shapeFn.resize(cellSize);
    squareSize = cellSize;
    canvasSize = side;

    final tempGraphics = graphicsFactory.newGraphicsSquare(side);
    _clearRenderedFlags();
    render(qrCodeGraphics: tempGraphics);
    canvas.drawPicture(tempGraphics.picture);

    squareSize = previousSquareSize;
    canvasSize = previousCanvasSize;
    shapeFn.resize(previousSquareSize);
    _clearRenderedFlags();
  }

  /// Adjusts module and canvas size to fit [width] x [height].
  /// 调整模块与画布尺寸以适配 [width] x [height]。
  @Deprecated('Use [paintOntoCanvas] or [CuteQrRenderView] for widget layout.')
  QrCode fitIntoArea(int width, int height) {
    final reference = width < height ? width : height;
    squareSize = (reference / rawData.length).floor();
    shapeFn.resize(squareSize);
    canvasSize = reference;
    _clearRenderedFlags();
    graphics = graphicsFactory.newGraphicsSquare(canvasSize);
    return this;
  }

  /// Resolves [logoProvider] for later drawing in [render].
  /// 解析 [logoProvider]，供 [render] 时绘制 Logo。
  Future<void> prepare() async {
    final provider = logoProvider;
    if (provider == null) return;

    final image = await QrCodeGraphics.resolveImageProvider(provider);
    resolvedLogo = image;
    logoDrawWidth = (logoWidth ?? image.width.toDouble()).round();
    logoDrawHeight = (logoHeight ?? image.height.toDouble()).round();
  }

  /// Renders modules into [qrCodeGraphics] or the default [graphics] buffer.
  /// 将模块渲染到 [qrCodeGraphics] 或默认 [graphics] 缓冲区。
  QrCodeGraphics render({QrCodeGraphics? qrCodeGraphics, int? xOffset, int? yOffset}) {
    final canvas = qrCodeGraphics ?? graphics;
    final x = xOffset ?? this.xOffset;
    final y = yOffset ?? this.yOffset;

    colorFn.beforeRender(this, canvas);
    shapeFn.beforeRender(this, canvas);
    canvas.fill(colorFn.bg(0, 0, this, canvas));
    _doBefore(this, canvas, x, y);
    _draw(x, y, rawData, canvas);
    _doAfter(this, canvas, x, y);
    return canvas;
  }

  /// Renders to encoded image bytes (PNG by default).
  /// 渲染为编码后的图片字节（默认 PNG）。
  Future<Uint8List> renderToBytes({
    QrCodeGraphics? qrCodeGraphics,
    int? xOffset,
    int? yOffset,
    String format = 'PNG',
  }) async {
    await prepare();
    final result = render(qrCodeGraphics: qrCodeGraphics, xOffset: xOffset, yOffset: yOffset);
    return result.getBytes(format);
  }

  /// Clears render flags and resets the graphics buffer.
  /// 清除渲染标记并重置图形缓冲区。
  void reset() {
    _clearRenderedFlags();
    graphics.reset();
  }

  void _clearRenderedFlags() {
    for (final row in rawData) {
      for (final cell in row) {
        cell.rendered = false;
        cell.parent?.rendered = false;
      }
    }
  }

  QrCodeGraphics _draw(int xOffset, int yOffset, QrCodeRawData rawData, QrCodeGraphics canvas) =>
      qrCodeProcessor.renderShaded(
        cellSize: squareSize,
        rawData: rawData,
        qrCodeGraphics: canvas,
        renderer: (x, y, currentSquare, _) {
          final actualSquare = currentSquare.parent ?? currentSquare;

          if (!actualSquare.rendered) {
            switch (currentSquare.squareInfo.type) {
              case QrCodeSquareType.positionProbe:
              case QrCodeSquareType.positionAdjust:
                shapeFn.renderControlSquare(xOffset, yOffset, colorFn, actualSquare, canvas, this);
              default:
                shapeFn.renderSquare(
                  xOffset + x,
                  yOffset + y,
                  colorFn,
                  currentSquare,
                  canvas,
                  this,
                );
            }
            actualSquare.rendered = true;
          }
        },
      );

  @override
  String toString() =>
      'QrCode(data=$data, squareSize=$squareSize, canvasSize=$canvasSize, '
      'xOffset=$xOffset, yOffset=$yOffset, errorCorrectionLevel=$errorCorrectionLevel, '
      'informationDensity=$informationDensity, maskPattern=$maskPattern)';
}
