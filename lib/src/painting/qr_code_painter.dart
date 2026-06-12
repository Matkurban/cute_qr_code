import 'package:flutter/widgets.dart';

import '../qr_code.dart';

class QrCodePainter extends CustomPainter {
  QrCodePainter(this.qrCode, {this.prepared = false});

  final QrCode qrCode;
  final bool prepared;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width.floor();
    final height = size.height.floor();

    qrCode.fitIntoArea(width, height);
    if (prepared) {
      qrCode.render();
    } else {
      qrCode.render();
    }

    canvas.drawPicture(qrCode.graphics.picture);
  }

  @override
  bool shouldRepaint(covariant QrCodePainter oldDelegate) =>
      oldDelegate.qrCode != qrCode || oldDelegate.prepared != prepared;
}
