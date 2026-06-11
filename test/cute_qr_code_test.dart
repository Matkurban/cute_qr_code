import 'package:cute_qr_code/cute_qr_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('public API exports work', () {
    expect(QrCode.ofSquares(), isA<QrCodeBuilder>());
    expect(QrCodeBuilder.ofCircles(), isA<QrCodeBuilder>());
    expect(Colors.black.toARGB32(), 0xFF000000);
  });
}
