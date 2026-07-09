class ValidationUtils {
  ValidationUtils._();

  /// Validate email address
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate phone number (Sri Lankan format)
  static bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^\+?94?[0-9]{9,10}$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[\s-]'), ''));
  }

  /// Validate password strength
  /// Requirements: min 8 chars, at least 1 uppercase, 1 lowercase, 1 number
  static bool isValidPassword(String password) {
    if (password.length < 8) {
      return false;
    }

    final hasUppercase = password.contains(RegExp('[A-Z]'));
    final hasLowercase = password.contains(RegExp('[a-z]'));
    final hasNumber = password.contains(RegExp('[0-9]'));

    return hasUppercase && hasLowercase && hasNumber;
  }

  /// Get password strength message
  static String getPasswordStrengthMessage(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!password.contains(RegExp('[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!password.contains(RegExp('[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!password.contains(RegExp('[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return '';
  }

  /// Validate name (2-50 chars, letters and spaces only)
  static bool isValidName(String name) {
    if (name.trim().length < 2 || name.trim().length > 50) {
      return false;
    }
    final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
    return nameRegex.hasMatch(name.trim());
  }

  /// Validate age (1-120 years)
  static bool isValidAge(int age) => age >= 1 && age <= 120;

  /// Validate height (50-250 cm)
  static bool isValidHeight(double height) => height >= 50 && height <= 250;

  /// Validate weight (20-300 kg)
  static bool isValidWeight(double weight) => weight >= 20 && weight <= 300;

  /// Validate goal weight (20-300 kg and less than current weight for weight loss)
  static bool isValidGoalWeight(double goalWeight, double currentWeight) => goalWeight >= 20 && goalWeight <= 300 && goalWeight < currentWeight;

  /// Validate caloric intake (500-5000 calories)
  static bool isValidCaloricIntake(double calories) => calories >= 500 && calories <= 5000;

  /// Validate water intake (500-10000 ml)
  static bool isValidWaterIntake(double waterMl) => waterMl >= 500 && waterMl <= 10000;

  /// Validate workout duration (1-300 minutes)
  static bool isValidWorkoutDuration(int minutes) => minutes >= 1 && minutes <= 300;

  /// Validate not empty string
  static bool isNotEmpty(String? value) => value != null && value.trim().isNotEmpty;

  /// Validate string length
  static bool isValidLength(String value, int minLength, int maxLength) {
    final length = value.trim().length;
    return length >= minLength && length <= maxLength;
  }

  /// Validate numeric string
  static bool isNumeric(String value) => double.tryParse(value) != null;

  /// Validate positive number
  static bool isPositive(num value) => value > 0;

  /// Validate date is not in the future
  static bool isNotFutureDate(DateTime date) => date.isBefore(DateTime.now()) ||
        date.isAtSameMomentAs(DateTime.now());

  /// Validate date of birth (age between 13 and 120)
  static bool isValidDateOfBirth(DateTime dateOfBirth) {
    final now = DateTime.now();
    final age = now.year - dateOfBirth.year;

    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      return age - 1 >= 13 && age - 1 <= 120;
    }

    return age >= 13 && age <= 120;
  }
}
