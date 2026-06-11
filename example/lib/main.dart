import 'dart:typed_data';

import 'package:cute_qr_code/cute_qr_code.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CuteQrCodeExampleApp());
}

class CuteQrCodeExampleApp extends StatelessWidget {
  const CuteQrCodeExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'cute_qr_code examples',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  static const _data = 'Hello world!';

  int _tab = 0;
  Uint8List? _pngBytes;

  @override
  void initState() {
    super.initState();
    _renderPng();
  }

  QrCodeBuilder _newBuilder() {
    return switch (_tab) {
      0 => QrCode.ofSquares(),
      1 => QrCode.ofCircles(),
      2 => QrCode.ofRoundedSquares(),
      _ => QrCode.ofSquares(),
    };
  }

  QrCodeBuilder _configureBuilder(QrCodeBuilder builder) {
    final shaped = switch (_tab) {
      1 => builder.withShape(QrCodeShapesEnum.circle),
      2 => builder.withShape(QrCodeShapesEnum.roundedSquare),
      _ => builder,
    };
    return switch (_tab) {
      0 => shaped.withColor(Colors.black).withSize(8),
      1 => shaped.withColor(Colors.blue).withSize(8),
      2 => shaped.withColor(Colors.green).withSize(8),
      3 => shaped.withGradientColor(Colors.pink, Colors.blue).withSize(8),
      _ =>
        shaped
            .withErrorCorrectionLevel(ErrorCorrectionLevel.high)
            .withMaskPattern(MaskPattern.pattern101)
            .withSize(8),
    };
  }

  Future<void> _renderPng() async {
    final bytes = await _configureBuilder(
      _newBuilder(),
    ).build(_data).renderToBytes();
    if (mounted) setState(() => _pngBytes = bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('cute_qr_code examples')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Square')),
              ButtonSegment(value: 1, label: Text('Circle')),
              ButtonSegment(value: 2, label: Text('Rounded')),
              ButtonSegment(value: 3, label: Text('Gradient')),
              ButtonSegment(value: 4, label: Text('ECL/Mask')),
            ],
            selected: {_tab},
            onSelectionChanged: (value) {
              setState(() => _tab = value.first);
              _renderPng();
            },
          ),
          const SizedBox(height: 24),
          if (_pngBytes != null)
            Center(child: Image.memory(_pngBytes!, width: 240, height: 240)),
          const SizedBox(height: 24),
          const Text('Live widget preview', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          SizedBox(
            height: 240,
            child: CuteQrCode(
              key: ValueKey(_tab),
              data: _data,
              builder: _configureBuilder,
            ),
          ),
        ],
      ),
    );
  }
}
