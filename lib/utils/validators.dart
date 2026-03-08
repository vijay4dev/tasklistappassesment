class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != password) return 'Passwords do not match';
    return null;
  }

  static String? taskTitle(String? value) {
    if (value == null || value.trim().isEmpty) return 'Task title is required';
    if (value.trim().length > 100) return 'Title must be under 100 characters';
    return null;
  }

  // ─── Full Name (Optional) ────────────────────────────────────
  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Optional field
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }
}
