import 'bit_buffer.dart';
import 'insufficient_information_density_exception.dart';
import 'polynomial.dart';
import 'qr_code_setup.dart';
import 'qr_code_square.dart';
import 'qr_data.dart';
import 'qr_util.dart';
import 'rs_block.dart';
import '../rendering/qr_code_graphics.dart';
import '../rendering/qr_code_graphics_factory.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color, Colors;
import 'qr_code_enums.dart';
import 'qr_code_raw_data.dart';

/// Encodes payload strings into QR matrices and can render flat graphics.
/// 将载荷字符串编码为 QR 矩阵，并可渲染为平面图形。
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

  /// Default module size in pixels for raster export. 光栅导出默认模块像素尺寸。
  static const int defaultCellSize = 25;

  /// Maximum QR version (40). 最大 QR 版本号（40）。
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

  /// Smallest QR version (1–40) whose bit capacity fits [data] at [errorCorrectionLevel].
  /// 在给定纠错等级下，能容纳 [data] 的最小 QR 版本（按 bit 容量计算）。
  static int minTypeForData(
    String data,
    ErrorCorrectionLevel errorCorrectionLevel, [
    QrCodeDataType? dataType,
  ]) {
    final resolvedDataType = dataType ?? QrUtil.getDataType(data);
    final qrCodeData = _createQrData(resolvedDataType, data);

    for (var typeNum = 1; typeNum < errorCorrectionLevel.maxTypeNum; typeNum++) {
      if (_fitsInType(qrCodeData, typeNum, errorCorrectionLevel)) {
        return typeNum;
      }
    }

    if (_fitsInType(qrCodeData, maximumInfoDensity, errorCorrectionLevel)) {
      return maximumInfoDensity;
    }

    final rsBlocks = RsBlock.getRsBlocks(maximumInfoDensity, errorCorrectionLevel);
    final buffer = _buildDataBuffer(qrCodeData, maximumInfoDensity);
    final totalDataCount = rsBlocks.fold<int>(0, (sum, b) => sum + b.dataCount) * 8;
    throw InsufficientInformationDensityException(
      'Data exceeds maximum QR capacity at version $maximumInfoDensity '
      '[neededBits=${buffer.lengthInBits}, maximumBitsForDensityLevel=$totalDataCount].',
    );
  }

  static int infoDensityForDataAndEcl(
    String data,
    ErrorCorrectionLevel errorCorrectionLevel, [
    QrCodeDataType? dataType,
  ]) => minTypeForData(data, errorCorrectionLevel, dataType);

  /// Resolves encode version; [requestedType] null or 0 means auto.
  /// 解析编码版本；[requestedType] 为 null 或 0 表示自动。
  static int resolveTypeNumber({
    required String data,
    required ErrorCorrectionLevel errorCorrectionLevel,
    int? requestedType,
    bool strictTypeNumber = false,
    QrCodeDataType? dataType,
  }) {
    final minType = minTypeForData(data, errorCorrectionLevel, dataType);
    final auto = requestedType == null || requestedType == 0;
    if (auto) return minType;

    if (requestedType < minType) {
      if (strictTypeNumber) {
        final resolvedDataType = dataType ?? QrUtil.getDataType(data);
        final qrCodeData = _createQrData(resolvedDataType, data);
        final rsBlocks = RsBlock.getRsBlocks(requestedType, errorCorrectionLevel);
        final buffer = _buildDataBuffer(qrCodeData, requestedType);
        final totalDataCount = rsBlocks.fold<int>(0, (sum, b) => sum + b.dataCount) * 8;
        throw InsufficientInformationDensityException(
          'Insufficient Information Density Parameter: $requestedType '
          '[neededBits=${buffer.lengthInBits}, maximumBitsForDensityLevel=$totalDataCount] - '
          'Try increasing the Information Density parameter value or use 0 (zero) to automatically '
          'compute the least amount needed to fit the QRCode data being encoded.',
        );
      }
      assert(() {
        debugPrint(
          'cute_qr_code: informationDensity $requestedType is too small for the data; '
          'upgraded to $minType.',
        );
        return true;
      }());
      return minType;
    }

    return requestedType;
  }

  static bool _fitsInType(
    QrData qrCodeData,
    int typeNum,
    ErrorCorrectionLevel errorCorrectionLevel,
  ) {
    final rsBlocks = RsBlock.getRsBlocks(typeNum, errorCorrectionLevel);
    final buffer = _buildDataBuffer(qrCodeData, typeNum);
    final totalDataCount = rsBlocks.fold<int>(0, (sum, b) => sum + b.dataCount) * 8;
    return buffer.lengthInBits <= totalDataCount;
  }

  static BitBuffer _buildDataBuffer(QrData qrCodeData, int typeNum) {
    final buffer = BitBuffer();
    buffer.putNum(qrCodeData.dataType.value, 4);
    buffer.putNum(qrCodeData.length(), qrCodeData.getLengthInBits(typeNum));
    qrCodeData.write(buffer);
    return buffer;
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
    final resolvedType = type ?? minTypeForData(_data, errorCorrectionLevel, dataType);
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
    final buffer = _buildDataBuffer(_qrCodeData, type);

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
