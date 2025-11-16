class AppUser {
  final String? id;
  final String firebaseUid;
  final String email;
  final String? name;
  final String? photoUrl;
  final String? password; // optional for Google sign-in
  final String provider; // "password" or "google"
  final String? role;

  AppUser({
    this.id,
    required this.firebaseUid,
    required this.email,
    this.name,
    this.photoUrl,
    this.password,
    required this.provider,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "firebase_uid": firebaseUid,
        "email": email,
        "name": name,
        "photo_url": photoUrl,
        "password": password,
        "provider": provider,
        "role": role,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json["id"],
      firebaseUid: json["firebase_uid"],
      email: json["email"],
      name: json["name"],
      photoUrl: json["photo_url"],
      password: json["password"],
      provider: json["provider"],
      role: json["role"],
    );
  }
}
