import 'package:cute_qr_code/cute_qr_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QrCode encoding', () {
    test('encodes hello world matrix', () {
      final qr = QrCode.create(data: 'Hello world!', config: const QrCodeConfig(squareSize: 10));
      expect(qr.rawData.length, greaterThan(0));
      expect(qr.rawData.length, qr.rawData.first.length);
    });

    test('renderToBytes returns PNG header', () async {
      final qr = QrCode.roundedSquares(
        data: 'Hello world!',
        config: const QrCodeConfig(color: Colors.blue, squareSize: 10),
      );
      final bytes = await qr.renderToBytes();
      expect(bytes.length, greaterThan(8));
      expect(bytes[0], 0x89);
      expect(bytes[1], 0x50);
      expect(bytes[2], 0x4E);
      expect(bytes[3], 0x47);
    });

    test('processor plain render dimensions', () {
      final processor = QrCodeProcessor('123456');
      final graphics = processor.render(cellSize: 25, darkColor: Colors.red);
      expect(graphics.width, processor.computeImageSizeFromRawData());
      expect(graphics.height, graphics.width);
    });
  });

  group('QrCodeConfig', () {
    test('gradient config uses linear color function', () {
      final qr = QrCode.create(
        data: 'test',
        config: const QrCodeConfig(gradientEnd: Colors.red, color: Colors.blue),
      );
      expect(qr.colorFn, isA<LinearGradientColorFunction>());
    });

    test('copyWith overrides fields', () {
      const base = QrCodeConfig(squareSize: 8);
      final updated = base.copyWith(color: Colors.green, squareSize: 12);
      expect(updated.color, Colors.green);
      expect(updated.squareSize, 12);
    });

    test('fitIntoArea adjusts square size', () {
      final qr = QrCode.circles(data: 'fit', config: const QrCodeConfig(squareSize: 25));
      qr.fitIntoArea(200, 200);
      expect(qr.squareSize, lessThan(25));
      expect(qr.canvasSize, 200);
    });

    test('repeated fitIntoArea and render still draws', () {
      final qr = QrCode.create(data: 'Hello', config: const QrCodeConfig(squareSize: 8));
      qr.fitIntoArea(200, 200);
      qr.render();
      expect(qr.graphics.changed(), isTrue);

      qr.fitIntoArea(200, 200);
      qr.render();
      expect(qr.graphics.changed(), isTrue);
    });
  });
}
