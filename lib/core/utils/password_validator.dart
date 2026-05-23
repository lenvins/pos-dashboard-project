enum PasswordStrength { weak, medium, strong }

class PasswordValidator {
  static PasswordStrength getStrength(String password) {
    if (password.length < 6) return PasswordStrength.weak;
    
    bool hasUpper = password.contains(RegExp(r'[A-Z]'));
    bool hasLower = password.contains(RegExp(r'[a-z]'));
    bool hasDigit = password.contains(RegExp(r'[\\d]'));
    bool hasSpecial = password.contains(RegExp(r'[!@#\$%\^&*]'));
    
    int score = 0;
    if (hasUpper) score++;
    if (hasLower) score++;
    if (hasDigit) score++;
    if (hasSpecial) score++;
    
    if (score >= 3) return PasswordStrength.strong;
    if (score >= 2) return PasswordStrength.medium;
    return PasswordStrength.weak;
  }
  
  static String getStrengthText(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.medium:
        return 'Medium';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }
}

