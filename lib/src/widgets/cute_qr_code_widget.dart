import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import '../qr_code.dart';
import '../qr_code_builder.dart';
import 'qr_code_painter.dart';

class CuteQrCode extends StatefulWidget {
  const CuteQrCode({super.key, required this.data, this.builder, this.qrCode, this.size})
    : assert(qrCode != null || data != null);

  final String? data;
  final QrCodeBuilder Function(QrCodeBuilder builder)? builder;
  final QrCode? qrCode;
  final double? size;

  @override
  State<CuteQrCode> createState() => _CuteQrCodeState();
}

class _CuteQrCodeState extends State<CuteQrCode> {
  QrCode? _qrCode;
  bool _prepared = false;

  @override
  void initState() {
    super.initState();
    _initQrCode();
  }

  @override
  void didUpdateWidget(covariant CuteQrCode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data ||
        oldWidget.qrCode != widget.qrCode ||
        oldWidget.builder != widget.builder) {
      _initQrCode();
    }
  }

  void _initQrCode() {
    _prepared = false;
    _qrCode =
        widget.qrCode ??
        (widget.builder ?? (b) => b)(QrCodeBuilder.ofSquares()).build(widget.data!);
    _prepare();
  }

  Future<void> _prepare() async {
    await _qrCode?.prepare();
    if (mounted) {
      setState(() => _prepared = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final qr = _qrCode;
    if (qr == null) return const SizedBox.shrink();

    final child = CustomPaint(
      painter: QrCodePainter(qr, prepared: _prepared),
      child: const SizedBox.expand(),
    );

    if (widget.size != null) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: AspectRatio(aspectRatio: 1, child: child),
      );
    }

    return AspectRatio(aspectRatio: 1, child: child);
  }
}

Future<Uint8List> cuteQrCodeToPng(
  String data, {
  QrCodeBuilder Function(QrCodeBuilder builder)? builder,
}) async {
  final qr = (builder ?? (b) => b)(QrCodeBuilder.ofSquares()).build(data);
  return qr.renderToBytes();
}
