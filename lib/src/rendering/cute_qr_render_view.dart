import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../core/qr_code.dart';

/// Render object that displays a [QrCode] scaled to the smallest parent constraint side.
/// 将 [QrCode] 缩放至父级约束最短边的渲染对象。
class CuteQrRenderView extends RenderBox {
  /// Creates a render view for [qrCode].
  /// 为 [qrCode] 创建渲染视图。
  CuteQrRenderView({required this._qrCode, this._prepared = true});

  QrCode _qrCode;
  bool _prepared;

  /// Current QR model. 当前 QR 模型。
  QrCode get qrCode => _qrCode;

  set qrCode(QrCode value) {
    if (_qrCode == value) return;
    _qrCode = value;
    markNeedsPaint();
  }

  /// Whether async [QrCode.prepare] has finished.
  /// 异步 [QrCode.prepare] 是否已完成。
  bool get prepared => _prepared;

  set prepared(bool value) {
    if (_prepared == value) return;
    _prepared = value;
    markNeedsPaint();
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void performLayout() {
    size = _sizeForConstraints(constraints);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) => _sizeForConstraints(constraints);

  Size _sizeForConstraints(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    if (width.isFinite && height.isFinite) {
      return Size.square(math.min(width, height));
    }
    if (width.isFinite) {
      return Size.square(width);
    }
    if (height.isFinite) {
      return Size.square(height);
    }
    return Size.zero;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (size.isEmpty) return;

    context.canvas.save();
    if (offset != Offset.zero) {
      context.canvas.translate(offset.dx, offset.dy);
    }

    _qrCode.paintOntoCanvas(context.canvas, size);
    context.canvas.restore();
    context.setIsComplexHint();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<QrCode>('qrCode', _qrCode));
    properties.add(DiagnosticsProperty<bool>('prepared', _prepared));
  }
}
