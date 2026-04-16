class AppConstants {
  static const String firestoreUsersCollection = 'users';
  static const String firestoreProfilesCollection = 'user_profiles';
  static const int minPasswordLength = 6;
  static const String emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String profileWizardRoute = '/profile-wizard';
  static const String dashboardRoute = '/dashboard';
}
