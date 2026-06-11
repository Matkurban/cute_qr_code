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
  static const _logoAsset = 'assets/logo/logo.png';

  int _tab = 0;
  Uint8List? _pngBytes;

  @override
  void initState() {
    super.initState();
    _renderPng();
  }

  QrCodeConfig _configForTab() => switch (_tab) {
    0 => const QrCodeConfig(color: Colors.black, squareSize: 8),
    1 => const QrCodeConfig(
      shape: QrCodeShapesEnum.circle,
      color: Colors.blue,
      squareSize: 8,
    ),
    2 => const QrCodeConfig(
      shape: QrCodeShapesEnum.roundedSquare,
      color: Colors.green,
      squareSize: 8,
    ),
    3 => const QrCodeConfig(
      gradientEnd: Colors.blue,
      color: Colors.pink,
      squareSize: 8,
    ),
    4 => const QrCodeConfig(
      errorCorrectionLevel: ErrorCorrectionLevel.high,
      maskPattern: MaskPattern.pattern101,
      squareSize: 8,
    ),
    _ => const QrCodeConfig(
      shape: QrCodeShapesEnum.roundedSquare,
      color: Colors.black,
      squareSize: 8,
      logo: AssetImage(_logoAsset),
      logoWidth: 56,
      logoHeight: 56,
      errorCorrectionLevel: ErrorCorrectionLevel.high,
    ),
  };

  Future<void> _renderPng() async {
    final bytes = await QrCode.create(
      data: _data,
      config: _configForTab(),
    ).renderToBytes();
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
              ButtonSegment(value: 5, label: Text('Logo')),
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
              config: _configForTab(),
            ),
          ),
        ],
      ),
    );
  }
}
