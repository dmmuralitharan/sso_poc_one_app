class AppUser {
  final String firebaseUid;
  final String email;
  final String? name;
  final String? photoUrl;
  final String? password; // optional for Google sign-in
  final String provider; // "password" or "google"

  AppUser({
    required this.firebaseUid,
    required this.email,
    this.name,
    this.photoUrl,
    this.password,
    required this.provider,
  });

  Map<String, dynamic> toJson() => {
        "firebase_uid": firebaseUid,
        "email": email,
        "name": name,
        "photo_url": photoUrl,
        "password": password,
        "provider": provider,
      };
}
