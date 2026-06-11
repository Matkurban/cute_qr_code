import 'package:flutter/material.dart' show Color, Colors;

import '../qr_code.dart';
import '../render/qr_code_graphics.dart';
import 'qr_code_color_function.dart';

class DefaultColorFunction extends QrCodeColorFunction {
  DefaultColorFunction({this.foreground = Colors.black, this.background = Colors.transparent});

  final Color foreground;

  final Color background;

  @override
  Color fg(int row, int col, QrCode qrCode, QrCodeGraphics qrCodeGraphics) => foreground;

  @override
  Color bg(int row, int col, QrCode qrCode, QrCodeGraphics qrCodeGraphics) => background;
}
