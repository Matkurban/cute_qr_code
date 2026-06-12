class InsufficientInformationDensityException implements Exception {
  InsufficientInformationDensityException([this.message]);

  final String? message;

  @override
  String toString() => 'InsufficientInformationDensityException: ${message ?? ''}';
}
