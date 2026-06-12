import '../exception/insufficient_information_density_exception.dart';
import '../internals/bit_buffer.dart';
import '../internals/polynomial.dart';
import '../internals/qr_code_setup.dart';
import '../internals/qr_code_square.dart';
import '../internals/qr_data.dart';
import '../internals/qr_util.dart';
import '../internals/rs_block.dart';
import '../render/qr_code_graphics.dart';
import '../render/qr_code_graphics_factory.dart';
import 'package:flutter/material.dart' show Color, Colors;
import 'qr_code_enums.dart';
import 'qr_code_raw_data.dart';

class QrCodeProcessor {
  QrCodeProcessor(
    this._data, {
    this.errorCorrectionLevel = ErrorCorrectionLevel.medium,
    QrCodeDataType? dataType,
    QrCodeGraphicsFactory? graphicsFactory,
  }) : dataType = dataType ?? QrUtil.getDataType(_data),
       graphicsFactory = graphicsFactory ?? QrCodeGraphicsFactory() {
    _qrCodeData = _createQrData(this.dataType, _data);
  }

  final String _data;
  final ErrorCorrectionLevel errorCorrectionLevel;
  final QrCodeDataType dataType;
  final QrCodeGraphicsFactory graphicsFactory;

  late final QrData _qrCodeData;

  static const int defaultCellSize = 25;
  static const int maximumInfoDensity = 40;
  static const int _pad0 = 0xEC;
  static const int _pad1 = 0x11;

  static QrData _createQrData(QrCodeDataType type, String data) {
    switch (type) {
      case QrCodeDataType.numbers:
        return QrNumber(data);
      case QrCodeDataType.upperAlphaNum:
        return QrAlphaNum(data);
      case QrCodeDataType.defaultType:
        return Qr8BitByte(data);
    }
  }

  static int infoDensityForDataAndEcl(
    String data,
    ErrorCorrectionLevel errorCorrectionLevel, [
    QrCodeDataType? dataType,
  ]) {
    final resolvedType = dataType ?? QrUtil.getDataType(data);
    final qrCodeData = _createQrData(resolvedType, data);
    final dataLength = qrCodeData.length();

    for (var typeNum = 1; typeNum < errorCorrectionLevel.maxTypeNum; typeNum++) {
      if (dataLength <= QrUtil.getMaxLength(typeNum, resolvedType, errorCorrectionLevel)) {
        return typeNum;
      }
    }

    return maximumInfoDensity;
  }

  int computeImageSizeFromRawData({int cellSize = defaultCellSize, QrCodeRawData? rawData}) =>
      computeImageSize(cellSize, (rawData ?? encode()).length);

  int computeImageSize(int cellSize, int size) => size * cellSize;

  QrCodeGraphics render({
    int cellSize = defaultCellSize,
    Color brightColor = Colors.white,
    Color darkColor = Colors.black,
  }) => renderComputed(cellSize: cellSize, brightColor: brightColor, darkColor: darkColor);

  QrCodeGraphics renderComputed({
    int cellSize = defaultCellSize,
    QrCodeRawData? rawData,
    QrCodeGraphics? qrCodeGraphics,
    Color brightColor = Colors.white,
    Color darkColor = Colors.black,
  }) {
    final data = rawData ?? encode();
    final graphics =
        qrCodeGraphics ??
        graphicsFactory.newGraphicsSquare(computeImageSize(cellSize, data.length));
    return renderShaded(
      cellSize: cellSize,
      rawData: data,
      qrCodeGraphics: graphics,
      renderer: (x, y, cellData, graphics) {
        if (cellData.dark) {
          graphics.fillRect(x, y, cellSize, cellSize, darkColor);
        } else {
          graphics.fillRect(x, y, cellSize, cellSize, brightColor);
        }
      },
    );
  }

  QrCodeGraphics renderShaded({
    int cellSize = defaultCellSize,
    QrCodeRawData? rawData,
    QrCodeGraphics? qrCodeGraphics,
    required void Function(int x, int y, QrCodeSquare cell, QrCodeGraphics graphics) renderer,
  }) {
    final data = rawData ?? encode();
    final graphics =
        qrCodeGraphics ??
        graphicsFactory.newGraphicsSquare(computeImageSize(cellSize, data.length));

    for (final rowData in data) {
      for (final cell in rowData) {
        if (!cell.rendered) {
          renderer(cell.absoluteX(cellSize), cell.absoluteY(cellSize), cell, graphics);
          cell.rendered = true;
        }
      }
    }

    return graphics;
  }

