import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import '../config/qr_code_config.dart';
import '../core/qr_code.dart';
import 'cute_qr_data_view.dart';

/// Widget that displays a styled QR code, scaling to the parent constraints.
/// 显示样式化 QR 码的组件，按父级约束缩放。
class CuteQrCode extends StatelessWidget {
  /// Creates a widget from [data] or a pre-built [qrCode].
  /// 根据 [data] 或预构建的 [qrCode] 创建组件。
  const CuteQrCode({
    super.key,
    required this.data,
    this.config = const QrCodeConfig(),
    this.qrCode,
    this.size,
    this.errorBuilder,
  }) : assert(qrCode != null || data != null);

  /// Recommended factory — encodes [data] with optional [errorBuilder].
  /// 推荐工厂：编码 [data]，可选 [errorBuilder]。
  factory CuteQrCode.data({
    required String data,
    Key? key,
    QrCodeConfig config = const QrCodeConfig(),
    ImageErrorWidgetBuilder? errorBuilder,
    double? size,
  }) {
    return CuteQrCode(key: key, data: data, config: config, errorBuilder: errorBuilder, size: size);
  }

  /// Payload when [qrCode] is not provided.
  /// 未提供 [qrCode] 时的载荷。
  final String? data;

  /// Styling and encoding options.
  /// 样式与编码选项。
  final QrCodeConfig config;

  /// Pre-encoded model; skips encoding in build.
  /// 预编码模型；构建时跳过编码。
  final QrCode? qrCode;

  /// Fixed square size; omit to use parent constraints.
  /// 固定正方形尺寸；省略则使用父级约束。
  final double? size;

  /// Widget shown when encoding fails.
  /// 编码失败时显示的组件。
  final ImageErrorWidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    if (qrCode != null) {
      return _PreparedCuteQrCodeView(qrCode: qrCode!, size: size);
    }

    return CuteQrDataView(data: data!, config: config, errorBuilder: errorBuilder, size: size);
  }
}

class _PreparedCuteQrCodeView extends StatefulWidget {
  const _PreparedCuteQrCodeView({required this.qrCode, this.size});

  final QrCode qrCode;
  final double? size;

  @override
  State<_PreparedCuteQrCodeView> createState() => _PreparedCuteQrCodeViewState();
}

class _PreparedCuteQrCodeViewState extends State<_PreparedCuteQrCodeView> {
  bool _prepared = false;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  @override
  void didUpdateWidget(covariant _PreparedCuteQrCodeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.qrCode != widget.qrCode) {
      _prepared = false;
      _prepare();
    }
  }

  Future<void> _prepare() async {
    await widget.qrCode.prepare();
    if (mounted) setState(() => _prepared = true);
  }

  @override
  Widget build(BuildContext context) {
    return CuteQrCodeView(qrCode: widget.qrCode, prepared: _prepared, size: widget.size);
  }
}

/// Encodes [data] and returns PNG bytes.
/// 编码 [data] 并返回 PNG 字节。
Future<Uint8List> cuteQrCodeToPng(String data, {QrCodeConfig config = const QrCodeConfig()}) async {
  final qr = QrCode.create(data: data, config: config);
  return qr.renderToBytes();
}
