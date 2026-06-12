import 'package:flutter/material.dart' show Color, Colors;

import '../../core/qr_code.dart';
import '../../rendering/qr_code_graphics.dart';
import 'qr_code_color_function.dart';

/// Linear gradient across dark modules; solid background.
/// 深色模块线性渐变；背景为纯色。
class LinearGradientColorFunction extends QrCodeColorFunction {
  LinearGradientColorFunction({
    required this.startForegroundColor,
    required this.endForegroundColor,
    this.backgroundColor = Colors.white,
    this.vertical = true,
  });

  /// Gradient start color for dark modules. 深色模块渐变起点色。
  final Color startForegroundColor;

  /// Gradient end color for dark modules. 深色模块渐变终点色。
  final Color endForegroundColor;

  /// Background color for light modules. 浅色模块背景色。
  final Color backgroundColor;

  /// Whether the gradient runs vertically (else horizontally).
  /// 渐变是否沿垂直方向（否则为水平）。
  bool vertical;

  @override
  Color fg(int row, int col, QrCode qrCode, QrCodeGraphics qrCodeGraphics) {
    final pct = (vertical ? row : col) / qrCode.rawData.length;
    return Color.lerp(startForegroundColor, endForegroundColor, pct) ?? startForegroundColor;
  }

  @override
  Color bg(int row, int col, QrCode qrCode, QrCodeGraphics qrCodeGraphics) => backgroundColor;
}
