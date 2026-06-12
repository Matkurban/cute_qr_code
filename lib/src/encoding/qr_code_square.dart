enum QrCodeSquareType { positionProbe, positionAdjust, timingPattern, defaultType }

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

class QrCodeSquareInfo {
  const QrCodeSquareInfo(this.type, this.region);

  final QrCodeSquareType type;
  final QrCodeRegion region;
}

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
