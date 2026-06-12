import '../../core/qr_code.dart';
import '../../encoding/qr_code_square.dart';
import '../../rendering/qr_code_graphics.dart';
import '../color/qr_code_color_function.dart';

/// Draws individual modules and control patterns onto [QrCodeGraphics].
/// 将各模块与控制图案绘制到 [QrCodeGraphics]。
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
