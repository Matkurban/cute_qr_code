## 1.1.0

### Added

- `CuteQrCode.data()`, `errorBuilder`, `CuteQrDataView`, `CuteQrCodeView`, `CuteQrRenderView`
- `QrCode.paintOntoCanvas()`, `QrCodeProcessor.minTypeForData()`, `resolveTypeNumber()`
- `QrCodeConfig.strictTypeNumber`, `typeNumber` alias
- Encoding, layout, and error-handling tests
- Reorganized `lib/src/` into `config/`, `core/`, `encoding/`, `painting/`, `rendering/`, `widgets/`
- Bilingual (English + Chinese) documentation comments across public API

### Changed

- `CuteQrCode` constraint-aware layout (`LayoutBuilder` + `RenderBox`)
- Explicit `informationDensity` auto-upgrades when too small (debug warning); `0` = auto
- `QrCodePainter` uses `paintOntoCanvas`
- Internal import paths: `raw/` + `internals/` → `encoding/`; `render/` → `rendering/`; `color/` + `shape/` → `painting/`

### Fixed

- Data-type regex ported incorrectly from kotlin
- Bit-accurate auto version selection
- `CuteQrRenderView` sizing under non-square tight constraints

### Deprecated

- `QrCode.fitIntoArea()` — use `paintOntoCanvas` or `CuteQrRenderView`

### Migration

- Remove hardcoded `informationDensity: 3`; use `null` or `0` for auto version selection
- Place widgets in a bounded parent (`SizedBox`, `Expanded`); fixed `size` is optional
- Deep imports `package:cute_qr_code/src/internals/...` → `package:cute_qr_code/src/encoding/...`

## 1.0.0

* Initial release — pure Dart/Flutter port of qrcode-kotlin
* `QrCodeConfig` configuration API with `QrCode.create(data, config)` entry point
* Shape factories: `squares`, `circles`, `roundedSquares`, `custom`
* Flutter `Color` + Material `Colors`; `QrColorUtils.css()` for hex strings
* Center logo via `ImageProvider` (`AssetImage`, `NetworkImage`, etc.)
* PNG export via `renderToBytes()` and `cuteQrCodeToPng()`
* `CuteQrCode` widget, `QrCodePainter`, and example app
* Low-level `QrCodeProcessor` encoding API