  QrCodeRawData encode({int? type, MaskPattern maskPattern = MaskPattern.pattern000}) {
    final resolvedType = type ?? infoDensityForDataAndEcl(_data, errorCorrectionLevel, dataType);
    final moduleCount = resolvedType * 4 + 17;
    final modules = List.generate(
      moduleCount,
      (_) => List<QrCodeSquare?>.filled(moduleCount, null),
    );

    QrCodeSetup.setupTopLeftPositionProbePattern(modules);
    QrCodeSetup.setupTopRightPositionProbePattern(modules);
    QrCodeSetup.setupBottomLeftPositionProbePattern(modules);
    QrCodeSetup.setupPositionAdjustPattern(resolvedType, modules);
    QrCodeSetup.setupTimingPattern(moduleCount, modules);
    QrCodeSetup.setupTypeInfo(errorCorrectionLevel, maskPattern, moduleCount, modules);

    if (resolvedType >= 7) {
      QrCodeSetup.setupTypeNumber(resolvedType, moduleCount, modules);
    }

    final encodedData = _createData(resolvedType);
    QrCodeSetup.applyMaskPattern(encodedData, maskPattern, moduleCount, modules);

    return List.generate(moduleCount, (row) {
      return List.generate(moduleCount, (column) {
        return modules[row][column] ??
            QrCodeSquare(dark: false, row: row, col: column, moduleSize: moduleCount);
      });
    });
  }

  List<int> _createData(int type) {
    final rsBlocks = RsBlock.getRsBlocks(type, errorCorrectionLevel);
    final buffer = BitBuffer();

    buffer.putNum(_qrCodeData.dataType.value, 4);
    buffer.putNum(_qrCodeData.length(), _qrCodeData.getLengthInBits(type));
    _qrCodeData.write(buffer);

    final totalDataCount = rsBlocks.fold<int>(0, (sum, b) => sum + b.dataCount) * 8;

    if (buffer.lengthInBits > totalDataCount) {
      throw InsufficientInformationDensityException(
        'Insufficient Information Density Parameter: $type '
        '[neededBits=${buffer.lengthInBits}, maximumBitsForDensityLevel=$totalDataCount] - '
        'Try increasing the Information Density parameter value or use 0 (zero) to automatically '
        'compute the least amount needed to fit the QRCode data being encoded.',
      );
    }

    if (buffer.lengthInBits + 4 <= totalDataCount) {
      buffer.putNum(0, 4);
    }

    while (buffer.lengthInBits % 8 != 0) {
      buffer.put(false);
    }

    while (true) {
      if (buffer.lengthInBits >= totalDataCount) break;
      buffer.putNum(_pad0, 8);
      if (buffer.lengthInBits >= totalDataCount) break;
      buffer.putNum(_pad1, 8);
    }

    return _createBytes(buffer, rsBlocks);
  }

  List<int> _createBytes(BitBuffer buffer, List<RsBlock> rsBlocks) {
    var offset = 0;
    var maxDcCount = 0;
    var maxEcCount = 0;
    var totalCodeCount = 0;
    final dcData = List<List<int>>.generate(rsBlocks.length, (_) => []);
    final ecData = List<List<int>>.generate(rsBlocks.length, (_) => []);

    for (var i = 0; i < rsBlocks.length; i++) {
      final block = rsBlocks[i];
      final dcCount = block.dataCount;
      final ecCount = block.totalCount - dcCount;

      totalCodeCount += block.totalCount;
      maxDcCount = maxDcCount < dcCount ? dcCount : maxDcCount;
      maxEcCount = maxEcCount < ecCount ? ecCount : maxEcCount;

      dcData[i] = List<int>.generate(dcCount, (idx) => 0xff & buffer.buffer[idx + offset]);
      offset += dcCount;

      final rsPoly = QrUtil.getErrorCorrectPolynomial(ecCount);
      final rawPoly = Polynomial(dcData[i], rsPoly.len() - 1);
      final modPoly = rawPoly.mod(rsPoly);
      final ecDataSize = rsPoly.len() - 1;

      ecData[i] = List<int>.generate(ecDataSize, (idx) {
        final modIndex = idx + modPoly.len() - ecDataSize;
        return modIndex >= 0 ? modPoly[modIndex] : 0;
      });
    }

    var index = 0;
    final data = List<int>.filled(totalCodeCount, 0);

    for (var i = 0; i < maxDcCount; i++) {
      for (var r = 0; r < rsBlocks.length; r++) {
        if (i < dcData[r].length) {
          data[index++] = dcData[r][i];
        }
      }
    }

    for (var i = 0; i < maxEcCount; i++) {
      for (var r = 0; r < rsBlocks.length; r++) {
        if (i < ecData[r].length) {
          data[index++] = ecData[r][i];
        }
      }
    }

    return data;
  }

  @override
  String toString() =>
      'QrCodeProcessor(data=$_data, errorCorrectionLevel=$errorCorrectionLevel, '
      'dataType=$dataType)';
}
