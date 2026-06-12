import '../color/qr_code_color_function.dart';
import '../internals/qr_code_square.dart';
import '../qr_code.dart';
import '../render/qr_code_graphics.dart';

abstract class QrCodeShapeFunction {
  void resize(int newSquareSize);

  void beforeRender(QrCode qrCode, QrCodeGraphics qrCodeGraphics) {}

  void renderSquare(
    int x,
    int y,
    QrCodeColorFunction colorFn,
    QrCodeSquare square,
    QrCodeGraphics canvas,
    QrCode qrCode,
  );

  void renderControlSquare(
    int xOffset,
    int yOffset,
    QrCodeColorFunction colorFn,
    QrCodeSquare square,
    QrCodeGraphics canvas,
    QrCode qrCode,
  );
}
