import 'package:flutter/material.dart' show Color, Colors;

import '../../core/qr_code.dart';
import '../../rendering/qr_code_graphics.dart';
import 'qr_code_color_function.dart';

/// Solid foreground and background colors for all modules.
/// 所有模块使用固定前景与背景色。
class DefaultColorFunction extends QrCodeColorFunction {
  DefaultColorFunction({this.foreground = Colors.black, this.background = Colors.transparent});

  /// Dark module color. 深色模块颜色。
  final Color foreground;

  /// Light module and canvas background color. 浅色模块与画布背景色。
  final Color background;

  @override
  Color fg(int row, int col, QrCode qrCode, QrCodeGraphics qrCodeGraphics) => foreground;

  @override
  Color bg(int row, int col, QrCode qrCode, QrCodeGraphics qrCodeGraphics) => background;
}
