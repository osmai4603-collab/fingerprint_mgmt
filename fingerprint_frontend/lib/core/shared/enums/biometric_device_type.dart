enum BiometricDeviceType {
  zkteco('zkteco'),
  real('real'),
  hikvision('hikvision'),
  generic('generic');

  final String value;
  const BiometricDeviceType(this.value);

  static BiometricDeviceType fromString(String? value) {
    return BiometricDeviceType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => BiometricDeviceType.generic,
    );
  }

  static BiometricDeviceType of(String map) {
    return BiometricDeviceType.values.firstWhere(
      (e) => e.value == map,
      orElse: () => BiometricDeviceType.generic,
    );
  }
}
