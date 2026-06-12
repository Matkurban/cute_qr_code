/// Functional role of a module in the QR symbol.
/// QR 符号中模块的功能角色。
enum QrCodeSquareType {
  /// Finder pattern module. 定位图案模块。
  positionProbe,

  /// Alignment pattern module. 对齐图案模块。
  positionAdjust,

  /// Timing pattern module. 时序图案模块。
  timingPattern,

  /// Data or format module. 数据或格式模块。
  defaultType,
}

/// Region of the symbol for styling control patterns.
/// 用于样式控制的功能区域。
enum QrCodeRegion {
  topLeftCorner,
  topRightCorner,
  topMid,
  leftMid,
  rightMid,
  center,
  bottomLeftCorner,
  bottomRightCorner,
  bottomMid,
  margin,
  unknown,
}

/// Metadata attached to a [QrCodeSquare] module.
/// 附在 [QrCodeSquare] 模块上的元数据。
class QrCodeSquareInfo {
  const QrCodeSquareInfo(this.type, this.region);

  final QrCodeSquareType type;
  final QrCodeRegion region;
}

/// Single QR module (dark/light) with layout and render state.
/// 单个 QR 模块（深/浅），含布局与渲染状态。
class QrCodeSquare {
  QrCodeSquare({
    required this.dark,
    required this.row,
    required this.col,
    required this.moduleSize,
    this.squareInfo = const QrCodeSquareInfo(QrCodeSquareType.defaultType, QrCodeRegion.unknown),
    this.rowSize = 1,
    this.colSize = 1,
    this.parent,
  });

  bool dark;
  final int row;
  final int col;
  final int moduleSize;
  final QrCodeSquareInfo squareInfo;
  final int rowSize;
  final int colSize;
  final QrCodeSquare? parent;

  bool rendered = false;

  static const int defaultCellSize = 25;

  int absoluteX([int cellSize = defaultCellSize]) => col * cellSize;

  int absoluteY([int cellSize = defaultCellSize]) => row * cellSize;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QrCodeSquare &&
        row == other.row &&
        col == other.col &&
        rowSize == other.rowSize &&
        colSize == other.colSize;
  }

  @override
  int get hashCode => Object.hash(row, col, rowSize, colSize);
}
