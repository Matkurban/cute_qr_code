import 'package:flutter/widgets.dart';

import '../core/qr_code.dart';

/// [CustomPainter] that scales [qrCode] via [QrCode.paintOntoCanvas].
/// 通过 [QrCode.paintOntoCanvas] 缩放绘制 [qrCode] 的 [CustomPainter]。
class QrCodePainter extends CustomPainter {
  QrCodePainter(this.qrCode, {this.prepared = false});

  /// QR model to paint. 要绘制的 QR 模型。
  final QrCode qrCode;

  /// Whether logo [prepare] has completed (affects repaint only).
  /// Logo [prepare] 是否已完成（仅影响重绘）。
  final bool prepared;

  @override
  void paint(Canvas canvas, Size size) {
    qrCode.paintOntoCanvas(canvas, size);
  }

  @override
  bool shouldRepaint(covariant QrCodePainter oldDelegate) =>
      oldDelegate.qrCode != qrCode || oldDelegate.prepared != prepared;
}
