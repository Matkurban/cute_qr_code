import '../rendering/qr_code_graphics.dart';
import 'qr_code.dart';

/// Callback invoked before or after rendering onto [QrCodeGraphics].
/// 在 [QrCodeGraphics] 上渲染前后调用的钩子。
typedef QrCodeHook =
    void Function(QrCode qrCode, QrCodeGraphics graphics, int xOffset, int yOffset);

/// No-op hook used as default. 默认空操作钩子。
void emptyQrCodeHook(QrCode qr, QrCodeGraphics g, int x, int y) {}
