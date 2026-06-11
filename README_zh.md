**语言：** [English](README.md) | [中文](README_zh.md)

# cute_qr_code

**版本 1.0.0**

基于 [qrcode-kotlin](https://github.com/g0dkar/qrcode-kotlin) 的纯 Dart/Flutter 二维码生成库。支持自定义模块形状、颜色、渐变和 Logo，无原生依赖，无需 Platform Channel。

## 特性

- **模块形状** — 方形、圆形、圆角方形
- **颜色** — 纯色前景/背景、透明背景、线性渐变
- **Logo 叠加** — 居中图片，可选清除 Logo 区域下的模块
- **编码选项** — 纠错等级与掩码模式
- **PNG 导出** — `renderToBytes()` 与 `cuteQrCodeToPng()`
- **Flutter 组件** — `CuteQrCode` 实时展示，`QrCodePainter` 自定义绘制
- **底层 API** — `QrCodeProcessor` 直接编码与渲染
- **API 对齐** — 公开 API 与 qrcode-kotlin 的 `QRCode` / `QRCodeBuilder` 保持一致

## 安装

在 `pubspec.yaml` 中添加：

```yaml
dependencies:
  cute_qr_code: ^1.0.0
```

然后执行：

```bash
flutter pub get
```

**环境要求：** Dart SDK `^3.12.0`，Flutter `>=1.17.0`

## 快速开始

```dart
import 'package:cute_qr_code/cute_qr_code.dart';
import 'package:flutter/material.dart';

Future<void> generateQr() async {
  final qr = QrCode.ofRoundedSquares()
      .withColor(Colors.blue)
      .withSize(10)
      .build('Hello world!');

  final pngBytes = await qr.renderToBytes();
  // 配合 Image.memory 显示，或写入文件等
}
```

## 模块形状

选择工厂方法，链式配置后调用 `build(data)`：

```dart
// 方形模块（默认）
QrCode.ofSquares().withColor(Colors.black).withSize(8).build('Square');

// 圆形模块
QrCode.ofCircles().withColor(Colors.blue).withSize(8).build('Circle');

// 圆角方形模块
QrCode.ofRoundedSquares()
    .withColor(Colors.green)
    .withSize(8)
    .withRadius(4) // 可选；省略时自动计算
    .build('Rounded');

// 自定义形状函数
QrCode.ofCustomShape(myShapeFunction).withSize(8).build('Custom');
```

| 工厂方法 | 说明 |
|---------|------|
| `QrCode.ofSquares()` | 标准方形模块 |
| `QrCode.ofCircles()` | 圆形模块 |
| `QrCode.ofRoundedSquares()` | 圆角方形模块 |
| `QrCode.ofCustomShape(fn)` | 完全自定义 `QrCodeShapeFunction` |

也可在已有 builder 上通过 `withShape(QrCodeShapesEnum.circle)` 切换形状。

## 颜色

颜色使用 Flutter 原生 `Color` 类型。导入 Material 以使用命名颜色：

```dart
import 'package:flutter/material.dart';

QrCode.ofSquares()
    .withColor(Colors.black)                    // 前景色
    .withBackgroundColor(Colors.white)          // 背景色（默认透明）
    .build('Colored');
```

### 十六进制颜色

使用 `QrColorUtils.css()` 解析 CSS 风格十六进制值（等同于 KMP 的 `Colors.css("#cc0000")`）：

```dart
QrCode.ofSquares()
    .withColor(QrColorUtils.css('#00BFFF'))
    .withBackgroundColor(QrColorUtils.css('#FFFFFF'))
    .build('Hex colors');
```

也可直接构造：`Color(0xFF00BFFF)`。

### 渐变

```dart
QrCode.ofSquares()
    .withGradientColor(Colors.pink, Colors.blue) // 默认垂直渐变
    .build('Vertical gradient');

QrCode.ofSquares()
    .withGradientColor(Colors.pink, Colors.blue, vertical: false)
    .build('Horizontal gradient');
```

## Logo 叠加

在中心嵌入 Logo 图片。`clearLogoArea` 为 `true`（默认）时，会跳过 Logo 区域的模块，保证图片清晰：

```dart
import 'dart:typed_data';

final logoBytes = ...; // PNG/JPEG 的 Uint8List

final qr = QrCode.ofSquares()
    .withColor(Colors.black)
    .withSize(10)
    .withLogo(logoBytes, 64, 64, clearLogoArea: true)
    .build('https://example.com');
```

## 纠错与掩码

```dart
QrCode.ofSquares()
    .withErrorCorrectionLevel(ErrorCorrectionLevel.high)
    .withMaskPattern(MaskPattern.pattern101)
    .build('Robust QR');
```

| `ErrorCorrectionLevel` | 约可恢复比例 |
|--------------------------|-------------|
| `low` | ~7% |
| `medium` | ~15% |
| `high` | ~25% |
| `veryHigh` | ~30% |

掩码模式：`MaskPattern.pattern000` 至 `MaskPattern.pattern111`。

手动指定信息密度：

```dart
QrCode.ofSquares()
    .withInformationDensity(4)
    .build('Long text...');
```

## Widget 用法

使用 `CuteQrCode` 在界面中直接渲染二维码，自动按 1:1 宽高比填充可用空间。

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

### Widget 参数

| 参数 | 类型 | 说明 |
|------|------|------|
| `data` | `String?` | 要编码的文本（提供 `qrCode` 时可省略） |
| `builder` | `QrCodeBuilder Function(QrCodeBuilder)?` | 配置形状、颜色、尺寸等 |
| `qrCode` | `QrCode?` | 预构建的 `QrCode` 实例（跳过 builder） |
| `size` | `double?` | 固定宽高（逻辑像素） |

### 使用建议

- `builder` 应传入**稳定的方法引用**（如 `_configureBuilder`），不要使用内联闭包。内联闭包在父组件每次 rebuild 时都会生成新函数，导致不必要的重新初始化。
- 按 Tab 或索引切换样式时，建议使用 `key: ValueKey(tabIndex)` 明确重建 Widget。
- `CuteQrCode` 内部默认从 `QrCodeBuilder.ofSquares()` 开始；圆形或圆角需通过 `builder.withShape(...)` 设置。

### 自定义绘制

需要完全控制时，可在 `CustomPaint` 中使用 `QrCodePainter`：

```dart
CustomPaint(
  painter: QrCodePainter(qrCode),
  child: const SizedBox.expand(),
)
```

## PNG 导出

### 从 `QrCode` 实例导出

```dart
final bytes = await qr.renderToBytes();           // PNG（默认）
final bytes = await qr.renderToBytes(format: 'PNG');
```

### 便捷函数

```dart
final bytes = await cuteQrCodeToPng(
  'Hello',
  builder: (b) => b.withColor(Colors.black).withSize(10),
);
```

## 高级定制

### 自定义颜色与形状函数

实现 `QrCodeColorFunction` 或 `QrCodeShapeFunction` 后：

```dart
QrCode.ofSquares()
    .withCustomColorFunction(myColorFn)
    .withCustomShapeFunction(myShapeFn)
    .build('Custom');
```

### 渲染钩子

在模块绘制前后执行自定义逻辑：

```dart
QrCode.ofSquares()
    .withBeforeRenderAction((qr, canvas) { /* ... */ })
    .withAfterRenderAction((qr, canvas) { /* ... */ })
    .build('Hooks');
```

### 缩放与适配

构建后可调整输出尺寸：

```dart
final qr = QrCode.ofSquares().withSize(8).build('Fit');

qr.fitIntoArea(200, 200); // 将模块缩放到 200×200 区域内
qr.resize(300);           // 固定 300×300 画布
await qr.renderToBytes();
```

## 底层 API

无需 Builder 装饰，直接编码渲染：

```dart
final processor = QrCodeProcessor('Hello QRCode!');
final graphics = processor.render(cellSize: 25, darkColor: Colors.black);
final bytes = await graphics.getBytes();
```

可通过 `processor.encode()` 访问原始矩阵，或在已构建实例上查看 `QrCode.rawData`。

## QrCodeBuilder API 速查

| 方法 | 说明 |
|------|------|
| `withShape(shape)` | 设置模块形状 |
| `withSize(size)` | 模块像素尺寸 |
| `withColor(color)` | 前景色 |
| `withBackgroundColor(color)` | 背景色 |
| `withGradientColor(start, end, {vertical})` | 线性渐变前景 |
| `withRadius(radius)` | 圆角方形的圆角半径 |
| `withInnerSpacing([spacing])` | 模块间距 |
| `withLogo(bytes, w, h, {clearLogoArea})` | 居中 Logo |
| `withErrorCorrectionLevel(ecl)` | 纠错等级 |
| `withMaskPattern(pattern)` | 掩码模式 |
| `withInformationDensity(density)` | 覆盖自动密度 |
| `withCanvasSize(size)` | 固定画布尺寸 |
| `withMargin(margin)` | 静默区边距 |
| `withXOffset(x)` / `withYOffset(y)` | 绘制偏移 |
| `withCustomColorFunction(fn)` | 自定义颜色逻辑 |
| `withCustomShapeFunction(fn)` | 自定义形状逻辑 |
| `withBeforeRenderAction(fn)` | 渲染前钩子 |
| `withAfterRenderAction(fn)` | 渲染后钩子 |
| `withGraphicsFactory(factory)` | 自定义图形后端 |
| `build(data)` | 创建 `QrCode` 实例 |

`QrCodeBuilder` 静态工厂：`ofSquares()`、`ofCircles()`、`ofRoundedSquares()`、`ofCustomShape(fn)`。

`QrCode` 便捷别名：`QrCode.ofSquares()`、`ofCircles()`、`ofRoundedSquares()`、`ofCustomShape(fn)`。

## 示例应用

`example/` 目录演示了所有主要功能：

```bash
cd example
flutter run
```

演示包含五个 Tab：

| Tab | 演示内容 |
|-----|---------|
| Square | 黑色方形模块 |
| Circle | 蓝色圆形模块 |
| Rounded | 绿色圆角方形模块 |
| Gradient | 粉红到蓝色渐变 |
| ECL/Mask | 高纠错 + 掩码模式 101 |

每个 Tab 同时展示 PNG 预览（`renderToBytes`）和实时 `CuteQrCode` Widget。

## 与 qrcode-kotlin 的关系

`cute_qr_code` 是 qrcode-kotlin `commonMain` 模块的忠实 Dart 移植，使用 `dart:ui` Canvas 渲染。Builder API、形状函数、颜色函数和编码内部实现遵循相同设计。主要差异：

- 颜色使用 Flutter `Color` / Material `Colors`，而非自定义 `Colors` 类
- 十六进制颜色通过 `QrColorUtils.css()`，而非 `Colors.css()`
- Flutter 专属导出：`CuteQrCode`、`QrCodePainter`、`cuteQrCodeToPng()`

## 许可证

MIT — 与 [qrcode-kotlin](https://github.com/g0dkar/qrcode-kotlin) 相同。
