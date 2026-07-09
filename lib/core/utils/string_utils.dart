class StringUtils {
  StringUtils._();

  /// Capitalize first letter of string
  static String capitalize(String text) {
    if (text.isEmpty) {
      return text;
    }
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Capitalize first letter of each word
  static String capitalizeWords(String text) {
    if (text.isEmpty) {
      return text;
    }
    return text.split(' ').map(capitalize).join(' ');
  }

  /// Convert to title case
  static String toTitleCase(String text) => capitalizeWords(text.toLowerCase());

  /// Truncate string with ellipsis
  static String truncate(String text, int maxLength,
      {String ellipsis = '...',}) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Remove all whitespace
  static String removeWhitespace(String text) => text.replaceAll(RegExp(r'\s+'), '');

  /// Convert to snake_case
  static String toSnakeCase(String text) => text
        .replaceAll(RegExp('([A-Z])'), r'_$1')
        .toLowerCase()
        .replaceAll(RegExp('^_'), '');

  /// Convert to camelCase
  static String toCamelCase(String text) {
    final words = text.split(RegExp(r'[_\s]+'));
    if (words.isEmpty) {
      return text;
    }

    return words.first.toLowerCase() +
        words.skip(1).map(capitalize).join();
  }

  /// Convert to PascalCase
  static String toPascalCase(String text) => text.split(RegExp(r'[_\s]+')).map(capitalize).join();

  /// Check if string is null or empty
  static bool isNullOrEmpty(String? text) => text == null || text.isEmpty;

  /// Check if string is null, empty, or whitespace
  static bool isNullOrWhitespace(String? text) => text == null || text.trim().isEmpty;

  /// Get initials from name (e.g., "John Doe" -> "JD")
  static String getInitials(String name, {int maxLength = 2}) {
    final words = name.trim().split(RegExp(r'\s+'));
    final initials = words
        .where((word) => word.isNotEmpty)
        .take(maxLength)
        .map((word) => word[0].toUpperCase())
        .join();
    return initials;
  }

  /// Format phone number (e.g., "+94771234567" -> "+94 77 123 4567")
  static String formatPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s-]'), '');

    if (cleaned.startsWith('+94')) {
      if (cleaned.length == 12) {
        return '+94 ${cleaned.substring(3, 5)} ${cleaned.substring(5, 8)} ${cleaned.substring(8)}';
      }
    } else if (cleaned.startsWith('0')) {
      if (cleaned.length == 10) {
        return '${cleaned.substring(0, 3)} ${cleaned.substring(3, 6)} ${cleaned.substring(6)}';
      }
    }

    return phone;
  }

  /// Mask email (e.g., "john.doe@example.com" -> "j***@example.com")
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) {
      return email;
    }

    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 2) {
      return '${username[0]}***@$domain';
    }

    return '${username[0]}***@$domain';
  }

  /// Mask phone number (e.g., "+94771234567" -> "+94 77 *** **67")
  static String maskPhoneNumber(String phone) {
    if (phone.length < 4) {
      return phone;
    }

    const visible = 4;
    final masked = phone.length - visible;

    return phone.substring(0, visible) +
        '*' * masked.clamp(0, 6) +
        phone.substring(phone.length - 2);
  }

  /// Clean and normalize text (remove extra spaces, trim)
  static String normalize(String text) => text.replaceAll(RegExp(r'\s+'), ' ').trim();

  /// Check if string contains only digits
  static bool isDigitsOnly(String text) => RegExp(r'^\d+$').hasMatch(text);

  /// Check if string contains only letters
  static bool isLettersOnly(String text) => RegExp(r'^[a-zA-Z]+$').hasMatch(text);

  /// Check if string contains only alphanumeric characters
  static bool isAlphanumeric(String text) => RegExp(r'^[a-zA-Z0-9]+$').hasMatch(text);

  /// Remove special characters
  static String removeSpecialChars(String text) => text.replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '');

  /// Format file size (e.g., 1024 -> "1 KB", 1048576 -> "1 MB")
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  /// Generate random string
  static String generateRandomString(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(
      length,
      (index) => chars[(random + index) % chars.length],
    ).join();
  }
}
