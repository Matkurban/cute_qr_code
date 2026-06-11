import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart' show ImageProvider;

import 'color/default_color_function.dart';
import 'color/qr_code_color_function.dart';
import 'internals/qr_code_square.dart';
import 'qr_code_config.dart';
import 'qr_code_create.dart';
import 'qr_code_hook.dart';
import 'qr_code_shapes_enum.dart';
import 'raw/qr_code_enums.dart';
import 'raw/qr_code_processor.dart';
import 'raw/qr_code_raw_data.dart';
import 'render/qr_code_graphics.dart';
import 'render/qr_code_graphics_factory.dart';
import 'shape/default_shape_function.dart';
import 'shape/qr_code_shape_function.dart';

class QrCode {
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
        informationDensity ?? QrCodeProcessor.infoDensityForDataAndEcl(data, errorCorrectionLevel);
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

  static const int defaultSquareSize = QrCodeProcessor.defaultCellSize;

  static const int defaultQrCodeSize = 0;

  static const int defaultXOffset = 0;

  static const int defaultYOffset = 0;

  final String data;

  final int xOffset;

  final int yOffset;

  final QrCodeColorFunction colorFn;

  final QrCodeShapeFunction shapeFn;

  final QrCodeGraphicsFactory graphicsFactory;

  final ErrorCorrectionLevel errorCorrectionLevel;

  late final int informationDensity;

  final MaskPattern maskPattern;

  late int squareSize;

  late QrCodeProcessor qrCodeProcessor;

  late QrCodeRawData rawData;

  late int canvasSize;

  late QrCodeGraphics graphics;

  final QrCodeHook _doBefore;

  final QrCodeHook _doAfter;

  final ImageProvider? logoProvider;

  final double? logoWidth;

  final double? logoHeight;

  ui.Image? resolvedLogo;

  int? logoDrawWidth;

  int? logoDrawHeight;

  static QrCode create({required String data, QrCodeConfig config = const QrCodeConfig()}) =>
      assembleQrCode(data: data, config: config);

  static QrCode squares({required String data, QrCodeConfig config = const QrCodeConfig()}) =>
      create(
        data: data,
        config: config.copyWith(shape: QrCodeShapesEnum.square),
      );

  static QrCode circles({required String data, QrCodeConfig config = const QrCodeConfig()}) =>
      create(
        data: data,
        config: config.copyWith(shape: QrCodeShapesEnum.circle),
      );

  static QrCode roundedSquares({
    required String data,
    QrCodeConfig config = const QrCodeConfig(),
  }) => create(
    data: data,
    config: config.copyWith(shape: QrCodeShapesEnum.roundedSquare),
  );

  static QrCode custom({required String data, required QrCodeConfig config}) {
    assert(config.shapeFunction != null, 'QrCode.custom requires config.shapeFunction');
    return create(
      data: data,
      config: config.copyWith(shape: QrCodeShapesEnum.custom),
    );
  }

  QrCode resize(int size) {
    canvasSize = size;
    _clearRenderedFlags();
    graphics = graphicsFactory.newGraphicsSquare(canvasSize);
    return this;
  }

  QrCode fitIntoArea(int width, int height) {
    final reference = width < height ? width : height;
    squareSize = (reference / rawData.length).floor();
    shapeFn.resize(squareSize);
    canvasSize = reference;
    _clearRenderedFlags();
    graphics = graphicsFactory.newGraphicsSquare(canvasSize);
    return this;
  }

  Future<void> prepare() async {
    final provider = logoProvider;
    if (provider == null) return;

    final image = await QrCodeGraphics.resolveImageProvider(provider);
    resolvedLogo = image;
    logoDrawWidth = (logoWidth ?? image.width.toDouble()).round();
    logoDrawHeight = (logoHeight ?? image.height.toDouble()).round();
  }

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
