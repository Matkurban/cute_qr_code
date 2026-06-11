**Languages:** [English](README.md) | [中文](README_zh.md)

# cute_qr_code

**Version 1.0.0**

Pure Dart/Flutter QR code generator ported from [qrcode-kotlin](https://github.com/g0dkar/qrcode-kotlin). Generate aesthetic QR codes with custom module shapes, colors, gradients, and logos — no native dependencies, no platform channels.

## Features

- **Module shapes** — square, circle, and rounded-square modules
- **Colors** — solid foreground/background, transparent backgrounds, linear gradients
- **Logo overlay** — center `ImageProvider` with optional clear area behind the logo
- **Encoding options** — error correction levels and mask patterns
- **PNG export** — `renderToBytes()` and `cuteQrCodeToPng()`
- **Flutter widgets** — `CuteQrCode` for live UI and `QrCodePainter` for custom painting
- **Low-level API** — `QrCodeProcessor` for direct matrix encoding and rendering
- **Dart-style API** — `QrCodeConfig` + `data` / `config` entry points

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  cute_qr_code: ^1.0.0
```

Then run:

```bash
flutter pub get
```

**Requirements:** Dart SDK `^3.12.0`, Flutter `>=1.17.0`

## Quick start

```dart
import 'package:cute_qr_code/cute_qr_code.dart';
import 'package:flutter/material.dart';

Future<void> generateQr() async {
  final qr = QrCode.roundedSquares(
    data: 'Hello world!',
    config: const QrCodeConfig(color: Colors.blue, squareSize: 10),
  );

  final pngBytes = await qr.renderToBytes();
  // Use pngBytes with Image.memory, save to file, etc.
}
```

## Creating QR codes

All high-level creation uses `data` plus an optional `QrCodeConfig`:

```dart
// Generic (uses config.shape)
QrCode.create(
  data: 'Hello',
  config: const QrCodeConfig(color: Colors.black, squareSize: 8),
);

// Shape-specific factories (override config.shape)
QrCode.squares(data: '...', config: const QrCodeConfig(color: Colors.black));
QrCode.circles(data: '...', config: const QrCodeConfig(color: Colors.blue));
QrCode.roundedSquares(
  data: '...',
  config: const QrCodeConfig(color: Colors.green, radius: 4),
);
QrCode.custom(
  data: '...',
  config: QrCodeConfig(shapeFunction: myShapeFn),
);
```

| Factory | Description |
|---------|-------------|
| `QrCode.create` | Uses `config.shape` |
| `QrCode.squares` | Square modules |
| `QrCode.circles` | Circular modules |
| `QrCode.roundedSquares` | Rounded-corner modules |
| `QrCode.custom` | Requires `config.shapeFunction` |

## Colors

Colors use Flutter's native `Color` type:

```dart
QrCode.create(
  data: 'Colored',
  config: const QrCodeConfig(
    color: Colors.black,
    backgroundColor: Colors.white,
  ),
);
```

### Hex strings

```dart
QrCode.create(
  data: 'Hex',
  config: QrCodeConfig(
    color: QrColorUtils.css('#00BFFF'),
    backgroundColor: QrColorUtils.css('#FFFFFF'),
  ),
);
```

### Gradients

```dart
QrCode.create(
  data: 'Gradient',
  config: const QrCodeConfig(
    color: Colors.pink,
    gradientEnd: Colors.blue,
    gradientVertical: true,
  ),
);
```

## Logo overlay

Pass a Flutter `ImageProvider` for the center logo:

```dart
QrCode.create(
  data: 'https://example.com',
  config: const QrCodeConfig(
    logo: AssetImage('assets/logo.png'),
    logoWidth: 64,
    logoHeight: 64,
    clearLogoArea: true,
  ),
);
```

`logoWidth` / `logoHeight` are optional — when omitted, the resolved image dimensions are used. The logo is resolved asynchronously in `prepare()` / `renderToBytes()`.

Supported providers include `AssetImage`, `NetworkImage`, and `MemoryImage`.

## Error correction and mask patterns

```dart
QrCode.create(
  data: 'Robust QR',
  config: const QrCodeConfig(
    errorCorrectionLevel: ErrorCorrectionLevel.high,
    maskPattern: MaskPattern.pattern101,
  ),
);
```

## Widget usage

```dart
CuteQrCode(
  key: ValueKey(tabIndex),
  data: 'Hello',
  config: const QrCodeConfig(
    shape: QrCodeShapesEnum.circle,
    color: Colors.blue,
    squareSize: 8,
  ),
)
```

### Widget parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `String?` | Text to encode (required unless `qrCode` is provided) |
| `config` | `QrCodeConfig` | Style and encoding options |
| `qrCode` | `QrCode?` | Pre-built instance (skips `create`) |
| `size` | `double?` | Fixed width/height in logical pixels |
| `key` | `Key?` | Use when switching configs (e.g. tab changes) |

`CuteQrCode` compares `config` with `==` in `didUpdateWidget`. Reuse `const QrCodeConfig(...)` or `copyWith` for stable updates.

### Custom painting

```dart
CustomPaint(
  painter: QrCodePainter(qrCode),
  child: const SizedBox.expand(),
)
```

## PNG export

```dart
final bytes = await QrCode.create(data: 'Hello', config: config).renderToBytes();

final bytes = await cuteQrCodeToPng(
  'Hello',
  config: const QrCodeConfig(color: Colors.black, squareSize: 10),
);
```

## Advanced customization

```dart
QrCode.create(
  data: 'Custom',
  config: QrCodeConfig(
    colorFunction: myColorFn,
    shapeFunction: myShapeFn,
    onBeforeRender: (qr, canvas) { /* ... */ },
    onAfterRender: (qr, canvas) { /* ... */ },
  ),
);
```

```dart
final qr = QrCode.create(data: 'Fit', config: const QrCodeConfig(squareSize: 8));
qr.fitIntoArea(200, 200);
await qr.renderToBytes();
```

## Low-level API

```dart
final processor = QrCodeProcessor('Hello QRCode!');
final graphics = processor.render(cellSize: 25, darkColor: Colors.black);
final bytes = await graphics.getBytes();
```

## QrCodeConfig reference

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `shape` | `QrCodeShapesEnum` | `square` | Module shape |
| `color` | `Color` | `Colors.black` | Foreground color |
| `backgroundColor` | `Color` | `transparent` | Background color |
| `gradientEnd` | `Color?` | `null` | Enables gradient when set |
| `gradientVertical` | `bool` | `true` | Gradient direction |
| `squareSize` | `int` | `25` | Module size in pixels |
| `radius` | `int?` | auto | Rounded-square corner radius |
| `innerSpacing` | `int?` | auto | Gap between modules |
| `logo` | `ImageProvider?` | `null` | Center logo image |
| `logoWidth` | `double?` | image width | Logo draw width |
| `logoHeight` | `double?` | image height | Logo draw height |
| `clearLogoArea` | `bool` | `true` | Skip modules under logo |
| `errorCorrectionLevel` | `ErrorCorrectionLevel` | `low` | Error correction |
| `maskPattern` | `MaskPattern` | `pattern000` | Mask pattern |
| `informationDensity` | `int?` | auto | Override auto density |
| `canvasSize` | `int` | `0` | Fixed canvas (0 = auto) |
| `margin` | `int` | `0` | Quiet zone margin |
| `xOffset` / `yOffset` | `int` | `0` | Draw offset |
| `colorFunction` | `QrCodeColorFunction?` | `null` | Custom color logic |
| `shapeFunction` | `QrCodeShapeFunction?` | `null` | Custom shape logic |
| `graphicsFactory` | `QrCodeGraphicsFactory?` | `null` | Custom graphics backend |
| `onBeforeRender` | callback | `null` | Pre-render hook |
| `onAfterRender` | callback | `null` | Post-render hook |

## Example app

```bash
cd example
flutter run
```

Five tabs demonstrate square, circle, rounded, gradient, and ECL/mask styles using `QrCodeConfig`.

## Relationship to qrcode-kotlin

`cute_qr_code` ports qrcode-kotlin encoding and rendering internals. The public Dart API uses `QrCodeConfig` instead of the Kotlin fluent builder. Colors use Flutter `Color` / `QrColorUtils.css()` for hex values.

## License

MIT — same as [qrcode-kotlin](https://github.com/g0dkar/qrcode-kotlin).
