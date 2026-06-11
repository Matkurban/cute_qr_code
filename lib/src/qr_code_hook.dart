import 'qr_code.dart';
import 'render/qr_code_graphics.dart';

typedef QrCodeHook =
    void Function(QrCode qrCode, QrCodeGraphics graphics, int xOffset, int yOffset);

void emptyQrCodeHook(QrCode qr, QrCodeGraphics g, int x, int y) {}
