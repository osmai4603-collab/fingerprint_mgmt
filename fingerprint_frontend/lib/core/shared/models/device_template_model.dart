class DeviceFingerprint {
  final int uid;
  final int size;
  final int valid;
  final String template;
  final int mark;

  DeviceFingerprint({
    required this.uid,
    this.size = 0,
    this.valid = 1,
    required this.template,
    this.mark = 0,
  });

  factory DeviceFingerprint.fromMap(Map<String, dynamic> map) {
    return DeviceFingerprint(
      uid: map['uid'] as int,
      size: map['size'] as int? ?? 0,
      valid: map['valid'] as int? ?? 1,
      template: map['template'] as String,
      mark: map['mark'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap({bool removeId = false}) {
    return {
      if (!removeId) 'uid': uid,
      'size': size,
      'valid': valid,
      'template': template,
      'mark': mark,
    };
  }
}
