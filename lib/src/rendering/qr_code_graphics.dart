import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart'
    show ImageConfiguration, ImageInfo, ImageProvider, ImageStreamListener;

/// Picture-recorder-backed canvas for QR raster output.
/// 基于 PictureRecorder 的 QR 光栅输出画布。
class QrCodeGraphics {
  /// Creates a graphics buffer of [width] x [height] pixels.
  /// 创建 [width] x [height] 像素的图形缓冲区。
  QrCodeGraphics(this.width, this.height) {
    _recorder = ui.PictureRecorder();
    _canvas = ui.Canvas(_recorder);
  }

  /// Buffer width in pixels. 缓冲区宽度（像素）。
  final int width;

  /// Buffer height in pixels. 缓冲区高度（像素）。
  final int height;

  late ui.PictureRecorder _recorder;
  late ui.Canvas _canvas;
  bool _changed = false;
  ui.Picture? _picture;
  final Map<int, ui.Paint> _paintCache = {};
  final Map<Uint8List, ui.Image> _imageCache = {};

  /// Underlying Flutter canvas. 底层 Flutter 画布。
  ui.Canvas get canvas => _canvas;

  /// Whether any draw call modified the buffer since last [reset].
  /// 自上次 [reset] 以来是否有绘制修改了缓冲区。
  bool changed() => _changed;

  void reset() {
    if (_changed) {
      _changed = false;
      _picture = null;
      _recorder = ui.PictureRecorder();
      _canvas = ui.Canvas(_recorder);
    }
  }

  List<int> dimensions() => [width, height];

