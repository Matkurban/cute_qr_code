/// QR error correction level (maps to ISO L/M/Q/H).
/// QR 纠错等级（对应 ISO L/M/Q/H）。
enum ErrorCorrectionLevel {
  /// Level L (~7% recovery). 等级 L（约 7% 纠错）。
  low(1, 21),

  /// Level M (~15% recovery). 等级 M（约 15% 纠错）。
  medium(0, 25),

  /// Level Q (~25% recovery). 等级 Q（约 25% 纠错）。
  high(3, 30),

  /// Level H (~30% recovery). 等级 H（约 30% 纠错）。
  veryHigh(2, 34);

  const ErrorCorrectionLevel(this.value, this.maxTypeNum);

  /// BCH-encoded value used in type info bits. 类型信息位中使用的 BCH 编码值。
  final int value;

  /// Upper bound for auto version search (kotlin port semantics). 自动选版本时的搜索上界。
  final int maxTypeNum;
}

/// Mask pattern applied to the QR matrix (8 variants).
/// 应用于 QR 矩阵的掩码模式（8 种）。
enum MaskPattern {
  /// Mask 0: (i + j) % 2 == 0.
  pattern000,

  /// Mask 1: i % 2 == 0.
  pattern001,

  /// Mask 2: j % 3 == 0.
  pattern010,

  /// Mask 3: (i + j) % 3 == 0.
  pattern011,

  /// Mask 4: (i/2 + j/3) % 2 == 0.
  pattern100,

  /// Mask 5: (i*j) % 2 + (i*j) % 3 == 0.
  pattern101,

  /// Mask 6: ((i*j) % 2 + (i*j) % 3) % 2 == 0.
  pattern110,

  /// Mask 7: ((i*j) % 3 + (i + j) % 2) % 2 == 0.
  pattern111,
}

/// Payload encoding mode for QR data segments.
/// QR 数据段的编码模式。
enum QrCodeDataType {
  /// Numeric mode (0–9). 数字模式（0–9）。
  numbers(1 << 0),

  /// Alphanumeric mode (0–9, A–Z, space, $%*+-./:). 大写字母数字模式。
  upperAlphaNum(1 << 1),

  /// 8-bit byte mode (default for arbitrary text). 8 位字节模式（任意文本默认）。
  defaultType(1 << 2);

  const QrCodeDataType(this.value);

  /// 4-bit mode indicator value. 4 位模式指示值。
  final int value;
}
