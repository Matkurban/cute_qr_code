**Languages:** [English](README.md) | [中文](README_zh.md)

# cute_qr_code

**Version 1.0.0**

Pure Dart/Flutter QR code generator ported from [qrcode-kotlin](https://github.com/g0dkar/qrcode-kotlin). Generate aesthetic QR codes with custom module shapes, colors, gradients, and logos — no native dependencies, no platform channels.

## Features

- **Module shapes** — square, circle, and rounded-square modules
- **Colors** — solid foreground/background, transparent backgrounds, linear gradients
- **Logo overlay** — center image with optional clear area behind the logo
- **Encoding options** — error correction levels and mask patterns
- **PNG export** — `renderToBytes()` and `cuteQrCodeToPng()`
- **Flutter widgets** — `CuteQrCode` for live UI and `QrCodePainter` for custom painting
- **Low-level API** — `QrCodeProcessor` for direct matrix encoding and rendering
- **API parity** — public API mirrors qrcode-kotlin `QRCode` / `QRCodeBuilder`

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
  final qr = QrCode.ofRoundedSquares()
      .withColor(Colors.blue)
      .withSize(10)
      .build('Hello world!');

  final pngBytes = await qr.renderToBytes();
  // Use pngBytes with Image.memory, save to file, etc.
}
```

## Module shapes

Choose a factory method, then chain builder options and call `build(data)`:

```dart
// Square modules (default)
QrCode.ofSquares().withColor(Colors.black).withSize(8).build('Square');

// Circle modules
QrCode.ofCircles().withColor(Colors.blue).withSize(8).build('Circle');

// Rounded-square modules
QrCode.ofRoundedSquares()
    .withColor(Colors.green)
    .withSize(8)
    .withRadius(4) // optional; auto-calculated when omitted
    .build('Rounded');

// Custom shape function
QrCode.ofCustomShape(myShapeFunction).withSize(8).build('Custom');
```

| Factory | Description |
|---------|-------------|
| `QrCode.ofSquares()` | Standard square modules |
| `QrCode.ofCircles()` | Circular modules |
| `QrCode.ofRoundedSquares()` | Rounded-corner square modules |
| `QrCode.ofCustomShape(fn)` | Fully custom `QrCodeShapeFunction` |

You can also switch shape on an existing builder with `withShape(QrCodeShapesEnum.circle)`.

## Colors

Colors use Flutter's native `Color` type. Import Material for named colors:

```dart
import 'package:flutter/material.dart';

QrCode.ofSquares()
    .withColor(Colors.black)                    // foreground
    .withBackgroundColor(Colors.white)          // background (default: transparent)
    .build('Colored');
```

### Hex strings

Use `QrColorUtils.css()` for CSS-style hex values (equivalent to KMP `Colors.css("#cc0000")`):

```dart
QrCode.ofSquares()
    .withColor(QrColorUtils.css('#00BFFF'))
    .withBackgroundColor(QrColorUtils.css('#FFFFFF'))
    .build('Hex colors');
```

You can also construct colors directly: `Color(0xFF00BFFF)`.

### Gradients

```dart
QrCode.ofSquares()
    .withGradientColor(Colors.pink, Colors.blue) // vertical by default
    .build('Vertical gradient');

QrCode.ofSquares()
    .withGradientColor(Colors.pink, Colors.blue, vertical: false)
    .build('Horizontal gradient');
```

## Logo overlay

Embed a center logo from PNG bytes. When `clearLogoArea` is `true` (default), modules under the logo are skipped so the image stays readable:

```dart
import 'dart:typed_data';

final logoBytes = ...; // Uint8List of PNG/JPEG bytes

final qr = QrCode.ofSquares()
    .withColor(Colors.black)
    .withSize(10)
    .withLogo(logoBytes, 64, 64, clearLogoArea: true)
    .build('https://example.com');
```

## Error correction and mask patterns

```dart
QrCode.ofSquares()
    .withErrorCorrectionLevel(ErrorCorrectionLevel.high)
    .withMaskPattern(MaskPattern.pattern101)
    .build('Robust QR');
```

| `ErrorCorrectionLevel` | Approx. recovery |
|------------------------|------------------|
| `low` | ~7% |
| `medium` | ~15% |
| `high` | ~25% |
| `veryHigh` | ~30% |

Mask patterns: `MaskPattern.pattern000` through `MaskPattern.pattern111`.

Override information density manually when needed:

```dart
QrCode.ofSquares()
    .withInformationDensity(4)
    .build('Long text...');
```

## Widget usage

Use `CuteQrCode` to render a QR code directly in your widget tree. It scales to fill the available space (1:1 aspect ratio).

```dart
SizedBox(
  height: 240,
  child: CuteQrCode(
    data: 'Hello',
    builder: _configureBuilder,
  ),
)

