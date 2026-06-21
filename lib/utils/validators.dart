class Validators {
  static String? requiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    final passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&.#^_-])[A-Za-z\d@$!%*?&.#^_-]{8,}$',
    );

    if (!passwordRegex.hasMatch(value)) {
      return 'Password must be 8+ chars with uppercase, lowercase, digit & special symbol';
    }

    return null;
  }

  static String? studentId(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Student ID is required';
  }

  if (value.trim().length != 16) {
    return 'Student ID must be exactly 16 digits';
  }

  if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
    return 'Student ID must contain only digits';
  }

  return null;
}

  static String? batch(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Batch is required';
    }

    return null;
  }

  static String? semester(int? value) {
    if (value == null) {
      return 'Semester is required';
    }

    if (value < 1 || value > 12) {
      return 'Semester must be between 1 and 12';
    }

    return null;
  }
}