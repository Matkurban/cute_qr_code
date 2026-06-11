enum ErrorCorrectionLevel {
  low(1, 21),
  medium(0, 25),
  high(3, 30),
  veryHigh(2, 34);

  const ErrorCorrectionLevel(this.value, this.maxTypeNum);

  final int value;
  final int maxTypeNum;
}

enum MaskPattern {
  pattern000,
  pattern001,
  pattern010,
  pattern011,
  pattern100,
  pattern101,
  pattern110,
  pattern111,
}

enum QrCodeDataType {
  numbers(1 << 0),
  upperAlphaNum(1 << 1),
  defaultType(1 << 2);

  const QrCodeDataType(this.value);

  final int value;
}
