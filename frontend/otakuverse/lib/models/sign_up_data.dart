class SignupData {
  // Step 1
  String? email;
  String? password;
  String? username;
  String? phone;

  // Step 2
  DateTime? dateOfBirth;
  String? gender;

  // Step 3
  String? avatarPath;

  // Auto
  String? location;

  // Onboarding
  List<String> favoriteAnimes = [];
  List<String> favoriteGames = [];

  SignupData();

  bool isComplete() {
    return email != null &&
        password != null &&
        username != null &&
        dateOfBirth != null &&
        gender != null;
  }

  /// Convertit dateOfBirth en ISO8601 String pour l'API
  String? get dateOfBirthString => dateOfBirth?.toIso8601String();

  Map<String, dynamic> toSignupJson() {
    return {
      'email': email,
      'password': password,
      'username': username,
      'phone': phone,
      'date_of_birth': dateOfBirthString,
      'gender': gender,
      'location': location,
    };
  }

  Map<String, dynamic> toOnboardingJson() {
    return {
      'favorite_animes': favoriteAnimes,
      'favorite_games': favoriteGames,
    };
  }
}