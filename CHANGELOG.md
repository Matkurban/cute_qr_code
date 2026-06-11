## 1.0.0

* Initial release — pure Dart/Flutter port of qrcode-kotlin
* `QrCodeConfig` configuration API with `QrCode.create(data, config)` entry point
* Shape factories: `squares`, `circles`, `roundedSquares`, `custom`
* Flutter `Color` + Material `Colors`; `QrColorUtils.css()` for hex strings
* Center logo via `ImageProvider` (`AssetImage`, `NetworkImage`, etc.)
* PNG export via `renderToBytes()` and `cuteQrCodeToPng()`
* `CuteQrCode` widget, `QrCodePainter`, and example app
* Low-level `QrCodeProcessor` encoding API
