import 'dart:ui';

import '../../core/qr_code.dart';
import '../../encoding/qr_code_square.dart';
import '../../rendering/qr_code_graphics.dart';

/// Strategy for foreground and background colors per module.
/// 按模块决定前景与背景色的策略。
abstract class QrCodeColorFunction {
  Color colorFn(QrCodeSquare square, QrCode qrCode, QrCodeGraphics qrCodeGraphics) => square.dark
      ? fg(square.row, square.col, qrCode, qrCodeGraphics)
      : bg(square.row, square.col, qrCode, qrCodeGraphics);

  void beforeRender(QrCode qrCode, QrCodeGraphics qrCodeGraphics) {}

  Color fg(int row, int col, QrCode qrCode, QrCodeGraphics qrCodeGraphics);

  Color bg(int row, int col, QrCode qrCode, QrCodeGraphics qrCodeGraphics);
}
