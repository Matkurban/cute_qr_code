**语言：** [English](README.md) | [中文](README_zh.md)

# cute_qr_code

**版本 1.0.0**

基于 [qrcode-kotlin](https://github.com/g0dkar/qrcode-kotlin) 的纯 Dart/Flutter 二维码生成库。支持自定义模块形状、颜色、渐变和 Logo，无原生依赖，无需 Platform Channel。

## 特性

- **模块形状** — 方形、圆形、圆角方形
- **颜色** — 纯色前景/背景、透明背景、线性渐变
- **Logo 叠加** — 居中 `ImageProvider`，可选清除 Logo 区域
- **编码选项** — 纠错等级与掩码模式
- **PNG 导出** — `renderToBytes()` 与 `cuteQrCodeToPng()`
- **Flutter 组件** — `CuteQrCode` 实时展示，`QrCodePainter` 自定义绘制
- **底层 API** — `QrCodeProcessor` 直接编码与渲染
- **Dart 风格 API** — `QrCodeConfig` + `data` / `config` 入口

## 安装

```yaml
dependencies:
  cute_qr_code: ^1.0.0
```

```bash
flutter pub get
```

**环境要求：** Dart SDK `^3.12.0`，Flutter `>=1.17.0`

## 快速开始

```dart
import 'package:cute_qr_code/cute_qr_code.dart';
import 'package:flutter/material.dart';

Future<void> generateQr() async {
  final qr = QrCode.roundedSquares(
    data: 'Hello world!',
    config: const QrCodeConfig(color: Colors.blue, squareSize: 10),
  );

  final pngBytes = await qr.renderToBytes();
}
```

## 创建二维码

高级 API 统一使用 `data` + 可选 `QrCodeConfig`：

```dart
// 通用（使用 config.shape）
QrCode.create(
  data: 'Hello',
  config: const QrCodeConfig(color: Colors.black, squareSize: 8),
);

// 按形状划分的便捷工厂（覆盖 config.shape）
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

| 工厂方法 | 说明 |
|---------|------|
| `QrCode.create` | 根据 `config.shape` 选择形状 |
| `QrCode.squares` | 方形模块 |
| `QrCode.circles` | 圆形模块 |
| `QrCode.roundedSquares` | 圆角方形模块 |
| `QrCode.custom` | 需设置 `config.shapeFunction` |

## 颜色

```dart
QrCode.create(
  data: 'Colored',
  config: const QrCodeConfig(
    color: Colors.black,
    backgroundColor: Colors.white,
  ),
);
```

### 十六进制

```dart
QrCode.create(
  data: 'Hex',
  config: QrCodeConfig(
    color: QrColorUtils.css('#00BFFF'),
    backgroundColor: QrColorUtils.css('#FFFFFF'),
  ),
);
```

### 渐变

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

## Logo 叠加

使用 Flutter `ImageProvider` 传入居中 Logo：

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

`logoWidth` / `logoHeight` 可省略，默认使用 resolve 后的图片尺寸。Logo 在 `prepare()` / `renderToBytes()` 中异步解析。

支持 `AssetImage`、`NetworkImage`、`MemoryImage` 等。

## 纠错与掩码

```dart
QrCode.create(
  data: 'Robust QR',
  config: const QrCodeConfig(
    errorCorrectionLevel: ErrorCorrectionLevel.high,
    maskPattern: MaskPattern.pattern101,
  ),
);
```

## Widget 用法

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

### Widget 参数

| 参数 | 类型 | 说明 |
|------|------|------|
| `data` | `String?` | 要编码的文本 |
| `config` | `QrCodeConfig` | 样式与编码配置 |
| `qrCode` | `QrCode?` | 预构建实例 |
| `size` | `double?` | 固定宽高 |
| `key` | `Key?` | 切换配置时使用（如 Tab） |

`CuteQrCode` 在 `didUpdateWidget` 中通过 `config ==` 判断是否需要重建。

## PNG 导出

```dart
final bytes = await QrCode.create(data: 'Hello', config: config).renderToBytes();

final bytes = await cuteQrCodeToPng(
  'Hello',
  config: const QrCodeConfig(color: Colors.black, squareSize: 10),
);
```

## 高级定制

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

## QrCodeConfig 字段速查

| 字段 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `shape` | `QrCodeShapesEnum` | `square` | 模块形状 |
| `color` | `Color` | `Colors.black` | 前景色 |
| `backgroundColor` | `Color` | `transparent` | 背景色 |
| `gradientEnd` | `Color?` | `null` | 设置后启用渐变 |
| `gradientVertical` | `bool` | `true` | 渐变方向 |
| `squareSize` | `int` | `25` | 模块像素尺寸 |
| `radius` | `int?` | 自动 | 圆角半径 |
| `innerSpacing` | `int?` | 自动 | 模块间距 |
| `logo` | `ImageProvider?` | `null` | 居中 Logo |
| `logoWidth` | `double?` | 图片宽度 | Logo 绘制宽度 |
| `logoHeight` | `double?` | 图片高度 | Logo 绘制高度 |
| `clearLogoArea` | `bool` | `true` | 清除 Logo 下模块 |
| `errorCorrectionLevel` | `ErrorCorrectionLevel` | `low` | 纠错等级 |
| `maskPattern` | `MaskPattern` | `pattern000` | 掩码模式 |
| `informationDensity` | `int?` | 自动 | 信息密度 |
| `canvasSize` | `int` | `0` | 画布尺寸（0=自动） |
| `margin` | `int` | `0` | 静默区边距 |
| `xOffset` / `yOffset` | `int` | `0` | 绘制偏移 |
| `colorFunction` | `QrCodeColorFunction?` | `null` | 自定义颜色 |
| `shapeFunction` | `QrCodeShapeFunction?` | `null` | 自定义形状 |
| `graphicsFactory` | `QrCodeGraphicsFactory?` | `null` | 图形后端 |
| `onBeforeRender` | 回调 | `null` | 渲染前钩子 |
| `onAfterRender` | 回调 | `null` | 渲染后钩子 |

## 示例应用

```bash
cd example
flutter run
```

## 与 qrcode-kotlin 的关系

编码与渲染内部逻辑移植自 qrcode-kotlin。公开 Dart API 使用 `QrCodeConfig` 配置对象，替代 Kotlin 链式 Builder。颜色使用 Flutter `Color` 与 `QrColorUtils.css()`。

## 许可证

MIT — 与 [qrcode-kotlin](https://github.com/g0dkar/qrcode-kotlin) 相同。
