
class AppConstants {
  AppConstants._();

  // Official ALU student email domain
  static const String aluEmailDomain = 'alustudent.com';

  // Validate ALU student email addresses
  static bool validCampusEmail(String email) {
    final normalizedEmail = email.trim().toLowerCase();

    return normalizedEmail.endsWith(
      '@$aluEmailDomain',
    );
  }

  // Incident categories
  static const List<String> categories = [
    'Facilities',
    'Water',
    'Electricity',
    'Sanitation',
    'Safety',
    'Other',
  ];

  // Campus locations
  static const List<String> locations = [
    'Classrooms',
    'Library',
    'Cafeteria',
    'Student Residence',
    'Computer Lab',
    'Reception',
    'Outdoor Area',
    'Other',
  ];
}
