import 'package:flutter/material.dart' show Color, Colors;

import '../qr_code.dart';
import '../render/qr_code_graphics.dart';
import 'qr_code_color_function.dart';

class LinearGradientColorFunction extends QrCodeColorFunction {
  LinearGradientColorFunction({
    required this.startForegroundColor,
    required this.endForegroundColor,
    this.backgroundColor = Colors.white,
    this.vertical = true,
  });

  final Color startForegroundColor;

  final Color endForegroundColor;

  final Color backgroundColor;

  bool vertical;

  @override
  Color fg(int row, int col, QrCode qrCode, QrCodeGraphics qrCodeGraphics) {
    final pct = (vertical ? row : col) / qrCode.rawData.length;
    return Color.lerp(startForegroundColor, endForegroundColor, pct) ?? startForegroundColor;
  }

  @override
  Color bg(int row, int col, QrCode qrCode, QrCodeGraphics qrCodeGraphics) => backgroundColor;
}
