class UserModel {
  String uid;
  String name;
  String email;
  String noHp;
  String sim;
  String photoUrl;
  String createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.noHp,
    required this.sim,
    required this.photoUrl,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      noHp: json['noHp'] ?? '',
      sim: json['sim'] ?? '',
      photoUrl: json['photo_url'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'noHp': noHp,
      'sim': sim,
      'photo_url': photoUrl,
      'created_at': createdAt,
    };
  }
}
