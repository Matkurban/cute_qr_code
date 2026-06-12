import 'package:cute_qr_code/cute_qr_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('CuteQrRenderView uses shortest bounded constraint side', () {
    final qr = QrCode.create(data: 'layout-test', config: const QrCodeConfig(squareSize: 8));
    final view = CuteQrRenderView(qrCode: qr);
    view.layout(const BoxConstraints.tightFor(width: 200, height: 100));
    expect(view.size, const Size(100, 100));

    view.layout(const BoxConstraints.tightFor(width: 720, height: 120));
    expect(view.size, const Size(120, 120));
  });

  testWidgets('encoding error does not throw with errorBuilder', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CuteQrCode.data(
          data: 'https://example.com/${'a' * 64}',
          config: const QrCodeConfig(informationDensity: 3, strictTypeNumber: true),
          errorBuilder: (context, error, stackTrace) {
            return const Text('qr-error');
          },
        ),
      ),
    );
    await tester.pump();

    expect(find.text('qr-error'), findsOneWidget);
  });
}