  Future<Uint8List> getBytes([String format = 'PNG']) async {
    if (format.toUpperCase() != 'PNG') {
      throw UnsupportedError('Unsupported format: $format');
    }
    final image = await toImage();
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('Failed to encode image as PNG');
    }
    return byteData.buffer.asUint8List();
  }

  List<String> availableFormats() => ['PNG'];

  Future<ui.Image> nativeImage() => toImage();

  Future<ui.Image> toImage() async {
    _picture ??= _recorder.endRecording();
    return _picture!.toImage(width, height);
  }

  ui.Picture get picture {
    _picture ??= _recorder.endRecording();
    return _picture!;
  }

  ui.Paint _paint(ui.Color color, {double? strokeWidth}) {
    final key = color.toARGB32() ^ (strokeWidth?.hashCode ?? 0);
    return _paintCache.putIfAbsent(key, () {
      final paint = ui.Paint()
        ..isAntiAlias = true
        ..color = color;
      if (strokeWidth != null && strokeWidth > 0) {
        paint.style = ui.PaintingStyle.stroke;
        paint.strokeWidth = strokeWidth;
        paint.strokeCap = ui.StrokeCap.round;
        paint.strokeJoin = ui.StrokeJoin.round;
      } else {
        paint.style = ui.PaintingStyle.fill;
      }
      return paint;
    });
  }

  void drawLine(int x1, int y1, int x2, int y2, ui.Color color, double thickness) {
    _changed = true;
    _canvas.drawLine(
      ui.Offset(x1.toDouble(), y1.toDouble()),
      ui.Offset(x2.toDouble(), y2.toDouble()),
      _paint(color, strokeWidth: thickness),
    );
  }

  void drawRect(int x, int y, int width, int height, ui.Color color, double thickness) {
    _changed = true;
    final halfThickness = (thickness / 2).round().clamp(0, 999999);
    _canvas.drawRect(
      ui.Rect.fromLTWH(
        (x + halfThickness).toDouble(),
        (y + halfThickness).toDouble(),
        (width - halfThickness * 2).toDouble(),
        (height - halfThickness * 2).toDouble(),
      ),
      _paint(color, strokeWidth: thickness),
    );
  }

  void fillRect(int x, int y, int width, int height, ui.Color color) {
    _changed = true;
    _canvas.drawRect(
      ui.Rect.fromLTWH(x.toDouble(), y.toDouble(), width.toDouble(), height.toDouble()),
      _paint(color),
    );
  }

  void fill(ui.Color color) {
    fillRect(0, 0, width, height, color);
  }

  void drawRoundRect(
    int x,
    int y,
    int width,
    int height,
    int borderRadius,
    ui.Color color,
    double thickness,
  ) {
    _changed = true;
    final halfThickness = (thickness / 2).round().clamp(0, 999999);
    final rrect = ui.RRect.fromRectAndRadius(
      ui.Rect.fromLTWH(
        (x + halfThickness).toDouble(),
        (y + halfThickness).toDouble(),
        (width - halfThickness * 2).toDouble(),
        (height - halfThickness * 2).toDouble(),
      ),
      ui.Radius.circular(borderRadius.toDouble()),
    );
    _canvas.drawRRect(rrect, _paint(color, strokeWidth: thickness));
  }

  void fillRoundRect(int x, int y, int width, int height, int borderRadius, ui.Color color) {
    _changed = true;
    final rrect = ui.RRect.fromRectAndRadius(
      ui.Rect.fromLTWH(x.toDouble(), y.toDouble(), width.toDouble(), height.toDouble()),
      ui.Radius.circular(borderRadius.toDouble()),
    );
    _canvas.drawRRect(rrect, _paint(color));
  }

  void drawEllipse(int x, int y, int width, int height, ui.Color color, double thickness) {
    _changed = true;
    final halfThickness = (thickness / 2).round().clamp(0, 999999);
    _canvas.drawOval(
      ui.Rect.fromLTWH(
        (x + halfThickness).toDouble(),
        (y + halfThickness).toDouble(),
        (width - 1 - halfThickness * 2).toDouble(),
        (height - 1 - halfThickness * 2).toDouble(),
      ),
      _paint(color, strokeWidth: thickness),
    );
  }

  void fillEllipse(int x, int y, int width, int height, ui.Color color) {
    _changed = true;
    _canvas.drawOval(
      ui.Rect.fromLTWH(x.toDouble(), y.toDouble(), width.toDouble(), height.toDouble()),
      _paint(color),
    );
  }

  void drawImage(Uint8List? rawData, int x, int y, {int? drawWidth, int? drawHeight}) {
    if (rawData == null || rawData.isEmpty) return;
    final image = _imageCache[rawData];
    if (image != null) {
      _drawUiImage(image, x, y, drawWidth, drawHeight);
    }
  }

  void drawUiImage(ui.Image image, int x, int y, {int? drawWidth, int? drawHeight}) {
    _drawUiImage(image, x, y, drawWidth, drawHeight);
  }

  void _drawUiImage(ui.Image image, int x, int y, int? drawWidth, int? drawHeight) {
    _changed = true;
    final w = (drawWidth ?? image.width).toDouble();
    final h = (drawHeight ?? image.height).toDouble();
    _canvas.drawImageRect(
      image,
      ui.Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      ui.Rect.fromLTWH(x.toDouble(), y.toDouble(), w, h),
      ui.Paint(),
    );
  }

  Future<void> cacheImage(Uint8List rawData) async {
    if (_imageCache.containsKey(rawData)) return;
    final codec = await ui.instantiateImageCodec(rawData);
    final frame = await codec.getNextFrame();
    _imageCache[rawData] = frame.image;
  }

  /// Resolves an [ImageProvider] to a [ui.Image].
  /// 将 [ImageProvider] 解析为 [ui.Image]。
  static Future<ui.Image> resolveImageProvider(ImageProvider provider) async {
    final completer = Completer<ui.Image>();
    final stream = provider.resolve(ImageConfiguration.empty);
    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (ImageInfo info, bool _) {
        if (!completer.isCompleted) completer.complete(info.image);
        stream.removeListener(listener);
      },
      onError: (Object error, StackTrace? stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
        stream.removeListener(listener);
      },
    );
    stream.addListener(listener);
    return completer.future;
  }
}