QrCodeBuilder _configureBuilder(QrCodeBuilder builder) {
  return builder
      .withShape(QrCodeShapesEnum.circle)
      .withColor(Colors.blue)
      .withSize(8);
}
```

### Widget parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `String?` | Text to encode (required unless `qrCode` is provided) |
| `builder` | `QrCodeBuilder Function(QrCodeBuilder)?` | Configures shape, color, size, etc. |
| `qrCode` | `QrCode?` | Pre-built `QrCode` instance (skips builder) |
| `size` | `double?` | Fixed width/height in logical pixels |

### Tips

- Pass a **stable method reference** for `builder` (e.g. `_configureBuilder`), not an inline closure. Inline closures create a new function on every parent rebuild, causing unnecessary re-initialization.
- When switching styles by tab or index, use `key: ValueKey(tabIndex)` to recreate the widget cleanly.
- `CuteQrCode` starts from `QrCodeBuilder.ofSquares()` internally; use `builder.withShape(...)` for circle or rounded shapes.

### Custom painting

For full control, use `QrCodePainter` inside your own `CustomPaint`:

```dart
CustomPaint(
  painter: QrCodePainter(qrCode),
  child: const SizedBox.expand(),
)
```

## PNG export

### From a `QrCode` instance

```dart
final bytes = await qr.renderToBytes();           // PNG (default)
final bytes = await qr.renderToBytes(format: 'PNG');
```

### Convenience helper

```dart
final bytes = await cuteQrCodeToPng(
  'Hello',
  builder: (b) => b.withColor(Colors.black).withSize(10),
);
```

## Advanced customization

### Custom color and shape functions

Implement `QrCodeColorFunction` or `QrCodeShapeFunction`, then:

```dart
QrCode.ofSquares()
    .withCustomColorFunction(myColorFn)
    .withCustomShapeFunction(myShapeFn)
    .build('Custom');
```

### Render hooks

Run code before or after the QR modules are drawn:

```dart
QrCode.ofSquares()
    .withBeforeRenderAction((qr, canvas) { /* ... */ })
    .withAfterRenderAction((qr, canvas) { /* ... */ })
    .build('Hooks');
```

### Resize and fit

After building, adjust output dimensions:

```dart
final qr = QrCode.ofSquares().withSize(8).build('Fit');

qr.fitIntoArea(200, 200); // scales modules to fit a 200×200 area
qr.resize(300);           // fixed 300×300 canvas
await qr.renderToBytes();
```

## Low-level API

For plain encoding without the builder decorators:

```dart
final processor = QrCodeProcessor('Hello QRCode!');
final graphics = processor.render(cellSize: 25, darkColor: Colors.black);
final bytes = await graphics.getBytes();
```

Access the raw matrix via `processor.encode()` or inspect `QrCode.rawData` on a built instance.

## QrCodeBuilder API reference

| Method | Description |
|--------|-------------|
| `withShape(shape)` | Set module shape enum |
| `withSize(size)` | Module size in pixels |
| `withColor(color)` | Foreground color |
| `withBackgroundColor(color)` | Background color |
| `withGradientColor(start, end, {vertical})` | Linear gradient foreground |
| `withRadius(radius)` | Corner radius for rounded squares |
| `withInnerSpacing([spacing])` | Gap between modules |
| `withLogo(bytes, w, h, {clearLogoArea})` | Center logo image |
| `withErrorCorrectionLevel(ecl)` | Error correction level |
| `withMaskPattern(pattern)` | Mask pattern |
| `withInformationDensity(density)` | Override auto density |
| `withCanvasSize(size)` | Fixed canvas size |
| `withMargin(margin)` | Quiet zone margin |
| `withXOffset(x)` / `withYOffset(y)` | Draw offset |
| `withCustomColorFunction(fn)` | Custom color logic |
| `withCustomShapeFunction(fn)` | Custom shape logic |
| `withBeforeRenderAction(fn)` | Pre-render hook |
| `withAfterRenderAction(fn)` | Post-render hook |
| `withGraphicsFactory(factory)` | Custom graphics backend |
| `build(data)` | Create `QrCode` instance |

Static factories on `QrCodeBuilder`: `ofSquares()`, `ofCircles()`, `ofRoundedSquares()`, `ofCustomShape(fn)`.

Convenience aliases on `QrCode`: `QrCode.ofSquares()`, `ofCircles()`, `ofRoundedSquares()`, `ofCustomShape(fn)`.

## Example app

The `example/` directory demonstrates all major features:

```bash
cd example
flutter run
```

The demo includes five tabs:

| Tab | Demonstrates |
|-----|--------------|
| Square | Black square modules |
| Circle | Blue circle modules |
| Rounded | Green rounded-square modules |
| Gradient | Pink-to-blue gradient |
| ECL/Mask | High error correction + mask pattern 101 |

Each tab shows both a PNG preview (`renderToBytes`) and a live `CuteQrCode` widget.

## Relationship to qrcode-kotlin

`cute_qr_code` is a faithful port of the qrcode-kotlin `commonMain` module to pure Dart, using `dart:ui` Canvas for rendering. The builder API, shape functions, color functions, and encoding internals follow the same design. Differences:

- Colors use Flutter `Color` / Material `Colors` instead of a custom `Colors` class
- Hex colors via `QrColorUtils.css()` instead of `Colors.css()`
- Flutter-specific exports: `CuteQrCode`, `QrCodePainter`, `cuteQrCodeToPng()`

## License

MIT — same as [qrcode-kotlin](https://github.com/g0dkar/qrcode-kotlin).
