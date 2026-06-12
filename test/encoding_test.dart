import 'package:cute_qr_code/cute_qr_code.dart';
import 'package:cute_qr_code/src/encoding/qr_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QrUtil data type detection', () {
    test('numeric strings use numbers mode', () {
      expect(QrUtil.getDataType('12345'), QrCodeDataType.numbers);
    });

    test('uppercase alphanumeric strings use upperAlphaNum mode', () {
      expect(QrUtil.getDataType('HELLO WORLD'), QrCodeDataType.upperAlphaNum);
    });

    test('mixed case urls use default 8-bit mode', () {
      expect(QrUtil.getDataType('https://example.com/path?foo=bar'), QrCodeDataType.defaultType);
    });
  });

  group('minTypeForData', () {
    test('large payload selects version above 3', () {
      final data = 'https://example.com/${'a' * 64}';
      final type = QrCodeProcessor.minTypeForData(data, ErrorCorrectionLevel.low);
      expect(type, greaterThan(3));
      final qr = QrCode.create(data: data);
      expect(qr.informationDensity, type);
    });

    test('explicit type 3 auto-upgrades by default', () {
      final data = 'https://example.com/${'a' * 64}';
      final qr = QrCode.create(data: data, config: const QrCodeConfig(informationDensity: 3));
      expect(qr.informationDensity, greaterThan(3));
    });

    test('strict type 3 throws for large payload', () {
      final data = 'https://example.com/${'a' * 64}';
      expect(
        () => QrCode.create(
          data: data,
          config: const QrCodeConfig(informationDensity: 3, strictTypeNumber: true),
        ),
        throwsA(isA<InsufficientInformationDensityException>()),
      );
    });

    test('informationDensity 0 selects auto', () {
      final data = 'https://example.com/${'a' * 64}';
      final auto = QrCodeProcessor.minTypeForData(data, ErrorCorrectionLevel.low);
      final qr = QrCode.create(data: data, config: const QrCodeConfig(informationDensity: 0));
      expect(qr.informationDensity, auto);
    });
  });
}
