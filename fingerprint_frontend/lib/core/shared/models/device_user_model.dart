class DeviceUser {
  final int? uid;
  final String userId;
  final String name;
  final int privilege;
  final String password;
  final String groupId;
  final int card;

  DeviceUser({
    this.uid,
    required this.userId,
    this.name = "",
    this.privilege = 0,
    this.password = "",
    this.groupId = "",
    this.card = 0,
  });

  factory DeviceUser.fromMap(Map<String, dynamic> map) {
    return DeviceUser(
      uid: map['uid'] != null ? map['uid'] as int : null,
      userId: map['user_id'] as String,
      name: map['name'] as String? ?? "",
      privilege: map['privilege'] as int? ?? 0,
      password: map['password'] as String? ?? "",
      groupId: map['group_id'] as String? ?? "",
      card: map['card'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap({bool removeId = false}) {
    return {
      if (!removeId && uid != null) 'uid': uid,
      'user_id': userId,
      'name': name,
      'privilege': privilege,
      'password': password,
      'group_id': groupId,
      'card': card,
    };
  }
}
