/// Module shape preset for [QrCodeConfig.shape].
/// [QrCodeConfig.shape] 使用的模块形状预设。
enum QrCodeShapesEnum {
  /// Square modules. 方形模块。
  square,

  /// Circular modules. 圆形模块。
  circle,

  /// Rounded-square modules. 圆角方形模块。
  roundedSquare,

  /// Custom shape via [QrCodeConfig.shapeFunction]. 通过 [QrCodeConfig.shapeFunction] 自定义。
  custom,
}
