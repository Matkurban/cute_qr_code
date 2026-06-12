/// Aesthetic QR code generation for Flutter (ported from qrcode-kotlin).
/// 美观 QR 码生成库（移植自 qrcode-kotlin）。
library;

export 'src/config/qr_code_config.dart';
export 'src/core/qr_code.dart';
export 'src/core/qr_code_hook.dart';
export 'src/core/qr_code_shapes_enum.dart';
export 'src/encoding/insufficient_information_density_exception.dart';
export 'src/encoding/qr_code_enums.dart';
export 'src/encoding/qr_code_processor.dart';
export 'src/encoding/qr_code_raw_data.dart';
export 'src/encoding/qr_code_square.dart' show QrCodeSquare, QrCodeSquareType;
export 'src/painting/color/default_color_function.dart';
export 'src/painting/color/linear_gradient_color_function.dart';
export 'src/painting/color/qr_code_color_function.dart';
export 'src/painting/qr_code_painter.dart';
export 'src/painting/shape/circle_shape_function.dart';
export 'src/painting/shape/default_shape_function.dart';
export 'src/painting/shape/qr_code_shape_function.dart';
export 'src/painting/shape/round_squares_shape_function.dart';
export 'src/rendering/cute_qr_render_view.dart';
export 'src/rendering/qr_code_graphics.dart';
export 'src/rendering/qr_code_graphics_factory.dart';
export 'src/widgets/cute_qr_code_widget.dart';
export 'src/widgets/cute_qr_data_view.dart';
