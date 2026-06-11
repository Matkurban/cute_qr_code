import 'qr_code_graphics.dart';

class QrCodeGraphicsFactory {
  QrCodeGraphics newGraphicsSquare(int size) => newGraphics(size, size);

  QrCodeGraphics newGraphics(int width, int height) => QrCodeGraphics(width, height);
}
