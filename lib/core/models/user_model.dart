class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? photoUrl;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.photoUrl,
  });

  UserModel copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? photoUrl,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        fullName: json['fullName'],
        email: json['email'],
        phoneNumber: json['phoneNumber'],
        photoUrl: json['photoUrl'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'photoUrl': photoUrl,
      };
}