import 'qr_code_graphics.dart';

/// Creates [QrCodeGraphics] buffers for rendering.
/// 创建用于渲染的 [QrCodeGraphics] 缓冲区。
class QrCodeGraphicsFactory {
  /// Square buffer of [size] x [size] pixels.
  /// [size] x [size] 像素的正方形缓冲区。
  QrCodeGraphics newGraphicsSquare(int size) => newGraphics(size, size);

  /// Buffer of arbitrary [width] and [height].
  /// 任意 [width] 与 [height] 的缓冲区。
  QrCodeGraphics newGraphics(int width, int height) => QrCodeGraphics(width, height);
}
