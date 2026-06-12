import 'dart:ui';

import '../internals/qr_code_square.dart';
import '../qr_code.dart';
import '../render/qr_code_graphics.dart';

abstract class QrCodeColorFunction {
  Color colorFn(QrCodeSquare square, QrCode qrCode, QrCodeGraphics qrCodeGraphics) => square.dark
      ? fg(square.row, square.col, qrCode, qrCodeGraphics)
      : bg(square.row, square.col, qrCode, qrCodeGraphics);

  void beforeRender(QrCode qrCode, QrCodeGraphics qrCodeGraphics) {}

  Color fg(int row, int col, QrCode qrCode, QrCodeGraphics qrCodeGraphics);

  Color bg(int row, int col, QrCode qrCode, QrCodeGraphics qrCodeGraphics);
}
