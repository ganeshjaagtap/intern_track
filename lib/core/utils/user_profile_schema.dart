class UserProfileSchema {
  static const Map<String, String> _departmentAliases = {
    'it': 'IT',
    'information technology': 'IT',
    'information tech': 'IT',
    'cse': 'CSE',
    'computer science': 'CSE',
    'computer engineering': 'CSE',
    'computer': 'CSE',
    'cs': 'CSE',
    'me': 'ME',
    'mechanical': 'ME',
    'mechanical engineering': 'ME',
    'civil': 'CIVIL',
    'civil engineering': 'CIVIL',
    'ee': 'EE',
    'electrical': 'EE',
    'electrical engineering': 'EE',
    'electronics': 'ENTC',
    'electronics engineering': 'ENTC',
    'electronics & telecommunication': 'ENTC',
    'electronics and telecommunication': 'ENTC',
    'entc': 'ENTC',
    'e&tc': 'ENTC',
    'aiml': 'AIML',
    'ai & ml': 'AIML',
    'artificial intelligence and machine learning': 'AIML',
    'automobile': 'AUTOMOBILE',
    'automobile engineering': 'AUTOMOBILE',
    'chemical': 'CHEMICAL',
    'chemical engineering': 'CHEMICAL',
    'instrumentation': 'INSTRUMENTATION',
    'instrumentation engineering': 'INSTRUMENTATION',
    'ddgm': 'DDGM',
    'dress designing & garments mfg.': 'DDGM',
  };

  static String normalizeRole(String? role) {
    final value = _clean(role).toLowerCase();
    switch (value) {
      case 'company mentor':
      case 'mentor':
        return 'mentor';
      case 'faculty':
        return 'faculty';
      case 'hod':
        return 'hod';
      case 'principal':
        return 'principal';
      default:
        return 'student';
    }
  }

  static String normalizeDept(String? dept) {
    final value = _clean(dept).toLowerCase();
    if (value.isEmpty) {
      return '';
    }
    return _departmentAliases[value] ?? _clean(dept).toUpperCase();
  }

  static String normalizeEnrollmentNo(String? enrollmentNo) {
    return _compactId(enrollmentNo);
  }

  static String normalizeMentorId(String? mentorId) {
    return _compactId(mentorId);
  }

  static String normalizeCompanyMentorId(String? mentorId) {
    return _compactId(mentorId);
  }

  static String normalizeCompanyName(String? companyName) {
    return _titleCase(_clean(companyName));
  }

  static String normalizePhoneNumber(String? phoneNumber) {
    final raw = (phoneNumber ?? '').trim();
    if (raw.isEmpty) {
      return '';
    }

    final hasPlus = raw.startsWith('+');
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return '';
    }
    return hasPlus ? '+$digits' : digits;
  }

  static String normalizeName(String? name) {
    return _titleCase(_clean(name));
  }

  static String normalizeEmail(String? email) {
    return _clean(email).toLowerCase();
  }

  static String validateRequired(String? value, String fieldLabel) {
    return _clean(value).isEmpty ? '$fieldLabel is required' : '';
  }

  static String validateDept(String? value) {
    final normalized = normalizeDept(value);
    return normalized.isEmpty ? 'Department is required' : '';
  }

  static String validateEnrollmentNo(String? value) {
    final normalized = normalizeEnrollmentNo(value);
    if (normalized.isEmpty) {
      return 'Enrollment number is required';
    }
    if (normalized.length < 4) {
      return 'Enter a valid enrollment number';
    }
    return '';
  }

  static String validateMentorId(String? value, {String label = 'ID'}) {
    final normalized = normalizeMentorId(value);
    if (normalized.isEmpty) {
      return '$label is required';
    }
    if (normalized.length < 3) {
      return 'Enter a valid $label';
    }
    return '';
  }

  static String validatePhoneNumber(String? value) {
    final normalized = normalizePhoneNumber(value);
    if (normalized.isEmpty) {
      return '';
    }

    final digitsOnly = normalized.replaceAll('+', '');
    if (digitsOnly.length < 10 || digitsOnly.length > 15) {
      return 'Enter a valid phone number';
    }
    return '';
  }

  static String validateEmail(String? value) {
    final email = normalizeEmail(value);
    if (email.isEmpty) {
      return 'Email is required';
    }
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return regex.hasMatch(email) ? '' : 'Enter a valid email';
  }

  static String _clean(String? value) {
    return (value ?? '').trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String _compactId(String? value) {
    return _clean(value).replaceAll(RegExp(r'\s+'), '').toUpperCase();
  }

  static String _titleCase(String value) {
    if (value.isEmpty) {
      return '';
    }
    return value
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) {
          if (part.length == 1) {
            return part.toUpperCase();
          }
          return part[0].toUpperCase() + part.substring(1).toLowerCase();
        })
        .join(' ');
  }
}
