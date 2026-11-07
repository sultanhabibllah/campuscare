class AppConstants {
  AppConstants._();

  // Replace this at run-time: flutter run --dart-define=ALU_EMAIL_DOMAIN=your-real-domain
  static const aluEmailDomain = String.fromEnvironment(
    'ALU_EMAIL_DOMAIN',
    defaultValue: 'alu.edu',
  );

  static bool validCampusEmail(String email) =>
      email.trim().toLowerCase().endsWith('@${aluEmailDomain.toLowerCase()}');

  static const categories = <String>[
    'Facilities', 'Water', 'Electricity', 'Sanitation', 'Safety', 'Other'
  ];
  static const locations = <String>[
    'Classrooms', 'Library', 'Cafeteria', 'Student Residence',
    'Computer Lab', 'Reception', 'Outdoor Area', 'Other'
  ];
}
