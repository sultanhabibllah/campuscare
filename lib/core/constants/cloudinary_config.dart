
class CloudinaryConfig {
  CloudinaryConfig._();

  static const String cloudName = 'vp2fzj3q';

  static const String uploadPreset = 'campuscare_incidents';

  static String get uploadUrl =>
      'https://api.cloudinary.com/v1_1/'
      '$cloudName/image/upload';

  static bool get isConfigured =>
      cloudName.trim().isNotEmpty &&
      uploadPreset.trim().isNotEmpty;
}
