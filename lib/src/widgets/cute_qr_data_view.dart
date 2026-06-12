import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../config/qr_code_config.dart';
import '../core/qr_code.dart';
import '../rendering/cute_qr_render_view.dart';

/// Encodes [data] and displays the resulting [QrCode] with error handling.
/// 编码 [data] 并显示得到的 [QrCode]，含错误处理。
class CuteQrDataView extends StatefulWidget {
  /// Creates a view that encodes [data] on each config/data change.
  /// 创建在 data/config 变化时重新编码的视图。
  const CuteQrDataView({
    required this.data,
    super.key,
    this.config = const QrCodeConfig(),
    this.errorBuilder,
    this.size,
  });

  /// Payload to encode. 要编码的载荷。
  final String data;

  /// Styling and encoding options. 样式与编码选项。
  final QrCodeConfig config;

  /// Widget shown when encoding fails. 编码失败时显示的组件。
  final ImageErrorWidgetBuilder? errorBuilder;

  /// Fixed square size; omit to use parent constraints.
  /// 固定正方形尺寸；省略则使用父级约束。
  final double? size;

  @override
  State<CuteQrDataView> createState() => _CuteQrDataViewState();
}

class _CuteQrDataViewState extends State<CuteQrDataView> {
  QrCode? _qrCode;
  bool _prepared = false;
  Object? _lastError;
  StackTrace? _lastStackTrace;

  @override
  void initState() {
    super.initState();
    _encodeQrCode();
    _prepareLogo();
  }

  @override
  void didUpdateWidget(covariant CuteQrDataView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data || oldWidget.config != widget.config) {
      _encodeQrCode();
      _prepareLogo();
    }
  }

  @pragma('vm:notify-debugger-on-exception')
  void _encodeQrCode() {
    try {
      _lastError = null;
      _lastStackTrace = null;
      _qrCode = QrCode.create(data: widget.data, config: widget.config);
      _prepared = false;
    } on Exception catch (error, stackTrace) {
      _lastError = error;
      _lastStackTrace = stackTrace;
      _qrCode = null;

      if (widget.errorBuilder != null) {
        return;
      }

      FlutterError.reportError(
        FlutterErrorDetails(
          silent: true,
          library: 'cute_qr_code',
          context: ErrorDescription('while encoding qr code'),
          exception: error,
          stack: stackTrace,
          informationCollector: () => [StringProperty('Data', widget.data)],
        ),
      );
    }
  }

  Future<void> _prepareLogo() async {
    final qr = _qrCode;
    if (qr == null) return;
    await qr.prepare();
    if (mounted) {
      setState(() => _prepared = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_lastError != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(context, _lastError!, _lastStackTrace);
      }
      return _CuteQrErrorWidget(error: _lastError!);
    }

    final qr = _qrCode;
    if (qr == null) return const SizedBox.shrink();

    return CuteQrCodeView(qrCode: qr, prepared: _prepared, size: widget.size);
  }
}

class _CuteQrRenderWidget extends LeafRenderObjectWidget {
  const _CuteQrRenderWidget({required this.qrCode, required this.prepared});

  final QrCode qrCode;
  final bool prepared;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return CuteQrRenderView(qrCode: qrCode, prepared: prepared);
  }

  @override
  void updateRenderObject(BuildContext context, CuteQrRenderView renderObject) {
    renderObject
      ..qrCode = qrCode
      ..prepared = prepared;
  }
}

/// Displays a prepared [QrCode] scaled to parent constraints.
/// 将已准备的 [QrCode] 按父级约束缩放显示。
class CuteQrCodeView extends StatelessWidget {
  /// Creates a view for an already-encoded [qrCode].
  /// 为已编码的 [qrCode] 创建视图。
  const CuteQrCodeView({required this.qrCode, super.key, this.prepared = true, this.size});

  /// QR model to display. 要显示的 QR 模型。
  final QrCode qrCode;

  /// Whether [QrCode.prepare] has completed for logos.
  /// [QrCode.prepare]（Logo）是否已完成。
  final bool prepared;

  /// Fixed square size; omit to use parent constraints.
  /// 固定正方形尺寸；省略则使用父级约束。
  final double? size;

  @override
  Widget build(BuildContext context) {
    final renderWidget = _CuteQrRenderWidget(qrCode: qrCode, prepared: prepared);
    if (size != null) {
      return SizedBox.square(dimension: size, child: renderWidget);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(constraints.maxWidth, constraints.maxHeight);
        if (!side.isFinite || side <= 0) {
          return const SizedBox.shrink();
        }
        return SizedBox.square(dimension: side, child: renderWidget);
      },
    );
  }
}

class _CuteQrErrorWidget extends StatelessWidget {
  const _CuteQrErrorWidget({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dimension = math.min(constraints.maxWidth, constraints.maxHeight);

        if (!kDebugMode) {
          return SizedBox.square(dimension: dimension);
        }

        return SizedBox.square(
          dimension: dimension,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Positioned.fill(child: ColoredBox(color: Color(0xCF8D021F))),
              Padding(
                padding: const EdgeInsets.all(4),
                child: FittedBox(
                  child: Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(shadows: [Shadow(blurRadius: 1)]),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
